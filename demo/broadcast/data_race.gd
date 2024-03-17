class_name RaceEntry extends RefCounted

signal registration_success(connection_id)

var connection_id : int
var cars = {}
var track_id = 0
var track_name = ""
var track_meter = -1
var session_type = 0
var session_time = 0.0
var session_endtime = 0.0

const status = ["OFF", "REPLAY", "LIVE", "PAUSE"]
const session_types = { -1: "UNKNOWN", 0: "PRACTICE", 4: "QUALIFY", 10: "RACE", 11: "HOTLAP", 12: "HOTSTINT", 13: "HOTLAPSUPERPOLE", 14: "REPLAY" }
const flags = [ "", "BLUE_FLAG", "YELLOW_FLAG", "BLACK_FLAG", "WHITE_FLAG", "CHECKERED_FLAG", "PENALTY_FLAG" ]
const grip_status = [ "GREEN", "FAST", "OPTIMUM", "GREASY", "DAMP", "WET", "FLOODED" ]
const rain_intenzity = [ "NO_RAIN", "DRIZZLE", "LIGHT_RAIN", "MEDIUM_RAIN", "HEAVY_RAIN", "THUNDERSTORM" ]
const driver_category = [ "Bronze", "Silver", "Gold", "Platinum" ]
const cup_category = [ "Overall/Pro", "ProAm", "Am", "Silver", "National" ]
const car_locations = [ "None", "Track", "Pit Lane", "Pit Entry", "Pit Exit" ]

# https://stackoverflow.com/questions/1168260/algorithm-for-generating-unique-colors
const colors = [
					  Color("#00FF00"), Color("#0000FF"), Color("#FF0000"), Color("#01FFFE"), Color("#FFA6FE"), Color("#FFDB66"), Color("#006401"), 
	Color("#010067"), Color("#95003A"), Color("#007DB5"),                   Color("#FF00F6"), Color("#774D00"), Color("#90FB92"), Color("#0076FF"), 
	Color("#D5FF00"), Color("#FF937E"), Color("#6A826C"), Color("#FF029D"), Color("#FE8900"), Color("#7A4782"), Color("#7E2DD2"), Color("#85A900"), 
	Color("#FF0056"), Color("#A42400"), Color("#00AE7E"), Color("#683D3B"), Color("#BDC6FF"), Color("#263400"), Color("#BDD393"), Color("#00B917"), 
	Color("#9E008E"), Color("#001544"), Color("#C28C9F"), Color("#FF74A3"), Color("#01D0FF"), Color("#004754"), Color("#E56FFE"), Color("#788231"),
	Color("#0E4CA1"), Color("#91D0CB"), Color("#BE9970"), Color("#968AE8"), Color("#BB8800"), Color("#43002C"), Color("#DEFF74"), Color("#00FFC6"), 
	Color("#FFE502"), Color("#620E00"), Color("#008F9C"), Color("#98FF52"), Color("#7544B1"), Color("#B500FF"), Color("#00FF78"), Color("#FF6E41"), 
	Color("#005F39"), Color("#6B6882"), Color("#5FAD4E"), Color("#A75740"), Color("#A5FFD2"), Color("#FFB167"), Color("#009BFF"), Color("#E85EBE")
]

func get_driver_name(car):
	var i = car.driver_index
	if i < len(car.drivers):
		return car.drivers[i].sn # + " (" + str(car.race_number) + ")"
	return car.team_name #+ " (" + str(car.race_number) + ")"

func get_time_sec_str(tms):
	var tmsi = int(tms)
	if tmsi == 2147483647:
		return "00:00.000"
	var sec = (tmsi / 1000) % 60
	var min = (tmsi / (1000 * 60))
	return ("%02d" % min) + ":" + ("%02d" % sec)
	
func get_time_ms_str(tms):
	var tmsi = int(tms)
	if tmsi == 2147483647:
		return "00:00.000"
	var ms = tmsi % 1000
	var sec = (tmsi / 1000) % 60
	var min = (tmsi / (1000 * 60))
	return ("%02d" % min) + ":" + ("%02d" % sec) + "." + ("%d" % ms)
	
func session_name():
	return session_types[session_type] + " " + get_time_sec_str(session_time if session_endtime < 0.0 else session_endtime )
	
func get_lap(reader):
	var lap = {}
	lap.LaptimeMS = reader.get_s32()
	lap.CarIndex = reader.get_s16()
	lap.DriverIndex = reader.get_s16()
	lap.splits = []
	
	var split_count = reader.get_u8()
	for i in split_count:
		lap.splits.push_back(reader.get_s32())
		
	lap.IsInvalid = reader.get_u8() > 0
	lap.IsValidForBest = reader.get_u8() > 0
	lap.IsOutlap = reader.get_u8() > 0
	lap.IsInlap = reader.get_u8() > 0
	
	return lap
	
func update(reader):
	var event_type = reader.get_u8()
	if event_type == AccBroadcast.REGISTRATION_RESULT:
		connection_id = reader.get_s32()
		var success = reader.get_u8() > 0
		var isreadonly = reader.get_u8() == 0
		var error_msg = reader.get_string()
		registration_success.emit(connection_id)
	elif event_type == AccBroadcast.TRACK_DATA:
		var conn_id = reader.get_s32()
		track_name = reader.get_string()
		track_id = reader.get_s32()
		track_meter = reader.get_s32()
	elif event_type == AccBroadcast.ENTRY_LIST:
		#var conn_id = reader.get_s32()
		#var count = reader.get_u16()
		#for i in count:
			#var car_index = reader.get_u16()
		pass
	elif event_type == AccBroadcast.ENTRY_LIST_CAR:
		var car_id = reader.get_u16()
		
		var car = null
		if cars.has(car_id):
			car = cars[car_id]
		else:
			car = CarEntry.new()
			car.index = car_id
			cars[car_id] = car
		
		car.pos = (car_id + 1)
		car.model_type = reader.get_u8()
		car.team_name = reader.get_string()
		car.race_number = reader.get_s32()
		car.cup_category =reader.get_s8()
		car.current_driver_index = reader.get_s8()
		car.nationality = reader.get_u16()
		var ds = reader.get_u8()
		for d in ds:
			var driver = {}
			driver.fn = reader.get_string()
			driver.ln = reader.get_string()
			driver.sn = reader.get_string()
			driver.cat = reader.get_u8()
			driver.nat = reader.get_u16()
			car.drivers.push_back(driver)
	elif event_type == AccBroadcast.BROADCASTING_EVENT:
		var type = reader.get_u8()
		var msg = reader.get_string()
		var tms = reader.get_s32()
		var car_id = reader.get_s32()
		
		print(msg)
	elif event_type == AccBroadcast.REALTIME_UPDATE:
		var event_index = reader.get_u16()
		var session_index = reader.get_u16()
		session_type = reader.get_u8()
		var phase = reader.get_u8()
		session_time = reader.get_float()
		session_endtime = reader.get_float()
		var focused_car_index = reader.get_s32()
		var active_camera_set = reader.get_string()
		var active_camera = reader.get_string()
		var current_hud_page = reader.get_string()
		var is_replay_playing = reader.get_u8()
		if is_replay_playing > 0:
			var replay_session_time = reader.get_float()
			var replay_remaining_time = reader.get_float()
		var time_of_day = reader.get_float()
		var ambient_temp = reader.get_u8()
		var track_temp = reader.get_u8()
		var clouds = reader.get_u8() / 10.0
		var rain_level = reader.get_u8() / 10.0
		var wetness = reader.get_u8() / 10.0
		var best_session_lap = get_lap(reader)
	elif event_type == AccBroadcast.REALTIME_CAR_UPDATE:
		var car_id = reader.get_u16()
			
		var car = null
		if cars.has(car_id):
			car = cars[car_id]
		else:
			car = CarEntry.new()
			car.index = car_id
			cars[car_id] = car
		
		car.driver_index = reader.get_s16()
		car.driver_count = reader.get_u8()
		car.gear = reader.get_u8()
		car.wx = reader.get_float()
		car.wy = reader.get_float()
		car.yaw = reader.get_float()
		car.location = reader.get_u8()
		car.kmh = reader.get_u16()
		car.pos = reader.get_u16()
		car.cup_position = reader.get_u16()
		car.track_position = reader.get_u16()
		car.spline = wrap(reader.get_float() , 0.0, 1.0)
		car.laps = reader.get_u16()
		car.cdelta = reader.get_s32()
		car.best_lap = get_lap(reader)
		car.last_lap = get_lap(reader)
		car.current_lap = get_lap(reader)
		car.color = colors[wrap(car_id, 0, len(colors) - 1)]
