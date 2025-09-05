extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player": return
	GameManager.add_coin()
	animation_player.play("pickup")
