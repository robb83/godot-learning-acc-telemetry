extends Node2D

var telemetry = null
var gears = ["R", "N", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

@onready var dashboard = $Control/Dash

func _process(delta):
	if telemetry:
		var dp = telemetry.poll_physics()
		var dg = telemetry.poll_graphics()
		var ds = telemetry.poll_static()
		
		#save_to_file(ds, dg, dp)
		
		# abs, tc, speed, map, pit, gear, pressures, temps, fuel, fpl, rev, lap, time_best, time_current, time_diff, time_last, gas, brk, clutch, is_delta_positive, is_valid_lap
		dashboard.update(
			(dg.ABS), (dg.TC), (dp.speedKmh), (dg.EngineMap + 1), 0,
			gears[dp.gear], dp.wheelsPressure, dp.tyreCoreTemperature, 
			(dp.fuel), dg.fuelXLap, (dp.rpms), (dg.completedLaps), dg.bestTime, dg.currentTime, dg.deltaLapTime, dg.lastTime, dp.gas, dp.brake, 1.0 - dp.clutch, 1, 1)
	
func _on_connect_button_pressed():
	if telemetry == null:
		telemetry = AccTelemetry.new()
		telemetry.connect()
