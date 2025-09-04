extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var DEAD = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func die():
	DEAD = true
	animated_sprite_2d.play("death")
	velocity.y = -175 
	self.collision_shape_2d.queue_free()
	self.set_collision_mask_value(1, false)
	self.set_collision_mask_value(3, true)
	self.set_collision_layer_value(2, false)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if DEAD: 
		move_and_slide()
		return
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		animated_sprite_2d.animation = "walk"
		velocity.x = direction * SPEED
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false;
		else:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.animation = "idle"

	move_and_slide()
