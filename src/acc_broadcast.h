#ifndef ACCBROADCAST_H
#define ACCBROADCAST_H

#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/classes/packet_peer_udp.hpp>

namespace godot {

#define ACC_BROADCAST_PROTOCOL_VERSION 4

enum AccBroadcastResult {
	REGISTRATION_RESULT = 1,
	REALTIME_UPDATE = 2,
	REALTIME_CAR_UPDATE = 3,
	ENTRY_LIST = 4,
	ENTRY_LIST_CAR = 6,
	TRACK_DATA = 5,
	BROADCASTING_EVENT = 7,
};

enum AccBroadcastCommands {
	REGISTER_COMMAND_APPLICATION = 1,
	UNREGISTER_COMMAND_APPLICATION = 9,
	REQUEST_ENTRY_LIST = 10,
	REQUEST_TRACK_DATA = 11,
};

class AccBroadcast : public RefCounted {
	GDCLASS(AccBroadcast, RefCounted)

protected:
	static void _bind_methods();
	Ref<PacketPeerUDP> socket;
	
public:
	AccBroadcast();
	~AccBroadcast();

	void connect(String ip, int port);
	void request_connect(String display_name, String connection_password, int update_interval, String command_password);
	void request_disconnect();
	void request_entry_list(int connectionId);
	void request_track_data(int connectionId);
	bool is_packet_available();
	PackedByteArray get_packet();
};

}

#endif