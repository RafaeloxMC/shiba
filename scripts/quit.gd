extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		SceneManager.call_scene("main_menu")

func _on_timer_timeout() -> void:
	get_tree().quit()
