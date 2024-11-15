extends VBoxContainer


func _on_button_1_pressed():
    $Button1/Button1Click.play()
    Events.emit_signal("button_1_pressed")

func _on_button_2_pressed():
    Events.emit_signal("button_2_pressed")

func _on_button_3_pressed():
    Events.emit_signal("button_3_pressed")

func _on_button_4_pressed():
    Events.emit_signal("button_4_pressed")
