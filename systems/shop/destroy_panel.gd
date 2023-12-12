extends Control


func is_hovered():
	return Rect2(Vector2.ZERO, get_rect().size).has_point(get_local_mouse_position())


func has_card():
	return get_child_count() > 0


func replace_card(new_card, old_parent):
	if get_child_count() > 0:
		get_child(0).reparent(old_parent)
	
	new_card.reparent(self)


func _process(delta):
	for child in get_children():
		child.move_around = false
		child.position = Vector2.ZERO


func destroy(player_data: PlayerData):
	if player_data.currency < 10:
		return
	if get_child_count() > 0:
		var card = get_child(0) as HandCard
		for idx in range(len(player_data.cardStack)):
			if player_data.cardStack[idx].name == card.card_name:
				player_data.cardStack.remove_at(idx)
				player_data.currency -= 10
				card.queue_free()
				break
