# boost_thrust_magnitude should be on order of relative velocity between launching platform and target
# boost_thrust_time should be short to minimize visibility to target
# for single stage missile boost_thrust_magnitude = terminal_thrust_magnitude
    # make sure to assign enough boost_thrust_time to ensure intercept
    # player will select boost and terminal thrust times from a total thrust time budget
# missile difficulty is proportional to boost_thrust_magnitude * boost_thrust_time + terminal_thrust_magnitude * terminal_thrust_time

# midcourse_thrust_magnitude should be ~0.1 and reserved for anti-missile missiles

class_name Missile
extends RigidBody2D

enum MissileState {BOOSTING, MIDCOURSE, SEEKING, TERMINAL, DISARMED}

var state: MissileState = MissileState.BOOSTING

var intended_target: String
var valid_targets: Array

@onready var target: Node = get_tree().get_first_node_in_group(intended_target)
@onready var approx_time_to_collision: float = (target.global_position - global_position).length() / (linear_velocity.length() + target.linear_velocity.length())

var total_thrust_time: int = 0 # player missiles only

var boost_thrust_magnitude: float
var boost_thrust_time: float
var midcourse_thrust_magnitude: float
var terminal_thrust_magnitude: float
var terminal_thrust_time: float
var terminal_range: int = 200

var is_boosting: bool = false
var is_terminal: bool = false
var armed: bool = true

var boost_thrust_timer: Timer = Timer.new()
var terminal_thrust_timer: Timer = Timer.new()

func _init(
    _intended_target: String = "player",
    _valid_targets: Array = ["decoys", "player"],
    _boost_thrust_magnitude: float = 3,
    _boost_thrust_time: float = 3,
    _midcourse_thrust_magnitude: float = 0,
    _terminal_thrust_magnitude: float = 3,
    _terminal_thrust_time: float = 3
) -> void:
    intended_target = _intended_target
    valid_targets = _valid_targets
    boost_thrust_magnitude = _boost_thrust_magnitude
    boost_thrust_time = _boost_thrust_time
    midcourse_thrust_magnitude = _midcourse_thrust_magnitude
    terminal_thrust_magnitude = _terminal_thrust_magnitude
    terminal_thrust_time = _terminal_thrust_time

func get_target() -> Node:
    for valid_target in valid_targets:
        if valid_target != intended_target:
            target = get_tree().get_first_node_in_group(valid_target)
            if target:
                return target
    return get_tree().get_first_node_in_group(intended_target)

func proportional_navigation(proportionality_constant: float = 3) -> Vector2:
    # https://en.wikipedia.org/wiki/Proportional_navigation
    var relative_velocity2: Vector2 = target.linear_velocity - linear_velocity
    var target_range2: Vector2 = target.global_position - global_position
    var relative_velocity3 = Vector3(relative_velocity2.x, relative_velocity2.y, 0)
    var target_range3 = Vector3(target_range2.x, target_range2.y, 0)
    var omega: Vector3 = target_range3.cross(relative_velocity3) / target_range3.dot(target_range3)
    var acceleration_commanded: Vector3 = proportionality_constant * relative_velocity3.cross(omega)
    return Vector2(acceleration_commanded.x, acceleration_commanded.y)

func get_closing_thrust(stage_thrust: float, stage_time_remaining: float) -> Vector2:
    var intercept_position: Vector2 = target.global_position + target.linear_velocity * approx_time_to_collision
    var intercept_direction: Vector2 = global_position.direction_to(intercept_position)
    var intercept_direction_unit: Vector2 = intercept_direction.normalized()
    var stage_delta_v: float = (stage_thrust * stage_time_remaining) / self.mass
    var velocity_vector_projection: Vector2 = linear_velocity.dot(intercept_direction_unit) * intercept_direction_unit
    var velocity_vector_rejection: Vector2 = linear_velocity - velocity_vector_projection
    var closing_thrust_direction: Vector2 = (stage_delta_v * intercept_direction_unit - velocity_vector_rejection).normalized()
    var closing_thrust_magnitude: float = stage_thrust
    var closing_thrust: Vector2 = closing_thrust_direction * closing_thrust_magnitude
    return closing_thrust

func _ready() -> void:
    boost_thrust_timer.wait_time = boost_thrust_time
    boost_thrust_timer.one_shot = true
    add_child(boost_thrust_timer)
    boost_thrust_timer.start()
    boost_thrust_timer.timeout.connect(_on_boost_thrust_timer_timeout)

    terminal_thrust_timer.wait_time = terminal_thrust_time
    terminal_thrust_timer.one_shot = true
    add_child(terminal_thrust_timer)
    terminal_thrust_timer.timeout.connect(_on_terminal_thrust_timer_timeout)

func _on_boost_thrust_timer_timeout() -> void:
    state = MissileState.MIDCOURSE

func _on_terminal_thrust_timer_timeout() -> void:
    state = MissileState.DISARMED

func _integrate_forces(_state) -> void:
    target = get_target()
    approx_time_to_collision = (target.global_position - global_position).length() / (linear_velocity.length() + target.linear_velocity.length())
    var applied_forces: Vector2 = Vector2(0,0)

    match state:
        MissileState.BOOSTING:
            is_boosting = true
            is_terminal = false
            applied_forces += get_closing_thrust(boost_thrust_magnitude, boost_thrust_timer.time_left)

        MissileState.MIDCOURSE:
            is_boosting = false
            is_terminal = false
            if (target.global_position - global_position).length() < terminal_range:
                state = MissileState.SEEKING
            elif midcourse_thrust_magnitude > 0:
                var prop_nav_acceleration = proportional_navigation()
                var prop_nav_thrust = prop_nav_acceleration * self.mass
                if prop_nav_thrust.length() > midcourse_thrust_magnitude:
                    prop_nav_thrust = prop_nav_thrust.normalized() * midcourse_thrust_magnitude
                    applied_forces += prop_nav_thrust

        MissileState.SEEKING:
            is_boosting = false
            is_terminal = true
            if approx_time_to_collision < terminal_thrust_time:
                terminal_thrust_timer.start()
                state = MissileState.TERMINAL

        MissileState.TERMINAL:
            is_boosting = true
            is_terminal = true
            applied_forces += get_closing_thrust(terminal_thrust_magnitude, approx_time_to_collision)

        MissileState.DISARMED:
            is_boosting = false
            is_terminal = false
            armed = false

    apply_central_force(applied_forces)
    print("\n----------------")
    print("target:" + str(target))
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("is_boosting:" + str(is_boosting))
    print("is_terminal:" + str(is_terminal))
    print("approx_time_to_collision: " + str(approx_time_to_collision) + " seconds")
    print("missile force applied: " + str(applied_forces))
    print("missile force magnitude: " + str(applied_forces.length()))
    print("----------------\n")
