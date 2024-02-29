#include "acc_broadcast.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>

using namespace godot;

void AccBroadcast::_bind_methods() {
	ClassDB::bind_method(D_METHOD("connect", "ip", "port"), &AccBroadcast::connect);
	ClassDB::bind_method(D_METHOD("request_connect", "display_name", "connection_password", "update_interval", "command_password"), &AccBroadcast::request_connect);
	ClassDB::bind_method(D_METHOD("request_disconnect"), &AccBroadcast::request_disconnect);
	ClassDB::bind_method(D_METHOD("request_entry_list", "connectionId"), &AccBroadcast::request_entry_list);
	ClassDB::bind_method(D_METHOD("request_track_data", "connectionId"), &AccBroadcast::request_track_data);
	ClassDB::bind_method(D_METHOD("get_packet"), &AccBroadcast::get_packet);
	ClassDB::bind_method(D_METHOD("is_packet_available"), &AccBroadcast::is_packet_available);
}

AccBroadcast::AccBroadcast() {
	// Initialize any variables here.
}

AccBroadcast::~AccBroadcast() {
	// Add your cleanup here.
}

bool AccBroadcast::is_packet_available()
{
	return socket->get_available_packet_count() > 0;
}

PackedByteArray AccBroadcast::get_packet()
{
	return socket->get_packet();
}

void AccBroadcast::connect(String ip, int port)
{
	socket.instantiate();
	socket->connect_to_host(ip, port);
}

void AccBroadcast::request_connect(String display_name, String connection_password, int update_interval, String command_password) 
{
	PackedByteArray data1 = display_name.to_utf8_buffer();
	PackedByteArray data2 = connection_password.to_utf8_buffer();
	PackedByteArray data3 = command_password.to_utf8_buffer();

	PackedByteArray temp1;
	temp1.resize(2);
	temp1.encode_s8(0, AccBroadcastCommands::REGISTER_COMMAND_APPLICATION);
	temp1.encode_s8(1, ACC_BROADCAST_PROTOCOL_VERSION);

	PackedByteArray temp2;
	temp2.resize(2);
	temp2.encode_u16(0, data1.size());

	PackedByteArray temp3;
	temp3.resize(2);
	temp3.encode_u16(0, data2.size());

	PackedByteArray temp4;
	temp4.resize(4);
	temp4.encode_u32(0, update_interval);
	
	PackedByteArray temp5;
	temp5.resize(2);
	temp5.encode_u16(0, data3.size());

	PackedByteArray buffer;
	buffer.append_array(temp1);
	buffer.append_array(temp2);
	buffer.append_array(data1);	
	buffer.append_array(temp3);
	buffer.append_array(data2);	
	buffer.append_array(temp4);
	buffer.append_array(temp5);
	buffer.append_array(data3);	
	socket->put_packet(buffer);
}

void AccBroadcast::request_disconnect()
{
	PackedByteArray buffer;
	buffer.resize(1);
	buffer.encode_u8(0, AccBroadcastCommands::UNREGISTER_COMMAND_APPLICATION);
	socket->put_packet(buffer);
}

void AccBroadcast::request_track_data(int connectionId) 
{
	PackedByteArray buffer;
	buffer.resize(5);
	buffer.encode_u8(0, AccBroadcastCommands::REQUEST_TRACK_DATA);
	buffer.encode_s32(1, connectionId);
	socket->put_packet(buffer);
}

void AccBroadcast::request_entry_list(int connectionId) 
{
	PackedByteArray buffer;
	buffer.resize(5);
	buffer.encode_u8(0, AccBroadcastCommands::REQUEST_ENTRY_LIST);
	buffer.encode_s32(1, connectionId);
	socket->put_packet(buffer);
}