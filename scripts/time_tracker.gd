extends Label

func _process(delta: float) -> void:
	GameManager.time += delta
	@warning_ignore("narrowing_conversion")
	var mins: int = GameManager.time / 60
	var seconds: int = int(GameManager.time) % 60
	var milliseconds: int = int((GameManager.time - int(GameManager.time)) * 100)
	self.text = str(mins).pad_zeros(2) + " : " + str(seconds).pad_zeros(2) + " : " + str(milliseconds).pad_zeros(2)
