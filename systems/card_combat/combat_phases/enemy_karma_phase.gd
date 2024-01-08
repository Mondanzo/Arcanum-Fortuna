class_name EnemyKarmaPhase
extends FriendlyKarmaPhase

func get_relevant_cards():
	return combat.gameBoard.get_front_enemies().filter(
			func(card: Card):
				return card.cost != 0
				)

func get_karma_modify_target():
	return combat.enemy
