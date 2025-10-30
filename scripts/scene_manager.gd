extends Node

@export var scenes: Dictionary[String, PackedScene]

var current_scene: String = ""
var current_level: String = "level_1"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func call_scene(scene: String) -> void:
	current_scene = scene
	if current_scene.begins_with("level_"):
		if scene == "level_3" && current_level == "level_2":
			SoundManager.call_sound_with_fade("You Know You Know - Forever Sunset")
		else:
			if scene == "level_14" && current_level == "level_13":
				SoundManager.call_sound_with_fade("Racing Heartbeats - The Big Let Down")
		current_level = current_scene
	print("Current scene now is: " + scene)
	GameManager.coins_collected_in_current_scene = 0
	get_tree().call_deferred("change_scene_to_packed", scenes.get(scene))
	
func next_level():
	if current_level.begins_with("level_"):
		var lvl_idx = int(current_level.split("_")[1])
		if scenes.has("level_" + str(lvl_idx + 1)):
			ShibaDB.save_progress({ "coins": GameManager.coins, "hearts": GameManager.hearts, "level": "level_" + str(lvl_idx + 1), "bought_items": GameManager.bought_items, "hat": GameManager.hat })
			call_scene("level_" + str(lvl_idx + 1))
		
func prev_level():
	if current_level.begins_with("level_"):
		var lvl_idx = int(current_level.split("_")[1])
		if scenes.has("level_" + str(lvl_idx - 1)):
			call_scene("level_" + str(lvl_idx - 1))
	
func reload_current_level():
	if current_level.begins_with("level_"):
		var lvl_idx = int(current_level.split("_")[1])
		if scenes.has("level_" + str(lvl_idx)):
			call_scene("level_" + str(lvl_idx))
	else:
		current_level = "level_1"
		reload_current_level()
	
func reload_current() -> void:
	call_deferred("rld")

func rld():
	if get_tree().current_scene == null:
		print("Warning: Cannot reload_current_scene — no scene is loaded yet.")
		return
	get_tree().reload_current_scene()
	
func get_random_level() -> PackedScene:
	var filtered_dict = {}
	for key in scenes.keys():
		if key.begins_with("level_"):
			filtered_dict[key] = scenes[key]
	return filtered_dict.values().pick_random()
