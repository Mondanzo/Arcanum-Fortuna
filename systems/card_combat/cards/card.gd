class_name Card extends Control

@export var card_data: CardData

var artwork_texture : Texture2D
var card_name : String
var cost : int
var attack : int
var health: int
var keywords : Array[Keyword] = []


func _ready():
	if card_data != null:
		load_from_data(card_data)
	setup()

func scale_to_fit(new_size):
	scale = get_rect().size / new_size

func copy(card : Card):
	init(card.artwork_texture, card.card_name, card.cost, card.attack, card.health, card.keywords)

func load_from_data(data: CardData):
	init(data.artwork, data.name, data.cost, data.attack, data.health, data.keywords)

func init(artwork_texture, name, cost, attack, health, keywords):
	self.artwork_texture = artwork_texture
	self.card_name = name
	self.cost = cost
	self.attack = attack
	self.health = health
	self.keywords = keywords
	for keyword in keywords:
		keyword.init()


func update_texts():
	%Name.text = card_name
	%AttackCost.text = str(attack)
	%HealthCost.text = str(health)

func setup():
	%Artwork.texture = artwork_texture
	%Name.text = card_name
	%KarmaCost.text = str(cost)
	%AttackCost.text = str(attack)
	%HealthCost.text = str(health)
	
	for i in range(keywords.size()):
		%KeyWords.get_child(i).set_icon(keywords[i].id)

