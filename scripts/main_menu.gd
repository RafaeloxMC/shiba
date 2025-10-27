extends Control

@onready var play: Area2D = $btn_play
@onready var endless: Area2D = $btn_endless
@onready var splitscreen: Area2D = $btn_splitscreen
@onready var settings: Area2D = $btn_settings
@onready var quit: Area2D = $btn_quit

@onready var title: Label = $title
@onready var subtitle: Label = $subtitle
@onready var hint: Label = $hint
@onready var background: Control = $Background
@onready var parallax_background: ParallaxBackground = $Background/ParallaxBackground
@onready var fade: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
@onready var current_song: Label = $"current song"

var current_button_id: int = 0
var first_visible_button: int = 0

var buttons: Array[Area2D] = []
var button_positions: Array[Vector2] = []

@onready var arrow_up: AnimatedSprite2D = $arrow_up
@onready var arrow_down: AnimatedSprite2D = $arrow_down

func _ready() -> void:
	buttons.clear()
	for child in get_children():
		if child is Area2D and child.name.begins_with("btn_"):
			buttons.append(child)

	if buttons.size() >= 1: button_positions.append(buttons[0].position)
	if buttons.size() >= 2: button_positions.append(buttons[1].position)
	if buttons.size() >= 3: button_positions.append(buttons[2].position)

	update_visible_buttons()
	get_current_button().selected = true

	if GameManager.hearts <= 0:
		fade.play("fadein")
	else:
		color_rect.hide()

func _process(_delta: float) -> void:
	if has_node("Settings") or has_node("Shutdown"):
		title.hide()
		subtitle.hide()
		hint.hide()
		for btn in buttons:
			btn.hide()
		return
	else:
		title.visible = true
		subtitle.visible = true
		hint.visible = true
		update_visible_buttons()
		current_song.text = "currently playing: " + SoundManager.currently_playing

	if has_node("Game") or has_node("Shutdown"):
		background.hide()
	else:
		background.visible = true

	if Input.is_action_just_pressed("ui_up"):
		last()
	elif Input.is_action_just_pressed("ui_down"):
		next()
	elif Input.is_action_just_pressed("ui_accept"):
		submit()

func next() -> void:
	get_current_button().selected = false
	current_button_id = (current_button_id + 1) % buttons.size()

	if current_button_id < first_visible_button:
		first_visible_button = current_button_id
	elif current_button_id >= first_visible_button + 3:
		first_visible_button = current_button_id - 2

	update_visible_buttons()
	get_current_button().selected = true

func last() -> void:
	get_current_button().selected = false
	current_button_id = (current_button_id - 1 + buttons.size()) % buttons.size()

	if current_button_id < first_visible_button:
		first_visible_button = current_button_id
	elif current_button_id >= first_visible_button + 3:
		first_visible_button = current_button_id - 2

	update_visible_buttons()
	get_current_button().selected = true

func update_visible_buttons() -> void:
	for i in buttons.size():
		if i >= first_visible_button and i < first_visible_button + 3:
			buttons[i].visible = true
			buttons[i].position = button_positions[i - first_visible_button]
		else:
			buttons[i].visible = false

	if first_visible_button == 0:
		arrow_up.visible = false
	else:
		arrow_up.visible = true

	if first_visible_button + 3 >= buttons.size():
		arrow_down.visible = false
	else:
		arrow_down.visible = true

func submit() -> void:
	var current = get_current_button()

	if current == play:
		GameManager.call_tick_ui()
		if GameManager.hearts <= 0 || GameManager.first_play == true:
			GameManager.first_play = false
			GameManager.reset()
			SceneManager.call_scene("kidnapping_cutscene")
		else:
			SceneManager.reload_current_level()
		Engine.time_scale = 1
		return
	
	if current == endless:
		GameManager.call_tick_ui()
		SceneManager.call_scene("endless")
	
	if current == splitscreen:
		GameManager.call_tick_ui()
		print("Called splitscreen")
		# SceneManager.call_scene("")

	if current.scene != null:
		var node = load(current.scene.resource_path)
		add_child(node.instantiate())

func get_current_button() -> Area2D:
	return buttons[current_button_id]
