extends CharacterBody2D


const SPEED = 130.0
const ACCELERATION = 1000.0
const JUMP_VELOCITY = -300.0
var DEAD = false
var jumping = false
var is_falling = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var fall_sfx: AudioStreamPlayer2D = $FallSFX
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var timer: Timer = $Timer

@export var projectile: PackedScene = load("res://scenes/bone.tscn")

func die():
	DEAD = true
	animated_sprite_2d.play("death")
	death_sfx.play()
	velocity.y = -175 
	self.set_collision_mask_value(1, false)
	self.set_collision_layer_value(2, false)
	
func _ready():
	self.set_collision_mask_value(1, true)
	self.set_collision_layer_value(2, true)
	GameManager.death.connect(die)
	if GameManager.should_show_intro == true:
		GameManager.call_dialog("Oh no! The robo dog kidnapped Shibina!\nI need to rescue her before something happens!", "Shiba", animated_sprite_2d.sprite_frames)
		GameManager.should_show_intro = false
	
func _process(_delta: float) -> void:
	var rand = floor(randf_range(0, 10000))
	if rand >= 9997:
		var bird_pos = self.position
		bird_pos.y = self.position.y - floor(randf_range(50, 125))
		bird_pos.x = self.position.x - 200
		GameManager.spawn_bird(bird_pos)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		Engine.time_scale = 1
		SceneManager.call_scene("main_menu")
	
	if Input.is_action_just_pressed("show_fps"):
		GameManager.show_fps = !GameManager.show_fps
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_falling = true
	else:
		if is_falling == true && jumping == false:
			fall_sfx.play()
		jumping = false
		is_falling = false
	
	if DEAD: 
		move_and_slide()
		return
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		jumping = true

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
		
	if Input.is_action_just_pressed("attack") && timer.time_left <= 0:
		var proj = projectile.instantiate()
		proj.position = self.global_position
		proj.position.y -= 10
		proj.get_node("AnimatedSprite2D").flip_h = animated_sprite_2d.flip_h
		self.add_sibling(proj)
		timer.start()

	move_and_slide()
