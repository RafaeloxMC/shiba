extends AnimatedSprite2D

@export var SPEED = 100
func _process(delta: float) -> void:
	self.position.x += SPEED * delta
	pass


func _on_timer_timeout() -> void:
	self.queue_free()
