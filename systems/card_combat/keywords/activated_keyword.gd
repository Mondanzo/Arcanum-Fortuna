class_name  ActivatedKeyword
extends Keyword

## Setup combat phases that should trigger this keyword
@export var combat_phase_triggers : Array[CombatPhaseTrigger] = []
## Setup other events that should trigger this keyword
@export_flags("OnKill", "OnKarmaDecrease", "OnActiveCardsChanged") var triggers := 0

@export_category("Animation")
@export var scale_speed = 0.6

func trigger(source, target, icon, params={}):
	await animate(source, target, icon, params)


func animate(source, target: CombatCard, icon, params):
	if icon:
		var prev_position = icon.position
		var tween = icon.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)
		tween.set_parallel(true)
		tween.tween_property(icon, "scale", Vector2.ONE * 5.0, scale_speed)
		tween.tween_property(icon, "position", Vector2(14, -85), scale_speed)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(false)
		tween.tween_property(icon, "scale", Vector2.ONE, scale_speed)
		tween.set_parallel(true)
		tween.tween_property(icon, "position", prev_position, scale_speed)
		tween.play()
		await icon.get_tree().create_timer(scale_speed * 2).timeout
