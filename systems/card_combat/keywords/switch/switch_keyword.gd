class_name SwitchKeyword
extends ActivatedKeyword

@export_category("Reward")
@export var attack_difference := 0
@export var health_difference := 0
@export var keywords_to_gain : Array[Keyword]
@export var keywords_to_remove : Array[Keyword]
@export var tranform_delay := 1.0

@export_category("Animation")
@export var rotation_duration = 0.8
@export var icon_rotation = 1.0


func _on_completed(owner : CombatCard, icon_to_animate = null):
	await animate_transform(owner, icon_to_animate)
	keywords_to_remove.append(self)
	owner.modifiy_keywords(keywords_to_remove, keywords_to_gain)
	owner.health += health_difference
	owner.health = max(1, owner.health)
	owner.attack += attack_difference


func animate_transform(target, icon_to_animate):
	if not target is Card:
		push_error("Can't animate a non-card!")
		return
	
	var card = target as Card
	
	if icon_to_animate is Control:
		var icon_tween = icon_to_animate.create_tween() as Tween
		icon_tween.set_ease(Tween.EASE_IN_OUT)
		icon_tween.set_trans(Tween.TRANS_BACK)
		icon_tween.tween_property(icon_to_animate, "rotation", deg_to_rad(360), icon_rotation)
		icon_tween.play()
	
	var tween = card.create_tween()
	target.get_node("%SFXCard")._SFX_Flip()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "scale", Vector2.RIGHT, rotation_duration / 2.0)
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2.ONE, rotation_duration / 2.0)
	tween.finished.connect(func(): icon_to_animate.is_animating = false)
	tween.play()
	await card.get_tree().create_timer(rotation_duration / 2).timeout
	target.reverse()
	await card.get_tree().create_timer(rotation_duration / 2).timeout
