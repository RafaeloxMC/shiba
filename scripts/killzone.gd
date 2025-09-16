extends Area2D

@onready var timer: Timer = $KillzoneTimer

func _on_body_entered(body: Node2D) -> void:
	if not body.name == "Player" && timer.time_left >= 0: return
	print("Player died!")
	GameManager.remove_heart()
	Engine.time_scale = 0.5
	if GameManager.hearts <= 0:
		timer.start(2)
	else:
		timer.start(1)
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	print("Timed out!")
	if GameManager.hearts <= 0:
		SceneManager.call_scene("main_menu")
		return
	SceneManager.reload_current()
