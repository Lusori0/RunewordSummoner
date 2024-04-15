extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	if global.Enemy["HP"] <= 0:
		text = "YOU WON"
		self_modulate = Color(0.3, 1.0, 0.7, 1.0)
	elif global.Player["HP"] <= 0:
		text = "YOU LOST"
		self_modulate = Color(1.0, 0.4, 0.4, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
