extends Node2D
var enemy_ship_scene = preload("res://enemy/ship/enemy_ship.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    var enemy_ship = enemy_ship_scene.instantiate()
    add_child(enemy_ship)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass
