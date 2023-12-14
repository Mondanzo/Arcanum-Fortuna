class_name EnemyPlayer extends Control

var health = 20

@export var attacked_color : Color = Color.RED
@export var active_color : Color = Color.GRAY

var data


func init(enemy_data):
	data = enemy_data
	if data is EnemyData:
		data.init()
	set_health(data.health)


func set_health(value):
	health = value
	$Health/Label.text = "Health: " + str(health)


func get_rows():
	return data.get_rows()


#region damage function
func take_damage(amount):
	$Health/Label.text = "Health: " + str(health) + " (" + str(-amount) + ")"
	health -= amount
	$Health.modulate = attacked_color
	GlobalLog.add_entry("The enemy took %d damage." % amount)


func restore_default_color():
	$Health/Label.text = "Health: " + str(health)
	$Health.modulate = Color.WHITE


func proccess_death() -> bool:
	if health < 0:
		GlobalLog.add_entry("The enemy died!")
	return health <= 0
#endregion
