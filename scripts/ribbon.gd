extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.ribbon_collected = true
		animation_player.play("pickup")
