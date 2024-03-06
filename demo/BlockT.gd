@tool
class_name BlockT extends Control

@export var label : String = ""
@export var value : float = 0.0
@export var padding : int = 2
@export var font_size_label : int = 10
@export var font_size_value : int = 16
@export var value_color : Color = Color.RED
@export var border_color : Color = Color("#cccccc")
	
func set_label(text):
	label = text
	queue_redraw()
		
func set_value(v):
	value = v
	queue_redraw()
	
func _ready():
	pass

func _process(delta):
	pass

func _draw():
	var v = clamp(value, 0.0, 1.0)
	if v > 0.0:		
		draw_rect(Rect2(0, size.y - (size.y * v), size.x, size.y * v), value_color)
		
	var font = get_theme_default_font()
	
	var label_size = font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_label)
	var label_block = min(size.x * 0.5, max(0, (size.x - label_size.x - padding - padding) * 0.5))
	
	var points = PackedVector2Array()
	points.push_back(Vector2(size.x - label_block, 0.5))
	points.push_back(Vector2(size.x - 0.5, 0.5))
	points.push_back(Vector2(size.x - 0.5, size.y - 0.5))
	points.push_back(Vector2(0.5, size.y - 0.5))
	points.push_back(Vector2(0.5, 0.5))
	points.push_back(Vector2(label_block + 0.5, 0.5))
	draw_polyline(points, border_color, 1, false)
	draw_string(font, Vector2(label_block + padding, 9), label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_label)	
