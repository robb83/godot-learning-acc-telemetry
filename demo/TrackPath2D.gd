extends Path2D

var current_track = ""
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
	"Circuit Zolder": "zolder",
}

func load_track_data(track_name):
	var parser = XMLParser.new()
	var error = parser.open("res://tracks/track_" + track_name + ".svg")
	if error == OK:
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT and "path" == parser.get_node_name() and parser.get_named_attribute_value("id") == "track":
				return parser.get_named_attribute_value("d")
	return ""

func _process(delta):
	if current_track != $"..".track_name:
		current_track = $"..".track_name
		print(current_track)
		var filename = current_track
		if track_mapping.has(filename):
			filename = track_mapping[filename]
		
		var data = load_track_data(filename)
		var words = data.split(' ')
		
		self.curve.clear_points()
		
		var current = Vector2()
		var cursor = 0
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
			self.curve.add_point(current)
			cursor += 1
		queue_redraw()
	
func _draw():
	var points = self.curve.get_baked_points()
	var cursor = 0
	while cursor < len(points) - 1:
		draw_line(points[cursor], points[cursor + 1], Color.WHITE, 1.0, true)
		cursor += 1
