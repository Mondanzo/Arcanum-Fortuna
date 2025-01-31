class_name HandCard extends Card

signal drag_started
signal drag_ended(card)

static var heldCard : HandCard

var isPickedUp = false
var isHovered = false

var move_around := true
var base_scale = 1.0


func _ready():
	super._ready()
	base_scale = scale


func _notification(what):
	if what == NOTIFICATION_PARENTED:
		rotation = 0
		if get_parent().has_method("_on_card_added"):
			get_parent()._on_card_added(self)


func setup():
	super()
	mouse_entered.connect(self.mouse_entered_event)
	mouse_exited.connect(self.mouse_exited_event)


func _process(delta):
	var target_scale = base_scale
	if isHovered:
		target_scale = base_scale * 1.1
		z_index = 4
	else:
		z_index = 3
	
	if isPickedUp:
		z_index = 5
		var target_position = get_global_mouse_position()
		global_position = global_position.lerp(target_position, 0.1)
		%SFXCard._SFX_SetLoopProps((global_position - target_position).length(), global_position)
		target_scale = base_scale
	scale = scale.lerp(target_scale, 0.1)


func _input(event: InputEvent):
	if event.is_action_pressed("pickUpCard") and not isPickedUp:
		if isHovered:
			pickup()
	
	if event.is_action_released("pickUpCard") and isPickedUp:
		put(null)
		emit_signal("drag_ended", self)

func mouse_entered_event():
	isHovered = true

func mouse_exited_event():
	isHovered = false

func pickup():
	%ShowCardTooltip.hide_tooltip()
	%ShowCardTooltip.set_process(false)
	$SFXCard._SFX_PickUp()
	
	isPickedUp = true
	if heldCard:
		# Edge case if you pick up multiple cards
		heldCard.put(null)
	heldCard = self
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	emit_signal("drag_started")

func put(dropNode):
	$SFXCard._SFX_PutDown()
	%ShowCardTooltip.set_process(true)
	isPickedUp = false
	heldCard = null
	mouse_filter = Control.MOUSE_FILTER_PASS
