extends ParallaxLayer

@export var SPEED = 10

func _process(delta) -> void:
	self.motion_offset.x -= SPEED * delta
