class_name CardData extends Resource

@export var name := "Your Card"
@export_multiline var description := "It can do stuff."
@export var artwork: Texture2D
@export var cost := 1
@export var attack := 1
@export var health := 1
@export var keywords : Array[Keyword]
@export var spawn_frequency : int = 100
