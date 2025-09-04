extends CharacterBody2D

@export var player: CharacterBody2D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 100
@export var JUMP_VELOCITY: int = -400
@export var ACCELERATION: int = 50
@export var BOUNDS: float = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var facing: RayCast2D = $AnimatedSprite2D/facing
@onready var ground: RayCast2D = $AnimatedSprite2D/ground
@onready var timer: Timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

var rand = RandomNumberGenerator.new()

enum States {
	IDLE,
	CHASE
}

var current_state: States = States.IDLE

func _ready():
	right_bounds = self.position + Vector2(BOUNDS, 0)
	left_bounds = self.position + Vector2(-BOUNDS, 0)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	search_player()

func search_player():
	if facing.is_colliding():
		var collider = facing.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()
		
func chase_player() -> void:
	timer.stop()
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
		if not animated_sprite_2d.flip_h:
			animated_sprite_2d.flip_h = true
			direction = Vector2(-1, 0)
			facing.target_position = Vector2(-BOUNDS, 0)
			ground.target_position = Vector2(-15, 15)
		else:
			animated_sprite_2d.flip_h = false
			direction = Vector2(1, 0)
			facing.target_position = Vector2(BOUNDS, 0)
			ground.target_position = Vector2(15, 15)
		return
	
	if current_state == States.IDLE:
		if not animated_sprite_2d.flip_h:
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				animated_sprite_2d.flip_h = true
				facing.target_position = Vector2(-BOUNDS, 0)
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				animated_sprite_2d.flip_h = false
				facing.target_position = Vector2(BOUNDS, 0)	
	else:
		if (player.position.x - self.position.x) <= 0.5:
			return
		direction = (player.position - self.position).normalized()
		direction = Vector2(sign(direction.x),0)
		if direction.x == 1:
			animated_sprite_2d.flip_h = false
			facing.target_position = Vector2(BOUNDS, 0)
		else:
			animated_sprite_2d.flip_h = true
			facing.target_position = Vector2(-BOUNDS, 0)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_timer_timeout() -> void:
	current_state = States.IDLE
