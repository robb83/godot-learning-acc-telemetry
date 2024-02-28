#include "acc_telemetry.h"
#include "SharedFileOut.h"

#include <windows.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>

using namespace godot;

void AccTelemetry::_bind_methods() {
    ClassDB::bind_method(D_METHOD("connect"), &AccTelemetry::connect);
    ClassDB::bind_method(D_METHOD("disconnect"), &AccTelemetry::disconnect);
    ClassDB::bind_method(D_METHOD("poll_physics"), &AccTelemetry::poll_physics);
    ClassDB::bind_method(D_METHOD("poll_graphics"), &AccTelemetry::poll_graphics);
    ClassDB::bind_method(D_METHOD("poll_static"), &AccTelemetry::poll_static);
}

AccTelemetry::AccTelemetry() {
	// Initialize any variables here.
}

AccTelemetry::~AccTelemetry() {
	disconnect();
}

bool AccTelemetry::connect()
{
	if (init_mm(&m_physics, TEXT("Local\\acpmf_physics"), sizeof(SPageFilePhysics)) &&
		init_mm(&m_graphics, TEXT("Local\\acpmf_graphics"), sizeof(SPageFileGraphic)) &&
		init_mm(&m_static, TEXT("Local\\acpmf_static"), sizeof(SPageFileStatic)))
		{
			return true;
		}

	disconnect();
	return false;
}

void AccTelemetry::disconnect()
{
	if (m_physics.hMapFile) 
	{
		UnmapViewOfFile(m_physics.mapFileBuffer);
		CloseHandle(m_physics.hMapFile);

		m_physics.hMapFile = NULL;
		m_physics.mapFileBuffer = NULL;
	}

	if (m_graphics.hMapFile) 
	{
		UnmapViewOfFile(m_graphics.mapFileBuffer);
		CloseHandle(m_graphics.hMapFile);

		m_graphics.hMapFile = NULL;
		m_graphics.mapFileBuffer = NULL;
	}
    
	if (m_static.hMapFile) 
	{
		UnmapViewOfFile(m_static.mapFileBuffer);
		CloseHandle(m_static.hMapFile);

		m_static.hMapFile = NULL;
		m_static.mapFileBuffer = NULL;
	}
}

bool AccTelemetry::init_mm(SMElement *element, TCHAR name[], size_t size)
{
	HANDLE handle = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, size, name);
	if (!handle) 
	{
		return false;
	}

	unsigned char* buffer = (unsigned char*)MapViewOfFile(handle, FILE_MAP_READ, 0, 0, size);
	if (!buffer)
	{
		CloseHandle(handle);
		return false;
	}

	element->hMapFile = handle;
	element->mapFileBuffer = buffer;

	return true;
}

Dictionary AccTelemetry::poll_physics()
{
    Dictionary result;

    SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;
    result["packetId"] = pf->packetId;
    result["brake"] = pf->brake;
    result["gas"] = pf->gas;
    result["fuel"] = pf->fuel;
    result["gear"] = pf->gear;
    result["speedKmh"] = pf->speedKmh;
    result["steerAngle"] = pf->steerAngle;
    result["clutch"] = pf->clutch;
	result["isAIControlled"] = pf->isAIControlled;

    return result;
}

Dictionary AccTelemetry::poll_graphics()
{
	Dictionary result;
    return result;
}

Dictionary AccTelemetry::poll_static()
{
	Dictionary result;
    return result;
}