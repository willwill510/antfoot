extends Node3D

@onready var exit = $Area3D
@onready var player = $Player
@onready var indicator_available = player.get_node('UI/ExitIndicators/Available')
@onready var scene_manager = get_parent()

var entered = false
var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = exit.overlaps_body(player)
	
	if not entered and overlaps: #player entered
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			scene_manager.switch_scene(scene_manager.world_scene)
			indicator_available.hide()
			entered = true
		
	elif not entered and shown:
		indicator_available.hide()
