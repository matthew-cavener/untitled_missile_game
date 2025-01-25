# @tool
extends RigidBody2D


var set_initial_state = true

var radar_sweep_speed = 3

var ciws_available = true
var ciws_cooldown_timer: float
var ciws_active: bool

var missile_scene = preload("res://missile/missile.tscn")
var decoy_scene = preload("res://decoy/decoy.tscn")
var radar_contact_texture= preload("res://assets/visual/radar_contact.tscn").instantiate().texture

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
    ciws_available = parameters.get("ciws_available", true)
    ciws_cooldown_timer = parameters.get("ciws_cooldown_timer", 3.0)

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

func _on_ciws_timer_timeout() -> void:
    ciws_active = false
    Events.emit_signal("ciws_stopped_firing")

func _on_radar_sweep_area_area_exited(area: Area2D) -> void:
    var radar_contact = Sprite2D.new()
    radar_contact.texture = radar_contact_texture
    radar_contact.scale = Vector2(0.031, 0.031)
    var area_parent = area.get_parent()
    radar_contact.global_position = area_parent.global_position - global_position
    add_child(radar_contact)
    var tween = create_tween()
    tween.tween_property(radar_contact, "modulate:a", 0, 6)
    tween.tween_callback(radar_contact.queue_free)

func draw_passive_sensor_line(source: Node, decay_time: float = 3) -> void:
    var direction = (source.global_position - global_position).normalized()
    var line = Line2D.new()
    var tween = create_tween()
    line.width = 1
    line.default_color = Color("#ffb000")
    line.points = [position, direction * 1000]
    line.antialiased = true
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
    if ciws_available and not ciws_active:
        ciws_active = true
        Events.emit_signal("ciws_started_firing")
        Events.emit_signal("resources_expended", 3000)
        $CIWSSound.play()
        var timer = Timer.new()
        timer.set_wait_time(ciws_cooldown_timer)
        timer.timeout.connect(_on_ciws_timer_timeout)
        add_child(timer)
        timer.start()
    else:
        Events.emit_signal("player_ship_hit")
        queue_free()

func check_enemy_missile_states():
    var warning_states = ["BOOSTING", "MIDCOURSE", "SEEKING", "TERMINAL"]
    var all_stowed = true
    var all_disarmed = true
    var enemy_missiles = get_tree().get_nodes_in_group("enemy_missiles")
    if enemy_missiles.size() == 0:
        Events.emit_signal("all_clear", true)
        return
    for missile in enemy_missiles:
        if missile.state_name in warning_states:
            Events.emit_signal("warning")
            Events.emit_signal("all_clear", false)
            return
        elif missile.state_name != "STOWED":
            all_stowed = false
        if missile.state_name != "DISARMED":
            all_disarmed = false
    if all_stowed:
        Events.emit_signal("caution")
        Events.emit_signal("all_clear", false)
    elif all_disarmed:
        Events.emit_signal("all_clear", true)

func _ready():
    var tween = create_tween()
    $RadarSweepLine.rotation_degrees = 0
    $RadarSweepLine/RadarSweepArea/RadarSweepCollision.rotation_degrees = 0
    tween.tween_property($RadarSweepLine, "rotation_degrees", 360, radar_sweep_speed).from_current()
    tween.set_loops()

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

func _process(delta: float) -> void:
    check_enemy_missile_states()
