extends Control

@onready var CIWSIndicator: Control = $CIWSIndicator
@onready var MasterWarningLight: Control = $MasterWarningLight
var warning_timer: Timer = Timer.new()
var is_warning_active: bool = false

func _ready() -> void:
    Events.connect("ciws_started_firing", _on_ciws_started_firing)
    Events.connect("ciws_stopped_firing", _on_ciws_stopped_firing)
    Events.connect("ciws_available", _on_ciws_available)
    Events.connect("all_clear", _on_all_clear)
    Events.connect("caution", _on_caution)
    Events.connect("warning", _on_warning)
    _on_ciws_available(false)
    _on_all_clear(true)
    warning_timer.set_wait_time(0.33)
    warning_timer.one_shot = false
    warning_timer.timeout.connect(_on_warning_timer_timeout)
    add_child(warning_timer)

func _on_ciws_available(ciws_available: bool) -> void:
    if ciws_available:
        CIWSIndicator.set_bulb_texture(CIWSIndicator.BulbState.GREEN)
    else:
        CIWSIndicator.set_bulb_texture(CIWSIndicator.BulbState.RED)

func _on_ciws_started_firing() -> void:
    CIWSIndicator.set_bulb_texture(CIWSIndicator.BulbState.YELLOW)

func _on_ciws_stopped_firing() -> void:
    CIWSIndicator.set_bulb_texture(CIWSIndicator.BulbState.GREEN)

func _on_all_clear(all_clear: bool) -> void:
    if all_clear:
        MasterWarningLight.set_bulb_texture(MasterWarningLight.BulbState.GREEN)
        warning_timer.stop()
        is_warning_active = false

func _on_caution() -> void:
    MasterWarningLight.set_bulb_texture(MasterWarningLight.BulbState.YELLOW)
    warning_timer.stop()
    is_warning_active = false

func _on_warning() -> void:
    if not is_warning_active:
        is_warning_active = true
        MasterWarningLight.set_bulb_texture(MasterWarningLight.BulbState.RED)
        warning_timer.start()

func _on_warning_timer_timeout() -> void:
    var current_texture = MasterWarningLight.get_bulb_texture()
    if current_texture == MasterWarningLight.BulbState.RED:
        MasterWarningLight.set_bulb_texture(MasterWarningLight.BulbState.OFF)
        warning_timer.set_wait_time(0.66)
    else:
        MasterWarningLight.set_bulb_texture(MasterWarningLight.BulbState.RED)
        warning_timer.set_wait_time(0.33)
