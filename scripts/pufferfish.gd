extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var speed: int = 20

func _ready() -> void:
	velocity.x = speed

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animated_sprite_2d.play("aggressive")
		await get_tree().create_timer(0.5).timeout
		animated_sprite_2d.play("aggressive_idle")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		animated_sprite_2d.play_backwards("aggressive")
		await get_tree().create_timer(0.5).timeout
		animated_sprite_2d.play("idle")

func _physics_process(_delta: float) -> void:
	if ray_cast_2d.is_colliding():
		scale.x = scale.x * -1
		velocity.x = -velocity.x
	print(str( self.transform.get_scale().x))
	move_and_slide()
