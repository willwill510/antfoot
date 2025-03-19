extends Node

const WIDTH = 256
const LENGTH = 256
const PLAYER_SPAWN = Vector3(WIDTH / 2, 0, LENGTH / 2)

const PLAYER_SPAWN_RADIUS = 8
const WATCHTOWER_SPAWN_RADIUS = 20

const WATCHTOWER_DISTANCE_MIN = (WIDTH + LENGTH) / 2 / 3

const TREE_SPRITE_SCALE = Vector3(2, 4, 2)
const GRASS_SPRITE_SCALE = Vector3(1, 1, 1)
const BUSH_SPRITE_SCALE = Vector3(0, 0, 0)
const ROCK_SPRITE_SCALE = Vector3(0, 0, 0)

const TREE_POSITION_OFFSET = Vector3(-0.5, 2, -0.5)
const GRASS_POSITION_OFFSET = Vector3(0, -0.2, 0)
const BUSH_POSITION_OFFSET = Vector3(0, 0, 0)
const ROCK_POSITION_OFFSET = Vector3(0, 0, 0)
const WATCHTOWER_POSITION_OFFSET = Vector3(-0.5, 4, -0.5)
const BUNKER_POSITION_OFFSET = Vector3(-0.5, 0.8, -0.5)

const TREE_SPAWN_RATE = 10
const GRASS_SPAWN_RATE = 100
const BUSH_SPAWN_RATE = 2
const ROCK_SPAWN_RATE = 1

var player_instance = load('res://player.tscn').instantiate()
var hunter_instance = load('res://hunter.tscn').instantiate()
var bunker_instance = load('res://props/bunker.tscn').instantiate()

var tree_prop = load('res://props/tree.tscn')
var grass_prop = load('res://props/grass.tscn')
var bush_prop #= load('res://props/bush.tscn')
var rock_prop #= load('res://props/rock.tscn')
var watchtower_prop = load('res://props/watchtower.tscn')

var tree_textures = [
	load('res://textures/trees/01.png'),
	load('res://textures/trees/02.png')
]
var grass_textures = [
	load('res://textures/grasses/01.png'),
	#load('res://textures/grass/02.png')
]
var bush_textures = [
	#load('res://textures/bush/01.png'),
	#load('res://textures/bush/02.png')
]
var rock_textures = [
	#load('res://textures/rock/01.png'),
	# load('res://textures/rock/02.png')
]

var grid = []
var trees = []
var grasses = []
var watchtowers = []

var bunker_inside_scene = load('res://scenes/bunker_inside.tscn')
var world_scene = load('res://scenes/world.tscn')
var watchtower_inside_scene = load('res://scenes/watchtower_inside.tscn')
var current_scene

var active_fuses = 0
var holding_fuse = false

var chasing = false

func generate_rand_vector(width, length):
	return Vector3(randi_range(0, width), 0, randi_range(0, length))

func remove_children_from(node: Node) -> void:
	for child in node.get_children():
		child.get_parent().remove_child(child)

func get_dist_between(a, b) -> float:
	return sqrt((a.x - b.x)**2 + (a.z - b.z)**2)

func in_radius(a, b, radius) -> bool:
	return get_dist_between(a, b) <= radius

func generate_world() -> void:
	player_instance.set_position(PLAYER_SPAWN + Vector3(0, 0, 5))
	hunter_instance.set_position(generate_rand_vector(WIDTH, LENGTH))
	bunker_instance.set_position(PLAYER_SPAWN + BUNKER_POSITION_OFFSET)
	
	# FIX WITH PARAMS ABOUT SPAWN PROX
	var watchtower_positions = [generate_rand_vector(WIDTH, LENGTH),]
	
	while len(watchtower_positions) == 1:
		var random_position = generate_rand_vector(WIDTH, LENGTH)
		
		if get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_positions.append(random_position)

	while len(watchtower_positions) == 2:
		var random_position = generate_rand_vector(WIDTH, LENGTH)
		
		if get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN and \
			get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_positions.append(random_position)

	for watchtower_position in watchtower_positions:
		var watchtower_instance = watchtower_prop.instantiate()
		
		watchtower_instance.set_position(watchtower_position + WATCHTOWER_POSITION_OFFSET)
		watchtowers.append(watchtower_instance)
	
	for x in range(WIDTH):
		grid.append([])
		
		for z in range(LENGTH):
			var tile_position = Vector3(x, 0, z)
			grid[x].append(0)
			
			if randi_range(0, 100) <= TREE_SPAWN_RATE and \
				not in_radius(tile_position, PLAYER_SPAWN, PLAYER_SPAWN_RADIUS):
				
				var skip = false
				for watchtower_position in watchtower_positions:
					if in_radius(tile_position, watchtower_position, WATCHTOWER_SPAWN_RADIUS):
						skip = true
						break
				
				if skip:
					continue
				
				var tree_instance = tree_prop.instantiate()
				var tree_sprite = tree_instance.get_node('Sprite3D')
				
				tree_sprite.texture = tree_textures.pick_random()
				tree_sprite.scale = TREE_SPRITE_SCALE
				
				tree_instance.set_position(tile_position + TREE_POSITION_OFFSET)
				trees.append(tree_instance)
				
			if randi_range(0, 100) <= GRASS_SPAWN_RATE:
				var grass_instance = grass_prop.instantiate()
				var grass_sprite = grass_instance.get_node('Sprite3D')
				
				grass_sprite.texture = grass_textures.pick_random()
				grass_sprite.scale = GRASS_SPRITE_SCALE
				
				grass_instance.set_position(tile_position + GRASS_POSITION_OFFSET + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))
				grasses.append(grass_instance)

func _ready() -> void:
	generate_world()
	switch_scene(bunker_inside_scene)
	
	var story = current_scene.get_node('Player').get_node('UI/Story')
	var start = story.get_node('Start')
	
	story.show()
	start.show()
	
	await get_tree().create_timer(4).timeout 
	
	story.hide()
	start.hide()

func update_fuse_visiblity():
	var fuse = current_scene.get_node('Player').get_node('UI/Fuse')
		
	if holding_fuse:
		fuse.show()
	else:
		fuse.hide()

func switch_scene(new_scene):
	var new_instance = new_scene.instantiate()
	var old_scene = current_scene
	
	current_scene = new_instance
	
	if new_instance.is_inside_tree():
		return

	if old_scene and old_scene.is_inside_tree():
		remove_children_from(old_scene)
		old_scene.add_sibling(new_instance)
		remove_child(old_scene)
	else:
		add_child(new_instance)
	
	update_fuse_visiblity()
