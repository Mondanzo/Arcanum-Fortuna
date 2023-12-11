extends TutorialAction

@export var card_battle: CardBattle
@export var phases : Array[CombatPhase]


func _execute():
	for phase in phases:
		phase.init(card_battle)
		phase.execute()
		await phase.completed
