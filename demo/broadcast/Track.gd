extends Node2D

@onready var root = $"../.."

var track_curve = Curve2D.new()
var track_transform = Transform2D()
var track_name = ""
var track_mapping = {
	"Circuit de Barcelona-Catalunya": "barcelona",
	"Brands Hatch Circuit": "brands_hatch",
	"Hungaroring": "hungaroring",
	"Misano World Circuit": "misano",
	"Monza Circuit": "monza",
	"Nürburgring GmbH": "nurburgring",
	"Circuit Paul Ricard": "paul_ricard",
	"Silverstone": "silverstone",
	"Circuit de Spa-Francorchamps": "spa",
	"Circuit Zandvoort": "zandvoort",
	"Circuit Zolder": "zolder",
}

func load_track_data(tn):
	var parser = XMLParser.new()
	var error = parser.open("res://tracks/track_" + tn + ".svg")
	if error == OK:
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT and "path" == parser.get_node_name() and parser.get_named_attribute_value("id") == "track":
				return parser.get_named_attribute_value("d")
	return ""

func load_track(tn):
		track_curve.clear_points()
		track_transform = Transform2D()
	
		var data = load_track_data(tn)
		var words = data.split(' ')
		
		var current = Vector2()
		var cursor = 0
		var bounds = null
		while cursor < len(words):
			if words[cursor] == "M":
				current = Vector2(float(words[cursor + 1]), float(words[cursor + 2]))
				cursor += 2
			elif words[cursor] == "H":
				current = Vector2(float(words[cursor + 1]), current.y)
				cursor += 1
			elif words[cursor] == "V":
				current = Vector2(current.x, float(words[cursor + 1]))
				cursor += 1
			elif words[cursor] == "L":
				current = Vector2(float(words[cursor + 1]), float(words[cursor + 2]))
				cursor += 2
			else:
				break
			if bounds == null:
				bounds = Rect2(current, Vector2())
			else:
				bounds = bounds.expand(current)
			track_curve.add_point(current)
			cursor += 1
		
		if bounds:
			var margin = Vector2(15, 15)
			var box = Vector2(700, 800)
			var ratio = (box - (2 * margin)) / bounds.size
			var s = min(ratio.x, ratio.y)
			var bs = (box - bounds.size * s) / 2.0
			track_transform = track_transform.scaled(Vector2(s, s))
			track_transform = track_transform.translated(bounds.position - bs / s)

func _process(delta):
	if track_name != root.track_name:
		track_name = root.track_name
		
		print(track_name)
		
		var filename = track_name
		if track_mapping.has(filename):
			filename = track_mapping[filename]
		
		load_track(filename)
		queue_redraw()
	
func _draw():
	var points = track_curve.get_baked_points()
	if len(points) > 1:
		var cursor = 0
		var current = points[cursor] * track_transform
		while cursor < len(points) - 1:
			var next = points[cursor + 1] * track_transform
			draw_line(current, next, Color.WHITE, 1.0, true)
			cursor += 1
			current = next
			
		# finish line
		var d = (points[0] - points[1]).normalized().rotated(PI / 2.0) * 10.0
		var start_point = points[0] * track_transform
		draw_line(start_point - d, start_point + d, Color.WHITE, 1.0, true)
