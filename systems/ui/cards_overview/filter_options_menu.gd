extends Control


func get_filter_options() -> FilterOptions:
	var result = FilterOptions.new()
	
	if $BtnConsume.button_pressed:
		result.keywords.append(Consume)
	if $BtnDrain.button_pressed:
		result.keywords.append(Drain)
	if $BtnFlip.button_pressed:
		result.keywords.append(Flip)
	if $BtnSplitAttack.button_pressed:
		result.keywords.append(SplitAttack)
	if $BtnTripleAttack.button_pressed:
		result.keywords.append(TripleAttack)
	
	if $KarmaSliderMin.value != $KarmaSliderMin.min_value:
		result.karma_min = $KarmaSliderMin.value
	if $KarmaSliderMax.value != $KarmaSliderMax.max_value:
		result.karma_max = $KarmaSliderMax.value
	
	if $AttackSliderMin.value != $AttackSliderMin.min_value:
		result.attack_min = $AttackSliderMin.value
	if $AttackSliderMax.value != $AttackSliderMax.max_value:
		result.attack_max = $AttackSliderMax.value
	
	if $HealthSliderMin.value != $HealthSliderMin.min_value:
		result.health_min = $HealthSliderMin.value
	if $HealthSliderMax.value != $HealthSliderMax.max_value:
		result.health_max = $HealthSliderMax.value
	
	return result


func update_slider_text(label, n, min, max):
	label.text = "%s (%d - %d)" % [n, min, max]


func _on_health_slider_value_changed(value):
	update_slider_text($LabelHealth, "Health", $HealthSliderMin.value, $HealthSliderMax.value)


func _on_attack_slider_value_changed(value):
	update_slider_text($LabelAttack, "Attack", $AttackSliderMin.value, $AttackSliderMax.value)


func _on_karma_slider_value_changed(value):
	update_slider_text($LabelKarma, "Karma", $KarmaSliderMin.value, $KarmaSliderMax.value)
