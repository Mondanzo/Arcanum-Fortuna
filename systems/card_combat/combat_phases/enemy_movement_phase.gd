class_name EnemyMovementPhase
extends CombatPhase


static func get_class_name():
	return "Enemy Movement Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_MOVEMENT


func process_effect():
	await combat.move_enemies()
