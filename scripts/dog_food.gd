extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if GameManager.is_food_blacklisted(self):
		self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player": return
	GameManager.eat_food(self, body as CharacterBody2D)
	animation_player.play("pickup")
