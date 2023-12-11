extends TutorialAction

@export_file("*.tscn") var scene := ""

func _execute():
	get_tree().change_scene_to_file(scene)
