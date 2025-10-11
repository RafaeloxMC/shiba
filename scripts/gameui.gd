extends Control

@onready var hearts_sprite: AnimatedSprite2D = $CanvasLayer/HeartsSprite
@onready var hearts_label: Label = $CanvasLayer/HeartsLabel

@onready var coins_sprite: AnimatedSprite2D = $CanvasLayer/CoinsSprite
@onready var coins_label: Label = $CanvasLayer/CoinsLabel
@onready var animation_player: AnimationPlayer = $CanvasLayer/ColorRect/AnimationPlayer

@onready var label: Label = $CanvasLayer/ColorRect/Label
@onready var fps: Label = $CanvasLayer/FPS

@onready var player: CharacterBody2D = $"../../.."

@onready var bubble: AnimatedSprite2D = $CanvasLayer/Bubbles/Bubble
@onready var bubble_2: AnimatedSprite2D = $CanvasLayer/Bubbles/Bubble2
@onready var bubble_3: AnimatedSprite2D = $CanvasLayer/Bubbles/Bubble3

var level_border_left: int = 0
var level_border_right: int = 100

@onready var shop_layer: CanvasLayer = $ShopLayer

func death():
	if GameManager.hat == "knight":
		return
	hearts_sprite.play("break")
	update_hearts()
	animation_player.play("fadeout")
	if GameManager.hearts <= 0:
		label.visible = true
	else:
		label.visible = false

func update_hearts():
	print("Updating hearts!")
	hearts_label.text = str(GameManager.hearts)

func coin_pickup():
	coins_sprite.sprite_frames.set_animation_speed("pickup", 20)
	coins_sprite.play("pickup")
	update_coins()

func update_coins():
	coins_label.text = str(GameManager.coins)
	
func eat_dog_food():
	hearts_sprite.play_backwards("break")
	update_hearts()
	
func tick_ui():
	update_coins()
	update_hearts()

func trigger_shop(value: bool) -> void:
	shop_layer.visible = value
	
func set_bubbles(amount: int) -> void:
	if amount == -1:
		bubble.visible = false
		bubble_2.visible = false
		bubble_3.visible = false
	else:
		bubble.visible = true
		bubble_2.visible = true
		bubble_3.visible = true
	if amount >= 1:
		bubble.play("default")
	else:
		if not bubble.animation == "pop":
			bubble.play("pop")
	if amount >= 2:
		bubble_2.play("default")
	else:
		if not bubble_2.animation == "pop":
			bubble_2.play("pop")
	if amount >= 3:
		bubble_3.play("default")
	else:
		if not bubble_3.animation == "pop":
			bubble_3.play("pop")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.death.connect(death)
	GameManager.coin_pickup.connect(coin_pickup)
	GameManager.tick_ui.connect(tick_ui)
	GameManager.eat_dog_food.connect(eat_dog_food)
	GameManager.trigger_shop.connect(trigger_shop)
	GameManager.set_underwater_bubbles.connect(set_bubbles)
	print("Loaded GameUI")
	update_hearts()
	update_coins()
	animation_player.play("fadein")
	GameManager.running = true
	label.visible = false
	level_border_left = player.level_border_left
	level_border_right = player.level_border_right
	print("Border left: " + str(level_border_left))
	print("Border right: " + str(level_border_right))

func _process(_delta: float) -> void:
	fps.visible = GameManager.show_fps
	if GameManager.show_fps:
		fps.text = str(Engine.get_frames_per_second()) + " FPS"
		
