class_name CardBattle extends Control

signal finished(remaining_health : int)

var player_data : PlayerData

@export_category("Debug")
@export var trigger_karma_on_turn_end = false
@export var trigger_karma_on_turn_start = true
@export var is_debug : bool
@export var debug_player_data : PlayerData
@export var debug_enemy_data : DebugEnemyData

@export var gameBoard : GameBoard
@onready var player : CardPlayer = $CardPlayer
@onready var enemy : EnemyPlayer = $EnemyPlayer
var enemy_board : Array[Array]
var board_width : int = 5

var is_battle_over = false

func _ready():
	if is_debug:
		await get_tree().process_frame # gameBoard needs to be ready first lol
		init(debug_player_data, debug_enemy_data)
		start_combat()


func init(player_data, enemy_data):
	self.player_data = player_data
	player.init(player_data)
	enemy.init(enemy_data)
	enemy_board = enemy.get_rows()


func _input(event):
	if OS.has_feature("debug") && event.is_action_pressed("debug_quit"):
		finished.emit(player.health)

func start_combat():
	update_enemy_card_placement()
	for i in range(player_data.start_hand_size):
		await player.draw_card()


func move_enemies():
	for y in range(enemy_board.size() - 1):
		for x in range(enemy_board[y].size()):
			if (enemy_board[y][x] == null &&  enemy_board[y+1][x] != null):
				if y == 1:
					gameBoard.place_enemy_card_back(enemy_board[y+1][x], x)
				elif y == 0:
					if await gameBoard.try_move_enemy_card_to_front(x):
						enemy_board[y+1][x] = null
					continue
				enemy_board[y][x] = enemy_board[y+1][x]
				enemy_board[y+1][x] = null


func update_enemy_card_placement():
	for x in range(board_width):
		if enemy_board.size() > 0 && enemy_board[0][x] != null:
			gameBoard.place_enemy_card_front(enemy_board[0][x], x)
			enemy_board[0][x] = null # front board row can only be set once via EnemyData
		if enemy_board.size() > 1 && enemy_board[1][x] != null:
			gameBoard.place_enemy_card_back(enemy_board[1][x], x)


func try_attack(attacker, column_idx, friendly = false) -> bool:
	var target = gameBoard.get_target(column_idx, friendly)
	if target == null:
		return false
	gameBoard.highlight_tile(column_idx, friendly)
	if await attacker.animate_attack(target):
		attacker.apply_consume()
		if target is CardPlayer or target is EnemyPlayer:
			finished.emit(player.health)
			is_battle_over = true
	gameBoard.end_tile_highlight(column_idx, friendly)
	await get_tree().process_frame
	return true


func handle_enemy_attacks():
	await move_enemies()
	for i in range(gameBoard.enemy_tiles_front.get_child_count()):
		if gameBoard.enemy_tiles_front.get_child(i).get_child_count() == 0:
			continue
		await handle_attacks(gameBoard.enemy_tiles_front.get_child(i).get_child(0), i, false)
		if is_battle_over:
			return


func handle_friendly_attacks():
	for i in range(gameBoard.player_tiles.get_child_count()):
		if gameBoard.player_tiles.get_child(i).get_child_count() == 0:
			continue
		await handle_attacks(gameBoard.player_tiles.get_child(i).get_child(0), i, true)
		if is_battle_over:
			return

func handle_attacks(attacker, column, is_source_friendly):
	if Card.Sigil.AttackSplit in attacker.sigils or \
		Card.Sigil.TrippleAttack in attacker.sigils:
		await try_attack(attacker, column-1, is_source_friendly)
	if !is_battle_over && not Card.Sigil.AttackSplit in attacker.sigils:
		await try_attack(attacker, column, is_source_friendly)
	if !is_battle_over && Card.Sigil.AttackSplit in attacker.sigils or \
		Card.Sigil.TrippleAttack in attacker.sigils:
		await try_attack(attacker, column+1, is_source_friendly)


func handle_friendly_karma():
	for card : CombatCard in gameBoard.get_friendly_cards():
		await card.animate_karma(player)
		if card.cost < 0:
			apply_drain()
	if await player.process_karma_overflow():
		finished.emit(player.health)
		is_battle_over = true


func apply_drain():
	for card in gameBoard.get_front_enemies():
		if card == null:
			continue
		for i in range(card.sigils.count(Card.Sigil.Drain)):
			card.attack += 1
			card.update_texts()
	for card in gameBoard.get_friendly_cards():
		if card == null || not Card.Sigil.Drain in card.sigils:
			continue
		for i in range(card.sigils.count(Card.Sigil.Drain)):
			card.attack += 1
			card.update_texts()


func _on_turn_end():
	player.set_active(false)
	$EndTurnButton.disabled = true
	await handle_friendly_attacks()
	if is_battle_over:
		return
	if trigger_karma_on_turn_end:
		await handle_friendly_karma()
		if is_battle_over:
			return
	await handle_enemy_attacks()
	if is_battle_over:
		return
	process_enemy_card_flips()
	_on_turn_start()


func process_friendly_card_flips():
	for card in gameBoard.get_friendly_cards():
		if card != null and Card.Sigil.Flip in card.sigils:
			card.flip()


func process_enemy_card_flips():
	for card in gameBoard.get_front_enemies():
		if card != null and Card.Sigil.Flip in card.sigils:
			card.flip()


func _on_turn_start():
	if trigger_karma_on_turn_start:
		await handle_friendly_karma()
	process_friendly_card_flips()
	player.set_active(true)
	await player.draw_card()
	$EndTurnButton.disabled = false


func _on_end_turn_button_button_down():
	_on_turn_end()
