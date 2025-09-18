extends Control

@onready var difficulty: Area2D = $difficulty
@onready var credits: Area2D = $credits
@onready var back: Area2D = $back

@onready var title: Label = $title
@onready var subtitle: Label = $subtitle
@onready var hint: Label = $hint

var current_button_id = 1
var credits_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_current_button().selected = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.has_node("Credits"):
		title.hide()
		subtitle.hide()
		hint.hide()
		difficulty.hide()
		credits.hide()
		back.hide()
		return
	else:
		credits_open = false
		title.visible = true
		subtitle.visible = true
		hint.visible = true
		difficulty.visible = true
		credits.visible = true
		back.visible = true
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
	if get_current_button() == credits:
		var node = load(get_current_button().scene.resource_path)
		add_child(node.instantiate())
		credits_open = true
	elif get_current_button().scene != null:
		if get_current_button() != back:
			get_tree().change_scene_to_packed(get_current_button().scene)
	elif get_current_button().type == 1:
		get_current_button().next()
	elif get_current_button() == back:
		queue_free()
	
func get_current_button() -> Area2D:
	if current_button_id == 1:
		return difficulty
	elif current_button_id == 2:
		return credits
	elif current_button_id == 3:
		return back
	return null
