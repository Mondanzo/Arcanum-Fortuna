class_name Keyword extends Node


enum Types {
	None = 0b0,
	Consume = 0b1,
	DestinyDrain = 0b10,
	Flip = 0b100,
	SideApply = 0b1000,
	AttackSplit = 0b10000,
}

@export var params : Array[String]

func get_type():
	return Types.None
