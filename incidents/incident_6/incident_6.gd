extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

@onready var world: Node2D = get_tree().get_first_node_in_group("world")

var resources_expended = 0
var salary = 2320
var max_bonus = 13333 - salary
var incident_started = false
var incident_resolved = false
var incident_resolution_time = 50
var incident_timer = Timer.new()

var enemy_ship_1_parameters = {
    "distance": 380,
    "position_bearing": 0,
    "speed": 12,
    "velocity_bearing": 180 - 12,
    "missiles": enemy_ship_1_missiles
}

var enemy_ship_2_parameters = {
    "distance": 380,
    "position_bearing": 120,
    "speed": 12,
    "velocity_bearing": 120 - 180 - 12,
    "missiles": enemy_ship_2_missiles
}

var enemy_ship_3_parameters = {
    "distance": 380,
    "position_bearing": 240,
    "speed": 12,
    "velocity_bearing": 240 - 180 - 12,
    "missiles": enemy_ship_3_missiles
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
    }
]

var enemy_ship_3_missiles = [
    {
        "seeker_has_ping": false,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["flare"],
        "stowed_time": 12.2,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 3.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    }
]

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

func _on_player_ship_hit():
    if not incident_resolved:
        incident_timer.queue_free()

func _on_resources_expended(amount: int):
    if incident_started && not incident_resolved:
        resources_expended += amount

func _on_incident_6_begin():
    incident_started = true
    incident_timer.wait_time = incident_resolution_time
    incident_timer.one_shot = true
    incident_timer.timeout.connect(_on_incident_6_resolved)
    add_child(incident_timer)
    incident_timer.start()
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship_1 = enemy_ship_scene.instantiate()
    var enemy_ship_2 = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship_1)
    add_child(enemy_ship_2)
    player_ship.set_parameters({"tube_1_contents": player_ship_tube_1_contents, "tube_2_contents": player_ship_tube_2_contents, "tube_4_contents": player_ship_tube_4_contents, "tube_5_contents": player_ship_tube_5_contents, "tube_6_contents": player_ship_tube_6_contents})
    enemy_ship_1.set_parameters(enemy_ship_1_parameters)
    enemy_ship_2.set_parameters(enemy_ship_2_parameters)

func _on_incident_6_resolved():
    incident_resolved = true
    Events.emit_signal("incident_resolved")
    incident_timer.queue_free()
    for child in get_children():
        if child.has_method("set_parameters"):
            child.queue_free()

func _ready():
    Events.connect("incident_5_begin", _on_incident_6_begin)
    Events.connect("resources_expended", _on_resources_expended)
    Events.connect("player_ship_hit", _on_player_ship_hit)
