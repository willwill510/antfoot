extends Node3D

@onready var exit = $Area3D
@onready var player = $Player
@onready var indicator_available = player.get_node('UI/ExitIndicators/Available')
@onready var scene_manager = get_parent()

var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = exit.overlaps_body(player)
	
	if overlaps and not shown:
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			indicator_available.hide()
			scene_manager.switch_scene(scene_manager.world_scene)
		
	elif shown:
		indicator_available.hide()
