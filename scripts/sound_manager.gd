extends Node

@export var sounds: Dictionary[String, AudioStreamMP3]

@onready var music: AudioStreamPlayer2D = $Music

var currently_playing: String = "Nothing is playing"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_sound("Tiger Tracks - Lexica")

func call_sound(song: String) -> void:
	music.stop()
	music.stream = sounds[song]
	currently_playing = song
	music.play()
