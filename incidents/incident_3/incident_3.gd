extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

@onready var world: Node2D = get_tree().get_first_node_in_group("world")

var resources_expended = 0
var salary = 2320
var max_bonus = 13333 - salary
var incident_started = false
var incident_resolved = false

var player_ship_tube_4_contents = {
    "type": "decoy",
    "display_name": "Mk 36 SRBOC\nChaff\nCost: 300",
    "resource_cost": 300,
    "group": "chaff",
    "launch_bearing": 90,
}

var player_ship_tube_5_contents = {
    "type": "decoy",
    "display_name": "Mk 214 BSIRCM\nFlare\nCost: 300",
    "resource_cost": 300,
    "group": "flare",
    "launch_bearing": 240,
}

var enemy_ship_1_missiles = [
    {
        "seeker_has_ping": true,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["chaff"],
        "stowed_time": 6,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 6.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    },
    {
        "seeker_has_ping": false,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["flare"],
        "stowed_time": 30,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 6.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    },
]

var enemy_ship_1_parameters = {
    "distance": 380,
    "position_bearing": 210,
    "speed": 9,
    "velocity_bearing": 60,
    "missiles": enemy_ship_1_missiles
}

func get_details():
    var details = {
        "name": "Incident 3",
        "description": "
Date: 1993-06-29
Location: Ganymede - Europa transfer orbit
Incident Report: Single RADAR contact
One Active RADAR homing missile deployed by contact,
One Passive IR homing missile deployed by contact,
No casualties.
Resource expended: " + str(resources_expended),
        "resources_expended": resources_expended,
        "incident_report_submitted": incident_resolved,
    }
    return details

func _on_resources_expended(amount: int):
    if incident_started && not incident_resolved:
        resources_expended += amount

func _on_incident_3_begin():
    incident_started = true
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship_1 = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship_1)
    player_ship.set_parameters({"tube_4_contents": player_ship_tube_4_contents, "tube_5_contents": player_ship_tube_5_contents})
    enemy_ship_1.set_parameters(enemy_ship_1_parameters)
func _on_incident_3_resolved():
    incident_resolved = true
    Events.emit_signal("incident_resolved")
    for child in get_children():
        if child.has_method("set_parameters"):
            child.queue_free()

func _ready():
    Events.connect("incident_3_begin", _on_incident_3_begin)
    Events.connect("incident_3_resolved", _on_incident_3_resolved)
    Events.connect("resources_expended", _on_resources_expended)
