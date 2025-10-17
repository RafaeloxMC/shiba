extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var timeout: float = 2

func _ready():
	collision_shape_2d.set_deferred("disabled", false)
	animated_sprite_2d.set_deferred("visible", true)
	timeout = timeout / clamp(GameManager.difficulty, 1, 4)

func _on_body_exited(body: Node2D) -> void:
	if not body.name == "Player":
		return
	await get_tree().create_timer(timeout).timeout
	animated_sprite_2d.play_backwards("break")
	await get_tree().create_timer(0.75).timeout
	animated_sprite_2d.play("idle")
	collision_shape_2d.set_deferred("disabled", false)
	animated_sprite_2d.set_deferred("visible", true)

func _on_body_entered(body: Node2D) -> void:
	if not body.name == "Player":
		return
	await get_tree().create_timer(timeout).timeout
	animated_sprite_2d.play("break")
	await get_tree().create_timer(0.75).timeout
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.set_deferred("visible", false)
