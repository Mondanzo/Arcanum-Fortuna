@tool
class_name EventNode extends Control

var isCurrent := false
@export var connectsTo: Array[EventNode]
var connectedFrom: Array[EventNode] = []
@export_range(0, 10) var lookahead := 2
var currentLookahead = 0

@export var no_card_overview := false

@export var event: PackedScene

@export_category("Display Options")
@export var defaultColor := Color.WHITE
@export var pickedColor := Color.YELLOW
@export var disabledColor := Color.GRAY
@export var highlightedColor := Color.BLUE
@export var width := 5.0
@export var dashed_width := 3.0
@export var offset := 2.0

var selectable = false
var player: Player
var selectedNode: EventNode
var hovering = false
var eventInProgress := false
var passed = false
var seed = 0
static var nodes_counter := 0

signal on_stepped_on


func _ready():
	nodes_counter += 1
	name += "+" + str(nodes_counter)
	$background/icon.visible = false
	for n in connectsTo:
		n.connectedFrom.append(self)


func get_required_color(node: EventNode):
	if node.hovering and node.selectable:
		return node.pickedColor
	if node.selectable:
		return defaultColor
	return node.disabledColor


func _process(delta):
	if selectable or Engine.is_editor_hint() or true:
		$background/icon.visible = true
	
	for node in connectsTo:
		if not is_instance_valid(node):
			continue
		
		if isCurrent:
			selectable = false
			node.player = player
			node.selectable = not eventInProgress
		
		if passed:
			node.selectable = false
	
	if passed:
		passed = false
	
	queue_redraw()



func _input(event: InputEvent):
	if (
			hovering
			and event.is_action_pressed("pickUpCard")
			and selectable
		):
		click()

func click():
	SfxOther._SFX_UIButtonPress()
	on_stepped_on.emit()
	GlobalLog.set_context(GlobalLog.Context.NODEMAP)
	GlobalLog.add_entry("went to " + name)
	player.update_target(self)
	for c in connectedFrom:
		c.passed = true
	
	eventInProgress = true
	await _trigger_event()
	eventInProgress = false

func _trigger_event():
	if event:
		if no_card_overview:
			CardsOverlay.toggle(false)
		var instance = event.instantiate()
		if "seed" in instance:
			instance.seed = seed
		instance.trigger(player.data, null)
		await instance.finished
		if no_card_overview:
			CardsOverlay.toggle(true)


func _draw():
	for node in connectedFrom:
		var target = node.position + (node.get_rect().size * Vector2(1, -1)) / 2 - position
		var direction = target.normalized()
		draw_dashed_line(direction * offset, target - direction * offset, get_required_color(self), width, dashed_width, true)
		
	for node in connectsTo:
		var target = node.position + (node.get_rect().size * Vector2(1, -1)) / 2 - position
		var direction = target.normalized()
		draw_dashed_line(direction * offset, target - direction * offset, get_required_color(node), width, dashed_width, true)


func _generated(node_index: int, level: int, _rng: RandomNumberGenerator):
	seed = _rng.randi()


func _on_mouse_entered():
	if selectable:
		SfxOther._SFX_UIButtonHover()
	hovering = true


func _on_mouse_exited():
	hovering = false
