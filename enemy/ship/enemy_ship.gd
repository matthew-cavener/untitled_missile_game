class_name EnemyShip
extends RigidBody2D

var set_initial_state = true
var enemy_missile_scene = preload("res://missile/missile.tscn")

var distance : float
var position_bearing : float
var velocity_bearing : float
var speed : float

var position_bearing_radian : float
var initial_position : Vector2

var velocity_bearing_radian : float
var initial_velocity : Vector2

func _init(
    _distance : float = 150,
    _position_bearing : float = 270,
    _velocity_bearing : float = 60,
    _speed : float = 10
) -> void:
    distance = _distance
    position_bearing = _position_bearing
    velocity_bearing = _velocity_bearing
    speed = _speed

    position_bearing_radian = deg_to_rad(position_bearing + 270)
    initial_position = Vector2(distance * cos(position_bearing_radian), distance * sin(position_bearing_radian))

    velocity_bearing_radian = deg_to_rad(velocity_bearing + 270)
    initial_velocity = Vector2(speed * cos(velocity_bearing_radian), speed * sin(velocity_bearing_radian))

func _ready() -> void:
    print("\n----------------")
    print("Enemy ship spawned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")

func _integrate_forces(state) -> void:
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
