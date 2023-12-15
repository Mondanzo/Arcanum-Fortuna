extends Node

@export var gold_to_reward := 4

signal finished


func trigger(player_data: PlayerData):
	player_data.currency += gold_to_reward
	$AnimationPlayer.animation_finished.connect(func(_w): finished.emit())
	$AnimationPlayer.play("present")
