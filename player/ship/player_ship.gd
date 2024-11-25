extends RigidBody2D

var set_initial_state = true

var missile_scene = preload("res://missile/missile.tscn")
var decoy_scene = preload("res://decoy/decoy.tscn")

var tube_1_contents
var tube_2_contents
var tube_3_contents
var tube_4_contents
var tube_5_contents
var tube_6_contents

func set_parameters(parameters: Dictionary = {}) -> void:
    tube_1_contents = parameters.get("tube_1_contents", {})
    tube_2_contents = parameters.get("tube_2_contents", {})
    tube_3_contents = parameters.get("tube_3_contents", {})
    tube_4_contents = parameters.get("tube_4_contents", {})
    tube_5_contents = parameters.get("tube_5_contents", {})
    tube_6_contents = parameters.get("tube_6_contents", {})

func _draw():
    var center: Vector2 = Vector2.ZERO
    var start_angle: float = 0
    var end_angle: float = 360
    var point_count: int = 180
    var color: Color = "#ffb000"
    var width: float = 1
    var antialiased: bool = true

    for radius in range(100, 400, 100):
        draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased)

func _on_launch_tube_1():
    launch_tube_contents(tube_1_contents)
    tube_1_contents = {}

func _on_launch_tube_2():
    launch_tube_contents(tube_2_contents)
    tube_2_contents = {}

func _on_launch_tube_3():
    launch_tube_contents(tube_3_contents)
    tube_3_contents = {}

func _on_launch_tube_4():
    launch_tube_contents(tube_4_contents)
    tube_4_contents = {}

func _on_launch_tube_5():
    launch_tube_contents(tube_5_contents)
    tube_5_contents = {}

func _on_launch_tube_6():
    launch_tube_contents(tube_6_contents)
    tube_6_contents = {}

func _on_ping(ping_source: Node) -> void:
    $RadarPingSound.play()
    draw_passive_sensor_line(ping_source)

func _on_missile_launched(launch_source: Node, boost_time: float) -> void:
    $MissileLaunchAlert.play(13.78)
    draw_passive_sensor_line(launch_source, boost_time)

func draw_passive_sensor_line(source: Node, decay_time: float = 1) -> void:
    var direction = (source.global_position - global_position).normalized()
    var line = Line2D.new()
    var tween = create_tween()
    line.width = 1
    line.default_color = Color("#ffb000")
    line.points = [position, direction * 1000]
    tween.tween_property(line, "default_color:a", 0, decay_time)
    tween.tween_callback(line.queue_free)
    add_child(line)

func launch_tube_contents(tube_contents):
    if tube_contents:
        $LaunchSound.play()
        match tube_contents["type"]:
            "missile":
                var missile = missile_scene.instantiate()
                missile.set_parameters(tube_contents)
                add_child(missile)
                missile.launch()
            "decoy":
                var decoy = decoy_scene.instantiate()
                decoy.set_parameters(tube_contents)
                add_child(decoy)
                decoy.launch()
            _:
                print("tube_contents type not recognized")
    else:
        print("tube is empty")

func on_hit() -> void:
    Events.emit_signal("player_ship_hit")
    queue_free()

func _ready():
    Events.connect("ping", _on_ping)
    Events.connect("launch_tube_1", _on_launch_tube_1)
    Events.connect("launch_tube_2", _on_launch_tube_2)
    Events.connect("launch_tube_3", _on_launch_tube_3)
    Events.connect("launch_tube_4", _on_launch_tube_4)
    Events.connect("launch_tube_5", _on_launch_tube_5)
    Events.connect("launch_tube_6", _on_launch_tube_6)
    Events.connect("missile_launch", _on_missile_launched)
    add_to_group("player")
    #print("\n----------------")
    #print("player ship spwaned")
    #print("global_position.x: " + str(global_position.x) + " | global_position.y:" + str(global_position.y))
    #print("----------------\n")

func _integrate_forces(state) -> void:
    pass
