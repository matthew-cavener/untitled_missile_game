extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
    print("\n----------------")
    print("player ship spwaned")
    print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    print("----------------\n")

