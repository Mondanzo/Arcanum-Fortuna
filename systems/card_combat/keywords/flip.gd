class_name Flip
extends ActivatedKeyword

@export_category("Animation")
@export var rotation_duration = 0.8
@export var icon_rotation = 1.0

func init(id = 2):
	super.init(id)


func trigger(source, owner, target, icon_to_animate, params={}):
	if not target.has_method("flip"):
		push_error("Keyword Flip was triggered from ", source, \
		", but target '", target, "' has no flip method!")
		return
	await super(source, owner, target, icon_to_animate, params)


func animate(source, target, icon_to_animate, params={}):
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
	tween.tween_property(card, "scale", Vector2.DOWN, rotation_duration / 2.0)
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2.ONE, rotation_duration / 2.0)
	tween.finished.connect(func(): icon_to_animate.is_animating = false)
	tween.play()
	await card.get_tree().create_timer(rotation_duration / 2).timeout
	target.flip()
	await card.get_tree().create_timer(rotation_duration / 2).timeout
