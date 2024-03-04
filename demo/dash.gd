extends Control

func update(abs, tc, speed, map, pit, gear, pressures, temps, fuel, fpl, rev, lap, time_best, time_current, time_diff, gas, brk, clutch):
	$Block11.set_value(str(abs))
	$Block12.set_value(str(tc))
	$Block13.set_value("%3.1f" % speed)
	$Block14.set_value(str(map))
	$Block15.set_value(str(pit))
	$Block21.set_value("%4.1f" % pressures[0])
	$Block22.set_value("%4.1f" % pressures[1])
	$Block23.set_value(str(gear))
	$Block24.set_value("%4.1f" % temps[0])
	$Block25.set_value("%4.1f" % temps[1])
	$Block31.set_value("%4.1f" % pressures[2])
	$Block32.set_value("%4.1f" % pressures[3])
	$Block34.set_value("%4.1f" % temps[2])
	$Block35.set_value("%4.1f" % temps[3])
	$Block41.set_value("%3.1f" % fuel)
	$Block42.set_value("%3.1f" % fpl)
	$Block43.set_value(str(rev))
	$Block44.set_value(str(lap))
	$Block51.set_value(str(time_best))
	$Block52.set_value(str(time_current))
	$Block53.set_value(str(time_diff))
	$BlockT1.set_value(gas)
	$BlockT2.set_value(brk)
	$BlockT3.set_value(clutch)
	$BlockT4.set_value(0.0)
