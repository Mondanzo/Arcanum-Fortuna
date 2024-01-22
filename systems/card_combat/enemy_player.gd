class_name EnemyPlayer extends Control

@export_category("Animation")
@export var animation_delay = 1
@export var attacked_color : Color = Color.RED
@export var active_color : Color = Color.GRAY
@export var positive_effect_color : Color = Color.GREEN

var data
var health := 20 : 
	get:
		return health
	set(value):
		health = value
		$Health/Label.text = "Health: " + str(health)
var max_health
var karma = 0


func init(enemy_data):
	data = enemy_data
	if data is OldEnemyData:
		health = data.health
	else:
		set_health(data.get_random_health())
	max_health = health
	var name_label = get_node_or_null("Title")
	if (name_label):
		name_label.text = name_label.text % enemy_data.title


func set_health(value):
	health = value
	$Health/Label.text = "Health: " + str(health)


func get_rows():
	return data.get_rows()


func calc_card_placements() -> Array[EnemyBrain.CardPlacement]:
	return data.brain.calc_card_placements()


#region damage function
func heal(amount):
	if amount < 0:
		push_error("Heal must be positive!")
		return
	health += amount
	health = min(health, max_health)

func take_damage(amount):
	SfxOther._SFX_Damage()
	$Health/Label.text = "Health: " + str(health) + " (" + str(-amount) + ")"
	health -= amount
	$Health.modulate = attacked_color
	GlobalLog.add_entry("The enemy took %d damage." % amount)


func restore_default_color():
	$Health/Label.text = "Health: " + str(health)
	$Health.modulate = Color.WHITE
	%Karma.modulate = Color.WHITE

func process_death() -> bool:
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
	var was_lethal = process_death()
	%Karma/Label.text = "Karma: " + str(karma)
	restore_default_color()
	return was_lethal
	

func set_karma(value):
	karma = value
	%Karma/Label.text = "Karma: " + str(karma)
#endregion
