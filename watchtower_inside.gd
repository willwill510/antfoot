extends Node3D

@onready var exit = $Area3D
@onready var player = $Player
@onready var indicator_available = player.get_node('UI/ExitIndicators/Available')
@onready var indicator_blocked = player.get_node('UI/ExitIndicators/Blocked')

var watchtower_scene = load('res://scenes/watchtower_inside.tscn').instantiate()

var entered = false
var shown = false

func _physics_process(delta: float) -> void:
	var overlaps = exit.overlaps_body(player)
	
	if not entered and overlaps: #player entered
		indicator_available.show()
		shown = true
		
		if Input.is_action_pressed('interact'):
			SceneManager.switch_scene(watchtower_scene)
			indicator_available.hide()
			entered = true
			
	elif entered and overlaps:
		indicator_blocked.show()
		shown = true
		
	elif not entered and shown:
		indicator_available.hide()
		indicator_blocked.hide()
