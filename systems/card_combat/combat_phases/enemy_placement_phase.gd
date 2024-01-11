class_name EnemyPlacementPhase
extends CombatPhase


static func get_class_name():
	return "Enemy Placement Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_PLACEMENT


func process_effect() -> ExitState:
	var card_placements = combat.enemy.calc_card_placements()
	
	for placement in card_placements:
		combat.game_board.place_enemy_card_back(placement.card, placement.target_column)
	
	return ExitState.DEFAULT
