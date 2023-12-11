class_name Drain
extends ActivatedKeyword

@export var health_gain : int = 0
@export var attack_gain : int = 1

func init(id = 4):
	if title.count('%d') == 2:
		title = title % [attack_gain, health_gain]
	if description.count('%d') == 2:
		description = description % [attack_gain, health_gain]
	super.init(id)

func trigger(source, target):
	if not target is CombatCard:
		push_error("Cannot apply Drain. Invalid target ", target, ".")
	target.attack += attack_gain
	target.health += health_gain
	target.update_texts()
