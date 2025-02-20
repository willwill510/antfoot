@tool
extends Node3D

const WIDTH = 256
const LENGTH = 256
const PLAYER_SPAWN = Vector3i(WIDTH / 2, 0, LENGTH / 2)

const PLAYER_SPAWN_RADIUS = 8
const WATCHTOWER_SPAWN_RADIUS = 20

const WATCHTOWER_DISTANCE_MIN = (WIDTH + LENGTH) / 2 / 3

const TREE_SPRITE_SCALE = Vector3(2, 4, 2)
const GRASS_SPRITE_SCALE = Vector3(0, 0, 0)
const BUSH_SPRITE_SCALE = Vector3(0, 0, 0)
const ROCK_SPRITE_SCALE = Vector3(0, 0, 0)
const WATCHTOWER_SPRITE_SCALE = Vector3(4, 8, 4)

const TREE_POSITION_OFFSET = Vector3(-0.5, 2, -0.5)
const GRASS_POSITION_OFFSET = Vector3(0, 0, 0)
const BUSH_POSITION_OFFSET = Vector3(0, 0, 0)
const ROCK_POSITION_OFFSET = Vector3(0, 0, 0)
const WATCHTOWER_POSITION_OFFSET = Vector3(-0.5, 4, -0.5)

const TREE_SPAWN_RATE = 10
const GRASS_SPAWN_RATE = 100
const BUSH_SPAWN_RATE = 2
const ROCK_SPAWN_RATE = 1

@onready var grid_map = $GridMap

var grass_noise_condition = func(noise): return noise >= 0.15
var sand_noise_condition = func(noise): return noise >= 0 and noise <= 0.2
var shallow_noise_condition = func(noise): return noise < 0.2
var deep_noise_condition = func(noise): return noise < 0.05

var player_instance = load('res://player.tscn').instantiate()

var tree_prop = load('res://props/tree.tscn')
var grass_prop #= load('res://props/grass.tscn')
var bush_prop #= load('res://props/bush.tscn')
var rock_prop #= load('res://props/rock.tscn')
var watchtower_prop = load('res://props/watchtower.tscn')

var watchtower_scene #= load('res://scenes/watchtower.tscn')

var watchtower_textures = [
	#load('res://textures/watchtowers/01.png'),
	#load('res://textures/watchtowers/02.png'),
	#load('res://textures/watchtowers/03.png')
]
var tree_textures = [
	load('res://textures/trees/01.png'),
	load('res://textures/trees/02.png')
]
var grass_textures = [
	#load('res://textures/grass/01.png'),
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

func get_dist_between(a, b) -> float:
	return sqrt((a.x - b.x)**2 + (a.z - b.z)**2)

func in_radius(a, b, radius) -> bool:
	return get_dist_between(a, b) <= radius

func _ready() -> void:
	player_instance.set_position(PLAYER_SPAWN)
	add_child(player_instance)
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	
	var watchtower_positions = [Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH)),]
	
	while len(watchtower_positions) == 1:
		var random_position = Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH))
		
		if get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_positions.append(random_position)

	while len(watchtower_positions) == 2:
		var random_position = Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH))
		
		if get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN and \
			get_dist_between(watchtower_positions[0], random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_positions.append(random_position)

	for watchtower_position in watchtower_positions:
		var watchtower_instance = watchtower_prop.instantiate()
		
		watchtower_instance.get_node('Sprite3D').scale = WATCHTOWER_SPRITE_SCALE
		watchtower_instance.set_position(watchtower_position + WATCHTOWER_POSITION_OFFSET)
		add_child(watchtower_instance)
	
	for x in range(WIDTH):
		for z in range(LENGTH):
			var position = Vector3(x, 0, z)
			var tile_noise = noise.get_noise_2d(position.x, position.z)
			
			grid_map.set_cell_item(position, 0)
			
			#if randi_range(0, 100) <= TREE_SPAWN_RATE and \
				#not in_radius(position, PLAYER_SPAWN, PLAYER_SPAWN_RADIUS):
				#
				#var skip = false
				#for watchtower_position in watchtower_positions:
					#if in_radius(position, watchtower_position, WATCHTOWER_SPAWN_RADIUS):
						#skip = true
						#break
				#
				#if skip:
					#continue
				#
				#var tree_instance = tree_prop.instantiate()
				#var tree_sprite = tree_instance.get_node('Sprite3D')
				#
				#tree_sprite.texture = tree_textures.pick_random()
				#tree_sprite.scale = TREE_SPRITE_SCALE
				#
				#tree_instance.set_position(position + TREE_POSITION_OFFSET)
				#add_child(tree_instance)
