class_name CompanionshipATK
extends ActivatedKeyword

@export var attack_gain = 1

var buffed_cards : Array[CombatCard] = []


func init(id = 4):
	if title.count('%d') == 1:
		title = title % attack_gain
	if description.count('%d') == 1:
		description = description % attack_gain
	super.init(id)


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DeathrattleAtk: Combat must be provided!")
		return
	var targets : Array[CombatCard] = []
	var cards = combat.game_board.get_front_enemies() if owner.is_enemy \
			else combat.game_board.get_friendly_cards()
	for i in range(cards.size()):
		if cards[i] != owner:
			continue
		if i > 0 && cards[i-1] != null:
			targets.append(cards[i-1])
		if i < cards.size() - 1 && cards[i+1] != null:
			targets.append(cards[i+1])
		break
	return targets


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered Companionship ATK." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y])
	
	if owner.health <= 0:
		print("[Keyword] Card " + str(owner) + " died and removed their Companionship ATK.")
		for card in buffed_cards:
			if is_instance_valid(card):
				card.attack -= attack_gain
		return
	for card : CombatCard in target:
		if not card in buffed_cards:
			card.attack += attack_gain
	buffed_cards = target
