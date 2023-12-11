class_name ShowCardTooltip
extends ShowTooltip

var card_data : CardData


func create_instance(value):
	if value == null:
		return null
	var new_instance = value as CardTooltip
	new_instance.setup(card_data)
	return new_instance


func init(data : CardData):
	card_data = data
