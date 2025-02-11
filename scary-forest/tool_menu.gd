extends Control

const SPRITE_SIZE = Vector2(128, 128)

@export var bg_color: Color
@export var ln_color: Color
@export var hglt_color: Color
@export var bdr_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var ln_width: int = 4
@export var bdr_width: int = 4

@export var options: Array[ToolOption]

var selection = 0

func Close():
	hide()
	return options[selection]

func  _draw() -> void:
	var offset = SPRITE_SIZE / -2
	
	draw_circle(Vector2.ZERO, outer_radius, bg_color, )
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, ln_color, ln_width)
	draw_arc(Vector2.ZERO, outer_radius, 0, TAU, 128, bdr_color, bdr_width)
	
	if len(options) >= 3:
		for i in range(len(options) - 1):
			var rads = TAU * i / (len(options) - 1)
			var points = Vector2.from_angle(rads)
			draw_line(
				points * inner_radius, 
				points * outer_radius,
				ln_color,
				ln_width
			)
			
		if selection == 0:
			draw_circle(Vector2.ZERO, inner_radius, hglt_color)
		
		draw_texture_rect_region(
			options[0].atlas, 
			Rect2(offset, SPRITE_SIZE),
			options[0].region
		)
		
		for i in range(1, len(options)):
			var start_rads = (TAU * (i - 1)) / (len(options) - 1)
			var end_rads = (TAU * i) / (len(options) - 1)
			var mid_rads = (start_rads + end_rads) / 2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2
			
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc + 1):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
				
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer, 
					PackedColorArray([hglt_color])
				)
			
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			draw_texture_rect_region(
				options[i].atlas,
				Rect2(draw_pos, SPRITE_SIZE),
				options[i].region
			)

func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
	
	queue_redraw()
