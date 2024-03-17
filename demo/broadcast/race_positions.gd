extends Node2D

var positions = []
var font : Font
var size = 30
var elapsed = 0
var label0 = ""
var background_color = Color("333333", 0.75)

@onready var root = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	font = SystemFont.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta

	if elapsed > 0.25:
		elapsed -= 0.25
		var race = root.race
		label0 = race.session_name()
		
		for car in race.cars.values():
			var ty = int(car.pos - 1) * size
			car.label1 = str(car.pos)
			car.label2 = race.get_driver_name(car)
			car.label3 = str(car.race_number)
			
			if car.last_lap:
				car.label4 = race.get_time_ms_str(car.last_lap.LaptimeMS)
			else:
				car.label4 = ""
			car.label4 += " PIT " if car.location > 1 else ""
				
			car.pos_target = Vector2(0, ty)
			car.tween = get_tree().create_tween()
			car.tween.tween_property(car, "pos_current", car.pos_target, 0.25)
		
	queue_redraw()
	
func _draw():
	var offset = Vector2(10, 10)
	var l0 = font.get_string_size(label0)
	
	draw_rect(Rect2(offset, Vector2(300, size - 2)), background_color)
	draw_string(font, offset + Vector2(135 - l0.x / 2.0, 20), label0)
	
	offset = offset + Vector2(0, size)
	
	var cars = root.race.cars
	for car in cars.values():
		draw_rect(Rect2(car.pos_current + offset, Vector2(300, size - 2)), background_color)
		
		var t1_s = font.get_string_size(car.label1)
		var t3_s = font.get_string_size(car.label3)
		draw_string(font, car.pos_current + offset + Vector2(15 - t1_s.x / 2.0, 20), car.label1)
		draw_rect(Rect2(car.pos_current + offset + Vector2(30, 0), Vector2(10, size - 2)), car.color)		
		draw_string(font, car.pos_current + offset + Vector2(80 - t3_s.x, 20), car.label3)
		draw_string(font, car.pos_current + offset + Vector2(95, 20), car.label2)
		draw_string(font, car.pos_current + offset + Vector2(150, 20), car.label4)
