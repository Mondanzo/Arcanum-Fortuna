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

func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not target is CombatCard:
		push_error("Cannot apply Drain. Invalid target ", target, ".")
		
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered drain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	target.attack += attack_gain
	target.health += health_gain
	target.update_texts()
