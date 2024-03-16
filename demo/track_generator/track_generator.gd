extends Node2D

@onready var container = $Path2D

func _ready():
	var fp = "2024-03-07_09-59-00.bin"
	var fa = FileAccess.open(fp, FileAccess.READ)
	
	var bounds = Rect2()
	
	var current_lap = 0
	var current_sector = -1
	var current_position = Vector2()
	var current_position_i = Vector2i()
	var current_is_valid = false
	var current_packet_id = 0
	var current_lap_time = 0
	
	var need_record = true
	var record = false
	var curve2d = Curve2D.new()
	curve2d.bake_interval = 5.0
	
	while not fa.eof_reached():
		var packet = fa.get_buffer(0xE00)
		var graphics = packet.slice(0x400, 0x400 + 0x700)
		
		var packetId = graphics.decode_s32(0)
		if packetId == current_packet_id:
			continue
			
		var status = graphics.decode_s32(4)
		if status != 2:
			continue
		
		var completed_laps = graphics.decode_s32(132)
		var lap_time = graphics.slice(12, 42).get_string_from_wchar()
		var lap_Time_i = graphics.decode_s32(140)
		var last_lap_time = graphics.slice(42, 72).get_string_from_wchar()
		var currentSectorIndex = graphics.decode_s32(164)
		var normalizedposition = graphics.decode_float(248)
		var cars = graphics.decode_s32(252)
		var player_id = graphics.decode_s32(1214)
		var is_valid = graphics.decode_s32(1408) == 1
		
		var position = Vector2(graphics.decode_float(256 + player_id * 4), graphics.decode_float(256 + player_id * 4 + 8))
		var position_i = Vector2i(position)
		bounds = bounds.expand(position)
		
		# no laptime
		if lap_time == "-:--:---":
			continue
		
		# reset or something
		if current_lap > completed_laps:
			current_lap = 0
			current_sector = -1
			current_position = Vector2()
			current_is_valid = false
		
		if record and current_lap_time > lap_Time_i and is_valid:
			record = false
			print("TRACK RECORD END")
			
		# detect finish line
		if need_record and current_lap_time > lap_Time_i and is_valid:
			record = true
			need_record = false
			current_is_valid = true
			print("TRACK RECORD BEGIN")
			
		if record:
			if current_is_valid and is_valid:
				if position_i != current_position_i:
					curve2d.add_point(position_i)
			else:
				curve2d.clear_points()
				need_record = true
				record = false
		
		current_lap = completed_laps
		current_lap_time = lap_Time_i
		current_is_valid = is_valid
		current_sector = currentSectorIndex
		current_packet_id = packetId
		current_position = position
		current_position_i = position_i
	
	var baked_points = curve2d.get_baked_points()
	print(bounds)
	print(len(baked_points))
	
	save_to_svg_path_data("user://track.dat", baked_points)

func save_to_svg_path_data(filepath, points):
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	var cursor = 0
	if len(points) > 0:
		var p = points[cursor]
		file.store_string("M " + ("%0d" % p.x) + ","  + ("%0d" % p.y))
		cursor += 1
		while cursor < len(points):
			p = points[cursor]
			file.store_string(" L " + ("%0d" % p.x) + ","  + ("%0d" % p.y))
			cursor += 1
			
	
