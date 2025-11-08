extends Control

@onready var difficulty: Area2D = $btn_difficulty
@onready var credits: Area2D = $btn_credits
@onready var back: Area2D = $btn_back
@onready var btn_shibadb_reset: Area2D = $btn_shibadb_reset
@onready var btn_language: Area2D = $btn_language

@onready var title: Label = $title
@onready var subtitle: Label = $subtitle
@onready var hint: Label = $hint

@onready var arrow_down: AnimatedSprite2D = $arrow_down
@onready var arrow_up: AnimatedSprite2D = $arrow_up

var current_button_id = 0
var credits_open = false
var first_visible_button = 0

var buttons: Array[Area2D]
var button_positions: Array[Vector2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons.clear()
	for child in self.get_children():
		if child.name.begins_with("btn_"):
			buttons.push_back(child)
	button_positions = [
		buttons[0].position,
		buttons[1].position if buttons.size() > 1 else buttons[0].position,
		buttons[2].position if buttons.size() > 2 else buttons[0].position
	]
	update_visible_buttons()
	get_current_button().selected = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.has_node("Credits"):
		title.hide()
		subtitle.hide()
		hint.hide()
		for button in buttons:
			button.hide()
		return
	else:
		credits_open = false
		title.visible = true
		subtitle.visible = true
		hint.visible = true
		update_visible_buttons()
	if Input.is_action_just_pressed("ui_up"):
		last()
	elif Input.is_action_just_pressed("ui_down"):
		next()
	elif Input.is_action_just_pressed("ui_accept"):
		submit()

func update_visible_buttons() -> void:
	for i in range(buttons.size()):
		if i >= first_visible_button and i < first_visible_button + 3:
			buttons[i].visible = true
			buttons[i].position = button_positions[i - first_visible_button]
		else:
			buttons[i].visible = false
	
	if first_visible_button == 0:
		arrow_up.visible = false
		arrow_down.visible = true
	elif first_visible_button + 3 >= buttons.size():
		arrow_up.visible = true
		arrow_down.visible = false
	else:
		arrow_up.visible = true
		arrow_down.visible = true
		

func next():
	get_current_button().selected = false
	current_button_id = (current_button_id + 1) % buttons.size()
	if current_button_id < first_visible_button or current_button_id >= first_visible_button + 3:
		first_visible_button = current_button_id - 2 if current_button_id >= 2 else 0
	update_visible_buttons()
	get_current_button().selected = true

func last():
	get_current_button().selected = false
	current_button_id = (current_button_id - 1 + buttons.size()) % buttons.size()
	if current_button_id < first_visible_button:
		first_visible_button = current_button_id
	elif current_button_id >= first_visible_button + 3:
		first_visible_button = current_button_id - 2
	update_visible_buttons()
	get_current_button().selected = true

func submit():
	var current_button = get_current_button()
	if current_button.scene != null:
		if current_button != back:
			get_tree().change_scene_to_packed(current_button.scene)
	elif current_button.type == 1:
		current_button.next()
	elif current_button == back:
		queue_free()
	if current_button == credits:
		arrow_up.hide()
		var node = load(current_button.scene.resource_path)
		add_child(node.instantiate())
		credits_open = true
		return
	if current_button == btn_language:
		if $btn_language/Label.text == "japanese":
			TranslationServer.set_locale("jp")
		else:
			TranslationServer.set_locale("en")
	if current_button == btn_shibadb_reset:
		ShibaDB.reset_progress("Untitled Save")
		GameManager.reset()

func get_current_button() -> Area2D:
	return buttons[current_button_id]
