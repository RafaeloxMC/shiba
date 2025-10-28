extends Label

func _ready():
	horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.x = 80
	GameManager.time_tracker = self

func _process(delta: float) -> void:
	if GameManager.time_tracker == self:
		GameManager.time += delta
	var mins: int = int(GameManager.time / 60)
	var seconds: int = int(GameManager.time) % 60
	var milliseconds: int = int((GameManager.time - int(GameManager.time)) * 100)
	text = "%02d : %02d : %02d" % [mins, seconds, milliseconds]
