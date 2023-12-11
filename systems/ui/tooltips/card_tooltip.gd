extends TooltipBase

@export var sigil_info_template: PackedScene = preload("res://Systems/UI/tooltips/keyword_info.tscn")


func setup(card_name: String,
		card_description: String,
		card_artwork: Texture2D,
		sigils_data: Array[KeywordDescription]
		):
	%CardName.text = card_name
	%CardDescription.text = card_description
	%CardArtwork.texture = card_artwork
	for info in sigils_data:
		var keyword_tooltip = sigil_info_template.instantiate()
		keyword_tooltip.setup()
		%Sigils.add_child(keyword_tooltip)
