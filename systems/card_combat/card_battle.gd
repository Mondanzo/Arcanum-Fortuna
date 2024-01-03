class_name CardBattle
extends Control

signal player_turn_ended
signal finished(remaining_health : int)

var player_data : PlayerData

## Each turn consits of the phases in the order they appear here
@export var phases : Array[CombatPhase] = []
## Will be used as the intital phase
@export var phase_idx = 0
@export var phase_end_delay = 0.5

@export_category("Debug")
@export var show_current_phase_text := true
@export var is_debug : bool
@export var debug_player_data : PlayerData
@export var debug_enemy_data : DebugEnemyData

@onready var gameBoard : GameBoard = $GameBoard
@onready var player : CardPlayer = $CardPlayer
@onready var enemy : EnemyPlayer = $EnemyPlayer

var enemy_board : Array[Array]
var board_width : int = 5
var is_battle_over = false

func _ready():
	GlobalLog.set_context(GlobalLog.Context.COMBAT)
	GlobalLog.add_entry(name + " loaded.")
	lock_player_actions()
	if is_debug:
		await get_tree().process_frame # gameBoard needs to be ready first lol
		init(debug_player_data, debug_enemy_data)
		start_combat()


func _exit_tree():
	for phase : CombatPhase in phases:
		phase.reset()


func init(player_data, enemy_data):
	self.player_data = player_data
	player.init(player_data)
	enemy.init(enemy_data)
	enemy_board = enemy.get_rows()
	for phase in phases:
		phase.init(self)


func _input(event):
	if not OS.has_feature("no-cheat") && event.is_action_pressed("debug_quit"):
		finished.emit(player.health)


func start_combat():
	process_next_phase()


func process_next_phase():
	if show_current_phase_text:
		$CurrentPhaseLabel.text = "Current Phase: \n" + \
		phases[phase_idx].get_class_name()
	phases[phase_idx].execute()
	match await phases[phase_idx].completed:
		CombatPhase.ExitState.ABORT:
			return
		_:
			pass
	_on_phase_completed()


func _on_phase_completed():
	await get_tree().create_timer(phase_end_delay).timeout
	phase_idx += 1
	if phase_idx >= phases.size():
		phase_idx = 0
	process_next_phase()


func lock_player_actions():
	player.set_active(false)
	%CardDeletionButton.button_pressed = false
	%CardDeletionButton.disabled = true
	%EndTurnButton.disabled = true


func unlock_player_actions():
	player.set_active(true)
	%CardDeletionButton.disabled = false
	%EndTurnButton.disabled = false


func _on_end_turn_button_pressed():
	player_turn_ended.emit()


func handle_attacks(attacker, column, is_source_friendly):
	for offset in await attacker.get_target_offsets():
		await try_attack(attacker, column + offset, is_source_friendly)


func try_attack(attacker, column_idx, friendly = false) -> bool:
	var target = gameBoard.get_target(column_idx, friendly)
	var was_target_player = target is CardPlayer or target is EnemyPlayer
	if target == null:
		return false
	gameBoard.highlight_tile(column_idx, friendly)
	if await attacker.animate_attack(target, column_idx, gameBoard.get_tile(column_idx, friendly)):
		# IMPORTANT: target should be null here
		gameBoard._on_active_cards_changed(target)
		if was_target_player:
			finished.emit(player.health)
			is_battle_over = true
	gameBoard.end_tile_highlight(column_idx, friendly)
	await get_tree().process_frame
	return true


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
