extends Node

@export var possibleCards: Array[CardData]
@export var cardsToReward := 1
@export var cardsToChooseFrom := 3
@export var cardTemplate: PackedScene
@export var seed := 0

var rng := RandomNumberGenerator.new()

var pauseMovement := true

signal finished

var player_data_ref : PlayerData
var selected_cards = []


func _ready():
	rng.seed = seed


func trigger(player_data: PlayerData):
	
	if cardsToChooseFrom < cardsToReward:
		push_error("Cards to Choose from is less than the Cards that get rewarded! force adjusting")
		cardsToChooseFrom = cardsToReward
	
	player_data_ref = player_data
	if not is_inside_tree():
		await tree_entered
	var grabbag = possibleCards.duplicate()
	for i in range(cardsToChooseFrom):
		await get_tree().create_timer(.5).timeout
		var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
		if c:
			var visualCard = cardTemplate.instantiate() as Card
			visualCard.card_data = c
			visualCard.load_from_data(c)
			visualCard.setup()
			$CanvasLayer/Control/Cards.add_child(visualCard)
			visualCard.clicked.connect(card_clicked)
			$AudioStreamPlayer.play()
			visualCard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for c in $CanvasLayer/Control/Cards.get_children():
		if cardsToChooseFrom == cardsToReward:
			c.clicked.emit(c)
		else:
			c.mouse_filter = Control.MOUSE_FILTER_STOP


func card_clicked(card: Card):
	if card in selected_cards:
		var idx = selected_cards.find(card)
		if idx > -1:
			card.selected = false
			selected_cards.remove_at(idx)
	else:
		card.selected = true
		selected_cards.push_back(card)

	while len(selected_cards) > cardsToReward:
		selected_cards.pop_front()
	if len(selected_cards) == cardsToReward:
		$CanvasLayer/Control/ConfirmButton.show()
	else:
		$CanvasLayer/Control/ConfirmButton.hide()


func _on_confirm_button_pressed():
	$CanvasLayer/Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c : Card in $CanvasLayer/Control/Cards.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.isHovered = false
		if c in selected_cards:
			continue
		player_data_ref.cardStack.push_back(c.card_data.duplicate())
		c.queue_free()
	$CanvasLayer/Control/Button.show()
	await $CanvasLayer/Control/Button.pressed
	finished.emit()
	queue_free()
