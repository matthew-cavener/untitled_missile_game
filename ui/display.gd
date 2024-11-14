extends Control

enum DisplayState {Boot, Radar, Ordnance, Incidents}

var display_state = DisplayState.Boot

@onready var label1: Label = $VBoxContainer/LeftTextPanel/Label1
@onready var label2: Label = $VBoxContainer/LeftTextPanel/Label2
@onready var label3: Label = $VBoxContainer/LeftTextPanel/Label3
@onready var label4: Label = $VBoxContainer/LeftTextPanel/Label4

@onready var label5: Label = $VBoxContainer/RightTextPanel/Label5
@onready var label6: Label = $VBoxContainer/RightTextPanel/Label6
@onready var label7: Label = $VBoxContainer/RightTextPanel/Label7
@onready var label8: Label = $VBoxContainer/RightTextPanel/Label8

@onready var world: Node2D = get_tree().get_first_node_in_group("world")
@onready var central_text: Label = $VBoxContainer/CenterDisplay/CentralText

func _ready() -> void:
    world.visible = false

    label1.text = ""
    label2.text = ""
    label3.text = ""
    label4.text = "Clock-In"

    label5.text = ""
    label6.text = ""
    label7.text = ""
    label8.text = "Quit"

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
            label1.text = ""
            label5.text = "Ordnance"


func _on_button_2_pressed() -> void:
    pass


func _on_button_3_pressed() -> void:
    pass


func _on_button_4_pressed() -> void:
    match display_state:
        DisplayState.Boot:
            display_state = DisplayState.Radar
            world.visible = true
            label5.text = "Ordnance"
            label4.text = ""
            label8.text = ""
            central_text.text = ""


func _on_button_5_pressed() -> void:
    match display_state:
        DisplayState.Radar:
            display_state = DisplayState.Ordnance
            world.visible = false
            label1.text = "Radar"
            label5.text = ""


func _on_button_6_pressed() -> void:
    pass


func _on_button_7_pressed() -> void:
    pass


func _on_button_8_pressed() -> void:
    match display_state:
        DisplayState.Boot:
            get_tree().quit()
