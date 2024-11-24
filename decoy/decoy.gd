class_name Decoy
extends RigidBody2D
enum DecoyState { STOWED, DEPLOYING, DEPLOYED, SPENT}

var decoy_state: DecoyState = DecoyState.DEPLOYING
var state_name: String = "DEPLOYING"

var display_name: String
var group: String
var lifetime: float
var thrust_time: float
var thrust_magnitude: float
var launch_bearing: float

var stowed_timer: Timer = Timer.new()
var thrust_timer: Timer = Timer.new()
var lifetime_timer: Timer = Timer.new()

func set_parameters(parameters: Dictionary = {}) -> void:
    display_name = parameters.get("display_name", "DEFAULT-1 Chaff Block N")
    group = parameters.get("group", "decoys")
    lifetime = parameters.get("lifetime", 12)
    thrust_time = parameters.get("thrust_time", 1)
    thrust_magnitude = parameters.get("thrust_magnitude", 3)
    launch_bearing = deg_to_rad(parameters.get("launch_bearing", 0) + 270)

func setup_timer(timer: Timer, wait_time: float, timeout_func) -> void:
    timer.wait_time = wait_time
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(timeout_func)

func on_hit() -> void:
    pass

func _ready():
    add_to_group(group)
    setup_timer(thrust_timer, thrust_time, _on_thrust_timer_timeout)
    setup_timer(lifetime_timer, lifetime, _on_lifetime_timer_timeout)
    thrust_timer.start()

func launch():
    decoy_state = DecoyState.DEPLOYING
    state_name = "DEPLOYING"

func _on_thrust_timer_timeout() -> void:
    decoy_state = DecoyState.DEPLOYED
    state_name = "DEPLOYED"

func _on_lifetime_timer_timeout() -> void:
    decoy_state = DecoyState.SPENT
    state_name = "SPENT"
    queue_free()

func _integrate_forces(_state) -> void:
    var applied_forces: Vector2 = Vector2.ZERO
    match decoy_state:
        DecoyState.STOWED:
            pass
        DecoyState.DEPLOYING:
            var launch_vector: Vector2
            launch_vector = Vector2(cos(launch_bearing), sin(launch_bearing))
            applied_forces += launch_vector * thrust_magnitude
        DecoyState.DEPLOYED:
            pass
        DecoyState.SPENT:
            pass

    apply_central_force(applied_forces)
    #print("\n----------------")
    #print("decoy global_position.x: %.2f | global_position.y: %.2f" % [global_position.x, global_position.y])
    #print("decoy linear_velocity.x: %.2f | linear_velocity.y: %.2f" % [linear_velocity.x, linear_velocity.y])
    #print("decoy state: " + state_name)
    #print("----------------\n")
