#ifndef ACCTELEMETRY_H
#define ACCTELEMETRY_H

#include <godot_cpp/classes/ref.hpp>
#include <windows.h>

namespace godot {

class AccTelemetry : public RefCounted {
	GDCLASS(AccTelemetry, RefCounted)

private:
	struct SMElement
	{
		HANDLE hMapFile;
		unsigned char* mapFileBuffer;
	};

    SMElement m_graphics;
    SMElement m_physics;
    SMElement m_static;

	bool init_mm(SMElement *element, TCHAR name[], size_t size);

protected:
	static void _bind_methods();

public:
	AccTelemetry();
	~AccTelemetry();

	bool connect();
	void disconnect();
	Dictionary poll_physics();
	Dictionary poll_graphics();
	Dictionary poll_static();
};

}

#endif