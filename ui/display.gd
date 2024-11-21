extends Control

enum DisplayState {Boot, Radar, Ordnance, Incidents}

var display_state = DisplayState.Boot

@onready var label_1: Label = $VBoxContainer/LeftTextPanel/Label1
@onready var label_2: Label = $VBoxContainer/LeftTextPanel/Label2
@onready var label_3: Label = $VBoxContainer/LeftTextPanel/Label3
@onready var label_4: Label = $VBoxContainer/LeftTextPanel/Label4

@onready var label_5: Label = $VBoxContainer/RightTextPanel/Label5
@onready var label_6: Label = $VBoxContainer/RightTextPanel/Label6
@onready var label_7: Label = $VBoxContainer/RightTextPanel/Label7
@onready var label_8: Label = $VBoxContainer/RightTextPanel/Label8

@onready var world: Node2D = get_tree().get_first_node_in_group("world")
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var central_text: Label = $VBoxContainer/CenterDisplay/CentralText

func _ready() -> void:
    world.visible = false

    label_1.text = ""
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


func _on_button_1_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            display_state = DisplayState.Radar
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
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_1")
            label_2.text = "empty"


func _on_button_3_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_2")
            label_3.text = "empty"


func _on_button_4_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_3")
            label_4.text = "empty"

        DisplayState.Boot:
            display_state = DisplayState.Radar
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


func _on_button_5_pressed() -> void:
    match display_state:
        DisplayState.Radar:
            display_state = DisplayState.Ordnance
            world.visible = false
            label_1.text = "Radar"
            label_2.text = player.get("tube_1_contents").get("display_name", "empty")
            label_3.text = player.get("tube_2_contents").get("display_name", "empty")
            label_4.text = player.get("tube_3_contents").get("display_name", "empty")
            label_5.text = ""
            label_6.text = player.get("tube_4_contents").get("display_name", "empty")
            label_7.text = player.get("tube_5_contents").get("display_name", "empty")
            label_8.text = player.get("tube_6_contents").get("display_name", "empty")


func _on_button_6_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_4")
            label_6.text = "empty"


func _on_button_7_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_5")
            label_7.text = "empty"


func _on_button_8_pressed() -> void:
    match display_state:
        DisplayState.Ordnance:
            Events.emit_signal("launch_tube_6")
            label_8.text = "empty"

        DisplayState.Boot:
            get_tree().quit()
