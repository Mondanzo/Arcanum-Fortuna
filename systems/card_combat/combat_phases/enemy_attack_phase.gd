class_name EnemyAttackPhase
extends CombatPhase


static func get_class_name():
	return "Enemy Attack Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_ATTACKS


func process_effect():
	for i in range(combat.gameBoard.enemy_tiles_front.get_child_count()):
		if combat.gameBoard.enemy_tiles_front.get_child(i).get_child_count() == 0:
			continue
		await combat.handle_attacks(combat.gameBoard.enemy_tiles_front.get_child(i).get_child(0), i, false)
		if combat.is_battle_over:
			return

