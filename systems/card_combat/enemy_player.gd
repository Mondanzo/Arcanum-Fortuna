class_name EnemyPlayer extends Control

var health = 20
var karma = 0

@export_category("Animation")
@export var animation_delay = 1
@export var attacked_color : Color = Color.RED
@export var active_color : Color = Color.GRAY
@export var positive_effect_color : Color = Color.GREEN

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
	%Karma.modulate = Color.WHITE

func proccess_death() -> bool:
	if health < 0:
		GlobalLog.add_entry("The enemy died!")
	return health <= 0
#endregion

#region karma
func modify_karma(amount):
	if amount > 0:
		%Karma.modulate = positive_effect_color
	elif amount < 0:
		%Karma.modulate = attacked_color
	else:
		return
	%Karma/Label.text = "Karma: "+ str(karma) + \
		" (" + ("+" if amount >= 0 else "") + str(amount) + ")"
	karma += amount

func process_karma_overflow() -> bool:
	%Karma/Label.text = "Karma: " + str(karma)
	if karma < 0:
		GlobalLog.add_entry("Applying karma overflow of %d." % -karma)
		take_damage(-karma)
		await get_tree().create_timer(animation_delay).timeout
		karma = 0
	var is_lethal = await proccess_death()
	%Karma/Label.text = "Karma: " + str(karma)
	restore_default_color()
	return is_lethal
	

func set_karma(value):
	karma = value
	%Karma/Label.text = "Karma: " + str(karma)
#endregion
