extends TextureRect

@onready var text: Label = $Text
@onready var character: AnimatedSprite2D = $Character
@onready var character_name: Label = $CharacterName

var text_queue: String

var time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_dialog()
	GameManager.dialog.connect(show_dialog)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next"):
		hide_dialog()
	time += delta
	if time >= 0.025 and not text_queue.is_empty():
		text.text += text_queue.substr(0, 1)
		text_queue = text_queue.substr(1, text_queue.length())
		time = 0.00

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

func hide_dialog():
	self.hide()

func unhide_dialog():
	self.visible = true
