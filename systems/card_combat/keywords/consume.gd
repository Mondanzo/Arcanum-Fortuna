class_name Consume
extends ActivatedKeyword

@export var health_gain : int = 1
@export var attack_gain : int = 1

func init(id = 3):
	super.init(id)


func trigger(source, target):
	if not target is CombatCard:
		push_error("Cannot apply Consume. Invalid target ", target, ".")
	target.attack += attack_gain
	target.health += health_gain
	target.update_texts()
