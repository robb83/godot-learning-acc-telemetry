class_name CarEntry extends RefCounted

# for animation
var pos_target : Vector2
var pos_current : Vector2
var tween : Tween
var label1 : String
var label2 : String
var label3 : String
var label4 : String

# received data
var index = 0
var driver_index = 0
var driver_count = 0
var gear = 0
var wx = 0.0
var wy = 0.0
var yaw = 0.0
var location = 0
var kmh = 0
var pos = 0
var cup_position = 0
var track_position = 0
var spline = 0.0
var laps = 0
var cdelta = 0
var best_lap = null
var last_lap = null
var current_lap = null
var color = Color.WHITE
var drivers = []
var model_type = 0
var team_name = ""
var race_number = 0
var cup_category = 0
var current_driver_index = 0
var nationality = 0
