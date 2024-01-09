extends TextureRect

@export var grid_rows := 2
@export var grid_columns := 3

@export var descriptions : Array[KeywordDescription]
@export var generate_tooltip := false

var origin_position


func _ready():
	origin_position = position


func set_icon(keyword : Keyword):
	texture = keyword.icon
	visible = true
	
	if not generate_tooltip:
		return
		
	var tooltip = ShowTooltip.new()
	tooltip.hover_min_duration = 0.8
	tooltip.title = keyword.title
	tooltip.icon = keyword.icon
	tooltip.text = keyword.description
	add_child(tooltip)
