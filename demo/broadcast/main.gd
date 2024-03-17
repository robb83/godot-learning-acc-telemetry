extends Node2D

var socket = null
var recorded = null
var race = null

func _ready():
	race = RaceEntry.new()

func on_registration_success(connection_id):
	print(connection_id)
	if socket:
		socket.request_track_data(connection_id)
		socket.request_entry_list(connection_id)
	
func _process(delta):
	if socket != null and socket.is_packet_available():
		var max_iteration = 30
		while socket.is_packet_available() and max_iteration > 0:
			max_iteration -= 1
			
			var packet : PackedByteArray = socket.get_packet()
			var reader = PacketReader.new()
			reader.set_buffer(packet)
			
			race.update(reader)
			
	if recorded != null:
		var max_iteration = 30
		while max_iteration > 0:
			max_iteration -= 1
			var length = recorded.get_buffer(4).decode_u32(0)
			var packet = recorded.get_buffer(length)
			if recorded.eof_reached():
				recorded.close()
				recorded = null
				break
			
			var reader = PacketReader.new()
			reader.set_buffer(packet)
			race.update(reader)
		
func _on_connect_button_pressed():
	var ip = $Control/MarginContainer/VBoxContainer/GridContainer/TextEditIP.text
	var port = int($Control/MarginContainer/VBoxContainer/GridContainer/TextEditPort.text)
	var password = $Control/MarginContainer/VBoxContainer/GridContainer/TextEditPassword.text
	
	if race:
		race.registration_success.disconnect(on_registration_success)
	
	race = RaceEntry.new()
	race.registration_success.connect(on_registration_success)
	
	if recorded:
		recorded.close()
		recorded = null
	
	if socket:
		socket.request_disconnect()
		socket = null
		
	socket = AccBroadcast.new()
	socket.connect(ip, port)
	socket.request_connect("Godot", password, 40, "")

func _on_button_open_pressed():
	$Control/FileDialogOpenRecorded.popup()

func _on_file_dialog_open_recorded_file_selected(path):
	if socket:
		socket.request_disconnect()
		socket = null	
		
	if recorded:
		recorded.close()
		recorded = null
	
	race = RaceEntry.new()
	recorded = FileAccess.open(path, FileAccess.READ)
