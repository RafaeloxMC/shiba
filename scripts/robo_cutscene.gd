extends Node2D

var robo_sprite_frames = preload("res://assets/sprite_frames/robo_shiba.tres")
var shiba_sprite_frames = preload("res://assets/sprite_frames/player.tres")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = 1

func call_first_robo_dialog():
	GameManager.call_dialog("LEVEL_16_FIRST", "Robo Dog", robo_sprite_frames)

func call_second_robo_dialog():
	GameManager.call_dialog("LEVEL_16_THIRD", "Robo Dog", robo_sprite_frames)

func call_first_shiba_dialog():
	GameManager.call_dialog("LEVEL_16_SECOND", "Shiba", shiba_sprite_frames)

func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		animation_player.speed_scale = 8
