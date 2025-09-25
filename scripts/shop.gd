extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var is_body_in_area = false

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		is_body_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_body_in_area = false


func _process(_delta: float) -> void:
	if is_body_in_area && Input.is_action_just_pressed("next") && GameManager.is_showing_shop == false:
		GameManager.trigger_shop.emit(true)
