class_name FriendlyKarmaPhase
extends CombatPhase


static func get_class_name():
	return "Friendly Karma Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.FRIENDLY_KARMA


func _on_karma_decreased(source):
	for card : CombatCard in combat.gameBoard.get_active_cards():
		for i in range(card.keywords.size()):
			if card.keywords[i] is ActivatedKeyword and card.keywords[i].triggers & 2:
				card.get_node("KeyWords").get_child(i).scale = Vector2(1.2, 1.2)
				await Engine.get_main_loop().create_timer(card.keywords[i].highlight_duration).timeout
				card.get_node("KeyWords").get_child(i).scale = Vector2.ONE
				card.keywords[i].trigger(source, card)

func process_effect():
	for card : CombatCard in combat.gameBoard.get_friendly_cards():
		await card.animate_karma(combat.player)
		if card.cost < 0:
			await _on_karma_decreased(card)
	if await combat.player.process_karma_overflow():
		combat.finished.emit(combat.player.health)
		combat.is_battle_over = true

