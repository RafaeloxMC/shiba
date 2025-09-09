extends TextureRect

@onready var text: Label = $Text
@onready var character: AnimatedSprite2D = $Character
@onready var character_name: Label = $CharacterName
@onready var timer: Timer = $Timer

var text_queue: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_dialog()
	GameManager.dialog.connect(show_dialog)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		hide_dialog()

func show_dialog(content: String, author: String, animation: SpriteFrames):
	print(author + " said: " + content)
	text.text = ""
	if content != null:
		text_queue = content
	else:
		text_queue = "I have nothing else to say."
	if author != null:
		character_name.text = author
	else:
		character_name.text = "Anonymous"
	if animation != null:
		character.sprite_frames = animation
		character.play("idle")
	unhide_dialog()
	timer.start()

func hide_dialog():
	self.hide()

func unhide_dialog():
	self.visible = true
	
func _on_timer_timeout() -> void:
	text.text += text_queue.substr(0, 1)
	text_queue = text_queue.substr(1, text_queue.length())
	if not text_queue.is_empty():
		timer.start()
