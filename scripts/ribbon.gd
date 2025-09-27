extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.ribbon_collected = true
		pickup_sound.play()
		self.queue_free()
