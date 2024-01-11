class_name EnemyAttackPhase
extends CombatPhase


static func get_class_name():
	return "Enemy Attack Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_ATTACKS


func process_effect() -> ExitState:
	for i in range(combat.game_board.enemy_tiles_front.get_child_count()):
		if combat.game_board.enemy_tiles_front.get_child(i).get_child_count() == 0:
			continue
		await combat.handle_attacks(combat.game_board.enemy_tiles_front.get_child(i).get_child(0), i, false)
		if combat.is_battle_over:
			return ExitState.ABORT
	return ExitState.DEFAULT

