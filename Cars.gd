extends Node2D

@export var font : Font

func _draw():
	var path2d = $"../TrackPath2D"
	var total_length = path2d.curve.get_baked_length()
	var cars = $"..".cars
	
	for c in cars.values():
		var p1 = path2d.curve.sample_baked( total_length * c.spline, true)
		draw_arc(p1, 12, 0, 360, 20, Color.BLACK, 4, true)
		draw_circle(p1, 12, c.color)
		if font:
			var text = str(c.index)
			var size = font.get_string_size(text)
			var str_pos = p1 - (Vector2(size.x / 2.0, size.y / -4.0))
			draw_string(font, str_pos, str(c.index))
