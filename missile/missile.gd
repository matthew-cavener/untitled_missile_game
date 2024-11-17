class_name Missile
extends RigidBody2D
# boost_thrust_magnitude * boost_thrust_time should be on order of relative velocity between launching platform and target to ensure enough delta_v is available to cancel orthogonal velocity
# boost_thrust_time should be short to minimize visibility to target
# for single stage missile boost_thrust_magnitude = terminal_thrust_magnitude
# missile difficulty is proportional to boost_thrust_magnitude * boost_thrust_time + terminal_thrust_magnitude * terminal_thrust_time

enum MissileState {STOWED, BOOSTING, MIDCOURSE, SEEKING, TERMINAL, DISARMED}

var missile_state: MissileState = MissileState.STOWED
var state_name: String = "STOWED"

var stowed_time: float

var group: String
var intended_target: String
var countermeasures: Array
@onready var target: Node = get_tree().get_first_node_in_group(intended_target)
@onready var approx_time_to_collision: float = 300.0

var boost_thrust_magnitude: float
var boost_thrust_time: float
var maneuvering_thrust_magnitude: float
var terminal_thrust_magnitude: float
var terminal_thrust_time: float
var seeker_range: int
var velocity_rejection_coefficient: float

var stowed_timer = Timer.new()
var boost_thrust_timer: Timer = Timer.new()
var terminal_thrust_timer: Timer = Timer.new()


func set_parameters(parameters: Dictionary = {}) -> void:
    stowed_time = parameters.get("stowed_time", 3)
    group = parameters.get("group", "enemy_missiles")
    intended_target = parameters.get("intended_target", "player")
    countermeasures = parameters.get("countermeasures", ["decoys"])
    boost_thrust_magnitude = parameters.get("boost_thrust_magnitude", 3.0)
    boost_thrust_time = parameters.get("boost_thrust_time", 3.0)
    maneuvering_thrust_magnitude = parameters.get("maneuvering_thrust_magnitude", 0.0)
    terminal_thrust_time = parameters.get("terminal_thrust_time", 3.0)
    terminal_thrust_magnitude = parameters.get("terminal_thrust_magnitude", 0.1)
    seeker_range = parameters.get("seeker_range", 200)
    velocity_rejection_coefficient = parameters.get("velocity_rejection_coefficient", 1.3)

func setup_timer(timer: Timer, wait_time: float, timeout_func) -> void:
    timer.wait_time = wait_time
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(timeout_func)

func on_hit() -> void:
    Events.emit_signal("missile_hit")
    queue_free()

func _ready() -> void:
    add_to_group(group)
    setup_timer(stowed_timer, stowed_time, _on_stowed_timer_timeout)
    setup_timer(boost_thrust_timer, boost_thrust_time, _on_boost_thrust_timer_timeout)
    setup_timer(terminal_thrust_timer, terminal_thrust_time, _on_terminal_thrust_timer_timeout)
    stowed_timer.start()

func get_target() -> Node:
    for countermeasure in countermeasures:
        target = get_tree().get_first_node_in_group(countermeasure)
        if target:
            return target
    return get_tree().get_first_node_in_group(intended_target)

func proportional_navigation(proportionality_constant: int = 3) -> Vector2:
    # https://en.wikipedia.org/wiki/Proportional_navigation
    if target:
        var relative_velocity2: Vector2 = target.linear_velocity - linear_velocity
        var target_range2: Vector2 = target.global_position - global_position
        var relative_velocity3 = Vector3(relative_velocity2.x, relative_velocity2.y, 0)
        var target_range3 = Vector3(target_range2.x, target_range2.y, 0)
        var omega: Vector3 = target_range3.cross(relative_velocity3) / target_range3.dot(target_range3)
        var acceleration_commanded: Vector3 = proportionality_constant * relative_velocity3.cross(omega)
        return Vector2(acceleration_commanded.x, acceleration_commanded.y)
    else:
        return Vector2.ZERO

func get_closing_thrust(stage_thrust: float, stage_time_remaining: float) -> Vector2:
    # https://en.wikipedia.org/wiki/Vector_projection#Vector_projection_2
    # create thrust vector to intercept target by reducing velocity orthogonal to intercept direction, and increasing velocity along intercept direction
    # first order approximation, assumes constant velocity, assumption mostly holds for the short burn times and low acceleration
    if target:
        var intercept_position: Vector2 = target.global_position + target.linear_velocity * approx_time_to_collision
        var intercept_direction: Vector2 = global_position.direction_to(intercept_position)
        if intercept_direction.length() == 0:
            intercept_direction = global_position.direction_to(target.global_position)
        var intercept_direction_unit: Vector2 = intercept_direction.normalized()
        var stage_delta_v: float = (stage_thrust * stage_time_remaining) / self.mass
        var velocity_vector_projection: Vector2 = linear_velocity.dot(intercept_direction_unit) * intercept_direction_unit # projection of velocity vector onto intercept direction
        var velocity_vector_rejection: Vector2 = linear_velocity - velocity_vector_projection
        var closing_thrust_direction: Vector2 = (stage_delta_v * intercept_direction_unit - velocity_rejection_coefficient * velocity_vector_rejection).normalized()
        var closing_thrust_magnitude: float = stage_thrust
        var closing_thrust: Vector2 = closing_thrust_direction * closing_thrust_magnitude
        return closing_thrust
    else:
        return Vector2.ZERO

func _on_stowed_timer_timeout() -> void:
    boost_thrust_timer.start()
    missile_state = MissileState.BOOSTING
    state_name = "BOOSTING"

func _on_boost_thrust_timer_timeout() -> void:
    missile_state = MissileState.MIDCOURSE
    state_name = "MIDCOURSE"

func _on_terminal_thrust_timer_timeout() -> void:
    missile_state = MissileState.DISARMED
    state_name = "DISARMED"

func _integrate_forces(_state) -> void:
    var applied_forces: Vector2 = Vector2.ZERO
    target = get_target()
    if target:
        var distance_to_target = (target.global_position - global_position).length()
        approx_time_to_collision = distance_to_target / ((linear_velocity - target.linear_velocity).length())
        if distance_to_target <= 3:
            target.on_hit()
            queue_free()
    else:
        pass

    match missile_state:
        MissileState.STOWED:
            pass

        MissileState.BOOSTING:
            applied_forces += get_closing_thrust(boost_thrust_magnitude, boost_thrust_timer.time_left)

        MissileState.MIDCOURSE:
            if (target.global_position - global_position).length() <= seeker_range:
                missile_state = MissileState.SEEKING

        MissileState.SEEKING:
            state_name = "SEEKING"
            if approx_time_to_collision <= terminal_thrust_time:
                terminal_thrust_timer.start()
                missile_state = MissileState.TERMINAL
            elif maneuvering_thrust_magnitude > 0:
                var prop_nav_acceleration = proportional_navigation()
                var prop_nav_thrust = prop_nav_acceleration * self.mass
                if prop_nav_thrust.length() > maneuvering_thrust_magnitude:
                    prop_nav_thrust = prop_nav_thrust.normalized() * maneuvering_thrust_magnitude
                applied_forces += prop_nav_thrust

        MissileState.TERMINAL:
            state_name = "TERMINAL"
            var prop_nav_acceleration = proportional_navigation()
            var prop_nav_thrust = prop_nav_acceleration * self.mass
            if prop_nav_thrust.length() > terminal_thrust_magnitude:
                prop_nav_thrust = prop_nav_thrust.normalized() * terminal_thrust_magnitude
            applied_forces += prop_nav_thrust

        MissileState.DISARMED:
            pass

    apply_central_force(applied_forces)
    print("\n----------------")
    print("target: " + str(target))
    print("global_position.x: %.2f | global_position.y: %.2f" % [global_position.x, global_position.y])
    print("linear_velocity.x: %.2f | linear_velocity.y: %.2f" % [linear_velocity.x, linear_velocity.y])
    print("missile_state: " + str(state_name))
    print("boost thrust time remaining: %.2f" % boost_thrust_timer.time_left)
    print("approx_time_to_collision: %.2f seconds" % approx_time_to_collision)
    print("missile force applied: Vector2(%.2f, %.2f)" % [applied_forces.x, applied_forces.y])
    print("missile force magnitude: %.2f" % applied_forces.length())
    print("----------------\n")
