extends Control

@export var green_bulb_texture: Texture2D = preload("res://assets/visual/green_bar_round_gloss_large_square.png")
@export var yellow_bulb_texture: Texture2D = preload("res://assets/visual/yellow_bar_round_gloss_large_square.png")
@export var red_bulb_texture: Texture2D = preload("res://assets/visual/red_bar_round_gloss_large_square.png")
@export var off_bulb_texture: Texture2D = preload("res://assets/visual/off_bar_round_gloss_large_square.png")

@onready var bulb = $IndicatorBorder/IndicatorBulb

enum BulbState {
    GREEN,
    YELLOW,
    RED,
    OFF
}

@export var initial_state: BulbState = BulbState.OFF

func _ready():
    set_bulb_texture(initial_state)

func set_bulb_texture(state: BulbState):
    match state:
        BulbState.GREEN:
            bulb.texture = green_bulb_texture
        BulbState.YELLOW:
            bulb.texture = yellow_bulb_texture
        BulbState.RED:
            bulb.texture = red_bulb_texture
        BulbState.OFF:
            bulb.texture = off_bulb_texture

func get_bulb_texture() -> BulbState:
    match bulb.texture:
        green_bulb_texture:
            return BulbState.GREEN
        yellow_bulb_texture:
            return BulbState.YELLOW
        red_bulb_texture:
            return BulbState.RED
        off_bulb_texture:
            return BulbState.OFF
        _:
            return BulbState.OFF
