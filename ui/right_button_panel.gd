extends VBoxContainer


func _on_button_5_pressed():
    Events.emit_signal("button_5_pressed")

func _on_button_6_pressed():
    Events.emit_signal("button_6_pressed")

func _on_button_7_pressed():
    Events.emit_signal("button_7_pressed")

func _on_button_8_pressed():
    Events.emit_signal("button_8_pressed")
