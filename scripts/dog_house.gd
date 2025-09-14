extends StaticBody2D

@onready var label: Label = $Text/Label
var goal_coins: int = 0

func pickup() -> void:
	label.text = str(GameManager.coins) + "/" + str(goal_coins)

func _ready() -> void:
	GameManager.coin_pickup.connect(pickup)
	goal_coins = get_tree().current_scene.get_node("Game/Coins").get_child_count()
	
	label.text = str(GameManager.coins) + "/" + str(goal_coins)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	print("Triggered!")
