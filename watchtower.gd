extends Area3D

const ENTER_RADIUS = 5

@onready var scene_manager = get_parent().get_parent()
@onready var player = scene_manager.current_scene.get_node('Player')
@onready var indicator_available = player.get_node('UI/EnterIndicators/Available')
@onready var indicator_blocked = player.get_node('UI/EnterIndicators/Blocked')

var entered = false
var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = overlaps_body(player)
	
	if not entered and overlaps: #player entered
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			print('entered watchtower') #load inside watchtwr lvl
			indicator_available.hide()
			entered = true
			
	elif entered and overlaps:
		indicator_blocked.show()
		shown = true
		
	elif not entered and shown:
		indicator_available.hide()
		indicator_blocked.hide()
