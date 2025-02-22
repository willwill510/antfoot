@tool
extends Node3D

@onready var grid_map = $GridMap
@onready var scene_manager = get_parent()

func _ready() -> void:
	print('ready')
	
	for x in scene_manager.WIDTH:
		for z in scene_manager.LENGTH:
			grid_map.set_cell_item(Vector3i(x, 0, z), scene_manager.grid[x][z])
	
	add_child(scene_manager.player)
	
	for watchtower in scene_manager.watchtowers:
		add_child(watchtower)
	
	for tree in scene_manager.trees:
		add_child(tree)
