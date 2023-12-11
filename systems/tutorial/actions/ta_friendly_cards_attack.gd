extends TutorialAction

@export var card_battle: CardBattle

func _execute():
	await card_battle.handle_friendly_attacks()
