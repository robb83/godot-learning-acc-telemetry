extends Node2D

var socket = null
var telemetry = null
var connectionID = -1
var cars = {}
var track_id = 0
var track_name = ""
var gears = ["R", "N", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

@onready var label_speed = $Control/MarginContainer2/VBoxContainer/LabelSpeed
@onready var label_gear = $Control/MarginContainer2/VBoxContainer/LabelGear
@onready var label_fuel = $Control/MarginContainer2/VBoxContainer/LabelFuel
@onready var progress_throttle = $Control/MarginContainer2/VBoxContainer/ProgressBarThrottle
@onready var progress_break = $Control/MarginContainer2/VBoxContainer/ProgressBarBreak
@onready var progress_clutch = $Control/MarginContainer2/VBoxContainer/ProgressBarClutch

# https://stackoverflow.com/questions/1168260/algorithm-for-generating-unique-colors
var colors = [
					  Color("#00FF00"), Color("#0000FF"), Color("#FF0000"), Color("#01FFFE"), Color("#FFA6FE"), Color("#FFDB66"), Color("#006401"), 
	Color("#010067"), Color("#95003A"), Color("#007DB5"),                   Color("#FF00F6"), Color("#774D00"), Color("#90FB92"), Color("#0076FF"), 
	Color("#D5FF00"), Color("#FF937E"), Color("#6A826C"), Color("#FF029D"), Color("#FE8900"), Color("#7A4782"), Color("#7E2DD2"), Color("#85A900"), 
	Color("#FF0056"), Color("#A42400"), Color("#00AE7E"), Color("#683D3B"), Color("#BDC6FF"), Color("#263400"), Color("#BDD393"), Color("#00B917"), 
	Color("#9E008E"), Color("#001544"), Color("#C28C9F"), Color("#FF74A3"), Color("#01D0FF"), Color("#004754"), Color("#E56FFE"), Color("#788231"),
	Color("#0E4CA1"), Color("#91D0CB"), Color("#BE9970"), Color("#968AE8"), Color("#BB8800"), Color("#43002C"), Color("#DEFF74"), Color("#00FFC6"), 
	Color("#FFE502"), Color("#620E00"), Color("#008F9C"), Color("#98FF52"), Color("#7544B1"), Color("#B500FF"), Color("#00FF78"), Color("#FF6E41"), 
	Color("#005F39"), Color("#6B6882"), Color("#5FAD4E"), Color("#A75740"), Color("#A5FFD2"), Color("#FFB167"), Color("#009BFF"), Color("#E85EBE")
]
	
func _process(delta):
	if socket != null and socket.is_packet_available():
		var max_iteration = 30
		while socket.is_packet_available() and max_iteration > 0:
			max_iteration -= 1
			var packet : PackedByteArray = socket.get_packet()
			var type = packet.decode_u8(0)
			if type == AccBroadcast.REGISTRATION_RESULT:
				connectionID = packet.decode_s32(1)
				var success = packet.decode_u8(5) > 0
				var isreadonly = packet.decode_u8(6) == 0
				socket.request_track_data(connectionID)
			elif type == AccBroadcast.TRACK_DATA:
				var cid = packet.decode_s32(1) # connectionId
				var track_name_length = packet.decode_u16(5)
				track_name = packet.slice(7, 7 + track_name_length).get_string_from_utf8()
				track_id = packet.decode_u32(7 + track_name_length)
			elif type == AccBroadcast.REALTIME_CAR_UPDATE:
				var car_index = packet.decode_u16(1)
				var car_wordx = packet.decode_float(11)
				var car_wordy = packet.decode_float(15)
				var car_yaw = packet.decode_float(15)
				var car_location = packet.decode_u8(19)
				var spline_position = wrap(packet.decode_float(28) , 0.0, 1.0)
				
				cars[car_index] = {
					"index": car_index,
					"wordx": car_wordx,
					"wordy": car_wordy,
					"yaw": car_yaw,
					"location": car_location,
					"spline": spline_position,
					"color": colors[wrap(car_index, 0, len(colors) - 1)],
				}
				$Cars.queue_redraw()
		if telemetry:
			var data = telemetry.poll_physics()
			label_speed.text = "%3.2f km/h" % data.speedKmh
			label_gear.text = gears[data.gear]
			label_fuel.text = "%3.3f kg" % data.fuel
			progress_break.value = data.brake
			progress_throttle.value = data.gas
			progress_clutch.value = data.clutch

func _on_connect_button_pressed():
	
	var ip = $Control/MarginContainer/VBoxContainer/GridContainer/TextEditIP.text
	var port = int($Control/MarginContainer/VBoxContainer/GridContainer/TextEditPort.text)
	
	socket = AccBroadcast.new()
	socket.connect(ip, port)
	socket.request_connect("Godot", "asd", 40, "")
	
	telemetry = AccTelemetry.new()
	telemetry.connect()
