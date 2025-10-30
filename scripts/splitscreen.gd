extends Node2D

@onready var target_layer: TileMapLayer = $SubViewportContainer/SubViewport/TileMapLayer
@onready var player: CharacterBody2D = $SubViewportContainer/SubViewport/Player
@onready var player_2nd: CharacterBody2D = $SubViewportContainer2/SubViewport/Player
@onready var camera: Camera2D = $SubViewportContainer/SubViewport/Player/Camera2D
@onready var camera_2nd: Camera2D = $SubViewportContainer2/SubViewport/Player/Camera2D

@onready var viewport1_root: Node = $SubViewportContainer/SubViewport
@onready var viewport2_root: Node = $SubViewportContainer2/SubViewport

func _ready() -> void:
	var world = viewport1_root.find_world_2d()
	$SubViewportContainer2/SubViewport.world_2d = world
	
	var level_scene = SceneManager.get_random_level()
	var level = level_scene.instantiate()
	add_child(level)
	
	var old_player: CharacterBody2D = level.find_child("Player")
	if not old_player:
		push_error("Level does not contain a Player node!")
		level.queue_free()
		return
	
	player.position = old_player.position
	player_2nd.position = old_player.position + Vector2(15, 0)
	
	player.level_border_left = old_player.level_border_left
	player.level_border_right = old_player.level_border_right
	player_2nd.level_border_left = old_player.level_border_left
	player_2nd.level_border_right = old_player.level_border_right
	
	camera.reset_smoothing()
	camera_2nd.reset_smoothing()
	camera.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	camera_2nd.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	GameManager.call_tick_ui()
	
	_duplicate_level_nodes_except_player(level, viewport1_root)
	
	var dog_houses = level.find_child("Dog Houses")
	if dog_houses:
		var dog_houses_v1 = dog_houses.duplicate()
		viewport1_root.add_child(dog_houses_v1)
		print("ADDED DOG HOUSES TO VIEWPORT!")
	else:
		print("DOG HOUSES NOT FOUND!")
	
	level.queue_free()
	
	GameManager.update_time_tracker.emit()


func _duplicate_level_nodes_except_player(source_level: Node, target_parent: Node) -> void:
	for child in source_level.get_children():
		if child.name == "Player" || child.name == "Parallax":
			continue
		
		var duplicated = child.duplicate()
		if duplicated:
			target_parent.add_child(duplicated)
			duplicated.owner = target_parent
			
			if duplicated is TileMapLayer:
				if duplicated.tile_set:
					duplicated.tile_set = duplicated.tile_set
				duplicated.z_index = child.z_index
				duplicated.modulate = child.modulate
				duplicated.y_sort_enabled = child.y_sort_enabled
