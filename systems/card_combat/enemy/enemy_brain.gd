class_name EnemyBrain extends Resource


@export var available_cards : Array[CardData]

@export_category("Strategy")
@export var strategy_modules : Array[EnemyBrainStrategyModule]

var rng := RandomNumberGenerator.new()
var stats : EnemyBrainStats 
var rows : Array[Array] = []
var owner : EnemyPlayer
var board : GameBoard
var combat : CardBattle


func init(stats: EnemyBrainStats, new_owner : EnemyPlayer, combat_context : CardBattle, seed : int):
	owner = new_owner
	self.stats = stats
	rng.seed = seed
	combat = combat_context

func get_random_health():
	return stats.min_health + rng.randi() % (stats.max_health - stats.min_health + 1) 

func get_possible_moves_rec(card_count, current_combi, res, added_card = null):
	if added_card != null:
		current_combi.append(added_card)
	if current_combi.size() >= card_count:
		res.append(current_combi)
		return
	for card in available_cards:
		get_possible_moves_rec(card_count, current_combi.duplicate(), res, card)

func get_possible_moves(target_columns : Array[int]) -> Array[Move]:
	var res = []
	var combis = []
	var tmp = ""
	get_possible_moves_rec(target_columns.size(), [], combis)
	for combi in combis:
		var possible_move = Move.new()
		var i = 0
		for card in combi:
			tmp += card.name + "-"
			possible_move.card_placements.append(CardPlacement.new(target_columns[i], card))
			i += 1
		print(tmp)
		tmp = ""
		res.append(possible_move)
	return res


class Move:
	var card_placements : Array[CardPlacement]
	var points := 0.0


class CardPlacement:
	var target_column := 0
	var card := CardData
	
	func _init(column, card):
		target_column = column
		self.card = card
