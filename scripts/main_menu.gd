extends Control

@onready var play: Area2D = $play
@onready var settings: Area2D = $settings
@onready var quit: Area2D = $quit
@onready var title: Label = $title
@onready var subtitle: Label = $subtitle
@onready var hint: Label = $hint
@onready var background: Control = $Background
@onready var parallax_background: ParallaxBackground = $Background/ParallaxBackground
@onready var fade: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

var current_button_id = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_current_button().selected = true
	if GameManager.hearts <= 0:
		fade.play("fadein")
	else:
		color_rect.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.has_node("Settings") || self.has_node("Shutdown"):
		title.hide()
		subtitle.hide()
		hint.hide()
		play.hide()
		settings.hide()
		quit.hide()
		return
	else:
		title.visible = true
		subtitle.visible = true
		hint.visible = true
		play.visible = true
		settings.visible = true
		quit.visible = true
		
	if self.has_node("Game") || self.has_node("Shutdown"):
		background.hide()
	else:
		background.visible = true
	if Input.is_action_just_pressed("ui_up"):
		last()
	elif Input.is_action_just_pressed("ui_down"):
		next()
	elif Input.is_action_just_pressed("ui_accept"):
		submit()

func next():
	get_current_button().selected = false
	if current_button_id >= 3:
		current_button_id = 1
	else:
		current_button_id += 1
	get_current_button().selected = true
		
func last():
	get_current_button().selected = false
	if current_button_id <= 1:
		current_button_id = 3
	else:
		current_button_id -= 1
	get_current_button().selected = true

func submit():
	if get_current_button() == play:
		if GameManager.hearts <= 0:
			GameManager.reset()
		GameManager.call_tick_ui()
		SceneManager.reload_current_level()
		Engine.time_scale = 1
		return
		
	if get_current_button().scene != null:
		var node = load(get_current_button().scene.resource_path)
		add_child(node.instantiate())

func get_current_button() -> Area2D:
	if current_button_id == 1:
		return play
	elif current_button_id == 2:
		return settings
	elif current_button_id == 3:
		return quit
	return null
