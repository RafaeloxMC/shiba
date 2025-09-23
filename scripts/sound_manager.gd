extends Node

@export var sounds: Dictionary[String, AudioStreamMP3]

@onready var music: AudioStreamPlayer2D = $Music
@onready var animation_player: AnimationPlayer = $Music/AnimationPlayer

var currently_playing: String = "Nothing is playing"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_sound("Tiger Tracks - Lexica")

func call_sound(song: String) -> void:
	music.stop()
	music.stream = sounds[song]
	currently_playing = song
	music.play()
	
func call_sound_with_fade(song: String) -> void:
	animation_player.play("fadeout")
	await get_tree().create_timer(0.5).timeout
	call_sound(song)
	animation_player.play("fadein")
