class_name Decoy
extends RigidBody2D
enum DecoyState { STOWED, DEPLOYING, DEPLOYED, SPENT}

var group: String
var lifetime: float
var thrust_time: float
var thrust_magnitude: float

var thrust_timer: Timer = Timer.new()

func set_perameters(parameters: Dictionary = {}) -> void:
    group = parameters.get("group", "decoys")
    lifetime = parameters.get("lifetime", 3)
    thrust_time = parameters.get("thrust_time", 3)
    thrust_magnitude = parameters.get("thrust_magnitude", 3)

func setup_timer(timer: Timer, wait_time: float, timeout_func) -> void:
    timer.wait_time = wait_time
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(timeout_func)

func _ready():
    add_to_group(group)
    setup_timer(thrust_timer, thrust_time, _on_thrust_timer_timeout)
    thrust_timer.start()

func _on_thrust_timer_timeout() -> void:
    pass

func _integrate_forces(_state) -> void:
    pass
