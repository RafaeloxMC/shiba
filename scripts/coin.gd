extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Player picked up coin!")
	queue_free()
	# Play sfx
	# Play animation
	# Increase score
