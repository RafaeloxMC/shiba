extends CharacterBody2D
@export var player: CharacterBody2D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 125
@export var JUMP_VELOCITY: int = -200
@export var CHASE_JUMP_VELOCITY: int = -250
@export var ACCELERATION: int = 20
@export var BOUNDS: float = 50
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var facing: RayCast2D = $AnimatedSprite2D/facing
@onready var ground: RayCast2D = $AnimatedSprite2D/ground
@onready var timer: Timer = $Timer
@onready var jump_timer: Timer = $JumpTimer
@onready var killzone: Area2D = $Killzone
var spotting_range = 200
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
var dead = false

func randomize_difficulty() -> void:
	CHASE_SPEED = int(randf_range(50, 125))
	use_cooldown = randf_range(0.5, 3)
	animated_sprite_2d.play("evolve")

func _ready() -> void:
	right_bounds = self.position + Vector2(BOUNDS, 0)
	left_bounds = self.position + Vector2(-BOUNDS, 0)
	var diff = GameManager.difficulty
	if diff == 0:
		CHASE_SPEED = 75
		use_cooldown = 0.75
	elif diff == 1:
		CHASE_SPEED = 75
		use_cooldown = 0.75
	elif diff == 2:
		CHASE_SPEED = 100
		use_cooldown = 0.5
	elif diff == 3:
		CHASE_SPEED = 100
		use_cooldown = 0.25
	elif diff == 4:
		randomize_difficulty()
	
	if not has_node("JumpTimer"):
		var new_timer = Timer.new()
		new_timer.name = "JumpTimer"
		add_child(new_timer)
		jump_timer = new_timer
	
	jump_timer.wait_time = 1.0
	jump_timer.one_shot = false
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_timer.start()

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	if dead == true:
		move_and_slide()
		return
	handle_movement(delta)
	change_direction()
	search_player()

func search_player() -> void:
	if facing.is_colliding():
		var collider = facing.get_collider()
		if collider == player:
			chase_player()
			return
	
	if current_state == States.CHASE:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > 300:
			stop_chase()

func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE
	jump_timer.wait_time = use_cooldown

func stop_chase() -> void:
	if not timer.is_stopped():
		return
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout, CONNECT_ONE_SHOT)

func handle_movement(_delta: float) -> void:
	if is_on_floor() and not ground.is_colliding():
		velocity.x = 0
		move_and_slide()
		return
	
	if current_state == States.CHASE:
		var xdiff = player.position.x - self.position.x
		velocity.x = sign(xdiff) * CHASE_SPEED
	else:
		velocity.x = direction.x * SPEED
	move_and_slide()

func _on_jump_timer_timeout() -> void:
	if is_on_floor() and not dead:
		animated_sprite_2d.play("jump")
		await get_tree().create_timer(0.25).timeout
		if current_state == States.IDLE:
			velocity.y = JUMP_VELOCITY
		elif current_state == States.CHASE:
			velocity.y = CHASE_JUMP_VELOCITY
			var xdiff = player.position.x - self.position.x
			velocity.x = sign(xdiff) * CHASE_SPEED
		
func change_direction() -> void:
	if is_on_floor() and not ground.is_colliding():
		direction = Vector2(0, 0)
		var player_dir_x = sign(player.position.x - self.position.x)
		if player_dir_x == 1 or player_dir_x == 0:
			animated_sprite_2d.flip_h = false
			facing.target_position = Vector2(spotting_range, 0)
			ground.target_position = Vector2(50, 50)
			killzone.position.x = 0
		else:
			animated_sprite_2d.flip_h = true
			facing.target_position = Vector2(-spotting_range, 0)
			ground.target_position = Vector2(-50, 50)
			killzone.position.x = -14
		return
	
	if current_state == States.IDLE:
		if not animated_sprite_2d.flip_h:
			if self.position.x >= right_bounds.x:
				direction = Vector2(-1, 0)
				animated_sprite_2d.flip_h = true
				facing.target_position = Vector2(-spotting_range, 0)
				ground.target_position = Vector2(-50, 50)
				killzone.position.x = -14
			else:
				direction = Vector2(1, 0)
		else:
			if self.position.x <= left_bounds.x:
				direction = Vector2(1, 0)
				animated_sprite_2d.flip_h = false
				facing.target_position = Vector2(spotting_range, 0)
				ground.target_position = Vector2(50, 50)
				killzone.position.x = 0
			else:
				direction = Vector2(-1, 0)
	else:
		direction = (player.position - self.position).normalized()
		direction = Vector2(sign(direction.x), 0)
		if direction.x == 1:
			animated_sprite_2d.flip_h = false
			facing.target_position = Vector2(spotting_range, 0)
			ground.target_position = Vector2(50, 50)
			killzone.position.x = 0
		else:
			animated_sprite_2d.flip_h = true
			facing.target_position = Vector2(-spotting_range, 0)
			ground.target_position = Vector2(-50, 50)
			killzone.position.x = -14

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_timer_timeout() -> void:
	current_state = States.IDLE
	jump_timer.wait_time = 1.0
	animated_sprite_2d.play("idle")
