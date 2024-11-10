extends RigidBody2D

var set_initial_state = true

var missile_scene = preload("res://missile/missile.tscn")
var missile = missile_scene.instantiate()
var missile_parameters = {
    "group": "player_missiles",
    "intended_target": "enemy_missiles",
    "countermeasures": ["none"],
    "stowed_time": 9,
    "maneuvering_thrust_magnitude": 0.1,
    "velocity_rejection_coefficient": 1.0
}

var decoy_scene = preload("res://decoy/decoy.tscn")
var decoy = decoy_scene.instantiate()
var decoy_parameters = {
    "group": "decoys",
    "lifetime": 600,
    "thrust_time": 1,
    "thrust_magnitude": 1,
    "launch_angle": 90
}


func on_hit() -> void:
    queue_free()

func _ready():
    add_to_group("player")
    print("\n----------------")
    print("player ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("----------------\n")

func _integrate_forces(state) -> void:
    if set_initial_state:
        # missile.set_parameters(missile_parameters)
        # add_child(missile)
        decoy.set_perameters(decoy_parameters)
        add_child(decoy)
        set_initial_state = false
