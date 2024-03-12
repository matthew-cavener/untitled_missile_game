extends RigidBody2D

var target = null
var thrust_magnitude = 12
var terminal_range = 0
var boost_time = 3
var is_boosting = false
var boost_timer := Timer.new()


func get_target():
    target = get_tree().get_first_node_in_group("threat")
    return target

func proportional_navigation(proportionality_constant = 3):
    var relative_velocity = target.linear_velocity - linear_velocity
    var target_range = target.global_position - global_position
    relative_velocity = Vector3(relative_velocity.x, relative_velocity.y, 0)
    target_range = Vector3(target_range.x, target_range.y, 0)
    var omega = target_range.cross(relative_velocity) / target_range.dot(target_range)
    var acceleration_commanded = proportionality_constant * relative_velocity.cross(omega)
    return Vector2(acceleration_commanded.x, acceleration_commanded.y)

func _ready():
    print("\n----------------")
    print("player missile spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")
    boost_timer.wait_time = boost_time
    boost_timer.one_shot = true
    add_child(boost_timer)
    boost_timer.start()

func _integrate_forces(_state):
    target = get_target()
    print("\n----------------")
    print("target:" + str(target))
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("is_boosting:" + str(is_boosting))
    print("----------------\n")
    #if (target.global_position - global_position).length() < terminal_range or not boost_timer.is_stopped():
    if not boost_timer.is_stopped():
        is_boosting = true
        var prop_nav_acceleration = proportional_navigation()
        var prop_nav_thrust = prop_nav_acceleration * self.mass
        if prop_nav_thrust.length() > thrust_magnitude:
            prop_nav_thrust = prop_nav_thrust.normalized() * thrust_magnitude
        var target_direction = global_position.direction_to(target.global_position)
        var closing_thrust_magnitude = thrust_magnitude - (prop_nav_thrust.length())
        var closing_thrust_direction = target_direction.normalized()
        apply_central_force(prop_nav_thrust + (closing_thrust_direction * closing_thrust_magnitude))
        print("player missile force applied: " + str(prop_nav_thrust + (closing_thrust_direction * closing_thrust_magnitude)))
        print("player missile force magnitude: " + str((prop_nav_thrust + (closing_thrust_direction * closing_thrust_magnitude)).length()))
    else:
        is_boosting = false
        var prop_nav_acceleration = proportional_navigation()
        var prop_nav_thrust = prop_nav_acceleration * self.mass
        if prop_nav_thrust.length() > thrust_magnitude:
            prop_nav_thrust = prop_nav_thrust.normalized() * thrust_magnitude
        print("player missile force applied: " + str(prop_nav_thrust))
        print("player missile force magnitude: " + str(prop_nav_thrust.length()))
        apply_central_force(prop_nav_thrust)
