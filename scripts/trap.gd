extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $Killzone/KillzoneCollisionShape
@onready var ramp_l: CollisionPolygon2D = $StaticBody2D/RampL
@onready var ramp_r: CollisionPolygon2D = $StaticBody2D/RampR

@export var upside_down: bool = false
@export var has_ramp_l: bool = true
@export var has_ramp_r: bool = true

var delay = 1

func _ready() -> void:
	if upside_down:
		self.rotation_degrees = 180
	if not has_ramp_l:
		ramp_l.queue_free()
	if not has_ramp_r:
		ramp_r.queue_free()
		
	if GameManager.difficulty == 3:
		delay = 0.25
	if GameManager.difficulty == 2:
		delay = 0.5
	if GameManager.difficulty == 1:
		delay = 0.75
	if GameManager.difficulty == 0:
		delay = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		await get_tree().create_timer(delay).timeout
		var anim = "attack"
		animated_sprite_2d.play(anim)
		collision_shape_2d.disabled = false
		await get_tree().create_timer(1).timeout
		animated_sprite_2d.play_backwards(anim)
		collision_shape_2d.disabled = true
