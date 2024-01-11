extends Control


func quit_menu():
	queue_free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		quit_menu()
		get_viewport().set_input_as_handled()

