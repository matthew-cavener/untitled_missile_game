extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

@onready var world: Node2D = get_tree().get_first_node_in_group("world")

var resources_expended = 0
var ciws_available = true
var salary = 2320
var max_bonus = 13333 - salary
var incident_started = false
var incident_resolved = false

var player_ship_tube_1_contents = {
    "type": "decoy",
    "display_name": "Mk 36 SRBOC\nChaff\nCost: 300",
    "resource_cost": 300,
    "group": "chaff",
    "launch_bearing": 90 + 45,
}

var player_ship_tube_2_contents = {
    "type": "decoy",
    "display_name": "Mk 214 BSIRCM\nFlare\nCost: 300",
    "resource_cost": 300,
    "group": "flare",
    "launch_bearing": 90,
}

var player_ship_tube_3_contents = {
    "type": "decoy",
    "display_name": "Mk 36 SRBOC\nChaff\nCost: 300",
    "resource_cost": 300,
    "group": "chaff",
    "launch_bearing": 90 + 45,
}

var player_ship_tube_4_contents = {
    "type": "decoy",
    "display_name": "Mk 214 BSIRCM\nFlare\nCost: 300",
    "resource_cost": 300,
    "group": "flare",
    "launch_bearing": 90,
}

var player_ship_tube_5_contents = {
    "type": "missile",
    "display_name": "VACM-161 SM-3 Block IIA\nAutonomous Missile Interceptor\nCost: 10k",
    "resource_cost": 10000,
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

var player_ship_tube_6_contents = {
    "type": "missile",
    "display_name": "VACM-161 SM-3 Block IIA\nAutonomous Missile Interceptor\nCost: 10k",
    "resource_cost": 10000,
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
        "stowed_time": 18,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 3.0,
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
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    }
]

var enemy_ship_2_missiles = [
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
        "stowed_time": 18,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    },
    {
        "seeker_has_ping": true,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["chaff"],
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

var enemy_ship_3_missiles = [
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
        "stowed_time": 18,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    },
    {
        "seeker_has_ping": true,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["chaff"],
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
    "position_bearing": 90,
    "speed": 3,
    "velocity_bearing": 90 - 180 - 12,
    "missiles": enemy_ship_1_missiles
}

var enemy_ship_2_parameters = {
    "distance": 380,
    "position_bearing": 270 + 45,
    "speed": 3,
    "velocity_bearing": 270 + 45 - 180 - 12,
    "missiles": enemy_ship_2_missiles
}

var enemy_ship_3_parameters = {
    "distance": 380,
    "position_bearing": 270 - 45,
    "speed": 3,
    "velocity_bearing": 270 - 45 - 180 - 12,
    "missiles": enemy_ship_3_missiles
}

func get_details():
    var details = {
        "name": "Incident 6",
        "description": "
Date: 1993-12-24
Location: Europa - Amalthea transfer orbit
Incident Report: Two RADAR contacts
Three Active RADAR homing missiles deployed by contacts,
Two Passive IR homing missiles deployed by contacts,
No casualties.
Resource expended: " + str(resources_expended),
        "resources_expended": resources_expended,
        "incident_report_submitted": incident_resolved,
    }
    return details

func _on_resources_expended(amount: int):
    if incident_started && not incident_resolved:
        resources_expended += amount

func _on_incident_6_begin():
    incident_started = true
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship_1 = enemy_ship_scene.instantiate()
    var enemy_ship_2 = enemy_ship_scene.instantiate()
    var enemy_ship_3 = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship_1)
    add_child(enemy_ship_2)
    add_child(enemy_ship_3)
    player_ship.set_parameters({
        "tube_1_contents": player_ship_tube_1_contents,
        "tube_2_contents": player_ship_tube_2_contents,
        "tube_3_contents": player_ship_tube_3_contents,
        "tube_4_contents": player_ship_tube_4_contents,
        "tube_5_contents": player_ship_tube_5_contents,
        "tube_6_contents": player_ship_tube_6_contents,
        "ciws_available": ciws_available
    })
    enemy_ship_1.set_parameters(enemy_ship_1_parameters)
    enemy_ship_2.set_parameters(enemy_ship_2_parameters)
    enemy_ship_3.set_parameters(enemy_ship_3_parameters)
    Events.emit_signal("ciws_available", ciws_available)

func _on_incident_6_resolved():
    incident_resolved = true
    Events.emit_signal("incident_resolved")
    Events.emit_signal("ciws_available", false)
    for child in get_children():
        if child.has_method("set_parameters"):
            child.queue_free()

func _ready():
    Events.connect("incident_6_begin", _on_incident_6_begin)
    Events.connect("incident_6_resolved", _on_incident_6_resolved)
    Events.connect("resources_expended", _on_resources_expended)
