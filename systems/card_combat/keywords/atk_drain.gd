class_name ATK_Drain
extends ActivatedKeyword

@export var attack_gain = 1

## If this is enabled only cards on the same side as the card containing this keyword will be considered for the buff
@export var scale_from_same_side_only = false
@export var enable_debug_print = false

var base_decription := ""
var granted_bufffs : Dictionary = {}

func init(id = 4):
	if description.count('%d') == 1:
		base_decription = description
		description = description % attack_gain
	super.init(id)

func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not target is CombatCard:
		push_error("Cannot apply ATKDrain. Invalid target ", target, ".")
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered ATKdrain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	if not granted_bufffs.has(owner):
		granted_bufffs[owner.get_instance_id()] = 0
	else:
		target.attack -= granted_bufffs[owner.get_instance_id()]
		granted_bufffs[owner.get_instance_id()] = 0 
	if enable_debug_print:
		print("ATK Drain triggered on ", target.card_name)
	var hit_count = 0
	for card : CombatCard in params.active_cards:
		if enable_debug_print:
			print("Card '" + card.card_name + "' costs " + str(card.cost))
		if card.cost > 0 and (!scale_from_same_side_only or card.is_enemy == owner.is_enemy):
			hit_count += 1
			var print_str = str(granted_bufffs[owner.get_instance_id()])
			granted_bufffs[owner.get_instance_id()] += attack_gain
			if enable_debug_print:
				print(print_str + " + " + str(attack_gain) + " = " + str(granted_bufffs[owner.get_instance_id()]))
	if enable_debug_print:
		print(str(target.attack) + " => " + str(target.attack + granted_bufffs[owner.get_instance_id()]))
	target.attack += granted_bufffs[owner.get_instance_id()]
	if base_decription.count('%d') < 2:
		base_decription += " (%d)"
	description = base_decription % [attack_gain, hit_count]
