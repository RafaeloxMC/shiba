extends Control

@onready var title: Label = $Title
@onready var description: Label = $Description
@onready var item: AnimatedSprite2D = $Item
@onready var price: Label = $Price

@export var items: Array[ShopItem]

var curr = 0
var bought_items: Array[ShopItem]

@export var tilemap: TileMap

func update() -> void:
	if items[curr].name:
		title.text = items[curr].name
	else:
		description.text = "No name"
	if items[curr].description:
		description.text = items[curr].description
	else:
		description.text = "No description provided."
	if items[curr].price:
		price.text = str(items[curr].price)
	else:
		price.text = "Sold out!"
	if items[curr].icon:
		item.sprite_frames = items[curr].icon
		if item.sprite_frames.has_animation("default"):
			item.play("default")
	else:
		item.sprite_frames = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_right"):
		if curr + 1 >= items.size():
			curr = 0
		else:
			curr += 1
			
	if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left"):
		if curr - 1 < 0:
			curr = items.size() - 1
		else:
			curr -= 1
	update()
