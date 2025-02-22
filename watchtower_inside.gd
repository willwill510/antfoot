extends Node3D

@onready var exit = $Area3D
@onready var player = $Player
@onready var indicator_available = player.get_node('UI/ExitIndicators/Available')
@onready var indicator_blocked = player.get_node('UI/ExitIndicators/Blocked')
@onready var scene_manager = get_parent()

var entered = false
var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = exit.overlaps_body(player)
	
	if not entered and overlaps: #player entered
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			entered = true
			indicator_available.hide()
			scene_manager.switch_scene(scene_manager.world_scene)
			
	elif entered and overlaps:
		indicator_blocked.show()
		shown = true
		
	elif shown:
		indicator_available.hide()
		indicator_blocked.hide()
