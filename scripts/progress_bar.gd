extends Control

@onready var sprite_2d: Sprite2D = $Slider/ShibaHead
var level_border_left: int
var level_border_right: int

var borders: int = 115

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.position.x = -borders
	if self.get_parent().get_parent():
		level_border_left = self.get_parent().get_parent().level_border_left
		level_border_right = self.get_parent().get_parent().level_border_right
	else:
		print("Couldn't find parent control!")
	if level_border_left == null or level_border_right == null:
		print("Level borders not set!")
		self.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# yes this is incredibly ugly i might change this in the future but for now it works :D
	var player_pos = self.get_parent().get_parent().get_parent().get_parent().get_parent().position as Vector2
	
	if player_pos.x <= level_border_left:
		sprite_2d.position.x = -borders
	elif player_pos.x >= level_border_right:
		sprite_2d.position.x = borders
	else:
		sprite_2d.position.x = -borders + ((player_pos.x - level_border_left) / (level_border_right - level_border_left)) * (2 * borders)
