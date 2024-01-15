class_name shield
extends Keyword


## Factor by which the damage is reduced. 1.0 == 100% of damage is blocked.
@export var damage_reduction := 1.0

## Damage reduction will only be apllied while uses are available. Setting it to < 0 will enabled unlimited uses.
@export var uses := 1

var user_lookup : Dictionary = {}

func get_reduced_damage(owner, damage):
	if uses < 0:
		return damage - damage * damage_reduction
	if not user_lookup.has(owner):
		user_lookup[owner] = uses
	if user_lookup[owner] <= 0 or damage == 0:
		return damage
	user_lookup[owner] -= 1
	return damage - damage * damage_reduction
