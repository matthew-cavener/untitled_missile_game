extends RigidBody2D

var set_initial_state = true

var missile_scene = preload("res://missile/missile.tscn")
var missile = missile_scene.instantiate()


# Called when the node enters the scene tree for the first time.
func _ready():
    print("\n----------------")
    print("player ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("----------------\n")

func _integrate_forces(state) -> void:
    if set_initial_state:
        missile.group = "player_missiles"
        missile.intended_target = "enemy_missiles"
        missile.valid_targets = ["enemy_missiles"]
        missile.stowed_time = 6
        missile.maneuvering_thrust_magnitude = 0.1
        add_child(missile)
        set_initial_state = false

