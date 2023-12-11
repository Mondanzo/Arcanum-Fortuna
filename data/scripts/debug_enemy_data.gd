class_name DebugEnemyData extends Resource

@export var health: float

@export var rows : Array[Array]

func get_rows():
	for row in rows:
		while row.size() < 5:
			row.push_back(null)
	return rows
