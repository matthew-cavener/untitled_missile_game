class_name EnemyShip
extends RigidBody2D

var set_initial_state = true
var enemy_missile_scene = preload("res://missile/missile.tscn")

var distance: float
var position_bearing: float
var initial_position: Vector2
var speed: float
var velocity_bearing: float
var initial_velocity: Vector2

var passive_emission: float = 1
var detection_distance: float = 200

var missiles: Array[Dictionary] = [
    {
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["decoys"],
        "stowed_time": 6,
        "boost_thrust_magnitude": 3.0,
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0,
        "terminal_thrust_time": 3,
        "terminal_thrust_magnitude": 0.1,
        "seeker_range": 200,
        "velocity_rejection_coefficient": 1.2
    },
    # {
    #     "group": "enemy_missiles",
    #     "intended_target": "player",
    #     "countermeasures": ["decoys"],
    #     "stowed_time": 12,
    #     "boost_thrust_magnitude": 3.0,
    #     "boost_thrust_time": 3.0,
    #     "maneuvering_thrust_magnitude": 0,
    #     "terminal_thrust_time": 1,
    #     "terminal_thrust_magnitude": 1,
    #     "seeker_range": 200,
    #     "velocity_rejection_coefficient": 1.3
    # },
    # {
    #     "group": "enemy_missiles",
    #     "intended_target": "player",
    #     "countermeasures": ["decoys"],
    #     "stowed_time": 18,
    #     "boost_thrust_magnitude": 3.0,
    #     "boost_thrust_time": 3.0,
    #     "maneuvering_thrust_magnitude": 0,
    #     "terminal_thrust_time": 1,
    #     "terminal_thrust_magnitude": 1,
    #     "seeker_range": 200,
    #     "velocity_rejection_coefficient": 1.3
    # }
]

func set_parameters(parameters: Dictionary = {}) -> void:
    distance = parameters.get("distance", 400)
    position_bearing = deg_to_rad(parameters.get("position_bearing", 0))
    initial_position = Vector2(cos(position_bearing), sin(position_bearing)) * distance
    speed = parameters.get("speed", 3)
    velocity_bearing = deg_to_rad(parameters.get("velocity_bearing", 90))
    initial_velocity = Vector2(cos(velocity_bearing), sin(velocity_bearing)) * speed
    passive_emission = parameters.get("passive_emission", 1)
    detection_distance = parameters.get("detection_distance", 200)

func _ready() -> void:
    pass

func _integrate_forces(state) -> void:
    if set_initial_state:
        state.transform = Transform2D(0.0, initial_position)
        self.linear_velocity = initial_velocity
        for missile in missiles:
            var enemy_missile = enemy_missile_scene.instantiate()
            enemy_missile.linear_velocity = self.linear_velocity
            enemy_missile.set_parameters(missile)
            add_child(enemy_missile)
        set_initial_state = false

    #print("\n----------------")
    #print("enemy ship global_position.x: %.2f | global_position.y: %.2f" % [global_position.x, global_position.y])
    #print("enemy ship linear_velocity.x: %.2f | linear_velocity.y: %.2f" % [linear_velocity.x, linear_velocity.y])
    #print("----------------\n")
