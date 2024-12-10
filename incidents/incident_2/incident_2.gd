extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")
var player_ship_scene = preload("res://player/ship/player_ship.tscn")

@onready var world: Node2D = get_tree().get_first_node_in_group("world")

var resources_expended = 0
var ciws_available = false
var salary = 2320
var max_bonus = 13333 - salary
var incident_started = false
var incident_resolved = false
var incident_resolution_time = 35
var incident_timer = Timer.new()

var player_ship_tube_1_contents = {
    "type": "missile",
    "display_name": "VACM-161 SM-3 Block IIA\nAutonomous Missile Interceptor\nCost: 3000",
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

var player_ship_tube_4_contents = {
    "type": "decoy",
    "display_name": "Mk 36 SRBOC\nChaff\nCost: 300",
    "resource_cost": 300,
    "group": "chaff",
    "launch_bearing": 30,
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
        "stowed_time": 9,
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
        "seeker_has_ping": true,
        "group": "enemy_missiles",
        "intended_target": "player",
        "countermeasures": ["chaff"],
        "stowed_time": 10,
        "boost_thrust_magnitude": 2.0,
        "boost_thrust_time": 6.0,
        "maneuvering_thrust_magnitude": 0.3,
        "terminal_thrust_time": 3.0,
        "terminal_thrust_magnitude": 1.0,
        "seeker_range": 120,
        "velocity_rejection_coefficient": 1.2
    }
]

var enemy_ship_1_parameters = {
    "distance": 380,
    "position_bearing": 330,
    "speed": 9,
    "velocity_bearing": 120,
    "missiles": enemy_ship_1_missiles
}

var enemy_ship_2_parameters = {
    "distance": 370,
    "position_bearing": 320,
    "speed": 9,
    "velocity_bearing": 120,
    "missiles": enemy_ship_2_missiles
}

var enemy_ship_3_parameters = {
    "distance": 375,
    "position_bearing": 325,
    "speed": 9,
    "velocity_bearing": 120,
    "missiles": enemy_ship_3_missiles
}

var enemy_ships = []

func get_details():
    var details = {
        "name": "Incident 2",
        "description": "
            Date: 1993-04-13
            Location: Io - Callisto transfer orbit
            Incident Report: Three RADAR contacts,
            Three Active RADAR homing missiles
            were deployed by contacts,
            No casualties.
            Resources expended: " + str(resources_expended),
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

func _on_incident_2_begin():
    incident_started = true
    incident_timer.wait_time = incident_resolution_time
    incident_timer.one_shot = true
    incident_timer.timeout.connect(_on_incident_2_resolved)
    add_child(incident_timer)
    incident_timer.start()
    var player_ship = player_ship_scene.instantiate()
    var enemy_ship_1 = enemy_ship_scene.instantiate()
    var enemy_ship_2 = enemy_ship_scene.instantiate()
    var enemy_ship_3 = enemy_ship_scene.instantiate()
    add_child(player_ship)
    add_child(enemy_ship_1)
    add_child(enemy_ship_2)
    add_child(enemy_ship_3)
    player_ship.set_parameters({"tube_1_contents": player_ship_tube_1_contents, "tube_4_contents": player_ship_tube_4_contents})
    enemy_ship_1.set_parameters(enemy_ship_1_parameters)
    enemy_ship_2.set_parameters(enemy_ship_2_parameters)
    enemy_ship_3.set_parameters(enemy_ship_3_parameters)
    Events.emit_signal("ciws_available", ciws_available)

func _on_incident_2_resolved():
    incident_resolved = true
    Events.emit_signal("incident_resolved")
    Events.emit_signal("ciws_available", false)
    incident_timer.queue_free()
    for child in get_children():
        if child.has_method("set_parameters"):
            child.queue_free()

func _ready():
    Events.connect("incident_2_begin", _on_incident_2_begin)
    Events.connect("resources_expended", _on_resources_expended)
    Events.connect("player_ship_hit", _on_player_ship_hit)
