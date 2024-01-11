class_name TripleAttack
extends Keyword

var turns_to_skip = 1

func init(id = 5):
	super.init(id)

func get_new_targets(target_offsets, attacker) -> Array[int]:
	return [-1, 1]
