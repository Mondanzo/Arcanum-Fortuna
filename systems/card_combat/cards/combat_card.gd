class_name CombatCard extends Card

@export var attack_delay = 1.0
@export var death_delay = 1.0
@export var karma_delay = 1.0
@export var attacked_color : Color
@export var highlight_color : Color
@export var active_color : Color
@export var move_speed = 0.5


var target_offsets : Array[int] = [0]
var is_enemy := false
var tile_coordinate := Vector2i(-1, -1)

func make_enemy():
	is_enemy = true
	$Cost.hide()
	if attack == 0 and keywords.filter(func(keyword): 
		return keyword is Drain or keyword is Flip).size() == 0:
		flip()


func flip():
	%Artwork.flip_v = !%Artwork.flip_v
	var flipped_name = ""
	for c in card_name:
		flipped_name = flipped_name.insert(0, c)
	card_name = flipped_name
	var health_transfer = health
	health = attack
	attack = health_transfer
	#cost = -cost
	%KarmaCost.text = str(cost)
	%Name.text = card_name
	%AttackCost.text = str(attack)
	%HealthCost.text = str(health)


func get_target_offsets():
	for i in range(keywords.size()):
		if not keywords[i] is ActivatedKeyword and keywords[i].has_method("get_new_targets"):
			$KeyWords.get_child(i).scale = Vector2(1.2, 1.2)
			await get_tree().create_timer(keywords[i].highlight_duration).timeout
			$KeyWords.get_child(i).scale = Vector2.ONE
			target_offsets = keywords[i].get_new_targets(target_offsets)
	return target_offsets


func apply_consume():
	#attack += sigils.count(Card.Sigil.Consume)
	#health += sigils.count(Card.Sigil.Consume)
	%AttackCost.text = str(attack)
	%HealthCost.text = str(health)


#region damage functions
func take_damage(amount : int):
	GlobalLog.add_entry("Card '%s' was dealt %d damage!" % [card_data.name, amount])
	health -= amount
	%HealthCost.text = str(health)
	$Health.modulate = attacked_color


func restore_default_color():
	modulate = Color.WHITE
	$Health.modulate = Color.WHITE
	$Attack.modulate = Color.WHITE
	$Cost.modulate = Color.WHITE


func proccess_death() -> bool:
	if health <= 0:
		#$VBoxContainer/Name/Label.text = "The DEAD!"
		modulate = attacked_color
		await get_tree().create_timer(death_delay).timeout
		print("Card '", card_name, "' died!")
		GlobalLog.add_entry("Card '%s' at position %d-%d died!" % [card_data.name, tile_coordinate.x, tile_coordinate.y])
		queue_free()
		return true
	return false
#endregion


func animate_attack(target, tile_idx) -> bool:
	$Attack.modulate = active_color
	modulate = highlight_color
	target.take_damage(attack)
	await get_tree().create_timer(attack_delay).timeout
	target.restore_default_color()
	restore_default_color()
	if target is CombatCard:
		GlobalLog.add_entry("Card '%s' at position %d-%d attacked card '%s' at position %d-%d." % [card_data.name, tile_coordinate.x, tile_coordinate.y, \
		 target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	else:
		GlobalLog.add_entry("Card '%s' at position %d-%d attacked empty tile at position %d-%d." % [card_data.name, tile_coordinate.x, tile_coordinate.y, \
		 1 if is_enemy else 0, tile_idx])
	var was_lethal = await target.proccess_death()
	var is_battle_over = false
	if was_lethal and (target is EnemyPlayer or target is CardPlayer):
		is_battle_over = true
	if was_lethal:
		for i in range(keywords.size()):
			if keywords[i] is ActivatedKeyword and keywords[i].triggers & 1:
				keywords[i].trigger(target, self)
				$KeyWords.get_child(i).scale = Vector2(1.2, 1.2)
				await get_tree().create_timer(keywords[i].highlight_duration).timeout
				$KeyWords.get_child(i).scale = Vector2.ONE
	return is_battle_over


func animate_karma(target):
	$Cost.modulate = active_color
	modulate = highlight_color
	var overflow = target.modify_karma(cost)
	await get_tree().create_timer(karma_delay).timeout
	GlobalLog.add_entry("Card '%s' at position %d-%d added %d karma." % \
	[card_data.name, tile_coordinate.x, tile_coordinate.y, cost])
	target.restore_default_color()
	restore_default_color()


func animate_move(target_pos):
	modulate = active_color
	global_position = target_pos
	await get_tree().create_timer(move_speed).timeout # todo interpolate move 
	GlobalLog.add_entry("Card '%s' at position %d-%d moved to positon %d-%d." % \
	[card_data.name, tile_coordinate.x, tile_coordinate.y, tile_coordinate.x, tile_coordinate.y - 1])
	tile_coordinate = Vector2i(tile_coordinate.x, tile_coordinate.y - 1)
	modulate = Color.WHITE


func set_delete_mode(value : bool):
	if value:
		%DeleteButton.show()
	else:
		%DeleteButton.hide()


func _on_delete_button_pressed():
	queue_free()
