class_name CombatCard extends Card

signal deleted(card : CombatCard)

@export var buff_color := Color.GREEN
@export var debuff_color := Color.RED

## If enabled enemy cards will flip (switch attack and health) when spawning with 0 Attack and having no way to increase it
@export var is_auto_flip = false

@export_category("Animation Settings")
@export var attack_speed = 0.2
@export var attack_rewind = 0.3
@export var attack_delay = 0.1
@export var death_delay = 1.0
@export var karma_delay = 1.0
@export var attacked_color : Color
@export var highlight_color : Color
@export var active_color : Color
@export var move_speed = 0.5

signal animation_finished

var target_offsets : Array[int] = [0]
var is_enemy := false
var tile_coordinate := Vector2i(-1, -1)
var base_attack : int
var base_health : int
var placed_position: Vector2

var __is_animating := false
var is_animating: bool:
	set(new_value):
		__is_animating = new_value
	get:
		for keyword_slot in %KeyWordSlots.get_children():
			if keyword_slot.get_child(0).is_animating:
				return true
		return __is_animating


func set_attack(value):
	super.set_attack(value)
	if attack > base_attack:
		%AttackCost.self_modulate = buff_color
	elif attack < base_attack:
		%AttackCost.self_modulate = debuff_color
	else:
		%AttackCost.self_modulate = Color.WHITE


func set_health(value):
	super.set_health(value)
	if health > base_health:
		%HealthCost.self_modulate = buff_color
	elif health < base_health:
		%HealthCost.self_modulate = debuff_color
	else:
		%HealthCost.self_modulate = Color.WHITE


func setup():
	super.setup()
	base_attack = attack
	base_health = health
	attack = base_attack
	health = base_health
	for keyword_slot in %KeyWordSlots.get_children():
		keyword_slot.get_child(0).animation_finished.connect(check_if_animations_finished)
	
	if card_data.sound_effect:
		%SFXCard.SFX_CardSignature = card_data.sound_effect
		%SFXCard._SFX_Signature()


func make_enemy():
	is_enemy = true
	#$Cost.hide()
	if is_auto_flip and attack == 0 and keywords.filter(func(keyword): 
			return keyword is Drain or keyword is Flip or keyword is ATK_Drain).size() == 0:
		flip()


func trigger_keywords(source, owner, trigger : int, combat = null):
	for i in range(keywords.size()):
		if keywords[i] is ActivatedKeyword and keywords[i].triggers & trigger:
			await keywords[i].trigger(source, owner, keywords[i].get_target(source, owner, combat), \
					get_node("KeyWordSlots").get_child(i).get_child(0))


func check_if_animations_finished():
	if not is_animating:
		animation_finished.emit()


func flip():
	%Artwork.flip_h = !%Artwork.flip_h
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
	placed_position = global_position
	target_offsets = [0]
	for i in range(keywords.size()):
		if not keywords[i] is ActivatedKeyword and keywords[i].has_method("get_new_targets"):
			target_offsets = keywords[i].get_new_targets(target_offsets, self)
	return target_offsets


#region damage functions

func heal(amount : int):
	pass


func take_damage(amount : int):
	GlobalLog.add_entry("'%s' at position %d-%d was dealt %d damage!" % \
	[card_data.name, tile_coordinate.x, tile_coordinate.y, amount])
	for keyword in keywords:
		if keyword.has_method("get_reduced_damage"):
			amount = keyword.get_reduced_damage(self, amount)
	health -= amount
	modulate = attacked_color if amount > 0 else active_color
	await animate_damage()


func animate_damage():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", rotation + deg_to_rad(-5), 0.2)
	tween.tween_property(self, "rotation", rotation, 0.1)
	tween.play()


func restore_default_color():
	modulate = Color.WHITE
	$Health.modulate = Color.WHITE
	$Attack.modulate = Color.WHITE
	$Cost.modulate = Color.WHITE


func process_death() -> bool:
	if health <= 0:
		await get_tree().process_frame
		if is_animating:
			await animation_finished
		modulate = attacked_color
		await get_tree().create_timer(death_delay).timeout
		print("Card '", card_name, "' died!")
		GlobalLog.add_entry("'%s' at position %d-%d died!" % [card_data.name, tile_coordinate.x, tile_coordinate.y])
		queue_free()
		return true
	return false
#endregion


func animate_attack(target, tile_idx, tile: Control) -> bool:
	%SFXCard._SFX_Attack()
	var target_position
	var half_card = get_rect().size.x / 2
	if target is CombatCard:
		GlobalLog.add_entry(
				"'%s' at position %d-%d attacked '%s' at position %d-%d." %
				[card_data.name,
				tile_coordinate.x,
				tile_coordinate.y,
				target.card_data.name,
				target.tile_coordinate.x,
				target.tile_coordinate.y])
		target_position = target.global_position
	else:
		GlobalLog.add_entry(
				"'%s' at position %d-%d attacked empty tile at position %d-%d." %
				[card_data.name,
				tile_coordinate.x,
				tile_coordinate.y,
				tile_idx, 0 if is_enemy else 1
				])
		target_position = tile.global_position
	
	var attack_tween = create_tween()
	z_index += 1
	attack_tween.set_trans(Tween.TRANS_SINE)
	attack_tween.set_ease(Tween.EASE_IN)
	var wait_mod = 0
	if not global_position.is_equal_approx(placed_position):
		attack_tween.tween_property(self, "global_position", placed_position, attack_rewind)
		wait_mod += attack_rewind
	attack_tween.tween_property(self, "global_position", target_position, attack_speed)
	attack_tween.set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "global_position", placed_position, attack_rewind)
	attack_tween.play()
	await get_tree().create_timer(attack_speed + wait_mod).timeout
	
	target.take_damage(attack)
	$Attack.modulate = active_color
	modulate = highlight_color
	get_tree().create_timer(max(attack_delay - wait_mod, 0)).timeout.connect(func():
		target.restore_default_color()
		restore_default_color()
		z_index -= 1
	)
	
	var was_lethal = target.health <= 0
	var is_battle_over = false
	if was_lethal and (target is EnemyPlayer or target is CardPlayer):
		is_battle_over = true
	if was_lethal:
		await get_tree().process_frame
		trigger_keywords(target, self, 1)
	return was_lethal


func animate_karma(target):
	GlobalLog.add_entry("'%s' at position %d-%d added %d karma."\
			% [card_data.name, tile_coordinate.x, tile_coordinate.y, cost])
	return %KarmaCost


func animate_move(target_pos):
	placed_position = target_pos
	modulate = active_color
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, move_speed)
	tween.play()
	await get_tree().create_timer(move_speed).timeout # todo interpolate move 
	GlobalLog.add_entry("'%s' at position %d-%d moved to positon %d-%d." % 
			[card_data.name,
			tile_coordinate.x,
			tile_coordinate.y,
			tile_coordinate.x,
			tile_coordinate.y - 1
			])
	tile_coordinate = Vector2i(tile_coordinate.x, tile_coordinate.y - 1)
	modulate = Color.WHITE


func set_delete_mode(value : bool):
	if value:
		%DeleteButton.show()
	else:
		%DeleteButton.hide()


func _on_delete_button_pressed():
	deleted.emit(self)
	queue_free()
