extends CharacterBody2D

@export var player: CharacterBody2D
@export var SPEED: int = 25
@export var CHASE_SPEED: int = 75
@export var JUMP_VELOCITY: int = -400
@export var ACCELERATION: int = 20
@export var BOUNDS: float = 50
@export var PROJECTILE: PackedScene

@export var difficulty: int = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var facing: RayCast2D = $AnimatedSprite2D/facing
@onready var ground: RayCast2D = $AnimatedSprite2D/ground
@onready var timer: Timer = $Timer

var spotting_range = 200;

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

var shot_cooldown: float
var use_cooldown: float

var rand = RandomNumberGenerator.new()

enum States {
	IDLE,
	CHASE
}

var current_state: States = States.IDLE

func randomize_difficulty() -> void:
	difficulty = int(randf_range(2, 50))
	CHASE_SPEED = int(randf_range(50, 125))
	use_cooldown = randf_range(0.5, 3)
	animated_sprite_2d.play("evolve")

func _ready() -> void:
	right_bounds = self.position + Vector2(BOUNDS, 0)
	left_bounds = self.position + Vector2(-BOUNDS, 0)
	var diff = GameManager.difficulty
	if diff == 0: 
		difficulty = 50
		CHASE_SPEED = 75
		use_cooldown = 2.5
	elif diff == 1:
		difficulty = 30
		CHASE_SPEED = 75
		use_cooldown = 2.5
	elif diff == 2:
		difficulty = 15
		CHASE_SPEED = 100
		use_cooldown = 2.0
	elif diff == 3:
		difficulty = 5
		CHASE_SPEED = 100
		use_cooldown = 1.5
	elif diff == 4:
		randomize_difficulty()

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	search_player()

func search_player() -> void:
	if facing.is_colliding():
		var collider = facing.get_collider()
		if collider == player:
			chase_player()
			shoot_nut()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()
		

func chase_player() -> void:
	timer.stop()
	if current_state == States.IDLE:
		animated_sprite_2d.play("aggressive")
	current_state = States.CHASE
	
func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()
		
func handle_movement(_delta: float) -> void:
	if self.is_on_floor() and not ground.is_colliding():
		velocity.x = 0
		move_and_slide()
		return
	if current_state == States.IDLE:
		if rand.randf() > 0.994:
			animated_sprite_2d.play("idle")
		if direction != Vector2.ZERO:
			velocity.x = direction.x * SPEED
		else:
			velocity.x = 0
	else:
		if direction != Vector2.ZERO:
			velocity.x = direction.x * CHASE_SPEED
		else:
			velocity.x = 0
		
	move_and_slide()
	
func change_direction() -> void:
	if is_on_floor() and not ground.is_colliding():
		if current_state == States.CHASE:
			direction = Vector2(0, 0)
			var player_dir_x = sign(player.position.x - self.position.x)
			if player_dir_x == 1 or player_dir_x == 0:
				animated_sprite_2d.flip_h = false
				facing.target_position = Vector2(spotting_range, 0)
				ground.target_position = Vector2(15, 15)
			else:
				animated_sprite_2d.flip_h = true
				facing.target_position = Vector2(-spotting_range, 0)
				ground.target_position = Vector2(-15, 15)
			return
	if current_state == States.IDLE:
		if not animated_sprite_2d.flip_h:
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
				ground.target_position = Vector2(15, 15)
			else:
				animated_sprite_2d.flip_h = true
				facing.target_position = Vector2(-spotting_range, 0)
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
				ground.target_position = Vector2(-15, 15)
			else:
				animated_sprite_2d.flip_h = false
				facing.target_position = Vector2(spotting_range, 0)	
	else:
		var xdiff = player.position.x - self.position.x
		var ydiff = player.position.y - self.position.y
		if (xdiff <= difficulty && xdiff >= -difficulty) || (ydiff <= 0.5 && ydiff >= -0.5):
			return
		direction = (player.position - self.position).normalized()
		direction = Vector2(sign(direction.x), 0)
		if direction.x == 1:
			animated_sprite_2d.flip_h = false
			facing.target_position = Vector2(spotting_range, 0)
			ground.target_position = Vector2(15, 15)
		else:
			animated_sprite_2d.flip_h = true
			facing.target_position = Vector2(-spotting_range, 0)
			ground.target_position = Vector2(-15, 15)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_timer_timeout() -> void:
	current_state = States.IDLE
	
func shoot_nut():
	if shot_cooldown + use_cooldown < Time.get_unix_time_from_system():
		animated_sprite_2d.play("shoot")
		shot_cooldown = Time.get_unix_time_from_system()
		var nut = PROJECTILE.instantiate()
		await get_tree().create_timer(0.5).timeout
		nut.transform = self.global_transform
		var nut_sprite = nut.get_child(0) as AnimatedSprite2D
		if nut_sprite != null:
			nut_sprite.flip_h = animated_sprite_2d.flip_h 
			self.add_sibling(nut)
			if GameManager.difficulty == 4:
				randomize_difficulty()
