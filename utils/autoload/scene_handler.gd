extends Node

var current_scene
@onready var scene_container = $CurrentScene
@onready var shelf = $Shelf


func _ready():
	await get_tree().root.ready
	get_tree().current_scene.reparent(scene_container)
	current_scene = get_tree().current_scene


func change_scene(new_scene):
	var scene_to_change
	if new_scene is PackedScene:
		scene_to_change = new_scene.instantiate()
	elif new_scene is Node:
		scene_to_change = new_scene
	elif new_scene is String:
		scene_to_change = load(new_scene).instantiate()
	
	for child in scene_container.get_children():
		child.queue_free()
	
	for child in shelf.get_children():
		child.queue_free()
	
	current_scene = scene_to_change
	scene_container.add_child(current_scene)


func add_shelf_element(element):
	var element_to_add
	if element is PackedScene:
		element_to_add = element.instantiate()
	elif element is Node:
		element_to_add = element
	elif element is String:
		element_to_add = load(element).instantiate()
	
	shelf.add_child(element_to_add)
