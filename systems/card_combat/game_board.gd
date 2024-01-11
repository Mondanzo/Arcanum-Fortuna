class_name GameBoard
extends VBoxContainer

@export var combat_card_prefab : PackedScene

@export var enemy_player : EnemyPlayer
@export var player : CardPlayer

@export_category("Style")
@export var tile_disabled_color : Color
@export var tile_interactible_color : Color
@export var tile_hovered_color : Color

var accept_card = false
var hovered_tile = null

@onready var player_tiles = $PlayerTiles
@onready var enemy_tiles_back = $EnemyTiles/Row1
@onready var enemy_tiles_front = $EnemyTiles/Row2

const width = 5

func _ready():
	for tile in $EnemyTiles.get_child(0).get_children():
		tile.self_modulate = tile_disabled_color
	for tile in $EnemyTiles.get_child(1).get_children():
		tile.self_modulate = tile_disabled_color
	for tile in $PlayerTiles.get_children():
		tile.self_modulate = tile_disabled_color


func get_enemy_tile_pos(y, x):
	return $EnemyTiles.get_child(y).get_child(x).global_position


func _on_card_dragged():
	for tile in $PlayerTiles.get_children():
		tile.self_modulate = tile_interactible_color
	accept_card = true


func _input(event):
	if not accept_card or not event is InputEventMouseMotion:
		return
	for tile in $PlayerTiles.get_children():
		if tile.get_global_rect().has_point(get_global_mouse_position()):
			tile.self_modulate = tile_hovered_color
			hovered_tile = tile
		else:
			if tile == hovered_tile:
				hovered_tile = null
			tile.self_modulate = tile_interactible_color


func _on_card_relased(card: Card):
	for tile in $PlayerTiles.get_children():
		tile.self_modulate = tile_disabled_color
	accept_card = false
	if not hovered_tile or hovered_tile.get_child_count() != 0:
		return
	card.reparent(hovered_tile)
	card.global_position = hovered_tile.global_position + Vector2(-20, -40)
	card.z_index = 2


func lock_friendly_cards():
	var i := -1
	for tile in player_tiles.get_children():
		i += 1
		if tile.get_child_count() == 0:
			continue
		var card = tile.get_child(0)
		if card is CombatCard:
			continue
		var new_combat_card = combat_card_prefab.instantiate()
		new_combat_card.copy(card)
		tile.add_child(new_combat_card)
		new_combat_card.scale_to_fit(tile.get_rect().size)
		new_combat_card.tile_coordinate = Vector2i(i, 0)
		GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
		[new_combat_card.card_data.name, i, 0])
		card.queue_free()
		await get_tree().process_frame
		_on_active_cards_changed(new_combat_card)


func place_enemy_card_front(cardData : CardData, tile_idx) -> bool:
	var target_tile = enemy_tiles_front.get_child(tile_idx)
	if target_tile.get_child_count() != 0:
		push_error("Can't place card. Enemy slot of id ", tile_idx, " is already filled!")
		return false
	var new_combat_card = combat_card_prefab.instantiate()
	new_combat_card.card_data = cardData
	new_combat_card.scale_to_fit(target_tile.get_rect().size)
	target_tile.add_child(new_combat_card)
	new_combat_card.make_enemy()
	new_combat_card.tile_coordinate = Vector2i(tile_idx, 1)
	GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
	[new_combat_card.card_data.name, tile_idx, 1])
	await get_tree().process_frame
	_on_active_cards_changed(new_combat_card)
	return true


func try_move_enemy_card_to_front(tile_idx):
	if enemy_tiles_front.get_child(tile_idx).get_child_count() != 0:
		return false
	if enemy_tiles_back.get_child(tile_idx).get_child_count() == 0:
		push_error("Tried moving nonexistent enemy at back tile ", tile_idx)
		return false
	await enemy_tiles_back.get_child(tile_idx).get_child(0).animate_move(get_enemy_tile_pos(1, tile_idx))
	enemy_tiles_back.get_child(tile_idx).get_child(0).reparent(enemy_tiles_front.get_child(tile_idx))
	await get_tree().process_frame
	_on_active_cards_changed(enemy_tiles_front.get_child(tile_idx).get_child(0))
	return true
	
func place_enemy_card_back(cardData : CardData, tile_idx) -> bool:
	var target_tile = enemy_tiles_back.get_child(tile_idx)
	if target_tile.get_child_count() != 0:
		push_error("Can't place card. Enemy slot of id ", tile_idx, " is already filled!")
		return false
	var new_combat_card = combat_card_prefab.instantiate()
	new_combat_card.card_data = cardData
	new_combat_card.scale_to_fit(target_tile.get_rect().size)
	target_tile.add_child(new_combat_card)
	new_combat_card.make_enemy()
	new_combat_card.tile_coordinate = Vector2i(tile_idx, 2)
	GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
	[new_combat_card.card_data.name, tile_idx, 2])
	return true


func get_target(tile_idx, is_friendly = false):
	if is_friendly:
		if tile_idx < 0 || tile_idx >= enemy_tiles_front.get_child_count():
			return null
		return enemy_tiles_front.get_child(tile_idx).get_child(0) \
			if enemy_tiles_front.get_child(tile_idx).get_child_count() != 0 else enemy_player
	if tile_idx < 0 || tile_idx >= player_tiles.get_child_count():
		return null
	return player_tiles.get_child(tile_idx).get_child(0) \
		if player_tiles.get_child(tile_idx).get_child_count() != 0 else player


func get_friendly_cards() -> Array[CombatCard]:
	var res : Array[CombatCard]
	for tile in player_tiles.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_front_enemies() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_front.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_back_enemies() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_back.get_children():
		if tile.get_child_count() != 0 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_enemy_front_row() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_front.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
		else:
			res.push_back(null)
	return res


func get_enemy_back_row() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_back.get_children():
		if tile.get_child_count() != 0 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
		else:
			res.push_back(null)
	return res


func _on_active_cards_changed(source):
	var active_cards = get_active_cards()
	for card : CombatCard in active_cards:
		for i in range(card.keywords.size()):
			if card.keywords[i] is ActivatedKeyword and card.keywords[i].triggers & 4:
				await card.keywords[i].trigger(source, card.keywords[i].get_target(self, card), \
						card.get_node("KeyWords").get_child(i), {"active_cards": active_cards})


func get_active_cards() -> Array[CombatCard]:
	return get_friendly_cards() + get_front_enemies()


func get_tile(idx, friendly = false):
	return ($PlayerTiles if not friendly else $EnemyTiles/Row2).get_child(idx)


func highlight_tile(idx, friendly = false):
	get_tile(idx, friendly).self_modulate = tile_hovered_color


func end_tile_highlight(idx, friendly = false):
	get_tile(idx, friendly).self_modulate = tile_disabled_color


func _on_card_deletion_button_toggled(toggled_on):
	for card : CombatCard in get_friendly_cards():
		card.set_delete_mode(toggled_on)
