extends RigidBody2D

# boost thrust should be on the order of deploying ship speed, all times should be ~1-3


@onready var target = get_tree().get_first_node_in_group("player")
@onready var approx_time_to_collision = (target.global_position - global_position).length() / (linear_velocity.length() + target.linear_velocity.length())
var boost_thrust_magnitude = 3
var boost_thrust_time = 3
var midcourse_thrust_magnitude = 0
var terminal_thrust_magnitude = 2
var terminal_thrust_time = 5
var terminal_range = 200
var is_boosting = false
var is_terminal = false
var armed = true
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

func get_closing_thrust(stage_thrust, stage_time_remaining):
    # https://en.wikipedia.org/wiki/Vector_projection#Vector_projection_2
    # create thrust vector to intercept target by minimizing velocity vector rejection
    # first order approximation, assumes constant velocity, assumption mostly holds for the short burn times and low acceleration
    var intercept_position = target.global_position + target.linear_velocity * approx_time_to_collision
    var intercept_direction = global_position.direction_to(intercept_position)
    var intercept_direction_unit = intercept_direction.normalized()
    var stage_delta_v = (stage_thrust * stage_time_remaining) / self.mass
    var velocity_vector_projection = linear_velocity.dot(intercept_direction_unit) * intercept_direction_unit
    var velocity_vector_rejection = linear_velocity - velocity_vector_projection
    var closing_thrust_direction = (stage_delta_v * intercept_direction_unit - velocity_vector_rejection).normalized()
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
    # first order approximation, assumes constant velocity, assumption mostly holds for the short burn times and low acceleration
    approx_time_to_collision = (target.global_position - global_position).length() / (linear_velocity.length() + target.linear_velocity.length())
    var applied_forces = Vector2(0,0)
    is_boosting = false
    if not boost_timer.is_stopped():
        is_boosting = true
        applied_forces += get_closing_thrust(boost_thrust_magnitude, boost_timer.time_left)
    elif (target.global_position - global_position).length() < terminal_range:
        is_terminal = true
        if approx_time_to_collision < terminal_thrust_time:
            is_boosting = true
            applied_forces += get_closing_thrust(terminal_thrust_magnitude, approx_time_to_collision)
    elif midcourse_thrust_magnitude > 0:
        var prop_nav_acceleration = proportional_navigation()
        var prop_nav_thrust = prop_nav_acceleration * self.mass
        if prop_nav_thrust.length() < 0.8 * midcourse_thrust_magnitude:
            prop_nav_thrust = Vector2(0,0)
        elif prop_nav_thrust.length() > midcourse_thrust_magnitude:
            prop_nav_thrust = prop_nav_thrust.normalized() * midcourse_thrust_magnitude
        if prop_nav_thrust.length() > 0:
            is_boosting = true
        applied_forces += prop_nav_thrust
    elif is_terminal:
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
    print("enemy missile force applied: " + str(applied_forces))
    print("enemy missile force magnitude: " + str(applied_forces.length()))
    print("----------------\n")
