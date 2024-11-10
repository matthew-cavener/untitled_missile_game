extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")

var missiles = [
    {
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["decoys"],
        "stowed_time": 6,
        "boost_thrust_magnitude": 3.0,
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0,
        "terminal_thrust_time": 0.1,
        "terminal_thrust_magnitude": 0.1,
        "seeker_range": 200,
        "velocity_rejection_coefficient": 1.2
    }
]

func _ready():
    var enemy_ship = enemy_ship_scene.instantiate()
    add_child(enemy_ship)
    enemy_ship.set_parameters({"missiles": missiles})
