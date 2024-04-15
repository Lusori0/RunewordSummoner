extends GridContainer

var drawsegment_scene = preload("res://drawsegment.tscn")

enum movement{l,r,o,u,e}

var last_segment_index = -1
var machine_state = 0

signal rune_cast(rune)

var STATECHANGEMATRIX = [
	[1, 5, 20, 20, 20, 20, 20, 20, 20, 20, 20, 12, 20, 14, 20, 20, 20, 18, 20, 20, 20],  #l
	[4, 20, 3, 20, 5, 20, 7, 20, 9, 20, 20, 15, 20, 20, 20, 20, 20, 18, 20, 20, 20, 20], #r
	[6, 2, 20, 20, 20, 20, 20, 20, 20, 10, 20, 20, 13, 20, 20, 16, 20, 20, 19, 20, 20],  #o
	[11, 2, 20, 20, 20, 20, 20, 8, 20, 20, 20, 20, 20, 17, 10, 20, 17, 20, 20, 20, 20]   #u
]

func _update_machine_state(move):
	if move == movement.e:
		machine_state = 20
	else:
		machine_state = STATECHANGEMATRIX[move][machine_state]

func _draw_active(index):
	if last_segment_index != index:
		if last_segment_index != -1:
			var move = movement.e
			if last_segment_index - index == 1:
				move = movement.l
			elif last_segment_index - index == -1:
				move = movement.r
			elif last_segment_index - index == 3:
				move = movement.o
			elif last_segment_index - index == -3:
				move = movement.u
			_update_machine_state(move)
		last_segment_index = index

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if not event.is_pressed():
			if machine_state == 3:
				rune_cast.emit(runetypes.AIR)
			elif machine_state == 5:
				rune_cast.emit(runetypes.EARTH)
			elif machine_state == 10:
				rune_cast.emit(runetypes.WATER)
			elif machine_state == 19:
				rune_cast.emit(runetypes.FIRE)
			last_segment_index = -1
			machine_state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 9:
		var inst = drawsegment_scene.instantiate()
		inst.INDEX = i
		inst.draw_active.connect(_draw_active)
		add_child(inst)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
