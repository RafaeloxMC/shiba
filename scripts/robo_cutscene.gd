extends Node2D

var robo_sprite_frames = preload("res://assets/sprite_frames/robo_shiba.tres")
var shiba_sprite_frames = preload("res://assets/sprite_frames/player.tres")

func call_first_robo_dialog():
	GameManager.call_dialog("I've been watching you. What an honor to see you here...", "Robo Dog", robo_sprite_frames)

func call_second_robo_dialog():
	GameManager.call_dialog("Oh, you wish I would. Get her back yourself!", "Robo Dog", robo_sprite_frames)

func call_first_shiba_dialog():
	GameManager.call_dialog("Not you again... Let Shibina go!", "Shiba", shiba_sprite_frames)
