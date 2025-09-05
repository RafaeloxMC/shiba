extends Control

@onready var hearts_sprite: AnimatedSprite2D = $CanvasLayer/HeartsSprite
@onready var hearts_label: Label = $CanvasLayer/HeartsLabel

@onready var coins_sprite: AnimatedSprite2D = $CanvasLayer/CoinsSprite
@onready var coins_label: Label = $CanvasLayer/CoinsLabel

func death():
	hearts_sprite.play("break")
	update_hearts()

func update_hearts():
	print("Updating hearts!")
	hearts_label.text = str(GameManager.hearts)

func coin_pickup():
	coins_sprite.play("pickup")
	update_coins()

func update_coins():
	coins_label.text = str(GameManager.coins)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.death.connect(death)
	GameManager.coin_pickup.connect(coin_pickup)
	print("Loaded GameUI")
	update_hearts()
	update_coins()
