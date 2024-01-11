class_name SplitAttack
extends Keyword

func init(id = 1):
	super.init(id)


func get_new_targets(target_offsets, attacker) -> Array[int]:
	return [-1, 1]
