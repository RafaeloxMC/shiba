extends Area2D

@onready var timer: Timer = $KillzoneTimer

func _on_body_entered(body: Node2D) -> void:
	if not body.name == "Player": return
	print("Player died!")
	GameManager.remove_heart()
	Engine.time_scale = 0.5
	timer.start()
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
