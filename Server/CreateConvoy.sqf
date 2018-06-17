disableSerialization;

_side = _this;

_grps = Blufor_Convoy_Groups;
_vehList = BLUFOR_CONVOY_VEHICLES;
_newVehPos = position bluforGarage;
_newVehDir = getDir bluforGarage;
if (_side == east) then {
	_grps = Opfor_Convoy_Groups;
	_vehList = OPFOR_CONVOY_VEHICLES;
	_newVehPos = position opforGarage;
	_newVehDir = getDir opforGarage;
};

_grpIndex = _grps find grpNull;
if (_grpIndex == -1) exitWith {};

// Create new group for the convoy
_group = createGroup [_side, true];
_grps set [_grpIndex, _group];

// Iterate through all the vehicles to be created
for "_i" from 0 to (count _vehList - 1) do {

	// Create the vehicle
	_newClassname = _vehList select _i;
	_vehArgs = [_newVehPos, _newVehDir, _newClassname, _group] call BIS_fnc_spawnVehicle;
	_veh = _vehArgs select 0;
	_fullCrew = units _group;

	// Lock the vehicle immediately
	_veh lock true;
	_veh allowCrewInImmobile true;
	_veh enableRopeAttach false;
	
	// Offset newVehPos for the next vehicle
	_newVehPos = [_newVehPos, 20, _newVehDir + 180] call BIS_fnc_relPos;
	
	// Apply Event handlers
	{
		_x addEventHandler ["GetOutMan", "(_this select 0) spawn FNC_RemoveAfterMinute;"];
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		_x addEventHandler ["Hit", FNC_DistributeHitmarkers];
	} forEach _fullCrew;
	_veh addEventHandler ["Hit","(_this select 0) spawn FNC_DelayedWheelRepair;"];
	_veh addEventHandler ["Killed","_this call FNC_EntityKilled"];
	_veh addEventHandler ["Hit","_this call FNC_AddAssistMember"];
	_veh setVariable ["listOfAssists",[]];
	_veh addEventHandler ["Hit", FNC_DistributeHitmarkers];
	_veh limitSpeed 60;
};

// Give the initial waypoint
_group call FNC_UpdateConvoyWaypoint;

//_newClassname = BLUFOR_CONVOY_VEHICLES select ([0, count BLUFOR_CONVOY_VEHICLES - 1] call BIS_fnc_randomInt);


