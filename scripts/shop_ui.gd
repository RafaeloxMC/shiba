extends Control

@onready var title: Label = $Title
@onready var description: Label = $Description
@onready var item: AnimatedSprite2D = $Item
@onready var price: Label = $Price

@export var items: Array[ShopItem]

var curr = 0

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
	if items[curr].is_bought || not items[curr].price:
		price.text = "Sold out!"
		price.label_settings.font_color = Color("da3840ff")
	else:
		price.text = str(items[curr].price)
		if GameManager.coins < items[curr].price:
			price.label_settings.font_color = Color("da3840ff")
		else: 
			price.label_settings.font_color = Color(255, 255, 255, 255)
	if items[curr].icon:
		item.sprite_frames = items[curr].icon
		if item.sprite_frames.has_animation("default"):
			item.play("default")
	else:
		item.sprite_frames = null

func buy() -> void:
	if items[curr].is_bought || GameManager.coins < items[curr].price:
		return
	else:
		items[curr].is_bought = true
		print("Bought " + str(items[curr].name))
		if items[curr].name.to_lower() == "dog food":
			GameManager.eat_food(null, self.get_parent().get_parent().get_parent().get_parent().get_parent() as CharacterBody2D)
		if items[curr].name.to_lower().contains("hat") or items[curr].name.to_lower().contains("helmet"):
			GameManager.hat = items[curr].name.split(" ")[0].to_lower()
		GameManager.bought_items.push_back(items[curr].name.to_lower())
		GameManager.coins -= items[curr].price
		GameManager.call_tick_ui()
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.visible == false || self.get_parent().visible == false:
		return
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
			
	if Input.is_action_just_pressed("next"):
		buy()
		
	if Input.is_action_just_pressed("pause"):
		self.get_parent().visible = false
		GameManager.trigger_shop.emit(false)
		
	update()
