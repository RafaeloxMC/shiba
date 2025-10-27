extends CharacterBody2D

const SPEED = 130.0
const ACCELERATION = 1000.0
const JUMP_VELOCITY = -300.0
var DEAD = false
var jumping = false
var is_falling = false
var is_swimming = false
var is_slippery = false
var water_multiplier = 1
var air_left: float = 30

var coyote_time: float = 0.25
var coyote_last_on_ground: float = 0.0
var coyote_already_jumped: bool = false

@export var movement_disabled = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var fall_sfx: AudioStreamPlayer2D = $FallSFX
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var splash_sfx: AudioStreamPlayer2D = $SplashSFX
@onready var break_sfx: AudioStreamPlayer2D = $BreakSFX
@onready var timer: Timer = $Timer
@onready var drown_timer: Timer = $DrownTimer

@export var projectile: PackedScene = load("res://scenes/bone.tscn")
@export var level_border_left: int = 0
@export var level_border_right: int = 100
@export var bats = false
@export var flying_animals = true
@export var snow = false
@export var second_player = false

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
			
	if self.get_parent().has_node("Slippery Triggers"):
		var slippery_triggers = self.get_parent().get_node("Slippery Triggers").get_children()
		for trigger in slippery_triggers:
			trigger.body_entered.connect(_on_slippery_trigger_entered)
			trigger.body_exited.connect(_on_slippery_trigger_exited)

func _on_swim_trigger_entered(body: Node) -> void:
	if body == self:
		is_swimming = true
		splash_sfx.play()
		water_multiplier = 0.05
		collision_shape_2d.position.y += 2
		collision_shape_2d.rotate(deg_to_rad(90))

func _on_swim_trigger_exited(body: Node) -> void:
	if body == self:
		is_swimming = false
		water_multiplier = 1
		collision_shape_2d.position.y -= 2
		collision_shape_2d.rotate(deg_to_rad(-90))

func _on_slippery_trigger_entered(body: Node) -> void:
	if body == self:
		is_slippery = true

func _on_slippery_trigger_exited(body: Node) -> void:
	if body == self:
		is_slippery = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") && GameManager.is_showing_shop == false:
		Engine.time_scale = 1
		SceneManager.call_scene("main_menu")
	var rand = floor(randf_range(0, 10000))
	if rand >= 9997:
		var bird_pos = self.position
		bird_pos.y = self.position.y - floor(randf_range(50, 125))
		bird_pos.x = self.position.x - 200
		GameManager.snow = snow
		GameManager.spawn_bird(bird_pos)
		
	if GameManager.hat != "":
		hat = "_" + GameManager.hat
	else:
		hat = ""

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("show_fps"):
		GameManager.show_fps = !GameManager.show_fps
	
	if not is_on_floor():
		coyote_last_on_ground += delta
		if not is_swimming:
			if hat == "_propeller":
				velocity += get_gravity() * 0.7 * delta
			else:
				velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * water_multiplier
		is_falling = true
	else:
		coyote_last_on_ground = 0
		coyote_already_jumped = false
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
		air_left = 30
	else:
		air_left = air_left - ( delta )
		GameManager.set_underwater_bubbles.emit(roundi(air_left / 5.0))
	
	if air_left <= 0:
		Engine.time_scale = 0.5
		if GameManager.hearts <= 0:
			drown_timer.start(2)
		else:
			drown_timer.start(1)
		GameManager.remove_heart()
		
	if ((Input.is_action_pressed("jump") && !second_player) || (Input.is_action_pressed("jump_2nd") && second_player)) && !movement_disabled:
		if is_on_floor() || (coyote_last_on_ground <= coyote_time and !coyote_already_jumped):
			if not is_swimming:
				velocity.y = JUMP_VELOCITY
				jump_sfx.play()
				jumping = true
				coyote_already_jumped = true
			else:
				velocity.y = JUMP_VELOCITY / 6
		else:
			if is_swimming:
				velocity.y = JUMP_VELOCITY / 6
		
	var direction: float
	if second_player == true:
		direction = Input.get_axis("move_left_2nd", "move_right_2nd")
	else:
		direction = Input.get_axis("move_left", "move_right")
	if direction && !movement_disabled:
		if is_swimming:
			animated_sprite_2d.play("swim" + hat)
		else:
			animated_sprite_2d.play("walk" + hat)
		if is_slippery:
			velocity.x = move_toward(velocity.x, direction * SPEED * 1.2, ACCELERATION * delta * 0.3)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	else:
		if is_slippery:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION * 1.2 * delta * 0.005)
		else: 
			velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("idle" + hat)
		
	if Input.is_action_just_pressed("attack") && timer.time_left <= 0 && !movement_disabled:
		if GameManager.bought_items.has("bone"):
			var proj = projectile.instantiate()
			proj.position = self.global_position
			proj.position.y -= 10
			proj.get_node("AnimatedSprite2D").flip_h = animated_sprite_2d.flip_h
			self.add_sibling(proj)
			timer.start()

	move_and_slide()

func _on_drown_timer_timeout() -> void:
	Engine.time_scale = 1
	print("Timed out!")
	if GameManager.hearts <= 0:
		SceneManager.call_scene("main_menu")
		return
	SceneManager.reload_current()
