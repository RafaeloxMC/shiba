extends CharacterBody2D


const SPEED = 130.0
const ACCELERATION = 1000.0
const JUMP_VELOCITY = -300.0
var DEAD = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func die():
	DEAD = true
	animated_sprite_2d.play("death")
	velocity.y = -175 
	self.collision_shape_2d.queue_free()
	
func _ready():
	GameManager.death.connect(die)
	if GameManager.should_show_intro == true:
		GameManager.call_dialog("Oh no! The robo dog kidnapped Shibina!\nI need to rescue her before something happens!", "Shiba", animated_sprite_2d.sprite_frames)
		GameManager.should_show_intro = false
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if DEAD: 
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		audio_stream_player_2d.play()

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		animated_sprite_2d.play("walk")
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false;
		else:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("idle")

	move_and_slide()
