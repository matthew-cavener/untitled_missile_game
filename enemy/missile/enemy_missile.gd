extends RigidBody2D

# boost thrust should be on order of deploying ship speed, all time should be ~1-3


@onready var target = get_tree().get_first_node_in_group("player")
var boost_thrust_magnitude = 12
var boost_thrust_time = 2
var coast_thrust_magnitude = 0
var terminal_thrust_magnitude = 2
var terminal_thrust_time = 2
var terminal_range = 200
var is_boosting = false
var is_terminal = false
var boost_timer := Timer.new()
var terminal_timer := Timer.new()


func get_target():
    target = get_tree().get_first_node_in_group("decoys")
    if target != null:
        return target
    else:
        return get_tree().get_first_node_in_group("player")

func proportional_navigation(proportionality_constant = 3):
    var relative_velocity = target.linear_velocity - linear_velocity
    var target_range = target.global_position - global_position
    relative_velocity = Vector3(relative_velocity.x, relative_velocity.y, 0)
    target_range = Vector3(target_range.x, target_range.y, 0)
    var omega = target_range.cross(relative_velocity) / target_range.dot(target_range)
    var acceleration_commanded = proportionality_constant * relative_velocity.cross(omega)
    return Vector2(acceleration_commanded.x, acceleration_commanded.y)

func get_velocity_rejection():
    var target_direction = global_position.direction_to(target.global_position)
    var velocity_vector_projection = linear_velocity.dot(target_direction) * target_direction
    var velocity_vector_rejection = linear_velocity - velocity_vector_projection
    return velocity_vector_rejection

func get_closing_thrust():
    pass

func _ready():
    print("\n----------------")
    print("enemy missile spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")
    boost_timer.wait_time = boost_thrust_time
    boost_timer.one_shot = true
    add_child(boost_timer)
    boost_timer.start()

func _integrate_forces(_state):
    target = get_target()
    var approx_time_to_collision = (target.global_position - global_position).length() / linear_velocity.length()
    print("\n----------------")
    print("target:" + str(target))
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("is_boosting:" + str(is_boosting))
    print("is_terminal:" + str(is_terminal))
    print("approx_time_to_collision: " + str(approx_time_to_collision) + " seconds")
    print("----------------\n")
    if not boost_timer.is_stopped() or (target.global_position - global_position).length() < terminal_range:
        var target_direction = global_position.direction_to(target.global_position)
        var stage_delta_v = 0
        var closing_thrust_direction = Vector2(0,0)
        var closing_thrust_magnitude = 0
        var closing_thrust = Vector2(0,0)
        var velocity_rejection = Vector2(0,0)
        var velocity_rejection_coeff = 0
        if not boost_timer.is_stopped():
            stage_delta_v = (boost_thrust_magnitude * boost_timer.time_left) / self.mass
            closing_thrust_magnitude = boost_thrust_magnitude
            is_boosting = true
            velocity_rejection = get_velocity_rejection()
            velocity_rejection_coeff = (velocity_rejection.length() / stage_delta_v)
            closing_thrust_direction = (target_direction.normalized() - velocity_rejection_coeff * velocity_rejection.normalized()).normalized()
            closing_thrust = closing_thrust_direction * closing_thrust_magnitude
        elif (target.global_position - global_position).length() < terminal_range:
            if is_terminal == false:
                terminal_timer.wait_time = terminal_thrust_time
                terminal_timer.one_shot = true
                add_child(terminal_timer)
                terminal_timer.start()
            is_terminal = true
            if approx_time_to_collision < terminal_thrust_time:
                stage_delta_v = (terminal_thrust_magnitude * approx_time_to_collision) / self.mass
                closing_thrust_magnitude = terminal_thrust_magnitude
                is_boosting = true
                velocity_rejection = get_velocity_rejection()
                velocity_rejection_coeff = (velocity_rejection.length() / stage_delta_v)
                closing_thrust_direction = (target_direction.normalized() - velocity_rejection_coeff * velocity_rejection.normalized()).normalized()
                closing_thrust = closing_thrust_direction * closing_thrust_magnitude
        apply_central_force(closing_thrust)
        print("enemy missile force applied: " + str(closing_thrust))
        print("enemy missile force magnitude: " + str(closing_thrust.length()))
    else:
        is_boosting = false
        var prop_nav_acceleration = proportional_navigation()
        var prop_nav_thrust = prop_nav_acceleration * self.mass
        if prop_nav_thrust.length() > coast_thrust_magnitude:
            prop_nav_thrust = prop_nav_thrust.normalized() * coast_thrust_magnitude
        if prop_nav_thrust.length() < 0.8 * coast_thrust_magnitude:
            prop_nav_thrust = Vector2(0,0)
        apply_central_force(prop_nav_thrust)
        print("enemy missile force applied: " + str(prop_nav_thrust))
        print("enemy missile force magnitude: " + str(prop_nav_thrust.length()))
