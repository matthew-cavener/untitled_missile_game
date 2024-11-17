extends RigidBody2D

var set_initial_state = true

var missile_scene = preload("res://missile/missile.tscn")
var missile = missile_scene.instantiate()
var missile_parameters = {
    "group": "player_missiles",
    "intended_target": "enemy_missiles",
    "countermeasures": ["none"],
    "stowed_time": 3,
    "boost_thrust_magnitude": 6.0,
    "boost_thrust_time": 6.0,
    "maneuvering_thrust_magnitude": 0.1,
    "velocity_rejection_coefficient": 3.0
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

func _draw():
    var center: Vector2 = Vector2.ZERO
    var start_angle: float = 0
    var end_angle: float = 360
    var point_count: int = 180
    var color: Color = "#ffb000"
    var width: float = 1
    var antialiased: bool = true

    for radius in range(100, 400, 100):
        draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased)


func on_hit() -> void:
    Events.emit_signal("player_ship_hit")

func _ready():
    add_to_group("player")
    print("\n----------------")
    print("player ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("----------------\n")

func _integrate_forces(state) -> void:
    if set_initial_state:
        missile.set_parameters(missile_parameters)
        add_child(missile)
        #decoy.set_perameters(decoy_parameters)
        #add_child(decoy)
        set_initial_state = false
