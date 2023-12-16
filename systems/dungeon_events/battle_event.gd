class_name BattleEvent
extends Node

@export var battleField: PackedScene
@export var winEvent: PackedScene
@export var loseEvent: PackedScene

var pauseMovement := true
var hideMap := true
var seed := 0

signal finished

func trigger(player_data: PlayerData, enemy_data: EnemyData):
	if not is_inside_tree():
		await tree_entered
	
	var field = battleField.instantiate()
	$CanvasLayer.add_child(field)
	field.is_debug = false
	field.init(player_data.duplicate(true), enemy_data.duplicate(true))
	field.start_combat()
	
	var remainingLife = await field.finished
	var won = remainingLife > 0
	
	player_data.health = remainingLife
	
	var event = winEvent if won else loseEvent
	
	if event:
		var instance = event.instantiate()
		if "seed" in instance:
			instance.seed = seed
		add_child(instance)
		instance.trigger(player_data, enemy_data)
		await instance.finished
	
	field.queue_free()
	finished.emit()
	queue_free()
