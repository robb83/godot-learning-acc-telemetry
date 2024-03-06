#include "acc_telemetry.h"
#include "SharedFileOut.h"

#include <windows.h>
#include <algorithm>
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
    SPageFilePhysics* pf = (SPageFilePhysics*)m_physics.mapFileBuffer;

	PackedFloat32Array pressures = PackedFloat32Array();
	PackedFloat32Array temps = PackedFloat32Array();
	PackedFloat32Array breaks = PackedFloat32Array();
	PackedFloat32Array brakePressure = PackedFloat32Array();

	for (int i = 0; i < 4; ++i)
	{
		temps.push_back(pf->wheelsPressure[i]);
		pressures.push_back(pf->tyreCoreTemperature[i]);
		breaks.push_back(pf->brakeTemp[i]);
		brakePressure.push_back(pf->brakePressure[i]);
	}
	

    Dictionary result;
    result["packetId"] = pf->packetId;
    result["gas"] = pf->gas;
    result["brake"] = pf->brake;
    result["fuel"] = pf->fuel;
    result["gear"] = pf->gear;
    result["rpms"] = pf->rpms;
    result["steerAngle"] = pf->steerAngle;
    result["speedKmh"] = pf->speedKmh;
	result["wheelsPressure"] = pressures;
	result["tyreCoreTemperature"] = temps;
	result["tc"] = pf->tc;
	result["heading"] = pf->heading;
	result["pitch"] = pf->pitch;
	result["roll"] = pf->roll;
	result["pitLimiterOn"] = pf->pitLimiterOn;
	result["abs"] = pf->abs;
	result["airTemp"] = pf->airTemp;
	result["roadTemp"] = pf->roadTemp;
	result["finalFF"] = pf->finalFF;
	result["brakeTemp"] = pf->brakeTemp;
    result["clutch"] = pf->clutch;
	result["isAIControlled"] = pf->isAIControlled;
	result["brakeBias"] = pf->brakeBias;
	result["waterTemp"] = pf->waterTemp;
	result["brakePressure"] = pf->brakePressure;
	result["ignitionOn"] = pf->ignitionOn;
	result["starterEngineOn"] = pf->starterEngineOn;
	result["isEngineRunning"] = pf->isEngineRunning;


    return result;
}

Dictionary AccTelemetry::poll_graphics()
{
	SPageFileGraphic* pf = (SPageFileGraphic*)m_graphics.mapFileBuffer;

	PackedVector3Array car_coordinates = PackedVector3Array();
	PackedInt32Array car_id = PackedInt32Array();

	int cars = std::max(std::min(pf->activeCars, 60), 0);

	car_coordinates.resize(cars);
	car_id.resize(cars);

	for (int i = 0; i < cars; ++i) {
		car_coordinates.push_back(Vector3(pf->carCoordinates[i][0], pf->carCoordinates[i][1], pf->carCoordinates[i][2]));
		car_id.push_back(pf->carID[i]);
	}

	Dictionary result;
    result["packetId"] = pf->packetId;
	result["status"] = pf->status;
	result["session"] = pf->session;
	
	result["currentTime"] = pf->currentTime;
	result["currentTimeMS"] = pf->iCurrentTime;
	result["lastTime"] = pf->lastTime;
	result["lastTimeMS"] = pf->iLastTime;
	result["bestTime"] = pf->bestTime;
	result["bestTimeMS"] = pf->iBestTime;
	result["split"] = pf->split;
	result["splitMS"] = pf->iSplit;
	result["deltaLapTime"] = pf->deltaLapTime;
	result["deltaLapTimeMS"] = pf->iDeltaLapTime;

	result["completedLaps"] = pf->completedLaps;
	result["position"] = pf->position;
	result["sessionTimeLeft"] = pf->sessionTimeLeft;
	result["distanceTraveled"] = pf->distanceTraveled;
	result["isInPit"] = pf->isInPit;
	result["currentSectorIndex"] = pf->currentSectorIndex;
	result["lastSectorTime"] = pf->lastSectorTime;
	result["numberOfLaps"] = pf->numberOfLaps;
	result["tyreCompound"] = pf->tyreCompound;
	result["normalizedCarPosition"] = pf->normalizedCarPosition;
	result["activeCars"] = pf->activeCars;
	result["carCoordinates"] = car_coordinates;
	result["carID"] = car_id;
	result["playerCarID"] = pf->playerCarID;
	result["penaltyTime"] = pf->penaltyTime;
	result["flag"] = pf->flag;
	result["penalty"] = (int)pf->penalty;
	result["idealLineOn"] = pf->idealLineOn;
	result["isInPitLane"] = pf->isInPitLane;
	result["surfaceGrip"] = pf->surfaceGrip;
	result["mandatoryPitDone"] = pf->mandatoryPitDone;
	result["windSpeed"] = pf->windSpeed;
	result["windDirection"] = pf->windDirection;
	result["isSetupMenuVisible"] = pf->isSetupMenuVisible;
	result["mainDisplayIndex"]= pf->mainDisplayIndex;
	result["secondaryDisplayIndex"] = pf->secondaryDisplayIndex;
	result["TC"] = pf->TC;
	result["TCCUT"] = pf->TCCut;
	result["EngineMap"] = pf->EngineMap;
	result["ABS"] = pf->ABS;
	result["fuelXLap"] = pf->fuelXLap;	
	result["rainLights"] = pf->rainLights;
	result["flashingLights"] = pf->flashingLights;
	result["lightsStage"] = pf->lightsStage;	
	result["exhaustTemperature"] = pf->exhaustTemperature;
	result["wiperLV"] = pf->wiperLV;
	result["driverStintTotalTimeLeft"] = pf->DriverStintTotalTimeLeft;
	result["driverStintTimeLeft"] = pf->DriverStintTimeLeft;
	result["rainTyres"] = pf->rainTyres;
	result["sessionIndex"] = pf->sessionIndex;
	result["usedFuel"] = pf->usedFuel;
	result["estimatedLapTime"] = pf->estimatedLapTime;
	result["iEstimatedLapTime"] = pf->iEstimatedLapTime;
	result["isDeltaPositive"] = pf->isDeltaPositive;
	result["iSplit"] = pf->iSplit;
	result["isValidLap"] = pf->isValidLap;
	result["fuelEstimatedLaps"] = pf->fuelEstimatedLaps;
	result["trackStatus"] = pf->trackStatus;
	result["missingMandatoryPits"] = pf->missingMandatoryPits;
	result["Clock"] = pf->Clock;
	result["directionLightsLeft"] = pf->directionLightsLeft;
	result["directionLightsRight"] = pf->directionLightsRight;
    result["GlobalYellow"] = pf->GlobalYellow;
    result["GlobalYellow1"] = pf->GlobalYellow1;
    result["GlobalYellow2"] = pf->GlobalYellow2;
    result["GlobalYellow3"] = pf->GlobalYellow3;
    result["GlobalWhite"] = pf->GlobalWhite;
    result["GlobalGreen"] = pf->GlobalGreen;
    result["GlobalChequered"] = pf->GlobalChequered;
    result["GlobalRed"] = pf->GlobalRed;
    result["mfdTyreSet"] = pf->mfdTyreSet;
    result["mfdFuelToAdd"] = pf->mfdFuelToAdd;
    result["mfdTyrePressureLF"] = pf->mfdTyrePressureLF;
    result["mfdTyrePressureRF"] = pf->mfdTyrePressureRF;
    result["mfdTyrePressureLR"] = pf->mfdTyrePressureLR;
    result["mfdTyrePressureRR"] = pf->mfdTyrePressureRR;
	result["trackGripStatus"] = pf->trackGripStatus;
	result["rainIntensity"] = pf->rainIntensity;
	result["rainIntensityIn10min"] = pf->rainIntensityIn10min;
	result["rainIntensityIn30min"] = pf->rainIntensityIn30min;
	result["currentTyreSet"] = pf->currentTyreSet;
	result["strategyTyreSet"] = pf->strategyTyreSet;
	result["gapAhead"] = pf->gapAhead;
	result["gapBehind"] = pf->gapBehind;

    return result;
}

Dictionary AccTelemetry::poll_static()
{
	SPageFileStatic* pf = (SPageFileStatic*)m_static.mapFileBuffer;
	
	Dictionary result;
	result["smVersion"] = String(pf->smVersion);
	result["acVersion"] = String(pf->acVersion);
	result["numberOfSessions"] = pf->numberOfSessions;
	result["numCars"] = pf->numCars;
	result["carModel"] = String(pf->carModel);
	result["track"] = String(pf->track);
	result["playerName"] = String(pf->playerName);
	result["playerSurname"] = String(pf->playerSurname);
	result["playerNick"] = String(pf->playerNick);

	result["penaltiesEnabled"] = pf->penaltiesEnabled;
	result["sectorCount"] = pf->sectorCount;
	result["maxRpm"] = pf->maxRpm;
	result["maxFuel"] = pf->maxFuel;
	result["PitWindowStart"] = pf->PitWindowStart;
	result["PitWindowEnd"] = pf->PitWindowEnd;
	result["isOnline"] = pf->isOnline;
	result["dryTyresName"] = pf->dryTyresName;
	result["wetTyresName"] = pf->wetTyresName;
	result["aidFuelRate"] = pf->aidFuelRate;
	result["aidTireRate"] = pf->aidTireRate;
	result["aidMechanicalDamage"] = pf->aidMechanicalDamage;
	result["aidAllowTyreBlankets"] = pf->aidAllowTyreBlankets;
	result["aidStability"] = pf->aidStability;
	result["aidAutoClutch"] = pf->aidAutoClutch;
	result["aidAutoBlip"] = pf->aidAutoBlip;

    return result;
}