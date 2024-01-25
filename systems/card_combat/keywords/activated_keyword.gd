class_name  ActivatedKeyword
extends Keyword

## Setup combat phases that should trigger this keyword
@export var combat_phase_triggers : Array[CombatPhaseTrigger] = []
## Setup other events that should trigger this keyword
@export_flags("OnKill", "OnKarmaDecrease", "OnActiveCardsChanged", "OnDeath", \
		"OnPlayed", "OnAttack") var triggers := 0

@export_category("Animation")
@export var is_animated := true
@export var scale_speed = 0.6


func get_target(source, owner, combat = null):
	return owner


func trigger(source, owner, target, icon_to_animate, params={}):
	if not is_animated:
		return
	await animate(source, owner, icon_to_animate, params)


func animate(source, owner: CombatCard, icon_to_animate, params):
	if emission_icon:
		await owner.animate_icon(emission_icon)
	return
	if icon_to_animate:
		var tween = icon_to_animate.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)
		tween.set_parallel(true)
		tween.tween_property(icon_to_animate, "scale", Vector2.ONE * 5.0, scale_speed)
		tween.tween_property(icon_to_animate, "position", Vector2(14, -85), scale_speed)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(false)
		tween.tween_property(icon_to_animate, "scale", Vector2.ONE, scale_speed)
		tween.set_parallel(true)
		tween.tween_property(icon_to_animate, "position", icon_to_animate.origin_position, scale_speed)
		tween.finished.connect(func(): icon_to_animate.is_animating = false)
		tween.play()
		await icon_to_animate.get_tree().create_timer(scale_speed).timeout
