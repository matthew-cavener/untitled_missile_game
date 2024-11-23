extends Control

enum DisplayState {BOOT, RADAR, ORDNANCE, INCIDENTS}

var display_state: DisplayState = DisplayState.BOOT
var selected_incident: String = "NONE"

@onready var label_1: Label = $VBoxContainer/LeftTextPanel/Label1
@onready var label_2: Label = $VBoxContainer/LeftTextPanel/Label2
@onready var label_3: Label = $VBoxContainer/LeftTextPanel/Label3
@onready var label_4: Label = $VBoxContainer/LeftTextPanel/Label4

@onready var label_5: Label = $VBoxContainer/RightTextPanel/Label5
@onready var label_6: Label = $VBoxContainer/RightTextPanel/Label6
@onready var label_7: Label = $VBoxContainer/RightTextPanel/Label7
@onready var label_8: Label = $VBoxContainer/RightTextPanel/Label8

@onready var world: Node2D = get_tree().get_first_node_in_group("world")
@onready var central_text: Label = $VBoxContainer/CenterDisplay/CentralText

func _ready() -> void:
    world.visible = false

    label_1.text = "Incidents"
    label_2.text = ""
    label_3.text = ""
    label_4.text = "Clock-In"

    label_5.text = ""
    label_6.text = ""
    label_7.text = ""
    label_8.text = "Quit"

    Events.connect("button_1_pressed", _on_button_1_pressed)
    Events.connect("button_2_pressed", _on_button_2_pressed)
    Events.connect("button_3_pressed", _on_button_3_pressed)
    Events.connect("button_4_pressed", _on_button_4_pressed)

    Events.connect("button_5_pressed", _on_button_5_pressed)
    Events.connect("button_6_pressed", _on_button_6_pressed)
    Events.connect("button_7_pressed", _on_button_7_pressed)
    Events.connect("button_8_pressed", _on_button_8_pressed)

    Events.connect("incident_resolved", _on_incident_resolved)


func _on_button_1_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            display_state = DisplayState.INCIDENTS
            world.visible = false
            central_text.text = "Please select an incident to review"
            label_1.text = ""
            label_2.text = world.incidents["incident1"].details["name"]
            label_3.text = ""
            label_4.text = ""
            label_5.text = "Main Menu"
            label_6.text = ""
            label_7.text = ""
            label_8.text = ""
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            display_state = DisplayState.RADAR
            world.visible = true
            label_1.text = ""
            label_2.text = ""
            label_3.text = ""
            label_4.text = ""
            label_5.text = "Ordnance"
            label_6.text = ""
            label_7.text = ""
            label_8.text = ""


func _on_button_2_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            pass
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_1")
            label_2.text = "empty"
        DisplayState.INCIDENTS:
            if not world.incidents["incident1"].details["incident_report_submitted"]:
                selected_incident = "1"
                central_text.text = "No incident report found.\nIf you are currently experiencing an incident, please Clock-In."
            else:
                central_text.text = world.incidents["incident1"].details["description"]


func _on_button_3_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            pass
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_2")
            label_3.text = "empty"
        DisplayState.INCIDENTS:
            selected_incident = "2"


func _on_button_4_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            if selected_incident != "NONE":
                Events.emit_signal("incident_" + selected_incident + "_begin")
                display_state = DisplayState.RADAR
                world.visible = true
                label_1.text = ""
                label_2.text = ""
                label_3.text = ""
                label_4.text = ""
                label_5.text = "Ordnance"
                label_6.text = ""
                label_7.text = ""
                label_8.text = ""
                central_text.text = ""
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_3")
            label_4.text = "empty"
        DisplayState.INCIDENTS:
            selected_incident = "3"


func _on_button_5_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            pass
        DisplayState.RADAR:
            display_state = DisplayState.ORDNANCE
            world.visible = false
            label_1.text = "Radar"
            var player = get_tree().get_first_node_in_group("player")
            label_2.text = player.get("tube_1_contents").get("display_name", "empty")
            label_3.text = player.get("tube_2_contents").get("display_name", "empty")
            label_4.text = player.get("tube_3_contents").get("display_name", "empty")
            label_5.text = ""
            label_6.text = player.get("tube_4_contents").get("display_name", "empty")
            label_7.text = player.get("tube_5_contents").get("display_name", "empty")
            label_8.text = player.get("tube_6_contents").get("display_name", "empty")
        DisplayState.ORDNANCE:
            pass
        DisplayState.INCIDENTS:
            display_state = DisplayState.BOOT
            world.visible = false
            label_1.text = "Incidents"
            label_2.text = ""
            label_3.text = ""
            label_4.text = "Clock-In"
            label_5.text = ""
            label_6.text = ""
            label_7.text = ""
            label_8.text = "Quit"


func _on_button_6_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            pass
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_4")
            label_6.text = "empty"
        DisplayState.INCIDENTS:
            selected_incident = "4"


func _on_button_7_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            pass
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_5")
            label_7.text = "empty"
        DisplayState.INCIDENTS:
            selected_incident = "5"


func _on_button_8_pressed() -> void:
    match display_state:
        DisplayState.BOOT:
            get_tree().quit()
        DisplayState.RADAR:
            pass
        DisplayState.ORDNANCE:
            Events.emit_signal("launch_tube_6")
            label_8.text = "empty"
        DisplayState.INCIDENTS:
            selected_incident = "6"

func _on_incident_resolved() -> void:
    display_state = DisplayState.BOOT
    world.visible = false
    label_1.text = "Incidents"
    label_2.text = ""
    label_3.text = ""
    label_4.text = "Clock-In"
    label_5.text = ""
    label_6.text = ""
    label_7.text = ""
    label_8.text = "Quit"
    central_text.text = "Incident resolved.\nThank you for safeguarding\nJoveEx property!"
