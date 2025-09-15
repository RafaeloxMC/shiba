extends Area2D

@export var text = ""
@export var author = ""
@export var sprite_frames: SpriteFrames

func _ready() -> void:
	if GameManager.is_dialog_blacklisted(self):
		self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	GameManager.call_dialog(text, author, sprite_frames)
	GameManager.dialog_blacklist.push_back(self.transform)
	self.queue_free()
