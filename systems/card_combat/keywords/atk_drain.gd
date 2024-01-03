class_name ATK_Drain
extends ActivatedKeyword

@export var attack_gain = 1

func init(id = 4):
	if description.count('%d') == 1:
		description = description % attack_gain
	super.init(id)

func trigger(source, target, params={}):
	if not target is CombatCard:
		push_error("Cannot apply ATKDrain. Invalid target ", target, ".")
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered ATKdrain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	target.attack = target.base_attack
	print("ATK Drain triggered on ", target.card_name)
	for card : CombatCard in params.active_cards:
		print("Card " + card.card_name + " costs " + str(card.cost))
		if card.cost > 0:
			var print_str = str(target.attack)
			target.attack += attack_gain
			print(print_str + " + " + str(attack_gain) + " = " + str(target.attack))
	print(str(target.base_attack) + " => " + str(target.attack))
	target.update_texts()
