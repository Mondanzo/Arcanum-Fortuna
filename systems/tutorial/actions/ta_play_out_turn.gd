extends TutorialAction

@export var card_battle: CardBattle

func _execute():
	await card_battle.handle_friendly_attacks()
	await card_battle.handle_friendly_karma()
	for i in range(4):
		if card_battle.gameBoard.get_node("EnemyTiles").get_child(0).get_child(i).get_child_count() > 0:
			await card_battle.gameBoard.try_move_enemy_card_to_front(i)
	await card_battle.handle_enemy_attacks()
