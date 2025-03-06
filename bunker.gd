extends Area3D

@onready var scene_manager = get_parent().get_parent()
@onready var player = scene_manager.current_scene.get_node('Player')
@onready var indicator_available = player.get_node('UI/EnterIndicators/Available')

var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = overlaps_body(player)
	
	if overlaps:
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			indicator_available.hide()
			scene_manager.switch_scene(scene_manager.bunker_inside_scene)
		
	elif shown:
		indicator_available.hide()
		shown = false
