extends Control

var ciws_firing_texture = preload("res://assets/visual/yellow_bar_round_gloss_large_square.png")
var ciws_ready_texture = preload("res://assets/visual/green_bar_round_gloss_large_square.png")
var ciws_unavailable_texture = preload("res://assets/visual/red_bar_round_gloss_large_square.png")

func _ready() -> void:
    Events.connect("ciws_started_firing", _on_ciws_started_firing)
    Events.connect("ciws_stopped_firing", _on_ciws_stopped_firing)
    Events.connect("ciws_available", _on_ciws_available)

func _on_ciws_available(ciws_available: bool) -> void:
    if ciws_available:
        $CIWSIndicator.texture = ciws_ready_texture
    else:
        $CIWSIndicator.texture = ciws_unavailable_texture

func _on_ciws_started_firing() -> void:
    $CIWSIndicator.texture = ciws_firing_texture

func _on_ciws_stopped_firing() -> void:
    $CIWSIndicator.texture = ciws_ready_texture
