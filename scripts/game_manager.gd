extends Node
## 0 = Easy
## 1 = Medium
## 2 = Hard
## 3 = Give Up
var difficulty = 0
var max_hearts;

var score = 0
var coins = 0
var hearts = 3

var running = false

var coin_blacklist: Array[Transform2D] = []

signal death()
signal coin_pickup()
signal tick_ui()

signal dialog(content: String, author: String, animation: SpriteFrames)

func _process(_delta: float) -> void:
	max_hearts = hearts_per_diff()
	
	if hearts > max_hearts:
		hearts = max_hearts

func add_coin(coin: Area2D, player: CharacterBody2D):
	if coin_blacklist.size() == 0:
		call_dialog("I picked up my first coin. I could use these to buy Shibina a gift to win her heart!", "Shiba", player.get_node("AnimatedSprite2D").sprite_frames)
	coin_blacklist.push_back(coin.transform)
	coins += 1
	print("Coin picked up: ", coins)
	coin_pickup.emit()
	
func is_coin_blacklisted(coin: Area2D) -> bool:
	if coin_blacklist.has(coin.transform):
		return true
	return false
	
func remove_heart():
	print("Removed heart!")
	hearts -= 1
	death.emit()

func reset():
	score = 0
	coins = 0
	hearts = hearts_per_diff()
	coin_blacklist.clear()
	
func call_tick_ui() -> void:
	tick_ui.emit()

func hearts_per_diff() -> int:
	if difficulty == 0 || difficulty == 1:
		return 3
	elif difficulty == 2:
		return 2
	elif difficulty == 3:
		return 1
	return 3

func call_dialog(content: String, author: String, animation: SpriteFrames):
	dialog.emit(content, author, animation)
