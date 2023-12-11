class_name CardStack extends Control

## Node that should hold the cards for drawing
@export var target: Node
@export var deckCardTemplate: PackedScene
@export var rng_seed := 1337
var rng : RandomNumberGenerator

var cardStack := []

func _ready() -> void:
	update_text()
	
func init(seed : int):
	rng_seed = seed
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed

func update_text():
	$TextureRect/CardCount.text = "Cards left: " + str(cardStack.size())


func shuffle():
	if rng == null:
		print("Shuffling using built-in shuffle")
		cardStack.shuffle()
		return
	
	# Fisher Shuffle
	print("Shuffling using fisher technique")
	for i in range(len(cardStack) - 1, 0, -1):
		var other = rng.randi_range(0, len(cardStack) - 1)
		if i == other:
			continue
		var t = cardStack[i]
		cardStack[i] = cardStack[other]
		cardStack[other] = t


func put_card_in_stack(card: CardData):
	cardStack.append(card)
	update_text()

func draw_card(hand: Node):
	if len(cardStack) <= 0:
		return null
	
	var cardData = cardStack.pop_back()
	var card = deckCardTemplate.instantiate() as Card
	card.load_from_data(cardData)
	add_child(card)
	card.global_position = global_position
	card.mouse_filter = MOUSE_FILTER_IGNORE
	card.reparent(hand)
	card.mouse_filter = MOUSE_FILTER_STOP

	#visible = len(cardStack) > 0
	update_text()
	return card
