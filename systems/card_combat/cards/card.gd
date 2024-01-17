class_name Card extends Control

@export var card_data: CardData

var artwork_texture : Texture2D
var card_name : String
var cost : int
var attack : int : set = set_attack, get = get_attack
var health: int : set = set_health, get = get_health
var keywords : Array[Keyword] = []

var is_hovered := false


func _ready():
	if card_data != null:
		load_from_data(card_data)
	setup()


func set_attack(value):
	attack = value
	%AttackCost.text = str(attack)


func get_attack():
	return attack



func set_health(value):
	health = value
	%HealthCost.text = str(health)


func get_health():
	return health


func scale_to_fit(new_size):
	scale = get_rect().size / new_size


func copy(card : Card):
	card_data = card.card_data
	init(card.artwork_texture, card.card_name, card.cost, card.attack, card.health, card.keywords)


func load_from_data(data: CardData):
	card_data = data
	init(data.artwork, data.name, data.cost, data.attack, data.health, data.keywords)


func init(artwork_texture, name, cost, attack, health, keywords):
	self.artwork_texture = artwork_texture
	self.card_name = name
	self.cost = cost
	self.attack = attack
	self.health = health
	self.keywords = keywords
	if card_data == null:
		card_data = CardData.new()
		card_data.artwork_texture = artwork_texture
		card_data.card_name = name
		card_data.cost = cost
		card_data.attack = attack
		card_data.health = health
		card_data.keywords = keywords
	for keyword in keywords:
		keyword.init()
	if has_node("%ShowCardTooltip"):
		%ShowCardTooltip.init(card_data)
	if card_data.sound_effect:
		$AudioStreamPlayer.stream = card_data.sound_effect


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
	
	for slot in %KeyWordSlots.get_children():
		slot.texture.atlas = null
		slot.texture = slot.texture.duplicate()
		slot.texture.atlas = card_data.keyword_slot_texture
	
	for i in range(keywords.size()):
		%KeyWordSlots.get_child(i).get_child(0).set_icon(keywords[i])


func _on_mouse_entered():
	is_hovered = true


func _on_mouse_exited():
	is_hovered = false
