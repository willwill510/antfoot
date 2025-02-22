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
			entered = true
			indicator_available.hide()
			scene_manager.switch_scene(scene_manager.watchtower_inside_scene)
			
	elif entered and overlaps:
		indicator_blocked.show()
		shown = true
		
	elif shown:
		indicator_available.hide()
		indicator_blocked.hide()
		shown = false
