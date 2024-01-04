extends TextureRect

@export var grid_rows := 2
@export var grid_columns := 3

@export var descriptions : Array[KeywordDescription]
@export var generate_tooltip := false

var origin_position


func _ready():
	origin_position = position


func set_icon(id: int):
	texture = texture.duplicate()
	if id == 0:
		return
	var width = texture.atlas.get_size().x / grid_rows
	var height = texture.atlas.get_size().y / grid_columns
	
	id -= 1
	
	texture.region = Rect2(
			id % grid_rows * width,
			(id / grid_rows) * height,
			width, height)
	visible = true
	
	if not generate_tooltip:
		return
		
	var tooltipInfo = descriptions[id]
	var tooltip = ShowTooltip.new()
	tooltip.hover_min_duration = 0.8
	tooltip.title = tooltipInfo.tooltip_title
	tooltip.icon = tooltipInfo.tooltip_icon
	tooltip.text = tooltipInfo.tooltip_description
	add_child(tooltip)
