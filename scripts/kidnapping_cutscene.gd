extends Node2D

const robo_shiba: SpriteFrames = preload("res://assets/sprite_frames/robo_shiba.tres")
const shibina: SpriteFrames = preload("res://assets/sprite_frames/shibina.tres")

@onready var animation_player: AnimationPlayer = $Camera2D/Control/CanvasLayer/ColorRect/AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")

func call_robo_dialog():
	GameManager.call_dialog("You will come with me now! You better not resist or you will regret it!", "Robo Shiba", robo_shiba)

func call_shibina_dialog():
	GameManager.call_dialog("Oh uh, what is this sound... It sounds like metal... Oh no!", "Shibina", shibina)

func call_level_1():
	SceneManager.call_scene("level_1")

func fade_in():
	animation_player.play("fadein")
	
func fade_out():
	animation_player.play("fadeout")
