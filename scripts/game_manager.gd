extends Node
## 0 = Easy
## 1 = Medium
## 2 = Hard
## 3 = Give Up
## 4 = Random
var difficulty = 0
var max_hearts;

var score = 0
var coins = 0
var hearts = 3

var coins_collected_in_current_scene = 0

var running = false
var first_play = true

var should_show_intro = true

var show_fps = false

var coin_blacklist: Array[Transform2D] = []
var food_blacklist: Array[Transform2D] = []

var dialog_blacklist: Array[Transform2D] = []

var bought_items: Array[String]

signal death()
signal coin_pickup()
signal tick_ui()
signal eat_dog_food()

@warning_ignore("unused_signal")
signal set_underwater_bubbles(amount: int)

signal trigger_shop(value: bool)
var is_showing_shop: bool = false
signal dialog(content: String, author: String, animation: SpriteFrames, char_size: float, y_offset: float)

@warning_ignore("unused_signal")
signal absorb()

var bird: PackedScene
var bat: PackedScene
var bats: bool = false
var flying_animals: bool = true

var hat: String = ""

var ribbon_collected = false

func set_show_shop(value: bool) -> void:
	is_showing_shop = value
	print("Showing shop: " + str(value))

func _on_save_loaded(saveData):
	print("GameManager received save!")
	print("Received data: " + str(saveData))
	if saveData.has("coins") and saveData.has("hearts") and saveData.has("level"):
		first_play = false
	if saveData.has("coins"):
		coins = int(saveData.coins)
	if saveData.has("hearts"):
		hearts = int(saveData.hearts)
	if saveData.has("level"):
		SceneManager.current_level = saveData.level
	if saveData.has("hat"):
		hat = saveData.hat
	if saveData.has("bought_items"):
		bought_items = saveData.bought_itmes
	
	

func _ready() -> void:
	bird = preload("res://scenes/bird.tscn")
	bat = preload("res://scenes/bat.tscn")
	trigger_shop.connect(set_show_shop)
	ShibaDB.save_loaded.connect(_on_save_loaded)
	await ShibaDB.init_shibadb("68d97ac7241f0847810f436d")
	ShibaDB.load_progress()

func _process(_delta: float) -> void:
	max_hearts = hearts_per_diff()
	
	if hearts > max_hearts:
		hearts = max_hearts

func add_coin(coin: Area2D, player: CharacterBody2D):
	if coin_blacklist.size() == 0:
		call_dialog("I picked up my first coin. I could use these to buy Shibina a gift to win her heart!", "Shiba", player.get_node("AnimatedSprite2D").sprite_frames)
	coin_blacklist.push_back(coin.transform)
	coins += 1
	coins_collected_in_current_scene += 1
	print("Coin picked up: ", coins)
	coin_pickup.emit()
	
func is_coin_blacklisted(coin: Area2D) -> bool:
	if coin_blacklist.has(coin.transform):
		return true
	return false
	
func is_food_blacklisted(food: Area2D) -> bool:
	if food_blacklist.has(food.transform):
		return true
	return false
	
func is_dialog_blacklisted(dlg: Area2D) -> bool:
	if dialog_blacklist.has(dlg.transform):
		return true
	return false
	
func eat_food(food: Area2D, player: CharacterBody2D):
	var diff_warning = ""
	if difficulty == 3: 
		diff_warning = "\nSadly I can't restore health on this difficulty!"
	if hearts < max_hearts: 
		hearts += 1
	if food != null:
		if food_blacklist.size() == 0:
			call_dialog("*nom nom nom*\nThis is very delicious! And I already feel so much better! I need more of that!" + diff_warning, "Shiba", player.get_node("AnimatedSprite2D").sprite_frames)
		food_blacklist.push_back(food.transform)
	eat_dog_food.emit()
	
func remove_heart():
	print("Removed heart!")
	hearts -= 1
	death.emit()

func reset():
	score = 0
	coins = 0
	hearts = hearts_per_diff()
	coin_blacklist.clear()
	food_blacklist.clear()
	dialog_blacklist.clear()
	should_show_intro = true
	bought_items.clear()
	hat = ""
	SceneManager.current_level = "level_1"
	SoundManager.call_sound("Tiger Tracks - Lexica")
	
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

func call_dialog(content: String, author: String, animation: SpriteFrames, char_size: float = 1, y_offset: float = 0):
	dialog.emit(content, author, animation, char_size, y_offset)
	
func spawn_bird(pos: Vector2):
	if not flying_animals:
		return
	if get_tree().current_scene.has_node("Birds"):
		var bird_node
		if bats == true:
			bird_node = bat.instantiate()
		else:
			bird_node = bird.instantiate()
		bird_node.position = pos
		get_tree().current_scene.get_node("Birds").add_child(bird_node)
	else:
		var node = Node.new()
		node.name = "Birds"
		var bird_node
		if bats == true:
			bird_node = bat.instantiate()
		else:
			bird_node = bird.instantiate()
		bird_node.position = pos
		get_tree().current_scene.add_child(node)
		get_tree().current_scene.get_node("Birds").add_child(bird_node)
