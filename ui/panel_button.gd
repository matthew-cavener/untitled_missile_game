extends TextureButton

func _on_button_down():
    $ButtonDown.play()

func _on_button_up():
    $ButtonUp.play()
