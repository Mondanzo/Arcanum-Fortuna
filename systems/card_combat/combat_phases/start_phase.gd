class_name StartPhase
extends CombatPhase

var was_already_invoked = false


static func get_class_name():
	return "Start Phase"

func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.TURN_START


func process_effect() -> ExitState:
	if not was_already_invoked:
		combat.update_enemy_card_placement()
		for i in range(combat.player_data.start_hand_size):
			await combat.player.draw_card()
		was_already_invoked = true
		return ExitState.DEFAULT
	for i in range(combat.player_data.draw_amount):
		await combat.player.draw_card()
	return ExitState.DEFAULT

func reset():
	was_already_invoked = false
