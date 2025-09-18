extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

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
		ray_cast_2d.target_position = Vector2(-6, 0)
	else:
		ray_cast_2d.target_position = Vector2(6, 0)
	animation_player.play("spin")


func _on_timer_timeout() -> void:
	self.queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Squirrel"):
		var squirrel = body as CharacterBody2D
		squirrel.set_collision_mask_value(1, false)
		squirrel.dead = true
		squirrel.velocity.y = -175
		self.queue_free()
		await get_tree().create_timer(0.5).timeout
		squirrel.queue_free()
