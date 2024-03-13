extends RigidBody2D

var set_initial_state = true

var distance = 500
var position_bearing = (270)
var position_bearing_radian = deg_to_rad(position_bearing + 270)
var initial_position = Vector2(distance * cos(position_bearing_radian), distance * sin(position_bearing_radian))

var speed = 3
var velocity_bearing = (60)
var velocity_bearing_radian = deg_to_rad(velocity_bearing + 270)
var initial_velocity = Vector2(speed * cos(velocity_bearing_radian), speed * sin(velocity_bearing_radian))

var enemy_missile_scene = preload("res://enemy/missile/enemy_missile.tscn")

func _ready():
    print("\n----------------")
    print("Enemy ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")



func _integrate_forces(state):
    if set_initial_state:
        state.transform = Transform2D(0.0, initial_position)
        self.linear_velocity = initial_velocity
        var enemy_missile = enemy_missile_scene.instantiate()
        enemy_missile.linear_velocity = self.linear_velocity
        add_child(enemy_missile)
        set_initial_state = false

    print("\n----------------")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")
