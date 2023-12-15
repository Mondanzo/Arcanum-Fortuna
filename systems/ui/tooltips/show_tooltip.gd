class_name ShowTooltip
extends Control

@export_category("Tooltip Settings")
@export var icon: Texture2D
@export var title := "Tooltip"
@export_multiline var text := "Lorem Ipsum... dolor sit amet..."
@export var tooltip_template : PackedScene = preload("res://systems/ui/tooltips/tooltip_basic.tscn")
@export var offset := Vector2.ZERO


@export_subgroup("Trigger Settings")
@export var trigger_automatically := true
@export_flags("Hover Duration", "Right-Click") var trigger_mode := 0b11
@export var hover_min_duration := 0.5

@onready var cooldown := hover_min_duration

var is_hovered := false
var instance: TooltipBase = null:
	set(value): instance = create_instance(value)

static var tooltip_container = null


func _exit_tree():
	hide_tooltip()


func create_instance(value):
	if value == null:
		return null
	var new_instance = value as TooltipBasic
	new_instance.setup(title, icon, text)
	return new_instance

func show_tooltip():
	if not tooltip_container:
		tooltip_container = CanvasLayer.new()
		tooltip_container.name = "tooltip_container"
		tooltip_container.layer = 10
		get_tree().root.add_child(tooltip_container)

	if not instance:
		instance = tooltip_template.instantiate()
		tooltip_container.add_child(instance)
		instance.global_position = get_global_mouse_position() + offset


func hide_tooltip():
	if instance:
		instance.queue_free()
		instance = null


func _input(event: InputEvent):
	if not trigger_automatically:
		return
	
	if not (trigger_mode & 0b1 << 1):
		return
	
	if event.is_action_pressed("show_tooltip"):
		if is_hovered:
			show_tooltip()

func _process(delta):
	if not trigger_automatically:
		return
	
	var parent_control = get_parent_control()
	if not parent_control:
		return
	
	if parent_control.has_method("is_hovered"):
		is_hovered = parent_control.is_hovered()
	elif "is_hovered" in parent_control:
		is_hovered = parent_control.is_hovered
	else:
		is_hovered = (
				Rect2(Vector2(), parent_control.get_rect().size)
				.has_point(parent_control.get_local_mouse_position())
			)
	
	if is_hovered:
		cooldown -= delta
	else:
		cooldown = hover_min_duration
		hide_tooltip()
	
	if cooldown <= 0 and trigger_mode & 0b1:
		show_tooltip()
