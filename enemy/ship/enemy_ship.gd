class_name EnemyShip
extends RigidBody2D

var set_initial_state = true
var missile_scene = preload("res://missile/missile.tscn")
@onready var player = get_tree().get_first_node_in_group("player")

var distance: float
var position_angle: float
var initial_position: Vector2
var speed: float
var velocity_bearing: float
var initial_velocity: Vector2

var missiles: Array

func set_parameters(parameters: Dictionary = {}) -> void:
    distance = parameters.get("distance", 500)
    position_angle = deg_to_rad(parameters.get("position_angle", 20))
    initial_position = player.global_position + Vector2(cos(position_angle), sin(position_angle)) * distance
    speed = parameters.get("speed", 6)
    velocity_bearing = deg_to_rad(parameters.get("velocity_bearing", 180))
    initial_velocity = Vector2(cos(velocity_bearing), sin(velocity_bearing)) * speed
    missiles = parameters.get("missiles", [])

func _ready() -> void:
    pass

func _integrate_forces(state) -> void:
    if set_initial_state:
        state.transform = Transform2D(0.0, initial_position)
        self.linear_velocity = initial_velocity
        for missile in missiles:
            var enemy_missile = missile_scene.instantiate()
            enemy_missile.linear_velocity = self.linear_velocity
            enemy_missile.set_parameters(missile)
            add_child(enemy_missile)
        set_initial_state = false

    #print("\n----------------")
    #print("enemy ship global_position.x: %.2f | global_position.y: %.2f" % [global_position.x, global_position.y])
    #print("enemy ship linear_velocity.x: %.2f | linear_velocity.y: %.2f" % [linear_velocity.x, linear_velocity.y])
    #print("----------------\n")
