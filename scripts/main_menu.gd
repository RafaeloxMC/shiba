extends Control

@onready var play: Area2D = $play
@onready var settings: Area2D = $settings
@onready var quit: Area2D = $quit

var current_button_id = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_current_button().get_node("AnimatedSprite2D").play("selected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		print("Up!")
		last()
	elif Input.is_action_just_pressed("ui_down"):
		print("Down!")
		next()
	elif Input.is_action_just_pressed("ui_accept"):
		print("Accept!")
		submit()

func next():
	get_current_button().get_node("AnimatedSprite2D").play("default")
	if current_button_id >= 3:
		current_button_id = 1
	else:
		current_button_id += 1
	highlight_current()
		
func last():
	get_current_button().get_node("AnimatedSprite2D").play("default")
	if current_button_id <= 1:
		current_button_id = 3
	else:
		current_button_id -= 1
	highlight_current()

func submit():
	print(current_button_id)
	get_tree().change_scene_to_packed(get_current_button().scene)

func highlight_current() -> void:
	var curr = get_current_button()
	print(str(curr))
	curr.get_node("AnimatedSprite2D").play("selected")

func get_current_button() -> Area2D:
	if current_button_id == 1:
		return play
	elif current_button_id == 2:
		return settings
	elif current_button_id == 3:
		return quit
	return null
