extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

@onready var world: Node2D = get_tree().get_first_node_in_group("world")

var resources_expended = 0
var incident_resolution_time = 15
var incident_timer = Timer.new()

var details = {
    "name": "Incident 1",
    "description": "
        Date: 2024-02-09
        Location: Callisto - Ganymede transfer orbit
        Incident Report: Single RADAR contact, no casualties.
        Resource expended: %d
    " % resources_expended,
    "resources_expended": resources_expended,
    "incident_report_submitted": false,
}

var player_ship_tube_1_contents = {
    "type": "missile",
    "display_name": "placeholder-1 AMM Block N",
    "resource_cost": 3000,
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
        "maneuvering_thrust_magnitude": 0,
        "terminal_thrust_time": 1.0,
        "terminal_thrust_magnitude": 0.1,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    }
]

var enemy_ship_1_parameters = {
    "distance": 300,
    "position_angle": 30,
    "speed": 6,
    "velocity_bearing": 210,
    "missiles": enemy_ship_1_missiles
}

func update_details():
    details = {
        "name": "Incident 1",
        "description": "
            Date: 2024-02-09
            Location: Callisto - Ganymede transfer orbit
            Incident Report: Single RADAR contact, no casualties.
            Resource expended: %d
        " % resources_expended,
        "resources_expended": resources_expended,
        "incident_report_submitted": false,
    }
    return details

func _on_resources_expended(amount: int):
    resources_expended += amount

func _on_incident_1_begin():
    incident_timer.wait_time = incident_resolution_time
    incident_timer.one_shot = true
    incident_timer.timeout.connect(_on_incident_1_resolved)
    add_child(incident_timer)
    incident_timer.start()
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship_1 = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship_1)
    player_ship.set_parameters({"tube_1_contents": player_ship_tube_1_contents})
    enemy_ship_1.set_parameters(enemy_ship_1_parameters)

func _on_incident_1_resolved():
    update_details()
    world.incidents["incident1"].details["resources_expended"] = resources_expended
    world.incidents["incident1"].details["incident_report_submitted"] = true
    Events.emit_signal("incident_resolved")
    incident_timer.queue_free()
    for child in get_children():
        if child.has_method("set_parameters"):
            child.queue_free()

func _ready():
    Events.connect("incident_1_begin", _on_incident_1_begin)
    Events.connect("resources_expended", _on_resources_expended)
