extends Control

@export var card_template: PackedScene

@export_category("Debug")
@export var is_debug := false
@export var debug_player_data: PlayerData

func _ready():
	if is_debug:
		setup(debug_player_data)

var player_data_ref: PlayerData

func setup(player_data: PlayerData):
	player_data_ref = player_data
	for card in player_data.cardStack:
		var instance = card_template.instantiate() as HandCard
		instance.init(card.artwork, card.name, card.cost, card.attack, card.health, card.keywords)
		%Hand.add_child(instance)
		instance.drag_ended.connect(on_card_dragged)


func _process(delta):
	%DestroyButton.disabled = not (%DestroyPanel.has_card() and player_data_ref.currency >= 10)
	%Money.text = str(player_data_ref.currency)

func destroy_card():
	%DestroyPanel.destroy(player_data_ref)


func on_card_dragged(card: HandCard):
	if %DestroyPanel.is_hovered():
		%DestroyPanel.replace_card(card, %Hand)
	else:
		card.reparent(%Hand)
