class_name TelemetryProtocol extends RefCounted

const PROTOCOL_VERSION = 4
const REGISTER_COMMAND_APPLICATION = 1
const UNREGISTER_COMMAND_APPLICATION = 9
const REQUEST_ENTRY_LIST = 10
const REQUEST_TRACK_DATA = 11

const REGISTRATION_RESULT = 1
const REALTIME_UPDATE = 2
const REALTIME_CAR_UPDATE = 3
const ENTRY_LIST = 4
const ENTRY_LIST_CAR = 6
const TRACK_DATA = 5
const BROADCASTING_EVENT = 7

func build_request_connection(display_name, connection_password, update_interval, command_password):
	var pb = PacketBuilder.new()
	pb.append_u8(REGISTER_COMMAND_APPLICATION)
	pb.append_u8(PROTOCOL_VERSION)
	pb.append_string(display_name)
	pb.append_string(connection_password)
	pb.append_u32(update_interval)
	pb.append_string(command_password)	
	return pb.to_packed_byte_array()

func build_request_disconnect():
	var pb = PacketBuilder.new()
	pb.append_u8(UNREGISTER_COMMAND_APPLICATION)
	return pb.to_packed_byte_array()
	
func build_request_entry_list(connectionID):
	var pb = PacketBuilder.new()
	pb.append_u8(REQUEST_ENTRY_LIST)
	pb.append_s32(connectionID)
	return pb.to_packed_byte_array()
	
func build_request_track_data(connectionID):
	var pb = PacketBuilder.new()
	pb.append_u8(REQUEST_ENTRY_LIST)
	pb.append_s32(connectionID)
	return pb.to_packed_byte_array()
