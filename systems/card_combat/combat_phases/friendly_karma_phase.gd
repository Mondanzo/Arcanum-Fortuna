class_name FriendlyKarmaPhase
extends CombatPhase

@export var karma_blob = preload("res://assets/vfx/big_blob.tscn")
@export var small_blob = preload("res://assets/vfx/karma_particle.tscn")
@export var karma_duration := 2.3
@export var karma_delay := 0.6


static func get_class_name():
	return "Friendly Karma Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.FRIENDLY_KARMA


func _on_karma_decreased(source):
	for card : CombatCard in combat.gameBoard.get_active_cards():
		for i in range(card.keywords.size()):
			if card.keywords[i] is ActivatedKeyword and card.keywords[i].triggers & 2:
				await card.keywords[i].trigger(source, card, card.get_node("KeyWords").get_child(i))

func process_effect() -> ExitState:
	# Create Blob
	var blob = karma_blob.instantiate()
	combat.gameBoard.add_child(blob)
	blob.global_position = Vector2(1920 / 2, 1080 / 2)
	
	var total_wait_count = 0.0

	for card : CombatCard in combat.gameBoard.get_friendly_cards():
		var health_slot = await card.animate_karma(combat.player)
		var small_pearl = small_blob.instantiate()
		combat.gameBoard.add_child(small_pearl)
		small_pearl.global_position = health_slot.global_position
		
		await combat.get_tree().create_timer(karma_delay).timeout
		var tween = combat.create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_EXPO)
		
		tween.tween_property(small_pearl, "global_position", blob.global_position, karma_delay)
		
		tween.finished.connect(func():
			blob.update_number(card.cost)
			small_pearl.emitting = false
			small_pearl.queue_free()
			blob.global_position += card.global_position.direction_to(blob.global_position) * 20
		)
		
		tween.play()
		
		if card.cost < 0:
			var start_time = Time.get_unix_time_from_system()
			await _on_karma_decreased(card)
			var duration = Time.get_unix_time_from_system() - start_time
			if duration >= karma_duration:
				
				continue
			
			total_wait_count += karma_duration - duration
	
	await combat.get_tree().create_timer(karma_delay).timeout
	
	# Put Blob into player.
	var t = blob.create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_EXPO)
	
	t.tween_property(blob, "global_position", combat.player.get_node("%Karma").global_position + Vector2.DOWN * 30, karma_delay)
	t.tween_property(blob, "scale", Vector2.ZERO, karma_delay)
	
	t.play()
	await combat.get_tree().create_timer(karma_delay).timeout
	combat.player.modify_karma(blob.count)
	blob.get_tree().create_timer(0.1).timeout.connect(func(): blob.queue_free())
	
	if await combat.player.process_karma_overflow():
		combat.finished.emit(combat.player.health)
		return ExitState.ABORT
	return ExitState.DEFAULT

