extends Node2D

var positions = []
var font : Font
var size = 30

@onready var root = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	font = SystemFont.new()

func get_driver_name(car):
	var i = car.driver_index
	if i < len(car.drivers):
		return car.drivers[i].sn
	return car.team_name

func get_time_str(t):
	var ms = int(t) % 1000
	var sec = int(t / 1000) % 60
	var min = int(t / (1000 * 60))
	return ("%02d" % min) + ":" + ("%02d" % sec) + "." + ("%d" % ms)
	
func session_name():
	return root.session_types[root.session_type] + " " + get_time_str(root.session_time if root.session_endtime < 0.0 else root.session_endtime )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cars = root.cars
	for c in cars:
		var car = cars[c]
		
		var ty = int(car.pos - 1) * size
		car.label1 = str(car.pos)
		car.label2 = get_driver_name(car)
		
		if car.last_lap:
			car.label3 = get_time_str(car.last_lap.LaptimeMS)
		else:
			car.label3 = ""
			
		car.pos_target = Vector2(0, ty)
		car.tween = get_tree().create_tween()
		car.tween.tween_property(car, "pos_current", car.pos_target, 0.25)
		
	queue_redraw()
	
func _draw():
	var offset = Vector2(10, 10)
	var label0 = session_name()
	var l0 = font.get_string_size(label0)
	
	draw_rect(Rect2(offset, Vector2(270, size - 2)), Color(Color.DARK_GREEN, 0.7))
	draw_string(font, offset + Vector2(135 - l0.x / 2.0, 20), label0)
	
	offset = offset + Vector2(0, size)
	
	var cars = root.cars
	for c in cars:
		var e = cars[c]
		
		draw_rect(Rect2(e.pos_current + offset, Vector2(270, size - 2)), Color(Color.DARK_GREEN, 0.7))
		
		var t1_s = font.get_string_size(e.label1)
		draw_string(font, e.pos_current + offset + Vector2(15 - t1_s.x / 2.0, 20), e.label1)
		draw_string(font, e.pos_current + offset + Vector2(40, 20), e.label2)
		draw_string(font, e.pos_current + offset + Vector2(190, 20), e.label3)
