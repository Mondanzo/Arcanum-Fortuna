class_name Consume
extends ActivatedKeyword

@export var health_gain : int = 1
@export var attack_gain : int = 1

func init(id = 3):
	if title.count('%d') == 2:
		title = title % [attack_gain, health_gain]
	if description.count('%d') == 2:
		description = description % [attack_gain, health_gain]
	super.init(id)


func trigger(source, target):
	if not target is CombatCard:
		push_error("Cannot apply Consume. Invalid target ", target, ".")
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered consume." % [source.card_data.name, source.tile_coordinate.x, source.tile_coordinate.y])
	target.attack += attack_gain
	target.health += health_gain
	target.update_texts()
