extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var world = $SubViewportContainer/SubViewport.find_world_2d()
	$SubViewportContainer2/SubViewport.world_2d = world
