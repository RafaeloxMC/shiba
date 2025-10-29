extends Node2D

@onready var target_layer: TileMapLayer = $SubViewportContainer/SubViewport/TileMapLayer
@onready var player: CharacterBody2D = $SubViewportContainer/SubViewport/Player
@onready var player_2nd: CharacterBody2D = $SubViewportContainer2/SubViewport/Player

func _ready() -> void:
	var world = $SubViewportContainer/SubViewport.find_world_2d()
	$SubViewportContainer2/SubViewport.world_2d = world
	
	var level_scene = SceneManager.get_random_level()
	var level = level_scene.instantiate()
	add_child(level)
	
	var old_player: CharacterBody2D = level.find_child("Player")
	
	player.position = old_player.position
	player_2nd.position = old_player.position + Vector2(15, 0)
	
	player.level_border_left = old_player.level_border_left
	player.level_border_right = old_player.level_border_right
	player_2nd.level_border_left = old_player.level_border_left
	player_2nd.level_border_right = old_player.level_border_right
	
	GameManager.call_tick_ui()
		
	var dog_houses = level.find_child("Dog Houses")
	if dog_houses:
		dog_houses.reparent($SubViewportContainer/SubViewport)
	else:
		print("DOG HOUSES NOT FOUND!")
	print("ADDED DOG HOUSES! " + str(dog_houses))
	
	var source_node: Node = level.find_child("TileMap", true, false)
	if not source_node:
		source_node = level.find_child("TileMapLayer", true, false)
		
	if not source_node:
		push_error("Level contains neither TileMap nor TileMapLayer!")
		level.queue_free()
		return
		
	_copy_level_to_target(source_node, target_layer)
	
	level.free()
	
	GameManager.update_time_tracker.emit()
	
func _copy_level_to_target(source_root: Node, target: TileMapLayer) -> void:
	target.clear()
	
	var source_layers: Array[TileMapLayer] = []
	if source_root is TileMapLayer:
		source_layers.append(source_root as TileMapLayer)
	else:
		for child in source_root.get_children():
			if child is TileMapLayer:
				source_layers.append(child)
			
	if source_layers.is_empty():
		push_warning("No TileMapLayer found under the source node.")
		return
		
	var first_layer = source_layers[0]
	if first_layer.tile_set:
		target.tile_set = first_layer.tile_set
		
	for src_layer in source_layers:
		_copy_layer_cells(src_layer, target)
		
func _copy_layer_cells(src: TileMapLayer, dst: TileMapLayer) -> void:
	for cell in src.get_used_cells():
		var src_id = src.get_cell_source_id(cell)
		var atlas = src.get_cell_atlas_coords(cell)
		var alt_tile = src.get_cell_alternative_tile(cell)
		dst.set_cell(cell, src_id, atlas, alt_tile)
		dst.z_index = src.z_index
		dst.modulate = src.modulate
