extends ParallaxLayer

@export var SPEED = 20
@export var snow = false

func _ready() -> void:
	if not snow:
		self.visible = false

func _process(delta) -> void:
	self.motion_offset.y += SPEED * delta
	self.motion_offset.x -= SPEED * delta
