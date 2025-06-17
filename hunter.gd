extends CharacterBody3D

const MOVE_SPEED = 4.5
const DETECT_RADIUS = 35
const ALLOWANCE_RADIUS = 2

@onready var collision = $CollisionShape3D
@onready var scene_manager = get_parent().get_parent()
@onready var current_target = generate_rand_vector(scene_manager.WIDTH, scene_manager.LENGTH)
@onready var player = scene_manager.current_scene.get_node('Player')
@onready var hitbox = $Area3D

func generate_rand_vector(width, length):
	return Vector3(randi_range(0, width), 0, randi_range(0, length))

func get_dist_between(a, b) -> float:
	return sqrt((a.x - b.x)**2 + (a.z - b.z)**2)

func in_radius(a, b, radius) -> bool:
	return get_dist_between(a, b) <= radius

func _physics_process(delta: float) -> void:
	if in_radius(player.global_position, global_position, DETECT_RADIUS):
		current_target = player.global_position
		
		if not scene_manager.chasing:
			scene_manager.chasing = true
	elif scene_manager.chasing:
		scene_manager.chasing = false
	
	if in_radius(current_target, global_position, ALLOWANCE_RADIUS):
		current_target = generate_rand_vector(scene_manager.WIDTH, scene_manager.LENGTH)
		
		if scene_manager.chasing:
			var story = player.get_node('UI/Story')
			
			story.show()
			story.get_node('Death').show()
	
	var move_vec = global_position.direction_to(current_target).normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec.y = 0
	print(get_dist_between(global_position, current_target))
	move_and_collide(move_vec * MOVE_SPEED * delta)
