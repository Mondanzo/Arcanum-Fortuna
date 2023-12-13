extends Node

signal finished

@export var events: Array[PackedScene]

var event_queue = []
var player_data_ref

func trigger(player_data: PlayerData):
	player_data_ref = player_data
	for event in events:
		var instance = event.instantiate()
		event_queue.append(instance)
		instance.finished.connect(event_finished)
	
	event_finished()


func event_finished():
	var event = event_queue.pop_front()
	event.trigger(player_data_ref)
