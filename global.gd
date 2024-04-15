extends Node

var Player = {
	"MAX_HP": 100,
	"HP": 100,
	"BASE_DAMAGE": 6,
	"STATUS_EFFECTS": {
		"HEAL_ROUNDS": 0,
		"DOT": 0,
		"DEFENSE": null,
		"DOUBLE_EFFECT": null
	},
	"RUNES": [
		randi() % runetypes.DATA.size(), 
		randi() % runetypes.DATA.size(),
		randi() % runetypes.DATA.size(),
		randi() % runetypes.DATA.size(),
		randi() % runetypes.DATA.size()]
}

var Enemy = {
	"MAX_HP": 50,
	"HP": 50,
	"TYPE": randi() % runetypes.DATA.size(),
	"NEXT_ACTIONS": [runetypes.FIRE, runetypes.AIR], # not used TODO implement
	"NEXT_DAMAGE": randi() % 30 + 10,
	"NAME": "Salamander"
}

signal update_ui

func _update_heal_round():
	if global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"] > 0:
		global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"] -= 1
		_update_player_health(15)
	update_ui.emit()
func _update_player_heal_rounds(n):
	global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"] += n
	update_ui.emit()

func _update_player_double_effect(rune):
	global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"] = rune
	update_ui.emit()

func _update_rune(rune, i):
	Player["RUNES"][i] = rune
	update_ui.emit()

func _reroll_runes():
	for i in 5:
		Player["RUNES"][i] = randi() % runetypes.DATA.size()
	update_ui.emit()

func _enemy_advance_round():
	Enemy["NEXT_DAMAGE"] = randi() % 30 + 10
	update_ui.emit()

func _update_player_defense(rune):
	Player["STATUS_EFFECTS"]["DEFENSE"] = rune
	update_ui.emit()

func _update_player_max_health(difference):
	Player["MAX_HP"] += difference
	Player["HP"] += difference
	update_ui.emit()
	
func _update_player_health(difference):
	Player["HP"] = min(Player["HP"] + difference, Player["MAX_HP"])
	if Player["HP"] <= 0:
		get_tree().change_scene_to_file("res://endscreen.tscn")
	update_ui.emit()
	
func _update_enemy_health(difference):
	Enemy["HP"] += difference
	if Enemy["HP"] <= 0:
		get_tree().change_scene_to_file("res://endscreen.tscn")
	update_ui.emit()
