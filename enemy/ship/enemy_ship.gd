class_name EnemyShip
extends RigidBody2D

var set_initial_state = true
var enemy_missile_scene = preload("res://missile/missile.tscn")
var enemy_missile = enemy_missile_scene.instantiate()

var distance: float
var position_bearing: float
var position_bearing_rad: float
var initial_position: Vector2
var speed: float
var velocity_bearing: float
var velocity_bearing_rad: float
var initial_velocity: Vector2

var passive_emission: float = 1
var detection_distance: float = 200

var missiles: Array[Missile] = []

func set_parameters(parameters: Dictionary = {}) -> void:
    distance = parameters.get("distance", 400)
    position_bearing = parameters.get("position_bearing", 270)
    position_bearing_rad = deg_to_rad(position_bearing + 270)
    initial_position = Vector2(distance * cos(position_bearing_rad), distance * sin(position_bearing_rad))
    speed = parameters.get("speed", 3)
    velocity_bearing = parameters.get("velocity_bearing", 60)
    velocity_bearing_rad = deg_to_rad(velocity_bearing + 270)
    initial_velocity = Vector2(speed * cos(velocity_bearing_rad), speed * sin(velocity_bearing_rad))
    passive_emission = parameters.get("passive_emission", 1)
    detection_distance = parameters.get("detection_distance", 200)

func _ready() -> void:
    pass

func _integrate_forces(state) -> void:
    if set_initial_state:
        state.transform = Transform2D(0.0, initial_position)
        self.linear_velocity = initial_velocity
        enemy_missile.linear_velocity = self.linear_velocity
        enemy_missile.set_parameters()
        add_child(enemy_missile)
        set_initial_state = false

    print("\n----------------")
    print("enemy ship global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("enemy ship linear_velocity.x: " + str(linear_velocity.x) + " | linear_velocity.y:" + str(linear_velocity.y))
    print("----------------\n")
