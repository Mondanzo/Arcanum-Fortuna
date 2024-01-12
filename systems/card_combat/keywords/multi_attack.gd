class_name MultiAttack
extends Keyword

## Honw many additional times this card can attack.
@export var extra_attacks := 1

func init(id = 3):
	if title.count('%d') == 1:
		title = title % extra_attacks
	if description.count('%d') == 1:
		description = description % extra_attacks
	super.init(id)

func get_new_targets(target_offsets, attacker) -> Array[int]:
	var prev_targets = []
	for target in target_offsets:
		prev_targets.append(target)
	for i in range(extra_attacks):
		for target in prev_targets:
			target_offsets.append(target)
	return target_offsets
