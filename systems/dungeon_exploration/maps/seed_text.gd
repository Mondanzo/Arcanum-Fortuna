extends Label

var seed := ""

func set_seed(seed_txt : String):
	seed = seed_txt
	text = "Seed: " + seed

func _input(event):
	if event is InputEventMouseButton && event.is_double_click():
		self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		var current_clipboard = DisplayServer.clipboard_get()
		if current_clipboard == seed:
			return
		DisplayServer.clipboard_set(seed)
