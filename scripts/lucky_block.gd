extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var static_body_2d: StaticBody2D = $StaticBody2D

@export var lootpool: Dictionary[String, Variant] = {}

var base_pos

func _ready() -> void:
	base_pos = self.position

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animated_sprite_2d.play("spin")
		move_up()
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(2, false)
		static_body_2d.set_collision_layer_value(1, false)
		await get_tree().create_timer(1).timeout
		var node = lootpool[lootpool.keys().pick_random()].instantiate()
		node.position = base_pos
		self.add_sibling(node)
		self.queue_free()

func move_up():
	for i in 100:
		self.position.y -= 0.25
		self.modulate.a -= 0.015
		await get_tree().create_timer(0.01).timeout
