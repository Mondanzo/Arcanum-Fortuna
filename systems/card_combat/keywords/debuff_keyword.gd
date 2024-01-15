class_name DebuffKeyword
extends ActivatedKeyword

@export_flags("EnemyInFront", "EnemyWithHighestAttack") var target_options
@export var attack_debuff := 1
@export var health_debuff := 0

var debuffed_cards_lookup : Dictionary = {}


func init(id = 3):
	if title.count('%d') == 2:
		title = title % [attack_debuff, health_debuff]
	elif title.count('%d') == 1:
		title = title % attack_debuff if health_debuff == 0 else health_debuff

	if description.count('%d') == 2:
		description = description % [attack_debuff, health_debuff]
	elif description.count('%d') == 1:
		description = description % attack_debuff if health_debuff == 0 else health_debuff
	super.init(id)


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DeathrattleAtk: Combat must be provided!")
		return
	var targets : Array[CombatCard] = []
	var opposing_row = combat.game_board.get_enemy_front_row() if not owner.is_enemy \
			else combat.game_board.get_friendly_row()
	if target_options & 1 and opposing_row[owner.tile_coordinate.x] != null:
			targets.append(opposing_row[owner.tile_coordinate.x])
	if target_options & 2:
		append_biggest_attack_target(owner, targets, \
				combat.game_board.get_front_enemies() if not owner.is_enemy \
				else combat.game_board.get_friendly_cards())
	return targets


func append_biggest_attack_target(owner, targets, opposing_cards):
	var highest_attack = -INF
	var target = null
	for card : CombatCard in opposing_cards:
		var attack = card.attack
		if owner in debuffed_cards_lookup and card in debuffed_cards_lookup[owner]:
			attack += attack_debuff
		if attack > highest_attack:
			target = card
	if target != null:
		targets.append(target)


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered '%s'." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y, title])
	
	if not debuffed_cards_lookup.has(owner):
		debuffed_cards_lookup[owner] = []
	
	for card in debuffed_cards_lookup[owner]:
		if is_instance_valid(card):
			card.attack += attack_debuff
			card.health += health_debuff
	if owner.health <= 0:
		print("[Keyword] Card " + str(owner) + " died and removed their Debuff.")
		return
	for card : CombatCard in target:
		card.attack -= attack_debuff
		card.health -= health_debuff
	debuffed_cards_lookup[owner] = target
