extends CharacterBody3D

const MOVE_SPEED = 4.5
const DETECT_RADIUS = 20

@onready var collision = $CollisionShape3D
@onready var scene_manager = get_parent().get_parent()
@onready var player = scene_manager.current_scene.get_node('Player')
@onready var hitbox = $Area3D

var current_target = null

func generate_rand_vector(width, length):
	return Vector3(randi_range(0, width), 0, randi_range(0, length))

func get_dist_between(a, b) -> float:
	return sqrt((a.x - b.x)**2 + (a.z - b.z)**2)

func in_radius(a, b, radius) -> bool:
	return get_dist_between(a, b) <= radius

func _physics_process(delta: float) -> void:
	if global_position == current_target:
		current_target = null
	
		
	if current_target == null:
		current_target = generate_rand_vector(scene_manager.WIDTH, scene_manager.LENGTH)
	else:
		if in_radius(player.global_position, global_position, DETECT_RADIUS):
			current_target = player.global_position
			
			if not scene_manager.chase:
				scene_manager.chase = true
		
		var move_vec = global_position.direction_to(current_target).normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_vec.y = 0
		move_and_collide(move_vec * MOVE_SPEED * delta)
