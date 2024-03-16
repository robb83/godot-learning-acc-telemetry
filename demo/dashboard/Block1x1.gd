@tool
class_name Block1x1 extends Control

@export var label : String = ""
@export var value : String = ""
@export var padding : int = 2
@export var font_size_label : int = 10
@export var font_size_value : int = 20
@export var border_color : Color = Color("#cccccc")
	
func set_label(text):
	label = text
	queue_redraw()
		
func set_value(text):
	value = text
	queue_redraw()
	
func _ready():
	pass

func _process(delta):
	pass

func _draw():
	var font = get_theme_default_font()
	
	var label_size = font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_label)
	var label_height = font.get_height(font_size_label)
	var label_block = min(size.x * 0.5, max(0, (size.x - label_size.x - padding - padding) * 0.5))
	
	var points = PackedVector2Array()
	points.push_back(Vector2(size.x - label_block, 0.5))
	points.push_back(Vector2(size.x - 0.5, 0.5))
	points.push_back(Vector2(size.x - 0.5, size.y - 0.5))
	points.push_back(Vector2(0.5, size.y - 0.5))
	points.push_back(Vector2(0.5, 0.5))
	points.push_back(Vector2(label_block + 0.5, 0.5))
	draw_polyline(points, border_color, 1, false)
	draw_string(font, Vector2(label_block + padding, label_height * 0.70), label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_label)
	
	var value_size = font.get_string_size(value, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_value)
	var font_height = font.get_height(font_size_value)
	draw_string(font, Vector2((size.x - value_size.x) * 0.5, size.y - font_height * 0.15), value, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_value)
	
