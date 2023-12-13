class_name CardTooltip
extends TooltipBase

@export var sigil_info_template: PackedScene = preload("res://Systems/UI/tooltips/keyword_info.tscn")


func setup(data : CardData):
	if data == null:
		push_error("Cannot setup Card Tooltip! CardData is missing!")
		return
	%CardName.text = data.name
	%CardDescription.text = data.description
	%CardArtwork.texture = data.artwork
	var added_keywords = []
	for keyword in data.keywords:
		if not keyword.get_script() in added_keywords:
			var keyword_tooltip = sigil_info_template.instantiate()
			keyword_tooltip.setup(keyword.title, keyword.description, keyword.icon)
			%Sigils.add_child(keyword_tooltip)
			added_keywords.append(keyword.get_script())


func _process(delta):
	var target_position = get_global_mouse_position() + mouse_offset
	var max_size = get_viewport_rect().size - $Container.get_rect().size
	target_position.x = clampf(target_position.x, 0, max_size.x)
	target_position.y = clampf(target_position.y, 0, max_size.y)
	global_position = target_position
