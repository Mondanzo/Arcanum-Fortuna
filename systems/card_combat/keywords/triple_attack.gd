class_name TripleAttack
extends Keyword

func init(id = 5):
	super.init(id)


func get_new_targets(target_offsets) -> Array[int]:
	return [-1, 0, 1]
