class_name EventBase
extends Node

signal finished


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	if not is_inside_tree():
		Events.add_child(self)
