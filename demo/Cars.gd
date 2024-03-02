extends Node2D

@export var font : Font
@onready var path2d = $"../Track"
@onready var root = $"../.."

func _process(delta):
	queue_redraw()

func _draw():
	var track_curve = path2d.track_curve
	var track_transform = path2d.track_transform
	var total_length = track_curve.get_baked_length()	
	if total_length == 0 or track_curve.point_count == 0:
		return
		
	var cars = root.cars
	for c in cars.values():
		var p1 = track_curve.sample_baked( total_length * c.spline, false) * track_transform
		draw_arc(p1, 12, 0, 360, 20, Color.BLACK, 4, true)
		draw_circle(p1, 12, c.color)
		if font:
			var text = str(c.index)
			var size = font.get_string_size(text)
			var str_pos = p1 - (Vector2(size.x / 2.0, size.y / -4.0))
			draw_string(font, str_pos, str(c.index))
