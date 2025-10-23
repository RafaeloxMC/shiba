extends Node2D

var robo_sprite_frames = preload("res://assets/sprite_frames/robo_shiba.tres")

func call_first_robo_dialog():
	GameManager.call_dialog("I've been watching you. What an honor to see you here...", "Robo Dog", robo_sprite_frames)
