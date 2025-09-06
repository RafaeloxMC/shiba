extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var scene: PackedScene
var original_scale: Vector2
var hover_scale: Vector2 = Vector2(1.05, 1.05)
var tween_duration: float = 0.2

func _ready():
	original_scale = animated_sprite_2d.scale

func _on_mouse_entered() -> void:
	print("Mouse entered")
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "scale", hover_scale, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	print("Mouse left")
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "scale", original_scale, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# print(str(event))
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_packed(scene)
