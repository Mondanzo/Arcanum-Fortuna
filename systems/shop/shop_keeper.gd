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
