extends Node2D

var incidents = {
    "incident1": preload("res://incidents/incident_1.tscn").instantiate()
}

func _ready():
    for incident in incidents:
        add_child(incidents[incident])
