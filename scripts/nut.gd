extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var launched = true
var velocity = Vector2(0, 0)

@export var maxVelocity = 200;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	launch()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if launched:
		position.x += velocity * delta

func launch():
	launched = true
	velocity = maxVelocity
	if animated_sprite_2d.flip_h == true:
		velocity = -maxVelocity
	animated_sprite_2d.play("shot")

func _on_timer_timeout() -> void:
	self.queue_free()
