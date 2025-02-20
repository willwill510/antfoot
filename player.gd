extends CharacterBody3D

const MOVE_SPEED = 4
const MOUSE_SENS = 0.5
const SPRITE_SCALE = Vector2(4, 4)

@onready var anim_player = $AnimationPlayer
@onready var map_menu = $UI/MapMenu
@onready var tool_menu = $UI/ToolMenu
@onready var tool_sprite = $UI/ToolEquiped/Sprite2D

var focus = 'world'
var equiped_tool: ToolOption

func _ready() -> void:
	tool_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().process_frame
	get_tree().call_group('zombies', 'set_player', self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and focus == 'world':
		rotation_degrees.y -= MOUSE_SENS * event.relative.x
		
		var new_y = rotation_degrees.x - MOUSE_SENS * event.relative.y
		if new_y > -20 and new_y < 20:
			rotation_degrees.x = new_y

func _process(delta: float) -> void:
	if Input.is_action_pressed('exit'):
		get_tree().quit()
	if Input.is_action_pressed('restart'):
		kill()
		
	if Input.is_action_just_pressed('map') and focus == 'world':
		focus = 'map_menu'
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	elif Input.is_action_just_released('map') and focus == 'map_menu':
		focus = 'world'
		
	if Input.is_action_just_pressed('menu') and focus == 'world':
		focus = 'tool_menu'
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		tool_menu.show()
	elif Input.is_action_just_released('menu') and focus == 'tool_menu':
		focus = 'world'
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		equiped_tool = tool_menu.Close()
		tool_sprite.texture = ImageTexture.create_from_image(equiped_tool.get_image())
		tool_sprite.global_scale = SPRITE_SCALE

func _physics_process(delta: float) -> void:
	if focus == 'world':
		var move_vec = Vector3()
		if Input.is_action_pressed('move_forward'):
			move_vec.z -= 1
		if Input.is_action_pressed('move_backward'):
			move_vec.z += 1
		if Input.is_action_pressed('move_left'):
			move_vec.x -= 1
		if Input.is_action_pressed('move_right'):
			move_vec.x += 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_and_collide(move_vec * MOVE_SPEED * delta)
		
		#if Input.is_action_pressed('use') and !anim_player.is_playing():
			#anim_player.play('use_flare')
			#var coll = raycast.get_collider()
			#if raycast.is_colliding() and coll.has_method('kill'):
				#coll.kill()
#
func kill() -> void:
	get_tree().reload_current_scene()
