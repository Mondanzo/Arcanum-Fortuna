class_name FriendlyPlacementPhase
extends CombatPhase


func init(combat : CardBattle):
	super.init(combat)
	combat.player_turn_ended.connect(_on_player_turn_ended)


static func get_class_name():
	return "Friendly Placement Phase"

func execute():
	await process_start_keywords(self, combat.gameBoard.get_active_cards())
	return await process_effect()

func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.FRIENDLY_PLACEMENT


func process_effect() -> ExitState:
	combat.unlock_player_actions()
	return ExitState.DEFAULT


func _on_player_turn_ended():
	await process_end_keywords(self, combat.gameBoard.get_active_cards())
	combat.lock_player_actions()
	completed.emit(ExitState.DEFAULT)
