extends TextureRect

@onready var text: Label = $Text
@onready var character: AnimatedSprite2D = $Character
@onready var character_name: Label = $CharacterName

var text_queue: String

var time: float = 0

var current_char: Node
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

func show_dialog(content: String, author: String, animation: SpriteFrames, char_size: float = 1, y_offset: float = 0):
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
		print("Animation provided!")
		if current_char != null:
			current_char.queue_free()
		current_char = null
		current_char = character.duplicate()
		character.hide()
		current_char.visible = true
		character.add_sibling(current_char)
		current_char.transform = current_char.transform.scaled(Vector2(char_size, char_size))
		current_char.position.x = 118.5
		current_char.position.y = 114 + y_offset
		current_char.sprite_frames = animation
		current_char.play("idle")
	else:
		print("No animation provided!")
	unhide_dialog()

func hide_dialog():
	self.hide()
	if current_char:
		current_char.queue_free()
		current_char = null
		print("Queue free called")

func unhide_dialog():
	self.visible = true
