class_name  ActivatedKeyword
extends Keyword

## Setup combat phases that should trigger this keyword
@export var combat_phase_triggers : Array[CombatPhaseTrigger] = []
## Setup other events that should trigger this keyword
@export_flags("OnKill", "OnKarmaDecrease", "ActiveCardsChanged") var triggers := 0

func trigger(source, target, params={}):
	pass
