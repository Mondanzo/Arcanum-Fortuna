class_name Card extends Control

@export var card_data: CardData

var artwork_texture : Texture2D
var card_name : String
var cost : int
var attack : int
var health: int
var sigils : Array[Sigil]


enum Sigil {
	None = 0,
	AttackSplit = 1,
	Flip = 2,
	Consume = 3,
	Drain = 4,
	TrippleAttack = 5
}


func _ready():
	if card_data != null:
		load_from_data(card_data)
	setup()

func scale_to_fit(new_size):
	scale = get_rect().size / new_size

func copy(card : Card):
	init(card.artwork_texture, card.card_name, card.cost, card.attack, card.health, card.sigils)

func load_from_data(data: CardData):
	init(data.artwork, data.name, data.cost, data.attack, data.health, data.sigils)

func init(artwork_texture, name, cost, attack, health, sigils):
	self.artwork_texture = artwork_texture
	self.card_name = name
	self.cost = cost
	self.attack = attack
	self.health = health
	self.sigils = sigils

func update_texts():
	$VBoxContainer/Name/Label.text = card_name
	$Attack/Label.text = str(attack)
	$Health/Label.text = str(health)

func setup():
	$VBoxContainer/Artwork.texture = artwork_texture
	$VBoxContainer/Name/Label.text = card_name
	$Cost/Label.text = str(cost)
	$Attack/Label.text = str(attack)
	$Health/Label.text = str(health)
	
	for i in range(sigils.size()):
		$KeyWords.get_child(i).set_icon(sigils[i])

