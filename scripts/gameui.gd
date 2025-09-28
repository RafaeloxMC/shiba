extends Control

@onready var hearts_sprite: AnimatedSprite2D = $CanvasLayer/HeartsSprite
@onready var hearts_label: Label = $CanvasLayer/HeartsLabel

@onready var coins_sprite: AnimatedSprite2D = $CanvasLayer/CoinsSprite
@onready var coins_label: Label = $CanvasLayer/CoinsLabel
@onready var animation_player: AnimationPlayer = $CanvasLayer/ColorRect/AnimationPlayer

@onready var label: Label = $CanvasLayer/ColorRect/Label
@onready var fps: Label = $CanvasLayer/FPS

@onready var player: CharacterBody2D = $"../../.."

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
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.death.connect(death)
	GameManager.coin_pickup.connect(coin_pickup)
	GameManager.tick_ui.connect(tick_ui)
	GameManager.eat_dog_food.connect(eat_dog_food)
	GameManager.trigger_shop.connect(trigger_shop)
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
		
