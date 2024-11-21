extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

var player_ship_tube_1_contents = {
    "type": "missile",
    "display_name": "placeholder-1 AMM Block N",
    "seeker_has_ping": false,
    "group": "player_missiles",
    "intended_target": "enemy_missiles",
    "countermeasures": ["none"],
    "stowed_time": 0,
    "boost_thrust_magnitude": 6.0,
    "boost_thrust_time": 6.0,
    "maneuvering_thrust_magnitude": 0.1,
    "velocity_rejection_coefficient": 3.0
}

var enemy_ship_1_missiles = [
    {
        "seeker_has_ping": true,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["decoys"],
        "stowed_time": 3,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 6.0,
        "maneuvering_thrust_magnitude": 0,
        "terminal_thrust_time": 1.0,
        "terminal_thrust_magnitude": 0.1,
        "seeker_range": 100,
        "velocity_rejection_coefficient": 1.2
    }
]

func _ready():
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship)
    player_ship.set_parameters({"tube_1_contents": player_ship_tube_1_contents})
    enemy_ship.set_parameters({"missiles": enemy_ship_1_missiles})
