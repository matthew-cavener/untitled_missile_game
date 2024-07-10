extends RigidBody2D

var set_initial_state = true

var missile_scene = preload("res://missile/missile.tscn")
var missile = missile_scene.instantiate()
var missile_parameters = {
    "group": "player_missiles",
    "intended_target": "enemy_missiles",
    "valid_targets": ["enemy_missiles"],
    "stowed_time": 6,
    "maneuvering_thrust_magnitude": 0.1
}


func _ready():
    print("\n----------------")
    print("player ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("----------------\n")

func _integrate_forces(state) -> void:
    if set_initial_state:
        missile.set_parameters(missile_parameters)
        add_child(missile)
        set_initial_state = false
