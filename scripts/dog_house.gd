extends StaticBody2D

@export var entry: bool = false
@onready var label: Label = $Text/Label
var goal_coins: int = 0

func pickup() -> void:
	label.text = str(GameManager.coins_collected_in_current_scene) + "/" + str(goal_coins)

func _ready() -> void:
	GameManager.coin_pickup.connect(pickup)
	if get_tree().current_scene.has_node("Coins"):
		goal_coins = get_tree().current_scene.get_node("Coins").get_child_count()
	
	label.text = str(GameManager.coins_collected_in_current_scene) + "/" + str(goal_coins)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player" or entry == true:
		return
	SceneManager.next_level()
