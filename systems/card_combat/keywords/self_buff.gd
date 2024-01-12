class_name SelfBuff
extends ActivatedKeyword

@export var health_gain : int = 0
@export var attack_gain : int = 1


func init(id = 3):
	if title.count('%d') == 2:
		title = title % [attack_gain, health_gain]
	elif title.count('%d') == 1:
		title = title % attack_gain if health_gain == 0 else health_gain

	if description.count('%d') == 2:
		description = description % [attack_gain, health_gain]
	elif description.count('%d') == 1:
		description = description % attack_gain if health_gain == 0 else health_gain
	super.init(id)


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not owner is CombatCard:
		push_error("Cannot apply Self-Buff. Invalid target ", owner, ".")
		return
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered self_buff." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y])
	owner.attack += attack_gain
	owner.health += health_gain
