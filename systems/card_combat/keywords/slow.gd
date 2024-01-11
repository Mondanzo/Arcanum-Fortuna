class_name Slow
extends Keyword

@export var turns_to_skip = 1
var turns_skipped_lookup : Dictionary = {}


func init(id = 1):
	super.init(id)
	if title.count('%d') == 1:
		title = title % turns_to_skip
	if description.count('%d') == 1:
		description = description % turns_to_skip

func get_new_targets(target_offsets, attacker) -> Array[int]:
	if not turns_skipped_lookup.has(attacker):
		turns_skipped_lookup[attacker] = 0
	turns_skipped_lookup[attacker] += 1
	if turns_skipped_lookup[attacker] <= turns_to_skip:
		return []
	turns_skipped_lookup[attacker] = 0
	return target_offsets
