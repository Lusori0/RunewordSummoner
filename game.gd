extends Node2D

enum gstate {firstcast, secondcast, enemyturn}

const PLAYER_HP_BAR_LENGTH = 400
const ENEMY_HP_BAR_LENGTH = 800

var ELEMENT_RUNE = null
var ACTION_RUNE = null
var gamestate = gstate.firstcast

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_ui()
	$CastUI/GridContainer.rune_cast.connect(_handle_rune_cast)
	global.update_ui.connect(_update_ui)

func _calculate_damage(el_rune):
	var effectiveness = 1.
	#Modify effectiveness based on matchup
	if (el_rune + 1) % runetypes.DATA.size() == global.Enemy["TYPE"]:
		effectiveness *= 2.
	elif el_rune == (global.Enemy["TYPE"] + 1) % runetypes.DATA.size():
		effectiveness *= 0.5
	#Modify effectiveness based on double effect
	if global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"] == runetypes.FIRE:
		effectiveness *= 2.
		global._update_player_double_effect(null)
	
	#Cast animation
	$CastUI.visible = false
	$PlayerSprite/AnimationPlayer.play("cast_rune")
	await $PlayerSprite/AnimationPlayer.animation_finished
	#Apply damage
	global._update_enemy_health(int(-global.Player["BASE_DAMAGE"] * effectiveness))
	#Damage animation
	$EnemySprite/AnimationPlayer.play("take_damage")
	await $EnemySprite/AnimationPlayer.animation_finished
	$CastUI.visible = true

func _calculate_healing(el_rune):
	var effectiveness = 1
	if global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"] == runetypes.WATER:
		effectiveness *= 2.
		global._update_player_double_effect(null)
		
	$CastUI.visible = false
	$PlayerSprite/AnimationPlayer.play("heal")
	await $PlayerSprite/AnimationPlayer.animation_finished
	if el_rune == runetypes.FIRE:
		global._update_player_health(int(15*effectiveness))
	elif el_rune == runetypes.WATER:
		global._update_player_heal_rounds(int(3*effectiveness))
	elif el_rune == runetypes.EARTH:
		global._update_player_max_health(int(5*effectiveness))
	elif el_rune == runetypes.AIR:
		global._update_player_health(int(effectiveness*(randi() % 24 + 1)))
	$CastUI.visible = true

func _calculate_defense(el_rune):
	$CastUI.visible = false
	$PlayerSprite/AnimationPlayer.play("defense")
	await $PlayerSprite/AnimationPlayer.animation_finished
	global._update_player_defense(el_rune)
	$CastUI.visible = true
	
func _calculate_utility(el_rune):
	#Double next element cast
	# air air: skip to next round
	$CastUI.visible = false
	$PlayerSprite/AnimationPlayer.play("cast_rune")
	await $PlayerSprite/AnimationPlayer.animation_finished
	
	if el_rune == runetypes.AIR:
		await _round_init()
	else:
		global._update_player_double_effect(el_rune)
	
	$CastUI.visible = true

	
func _round_init():
	if global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"] > 0:
		$CastUI.visible = false
		$PlayerSprite/AnimationPlayer.play("heal")
		await $PlayerSprite/AnimationPlayer.animation_finished
		global._update_heal_round()
		$CastUI.visible = true
		
	global._enemy_advance_round()
	gamestate = gstate.firstcast
	global._reroll_runes()
	
	
func _enemy_turn():
	$CastUI.visible = false
	$EnemySprite/AnimationPlayer.play("attack")
	await $EnemySprite/AnimationPlayer.animation_finished
		
	if global.Player["STATUS_EFFECTS"]["DEFENSE"] == global.Enemy["TYPE"]:
		var effectiveness = 2.
		if global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"] == runetypes.WATER:
			effectiveness *= 2.
			global._update_player_double_effect(null)
		global._update_player_health(-int(global.Enemy["NEXT_DAMAGE"]/effectiveness))
		global._update_player_defense(null)
	else:
		global._update_player_health(-global.Enemy["NEXT_DAMAGE"])
	
	$PlayerSprite/AnimationPlayer.play("take_damage")
	await $PlayerSprite/AnimationPlayer.animation_finished
	$CastUI.visible = true
	await _round_init()


func _handle_spell_cast():
	$CastUI/Runeword/ElementRune.visible = false
	$CastUI/Runeword/ActionRune.visible = false
	
	if ACTION_RUNE == runetypes.FIRE:
		await _calculate_damage(ELEMENT_RUNE)
	elif ACTION_RUNE == runetypes.WATER:
		await _calculate_healing(ELEMENT_RUNE)
	elif ACTION_RUNE == runetypes.EARTH:
		await _calculate_defense(ELEMENT_RUNE)
	elif ACTION_RUNE == runetypes.AIR:
		await _calculate_utility(ELEMENT_RUNE)
	
	ELEMENT_RUNE = null
	ACTION_RUNE = null
	
	gamestate += 1
	if gamestate == gstate.enemyturn:
		await _enemy_turn()


func _handle_rune_cast(rune):
	for i in 6:
		if i == 5: #Player does not have rune available
			return
		if global.Player["RUNES"][i] == rune:
			global._update_rune(null, i)
			break
	
	if ELEMENT_RUNE == null:
		ELEMENT_RUNE = rune
		_update_ui()
		$CastUI/Runeword/ElementRune._set_rune(rune)
		$CastUI/Runeword/ElementRune.visible = true
	elif ACTION_RUNE == null:
		ACTION_RUNE = rune
		_update_ui()
		$CastUI/Runeword/ActionRune._set_rune(rune)
		$CastUI/Runeword/ActionRune.visible = true
		await get_tree().create_timer(.7).timeout
		await _handle_spell_cast()

func _update_ui():
	if ELEMENT_RUNE == null:
		$CastUI/Runeword/ElementIndicator.visible = true
		$CastUI/Runeword/ActionIndicator.visible = false
	elif ACTION_RUNE == null:
		$CastUI/Runeword/ElementIndicator.visible = false
		$CastUI/Runeword/ActionIndicator.visible = true
	
	$PlayerInfo/PlayerHealthBar.size = Vector2(
		float(global.Player["HP"])/global.Player["MAX_HP"] * PLAYER_HP_BAR_LENGTH,
		 20)
	$PlayerInfo/HP.text = str(global.Player["HP"]) + " HP"
	if global.Player["STATUS_EFFECTS"]["DEFENSE"] == null:
		$PlayerInfo/Defense.visible = false
	else:
		$PlayerInfo/Defense.text = "Defense: " + runetypes.DATA[global.Player["STATUS_EFFECTS"]["DEFENSE"]]["Element"]
		$PlayerInfo/Defense.visible = true
	
	if global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"] == 0:
		$PlayerInfo/HealDot.visible = false
	else:
		$PlayerInfo/HealDot.text = "DoT Heal: " + str(global.Player["STATUS_EFFECTS"]["HEAL_ROUNDS"])
		$PlayerInfo/HealDot.visible = true
	
	if global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"] == null:
		$PlayerInfo/DoubleEffect.visible = false
	else:
		$PlayerInfo/DoubleEffect.text = "2x Action: " + runetypes.DATA[global.Player["STATUS_EFFECTS"]["DOUBLE_EFFECT"]]["Element"]
		$PlayerInfo/DoubleEffect.visible = true
	
	for i in 5:
		if global.Player["RUNES"][i] == null:
			$Runeroll.get_node("Rune"+str(i)).visible = false
		else:
			$Runeroll.get_node("Rune"+str(i))._set_rune(global.Player["RUNES"][i])
			$Runeroll.get_node("Rune"+str(i)).visible = true
	
	$EnemyInfo/EnemyHealthBar.size = Vector2(
		float(global.Enemy["HP"])/global.Enemy["MAX_HP"] * ENEMY_HP_BAR_LENGTH,
		 20)
	$EnemyInfo/HP.text = str(global.Enemy["HP"]) + " HP"
	$EnemyInfo/Type.text = "Type: " + runetypes.DATA[global.Enemy["TYPE"]]["Element"]
	$EnemyInfo/NextDamage.text = "Next Attack: " + str(global.Enemy["NEXT_DAMAGE"])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

