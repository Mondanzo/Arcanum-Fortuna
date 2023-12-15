class_name Hand extends Control

@export var lerpFactor := 0.3
@export var cardSpacing = 0
@export var cardHeight = 400
@export var cardHiddenHeight = 100
@export var cardArc = 0.05
@export var enabled := true : 
	get:
		return enabled
	set(value):
		enabled = value
		for child in get_children():
			child.set_process_input(value)

@export_category("DEBUG")
@export var is_debug := false
@export var card : PackedScene

var showCards = false
var is_card_dragged = false

func _process(delta):
	if get_global_mouse_position().y < get_viewport_rect().get_center().y:
		showCards = false
	
	if get_global_mouse_position().y > (get_viewport_rect().size.y - get_viewport_rect().size.y / 5):
		showCards = true
	
	if !enabled or is_card_dragged:
		showCards = false
	
	var count = get_child_count()
	
	if card && is_debug:
		if Input.is_action_just_pressed("ui_up"):
			var c = card.instantiate()
			add_child(c)
	
		if Input.is_action_just_pressed("ui_down"):
			if count == 0:
				return
		
			get_child(count - 1).queue_free()
	
	if count < 1:
		return
	
	var idx = 0
	for child in get_children():
		var card = child as Card
		if not card:
			continue
		if "isPickedUp" in card and card.isPickedUp:
			continue
		
		var width = card.get_rect().size.x + cardSpacing
		var posX = 0
		if count > 1:
			posX = ((float(idx) - (float(count) / 2.0)) / count) * min(width * count, 1920)
		var posY = curve(posX)
		card.position = card.position.lerp(Vector2(posX, -posY) + get_rect().size , lerpFactor)
		var rot = -derivative(posX)
		card.rotation = lerpf(card.rotation, rot, lerpFactor)
		idx += 1
	
	if lerpFactor >= 1:
		lerpFactor = 0.1
	
	queue_redraw()

func _on_card_drag_started():
	is_card_dragged = true

func _on_card_drag_ended(card):
	if not card in get_children():
		card.reparent(self)
	is_card_dragged = false

func _on_card_added(card : HandCard):
	if card.drag_started.is_connected(_on_card_drag_started):
		return
	card.drag_started.connect(_on_card_drag_started)
	card.drag_ended.connect(_on_card_drag_ended)


func curve(x):
	return (x * x) * (cardArc * 0.001) + (cardHeight if showCards else cardHiddenHeight)


func derivative(x):
	return -2 * x * (cardArc * 0.001)
