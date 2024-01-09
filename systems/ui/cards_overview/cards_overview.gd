class_name CardsOverview
extends Control

@export var card_template: PackedScene

@export var player_data: PlayerData

var descending = true
var last_sort: Array[CardData]

static var instance

func _ready():
	instance = self
	_on_btn_karma_pressed()

static func toggle(visible: bool):
	if instance:
		instance.visible = visible

func filter_cards(cards: Array[CardData], filter_opts: FilterOptions) -> Array[CardData]:
	var result = cards.filter(func(card: CardData):
		if not filter_opts.attack_min == null:
			if card.attack < filter_opts.attack_min:
				return false
		if not filter_opts.attack_max == null:
			if card.attack >= filter_opts.attack_max:
				return false
		
		if not filter_opts.karma_min == null:
			if card.cost < filter_opts.karma_min:
				return false
		if not filter_opts.karma_max == null:
			if card.cost >= filter_opts.karma_max:
				return false
		
		if not filter_opts.health_min == null:
			if card.health < filter_opts.health_min:
				return false
		if not filter_opts.health_max == null:
			if card.health >= filter_opts.health_max:
				return false
		
		for _keyword in filter_opts.keywords:
			var found = false
			for keyword in card.keywords:
				if is_instance_of(keyword, _keyword):
					found = true
			if not found:
				return false
		
		return true
	)
	
	return result


func show_cards(cards: Array[CardData]):
	for child in %CardsContainer.get_children():
		child.queue_free()
	
	for card in cards:
		var instance = card_template.instantiate() as Card
		instance.load_from_data(card)
		instance.setup()
		%CardsContainer.add_child(instance)


func _on_confirm_filter_pressed():
	var options = %FilterOptions.get_filter_options()
	show_cards(filter_cards(player_data.cardStack, options))


func refresh():
	var options = %FilterOptions.get_filter_options()
	show_cards(filter_cards(player_data.cardStack, options))
	%HealthCost.text = str(player_data.health)
	%MoneyAmount.text = str(player_data.currency)


func _on_btn_karma_pressed():
	var cards = player_data.cardStack.duplicate()
	cards.sort_custom(func(a, b): return a.cost > b.cost == descending)
	show_cards(cards)
	last_sort = cards


func _on_btn_health_pressed():
	var cards = player_data.cardStack.duplicate()
	cards.sort_custom(func(a, b): return a.health > b.health == descending)
	show_cards(cards)
	last_sort = cards

func _on_btn_attack_pressed():
	var cards = player_data.cardStack.duplicate()
	cards.sort_custom(func(a, b): return a.attack > b.attack == descending)
	show_cards(cards)
	last_sort = cards


func _on_btn_ordering_pressed():
	descending = !descending
	if descending:
		%btn_ordering.text = "descending"
	else:
		%btn_ordering.text = "ascending"
	last_sort.reverse()
	show_cards(last_sort)
