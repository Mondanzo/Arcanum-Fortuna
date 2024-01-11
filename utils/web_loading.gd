extends Control

## The whole purpose of this scene is to preload assets that are going to be used later on in the game.
## After completing this scene should kill itself.

signal complete

func _ready():
	await get_tree().create_timer(0.1).timeout
	$LoadAssets.visible = true
	await get_tree().process_frame
	complete.emit()
	queue_free()
