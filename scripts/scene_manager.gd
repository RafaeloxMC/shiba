extends Node

@export var scenes: Dictionary[String, PackedScene]

var current_scene: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func call_scene(scene: String) -> void:
	current_scene = scene
	GameManager.coins_collected_in_current_scene = 0
	get_tree().call_deferred("change_scene_to_packed", scenes.get(scene))
	
func next_level():
	if current_scene.begins_with("level_"):
		var lvl_idx = int(current_scene.split("_")[1])
		if scenes.has("level_" + str(lvl_idx + 1)):
			call_scene("level_" + str(lvl_idx + 1))
		
func prev_level():
	if current_scene.begins_with("level_"):
		var lvl_idx = int(current_scene.split("_")[1])
		if scenes.has("level_" + str(lvl_idx - 1)):
			call_scene("level_" + str(lvl_idx - 1))
	
func reload_current() -> void:
	get_tree().reload_current_scene()
