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
	for keyword in data.keywords:
		var keyword_tooltip = sigil_info_template.instantiate()
		keyword_tooltip.setup(keyword.title, keyword.description, keyword.icon)
		%Sigils.add_child(keyword_tooltip)
