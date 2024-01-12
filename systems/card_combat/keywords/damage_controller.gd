class_name DamageController
extends ActivatedKeyword

## How much damage is dealt to the cards controller whenever this is triggered
@export var damage_amount = 1

func init(id = 3):
	if title.count('%d') == 1:
		title = title % [damage_amount]
	if description.count('%d') == 1:
		description = description % [damage_amount]
	super.init(id)


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DamageOwner: Combat must be provided!")
		return
	return combat.enemy if owner.is_enemy else combat.player


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not target.has_method("take_damage"):
		push_error("Cannot apply DeathrattleSacrifice: target '" + str(target) + "' has no take_damage method!")
		return
	target.take_damage(damage_amount)
