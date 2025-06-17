extends CharacterBody3D

const MOVE_SPEED = 4
const SPRINT_SPEED = 8
const STAMINA_REGEN = 0.25
const MOVE_PITCH = 1
const SPRINT_PITCH = 2
const MAX_STAMINA = 12
const MOUSE_SENS = 0.5
const SPRITE_SCALE = Vector2(4, 4)

@onready var scene_manager = get_parent().get_parent()
@onready var stamina_bar = $UI/Stamina
@onready var breathing = $Breathing
@onready var heartbeat = $Heartbeat
@onready var footsteps_inside = $FootstepsInside
@onready var footsteps_outside = $FootstepsOutside

var sprinting = false
var exausted = false
var stamina = MAX_STAMINA

var focus = 'world'
var equipped = false

var footstep_audio

func _ready() -> void:
	stamina_bar.max_value = MAX_STAMINA
	stamina_bar.value = stamina
	
	breathing.play()
	footstep_audio = footsteps_inside
	
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
		
	#if Input.is_action_just_pressed('map') and focus == 'world':
		#focus = 'map_menu'
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#elif Input.is_action_just_released('map') and focus == 'map_menu':
		#focus = 'world'
		#
	#if Input.is_action_just_pressed('menu') and focus == 'world':
		#focus = 'tool_menu'
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#elif Input.is_action_just_released('menu') and focus == 'tool_menu':
		#focus = 'world'
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		var speed = 0
		
		breathing.volume_db = linear_to_db(1 - (stamina / MAX_STAMINA))
		
		if scene_manager.chasing and not heartbeat.playing:
			heartbeat.play()
		
		if not scene_manager.chasing and heartbeat.playing:
			heartbeat.stop()
		
		if is_outside():
			footstep_audio = footsteps_outside
		else:
			footstep_audio = footsteps_inside
		
		if sprinting:
			speed = SPRINT_SPEED
		else:
			speed = MOVE_SPEED
		
		if move_vec != Vector3(0, 0, 0):
			if not footstep_audio.playing:
				footstep_audio.play()
			
		elif footstep_audio.playing:
			footstep_audio.stop()
		
		move_and_collide(move_vec * speed * delta)
		
		if Input.is_action_pressed('sprint'):
			if not exausted:
				if not sprinting:
					sprinting = true
					footstep_audio.pitch_scale = SPRINT_PITCH
				stamina = stamina - delta
				
				if stamina <= 0:
					sprinting = false
					footstep_audio.pitch_scale = MOVE_PITCH
					exausted = true
		else:
			if sprinting:
				sprinting = false
				footstep_audio.pitch_scale = MOVE_PITCH
			
			if stamina < MAX_STAMINA:
				stamina = stamina + (delta * STAMINA_REGEN)
			elif exausted:
				exausted = false
		
		update_stamina_bar()
		
		#if Input.is_action_pressed('use') and !anim_player.is_playing():
			#anim_player.play('use_flare')
			#var coll = raycast.get_collider()
			#if raycast.is_colliding() and coll.has_method('kill'):
				#coll.kill()

func update_stamina_bar() -> void:
	stamina_bar.value = stamina
	
	if stamina < MAX_STAMINA and not stamina_bar.visible:
		stamina_bar.show()
	
	if stamina >= MAX_STAMINA and stamina_bar.visible:
		stamina_bar.hide()

func kill() -> void:
	get_tree().reload_current_scene()

func is_outside() -> bool:
	if scene_manager.current_scene.get_name() == 'World':
		return true
	
	return false
