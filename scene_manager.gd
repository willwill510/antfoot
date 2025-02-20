extends Node

var bunker_scene = load('res://scenes/bunker.tscn').instantiate()
var world_scene = load('res://scenes/world.tscn').instantiate()
var current_scene = get_tree()

func _ready() -> void:
	switch_scene(bunker_scene)

func switch_scene(new_scene):
	print(current_scene)
	if new_scene.is_inside_tree():
		return

	if current_scene and current_scene.is_inside_tree():
		current_scene.replace_by(new_scene)
	else:
		add_child(new_scene)
		
	current_scene = new_scene
