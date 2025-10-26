extends Node2D

@export var tiles: Array[PackedScene]
@export var gap: float = 50.0
var player: CharacterBody2D
var offset: float = 0.0
var last_end: float = 0.0
var tile_width: float = 100

var current_biome = "grassland"
var biome_tile_counter = 0

func _ready() -> void:
	player = find_child("Player", true)
	var node = tiles[0].instantiate() as Node2D
	node.position = player.position
	player.add_sibling(node)
	update_tile_width(node)
	last_end = player.position.x + tile_width

func _process(_delta: float) -> void:
	offset = maxf(player.position.x, offset)
	var buffer = tile_width
	while (offset + buffer >= last_end):
		var tile_scene = get_random_themed_part(current_biome)
		if tile_scene != null:
			var tile = tile_scene.instantiate() as Node2D
			tile.position.x = last_end + gap
			add_child(tile)
			update_tile_width(tile)
			last_end += tile_width + gap
			if biome_tile_counter > 10:
				var rand = randi_range(0, 10)
				if rand == 5:
					if current_biome == "grassland":
						current_biome = "northern_territories"
					else:
						if current_biome == "northern_territories":
							current_biome = "grassland"
					biome_tile_counter = 0
			else:
				biome_tile_counter = biome_tile_counter + 1
		else:
			print("Warning: No tiles found for biome '" + current_biome + "'")

func get_random_themed_part(biome: String) -> PackedScene:
	var biome_tiles: Array[PackedScene] = tiles
	biome_tiles = biome_tiles.filter(func(tile): return tile.resource_path.contains(biome))
	return biome_tiles[randi() % biome_tiles.size()] if biome_tiles.size() > 0 else null

func update_tile_width(tile: Node2D) -> void:
	var tilemap_layer = tile.find_child("TileMapLayer") as TileMapLayer
	if tilemap_layer and tilemap_layer.tile_set:
		var tile_set = tilemap_layer.tile_set
		var tile_size = tile_set.tile_size
		var used_cells = tilemap_layer.get_used_cells()
		if used_cells.size() > 0:
			var min_x = used_cells[0].x
			var max_x = used_cells[0].x
			for cell in used_cells:
				min_x = min(min_x, cell.x)
				max_x = max(max_x, cell.x)
			var tile_count_x = max_x - min_x + 1
			tile_width = tile_count_x * tile_size.x
		else:
			print("Warning: No used cells found in TileMapLayer, using default width: ", tile_width)
	else:
		print("Warning: No TileMapLayer found, using default width: ", tile_width)
