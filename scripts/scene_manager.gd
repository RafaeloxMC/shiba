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
		if scene == "level_4" && current_level == "level_3":
			SoundManager.call_sound_with_fade("You Know You Know - Forever Sunset")
		current_level = current_scene
	print("Current scene now is: " + scene)
	GameManager.coins_collected_in_current_scene = 0
	get_tree().call_deferred("change_scene_to_packed", scenes.get(scene))
	
func next_level():
	if current_level.begins_with("level_"):
		var lvl_idx = int(current_level.split("_")[1])
		if scenes.has("level_" + str(lvl_idx + 1)):
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
	get_tree().reload_current_scene()
