extends CharacterBody2D

const SPEED = 130.0
const ACCELERATION = 1000.0
const JUMP_VELOCITY = -300.0
var DEAD = false
var jumping = false
var is_falling = false
var is_swimming = false
var water_multiplier = 1
var air_left: float = 15

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var fall_sfx: AudioStreamPlayer2D = $FallSFX
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var splash_sfx: AudioStreamPlayer2D = $SplashSFX
@onready var break_sfx: AudioStreamPlayer2D = $BreakSFX
@onready var timer: Timer = $Timer

@export var projectile: PackedScene = load("res://scenes/bone.tscn")
@export var level_border_left: int = 0
@export var level_border_right: int = 100
@export var bats = false
@export var flying_animals = true

var hat = ""

func die():
	if hat == "_knight":
		GameManager.hat = ""
		return
	DEAD = true
	animated_sprite_2d.play("death")
	death_sfx.play()
	velocity.y = -175 
	self.set_collision_mask_value(1, false)
	self.set_collision_layer_value(2, false)
	self.set_collision_mask_value(3, false)

func absorb():
	break_sfx.play()
	
func _ready():
	self.set_collision_mask_value(1, true)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(3, true)
	GameManager.death.connect(die)
	GameManager.absorb.connect(absorb)
	GameManager.bats = bats
	GameManager.flying_animals = flying_animals
	if GameManager.should_show_intro == true:
		GameManager.call_dialog("Oh no! The robo dog kidnapped Shibina!\nI need to rescue her before something happens!", "Shiba", animated_sprite_2d.sprite_frames)
		GameManager.should_show_intro = false
	
	if self.get_parent().has_node("Swim Triggers"):
		var swim_triggers = self.get_parent().get_node("Swim Triggers").get_children()
		for trigger in swim_triggers:
			trigger.body_entered.connect(_on_swim_trigger_entered)
			trigger.body_exited.connect(_on_swim_trigger_exited)

func _on_swim_trigger_entered(body: Node) -> void:
	if body == self:
		is_swimming = true
		splash_sfx.play()
		water_multiplier = 0.5
		

func _on_swim_trigger_exited(body: Node) -> void:
	if body == self:
		is_swimming = false
		water_multiplier = 1

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") && GameManager.is_showing_shop == false:
		Engine.time_scale = 1
		SceneManager.call_scene("main_menu")
	var rand = floor(randf_range(0, 10000))
	if rand >= 9997:
		var bird_pos = self.position
		bird_pos.y = self.position.y - floor(randf_range(50, 125))
		bird_pos.x = self.position.x - 200
		GameManager.spawn_bird(bird_pos)
		
	if GameManager.hat != "":
		hat = "_" + GameManager.hat
	else:
		hat = ""

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("show_fps"):
		GameManager.show_fps = !GameManager.show_fps
	
	if not is_on_floor():
		if not is_swimming:
			if hat == "_propeller":
				velocity += get_gravity() * 0.7 * delta
			else:
				velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * water_multiplier
		is_falling = true
	else:
		if is_falling == true && jumping == false:
			fall_sfx.play()
		jumping = false
		is_falling = false
	
	if DEAD: 
		move_and_slide()
		return
	
	if GameManager.is_showing_shop:
		return
		
	if not is_swimming:
		GameManager.set_underwater_bubbles.emit(-1)
		air_left = 15
	else:
		air_left = air_left - ( delta )
		GameManager.set_underwater_bubbles.emit(roundi(air_left / 5.0))
	
	if air_left <= 0:
		GameManager.death.emit()
		
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			if not is_swimming:
				velocity.y = JUMP_VELOCITY
				jump_sfx.play()
				jumping = true
			else:
				velocity.y = JUMP_VELOCITY / 2.5
		else:
			if is_swimming:
				velocity.y = JUMP_VELOCITY / 2.5
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		if is_swimming:
			animated_sprite_2d.play("swim" + hat)
		else:
			animated_sprite_2d.play("walk" + hat)
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("idle" + hat)
		
	if Input.is_action_just_pressed("attack") && timer.time_left <= 0:
		if GameManager.bought_items.has("bone"):
			var proj = projectile.instantiate()
			proj.position = self.global_position
			proj.position.y -= 10
			proj.get_node("AnimatedSprite2D").flip_h = animated_sprite_2d.flip_h
			self.add_sibling(proj)
			timer.start()

	move_and_slide()
