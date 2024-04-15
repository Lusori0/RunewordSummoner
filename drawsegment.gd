extends Panel

const INACTIVE_COL = Color(0.1, 0.1, 0.1, 1)
const ACTIVE_COL = Color(0.8, 0.8, 0.8, 1)

var INDEX = -1
signal draw_active(index)
var MOUSE_IN = false
var MOUSE_DOWN = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate = INACTIVE_COL
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if MOUSE_IN and MOUSE_DOWN:
		draw_active.emit(INDEX)
		self_modulate = ACTIVE_COL
		#print("Draw active index: " + str(INDEX))

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			MOUSE_DOWN = true
		elif not event.is_pressed():
			self_modulate = INACTIVE_COL
			MOUSE_DOWN = false
		

func _on_mouse_entered():
	MOUSE_IN = true

func _on_mouse_exited():
	MOUSE_IN = false
