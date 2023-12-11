class_name CombatPhase
extends Resource

signal completed

var combat : CardBattle


func init(combat : CardBattle):
	self.combat = combat


#region override functions

static func get_class_name():
	return "Undefined"

func get_corresponding_trigger() -> CombatPhaseTrigger.SourcePhases:
	return CombatPhaseTrigger.SourcePhases.NONE


func process_effect():
	pass


func reset():
	pass


func execute():
	await process_start_keywords(self, combat.gameBoard.get_active_cards())
	await process_effect()
	await process_end_keywords(self, combat.gameBoard.get_active_cards())
	await Engine.get_main_loop().process_frame
	completed.emit()

#endregion


func process_start_keywords(trigger_source, applicable_cards : Array[CombatCard]):
	for card : CombatCard in applicable_cards:
		for i in range(card.keywords.size()):
			if not card.keywords[i] is ActivatedKeyword:
				continue
			for trigger : CombatPhaseTrigger in card.keywords[i].combat_phase_triggers:
				if trigger.timing != CombatPhaseTrigger.Timings.STARTED:
					continue
				if trigger.source_phase != get_corresponding_trigger():
					continue
				card.get_node("KeyWords").get_child(i).scale = Vector2(1.2, 1.2)
				await Engine.get_main_loop().create_timer(card.keywords[i].highlight_duration).timeout
				card.get_node("KeyWords").get_child(i).scale = Vector2.ONE
				card.keywords[i].trigger(self, card)


func process_end_keywords(trigger_source, applicable_cards : Array[CombatCard]):
	for card : CombatCard in applicable_cards:
		for i in range(card.keywords.size()):
			if not card.keywords[i] is ActivatedKeyword:
				continue
			for trigger : CombatPhaseTrigger in card.keywords[i].combat_phase_triggers:
				if trigger.timing != CombatPhaseTrigger.Timings.FINISHED:
					continue
				if trigger.source_phase != get_corresponding_trigger():
					continue
				card.get_node("KeyWords").get_child(i).scale = Vector2(1.2, 1.2)
				await Engine.get_main_loop().create_timer(card.keywords[i].highlight_duration).timeout
				card.get_node("KeyWords").get_child(i).scale = Vector2.ONE
				card.keywords[i].trigger(self, card)
