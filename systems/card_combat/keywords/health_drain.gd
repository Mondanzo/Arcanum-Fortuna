class_name HealthDrain
extends ActivatedKeyword

@export var health_gain = 1
@export var enable_debug_print = false

var previous_health_gained := 0
var base_decription := ""


func init(id = 4):
	if description.count('%d') == 1:
		base_decription = description
		description = description % health_gain
	super.init(id)

func trigger(source, owner, target, icon, params={}):
	await super(source, owner, target, icon, params)
	if not target is CombatCard:
		push_error("Cannot apply HealthDrain. Invalid target ", target, ".")
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered Healthdrain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	if enable_debug_print:
		print("Health Drain triggered on ", target.card_name)
	var hit_count = 0
	for card : CombatCard in params.active_cards:
		if enable_debug_print:
			print("Card " + card.card_name + " costs " + str(card.cost))
		if card.cost > 0:
			hit_count += 1
	var new_health_gained = hit_count * health_gain
	var gain_difference = new_health_gained - previous_health_gained
	if enable_debug_print:
		print("Card health gain changed from " + str(previous_health_gained) \
				+ " to " + str(new_health_gained) + ". Health: " + str(target.health) + \
				" => " + str(target.health + gain_difference))
	target.health += gain_difference
	if target.health <= 0:
		target.health = 1
	previous_health_gained = new_health_gained
	target.update_texts()
	if base_decription.count('%d') < 2:
		base_decription = base_decription + " (%d)"
	description = base_decription % [health_gain, hit_count]
