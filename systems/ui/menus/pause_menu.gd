extends CanvasLayer

@export_category("Pause Menu")
@export var can_pause = true


var pre_paused = false



func _ready():
	visible = false


func toggle_pause_menu():
	if visible:
		hide_pause_menu()
	else:
		show_pause_menu()


func hide_pause_menu():
	visible = false
	get_tree().paused = pre_paused


func show_pause_menu():
	if not can_pause:
		return
	visible = true
	pre_paused = get_tree().paused
	get_tree().paused = true


func _on_btn_continue_pressed():
	hide_pause_menu()


func _on_btn_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://systems/ui/main_menu.tscn")
	hide_pause_menu()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()
