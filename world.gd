extends Node3D

const WIDTH = 256
const LENGTH = 256
const PLAYER_SPAWN = Vector3i(0, 0, 0)

const WATCHTOWER_DISTANCE_MIN = ((WIDTH + LENGTH) / 2) / 4

const TREE_SPRITE_SCALE = Vector3(2, 4, 2)
const GRASS_SPRITE_SCALE = Vector3(1, 1, 1)
const BUSH_SPRITE_SCALE = Vector3(1, 1, 1)
const ROCK_SPRITE_SCALE = Vector3(1, 1, 1)

const TREE_POSITION_OFFSET = Vector3(-0.5, 2, -0.5)
const GRASS_POSITION_OFFSET = Vector3(1, 1, 1)
const BUSH_POSITION_OFFSET = Vector3(1, 1, 1)
const ROCK_POSITION_OFFSET = Vector3(1, 1, 1)

const TREE_SPAWN_RATE = 10
const GRASS_SPAWN_RATE = 100
const BUSH_SPAWN_RATE = 2
const ROCK_SPAWN_RATE = 1

@onready var grid_map = $GridMap

var grass_noise_condition = func(noise): return noise >= 0.15
var sand_noise_condition = func(noise): return noise >= 0 and noise <= 0.2
var shallow_noise_condition = func(noise): return noise < 0.2
var deep_noise_condition = func(noise): return noise < 0.05

var tree_scene = load('res://tree.tscn')
var grass_scene #= load('res://grass.tscn')
var bush_scene #= load('res://bush.tscn')
var rock_scene #= load('res://rock.tscn')
var watchtower_scene #= load('res://watchtower.tscn')
var watchtower_inside_scene #= load('res://watchtower_inside.tscn')

var tree_textures = [
	get_imagetexture('res://textures/trees/tree01.png'),
	get_imagetexture('res://textures/trees/tree02.png')
]
var grass_textures = [
	
]
var bush_textures = [
	
]
var rock_textures = [
	
]

func center_position(coordinate) -> Vector3:
	return Vector3(coordinate.x - WIDTH / 2, 0, coordinate.z - LENGTH / 2)

func get_dist_between(a, b) -> float:
	return sqrt((b.x - a.x)**2 + (b.y - a.y)**2)

func get_imagetexture(path) -> ImageTexture:
	return ImageTexture.create_from_image(Image.load_from_file(path))

func _ready() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	
	var watchtower_first = center_position(Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH)))
	var watchtower_second
	var watchtower_third
	
	while watchtower_second == null:
		var random_position = center_position(Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH)))
		
		if get_dist_between(watchtower_first, random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_second = random_position
			
	while watchtower_third == null:
		var random_position = center_position(Vector3(randi_range(0, WIDTH), 0, randi_range(0, LENGTH)))
		
		if get_dist_between(watchtower_first, random_position) > WATCHTOWER_DISTANCE_MIN and \
			get_dist_between(watchtower_second, random_position) > WATCHTOWER_DISTANCE_MIN:
			watchtower_third = random_position
			
	print(watchtower_first, watchtower_second, watchtower_third)
	
	for x in range(WIDTH):
		for z in range(LENGTH):
			var position = center_position(Vector3(x, 0, z))
			var tile_noise = noise.get_noise_2d(position.x, position.z)
			
			if grass_noise_condition.call(tile_noise):
				grid_map.set_cell_item(position, 0)
				
				if randi_range(0, 100) <= TREE_SPAWN_RATE:
					var instance = tree_scene.instantiate()
					var sprite = instance.get_node('Sprite3D')
					
					sprite.texture = tree_textures.pick_random()
					sprite.scale = TREE_SPRITE_SCALE
					
					instance.set_position(position + TREE_POSITION_OFFSET)
					add_child(instance)
			
			else:
				grid_map.set_cell_item(position, 1)
				
			#elif sand_noise_condition.call(tile_noise):
				#grid_map.set_cell_item(position, 1)
				#
			#elif shallow_noise_condition.call(tile_noise):
				#grid_map.set_cell_item(position, 2)
