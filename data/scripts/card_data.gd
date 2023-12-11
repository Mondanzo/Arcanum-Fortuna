class_name CardData extends Resource

@export var name := "Your Card"
@export var artwork: Texture2D
@export var cost := 1
@export var attack := 1
@export var health := 1
@export var sigils : Array[Card.Sigil]
@export var spawn_frequency : int = 100
