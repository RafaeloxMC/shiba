extends Node2D

const robo_shiba: SpriteFrames = preload("res://assets/sprite_frames/robo_shiba.tres")
const shibina: SpriteFrames = preload("res://assets/sprite_frames/shibina.tres")

@onready var animation_player: AnimationPlayer = $Camera2D/Control/CanvasLayer/ColorRect/AnimationPlayer
@onready var cutscene_anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")
	cutscene_anim.speed_scale = 1
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		cutscene_anim.speed_scale = 8
		print("Skipped!")

func call_robo_dialog():
	GameManager.call_dialog("INTRO_ROBO", "Robo Shiba", robo_shiba)

func call_shibina_dialog():
	GameManager.call_dialog("INTRO_SHIBINA", "Shibina", shibina)

func call_level_1():
	SceneManager.call_scene("level_1")

func fade_in():
	animation_player.play("fadein")
	
func fade_out():
	animation_player.play("fadeout")
