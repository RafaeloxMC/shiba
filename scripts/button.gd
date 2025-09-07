extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@export var scene: PackedScene
@export var type: int
@export var settings: Array
var original_scale: Vector2
var hover_scale: Vector2 = Vector2(1.05, 1.05)
var tween_duration: float = 0.2
var selected = false
var current_value = 0

func _ready():
	original_scale = animated_sprite_2d.scale
	if type == 1:
		animated_sprite_2d.play("settings")
	
func _process(_delta: float) -> void:
	if selected == true:
		animated_sprite_2d.play(get_btn_name() + "_selected")
	else:
		animated_sprite_2d.play(get_btn_name())
		
func get_btn_name() -> String:
	if type == 1:
		return "settings"
	else:
		return "default"
		
func next() -> void:
	if label.text not in settings:
		label.text = settings[current_value]
		return
	if settings.size() <= current_value + 1:
		current_value = 0
	else:
		current_value += 1
	label.text = settings[current_value]
	GameManager.difficulty = current_value
	print("Set difficulty to " + label.text)
