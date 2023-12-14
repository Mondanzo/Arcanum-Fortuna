extends CanvasLayer

signal finished
@export_file("*.tscn") var main_menu_scene = ""


func _ready():
	GlobalLog.set_context(GlobalLog.Context.MENU)
	GlobalLog.add_entry(name + " loaded.")


func trigger(player_data: PlayerData):
	pass


func quit():
	get_tree().quit()


func restart():
	get_tree().reload_current_scene()


func _on_btn_main_menu_button_down():
	get_tree().change_scene_to_file(main_menu_scene)
