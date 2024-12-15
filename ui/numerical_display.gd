extends Control

@export var flashes: int = 3
@export var flash_delay: float = 0.333
@export var reveal_time: float = 0.333
@export var new_value: String = "123456"

@onready var lit_segments = $LitSegments
var is_updating: bool = false
var current_timers = []

# func _ready() -> void:
#     update_display(flashes, flash_delay, new_value, reveal_time)

func _flash(flashes: int, delay: float, new_value: String, flash_count: int, reveal_time: float) -> void:
    if flash_count < flashes * 2:
        lit_segments.visible = not lit_segments.visible
        flash_count += 1
        var timer = Timer.new()
        add_child(timer)
        current_timers.append(timer)
        timer.wait_time = delay
        timer.one_shot = true
        timer.connect("timeout", _on_flash_timeout.bind(flashes, delay, new_value, flash_count, reveal_time))
        timer.start()
    else:
        lit_segments.visible = true
        _reveal(new_value, reveal_time)

func _on_flash_timeout(flashes: int, delay: float, new_value: String, flash_count: int, reveal_time: float) -> void:
    _flash(flashes, delay, new_value, flash_count, reveal_time)

func _reveal(new_value: String, reveal_time: float) -> void:
    lit_segments.text = new_value
    lit_segments.visible_characters = 0
    var reveal_index = 0
    var reveal_delay = reveal_time / new_value.length()
    _reveal_step(new_value, reveal_index, reveal_delay)

func _reveal_step(new_value: String, reveal_index: int, reveal_delay: float) -> void:
    if reveal_index < new_value.length():
        reveal_index += 1
        lit_segments.visible_characters = reveal_index
        var timer = Timer.new()
        add_child(timer)
        current_timers.append(timer)
        timer.wait_time = reveal_delay
        timer.one_shot = true
        timer.connect("timeout", Callable(self, "_on_reveal_step_timeout").bind(new_value, reveal_index, reveal_delay))
        timer.start()
    else:
        lit_segments.visible_characters = new_value.length()
        is_updating = false
        _cleanup_timers()

func _on_reveal_step_timeout(new_value: String, reveal_index: int, reveal_delay: float) -> void:
    _reveal_step(new_value, reveal_index, reveal_delay)

func update_display(flashes: int, delay: float, new_value: String, reveal_time: float) -> void:
    if is_updating:
        _cleanup_timers()
    is_updating = true
    var flash_count = 0
    _flash(flashes, delay, new_value, flash_count, reveal_time)

func _cleanup_timers() -> void:
    for timer in current_timers:
        timer.queue_free()
    current_timers.clear()

func _on_button_pressed() -> void:
    update_display(6, 0.167, "hello", 0.167)
