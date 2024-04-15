extends Node2D

var RUNE



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _set_rune(rune):
	RUNE = rune
	$Sprite2D.frame = RUNE
	var tooltipstr = "Element: " + runetypes.DATA[RUNE]["Element"] + "\n"
	tooltipstr += "Effective against: " + runetypes.DATA[(RUNE+1)%4]["Element"] + "\n"
	tooltipstr += "Ineffective against: " + runetypes.DATA[int(fposmod(RUNE-1, 4))]["Element"] + "\n\n"
	tooltipstr += "Action: " + runetypes.DATA[RUNE]["Action"]
	$Background.tooltip_text = tooltipstr
