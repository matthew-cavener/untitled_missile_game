extends RigidBody2D

# boost thrust should be on order of deploying ship speed, all times should be ~1-3


@onready var target = get_tree().get_first_node_in_group("player")
var boost_thrust_magnitude = 3
var boost_thrust_time = 3
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
    # https://en.wikipedia.org/wiki/Proportional_navigation
    var relative_velocity = target.linear_velocity - linear_velocity
    var target_range = target.global_position - global_position
    relative_velocity = Vector3(relative_velocity.x, relative_velocity.y, 0)
    target_range = Vector3(target_range.x, target_range.y, 0)
    var omega = target_range.cross(relative_velocity) / target_range.dot(target_range)
    var acceleration_commanded = proportionality_constant * relative_velocity.cross(omega)
    return Vector2(acceleration_commanded.x, acceleration_commanded.y)

func get_velocity_rejection():
    # https://en.wikipedia.org/wiki/Vector_projection#Vector_projection_2
    var target_direction = global_position.direction_to(target.global_position)
    var target_direction_unit = target_direction.normalized()
    var velocity_vector_projection = linear_velocity.dot(target_direction_unit) * target_direction_unit
    var velocity_vector_rejection = linear_velocity - velocity_vector_projection
    return velocity_vector_rejection

func get_closing_thrust(stage_thrust, stage_time_remaining):
    var target_direction = global_position.direction_to(target.global_position)
    var stage_delta_v = (stage_thrust * stage_time_remaining) / self.mass
    var velocity_rejection = get_velocity_rejection()
    # ensure enough of the available thrust is expended to cancel out the velocity rejection, using the rest to close the distance
    var closing_thrust_direction = (stage_delta_v * target_direction.normalized() - velocity_rejection).normalized()
    var closing_thrust_magnitude = stage_thrust
    var closing_thrust = closing_thrust_direction * closing_thrust_magnitude
    return closing_thrust

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
    var approx_time_to_collision = (target.global_position - global_position).length() / (linear_velocity.length() + target.linear_velocity.length())
    var applied_forces = Vector2(0,0)
    if not boost_timer.is_stopped():
        is_boosting = true
        applied_forces += get_closing_thrust(boost_thrust_magnitude, boost_timer.time_left)
        # apply_central_force(get_closing_thrust(boost_thrust_magnitude, boost_thrust_time))
    elif (target.global_position - global_position).length() < terminal_range:
        is_terminal = true
        if approx_time_to_collision < terminal_thrust_time:
            is_boosting = true
            applied_forces += get_closing_thrust(terminal_thrust_magnitude, approx_time_to_collision)
            # apply_central_force(get_closing_thrust(terminal_thrust_magnitude, approx_time_to_collision))
    else:
        is_boosting = false
        var prop_nav_acceleration = proportional_navigation()
        var prop_nav_thrust = prop_nav_acceleration * self.mass
        if prop_nav_thrust.length() > coast_thrust_magnitude:
            prop_nav_thrust = prop_nav_thrust.normalized() * coast_thrust_magnitude
        if prop_nav_thrust.length() < 0.8 * coast_thrust_magnitude:
            prop_nav_thrust = Vector2(0,0)
        applied_forces += prop_nav_thrust
        # apply_central_force(prop_nav_thrust)
    apply_central_force(applied_forces)
    print("\n----------------")
    print("target:" + str(target))
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("is_boosting:" + str(is_boosting))
    print("is_terminal:" + str(is_terminal))
    print("approx_time_to_collision: " + str(approx_time_to_collision) + " seconds")
    print("enemy missile force applied: " + str(applied_forces))
    print("enemy missile force magnitude: " + str(applied_forces.length()))
    print("----------------\n")
