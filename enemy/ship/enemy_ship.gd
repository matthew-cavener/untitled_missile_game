class_name EnemyShip
extends RigidBody2D

var set_initial_state = true
var enemy_missile_scene = preload("res://missile/missile.tscn")
var enemy_missile = enemy_missile_scene.instantiate()

var distance : float
var position_bearing : float
var initial_position : Vector2
var speed : float
var velocity_bearing : float
var initial_velocity : Vector2

var passive_emission : float
var detection_distance : float

# var missiles: Array[Missile]

func _init(
    _distance : float = 150,
    _position_bearing : float = 270,
    _velocity_bearing : float = 60,
    _speed : float = 3,
    _passive_emission : float = 0.5,
    _detection_distance : float = 200


) -> void:
    distance = _distance
    position_bearing = _position_bearing
    position_bearing = deg_to_rad(position_bearing + 270)
    initial_position = Vector2(distance * cos(position_bearing), distance * sin(position_bearing))
    velocity_bearing = _velocity_bearing
    speed = _speed
    velocity_bearing = deg_to_rad(velocity_bearing + 270)
    initial_velocity = Vector2(speed * cos(velocity_bearing), speed * sin(velocity_bearing))
    passive_emission = _passive_emission
    detection_distance = _detection_distance

func _ready() -> void:
    pass

func _integrate_forces(state) -> void:
    if set_initial_state:
        state.transform = Transform2D(0.0, initial_position)
        self.linear_velocity = initial_velocity
        enemy_missile.linear_velocity = self.linear_velocity
        add_child(enemy_missile)
        set_initial_state = false

    print("\n----------------")
    print("enemy ship global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("enemy ship linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")
