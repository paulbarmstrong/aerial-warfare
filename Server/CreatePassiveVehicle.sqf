disableSerialization;

_side = _this;

_grps = Blufor_Passive_Groups;
_newVehPos = position bluforGarage;
_newVehDir = getDir bluforGarage;
_newClassname = BLUFOR_GARAGE_VEHICLES select ([0, count BLUFOR_GARAGE_VEHICLES - 1] call BIS_fnc_randomInt);
if (_side == east) then {
	_grps = Opfor_Passive_Vehicles;
	_newVehPos = position opforGarage;
	_newVehDir = getDir opforGarage;
	_newClassname = OPFOR_GARAGE_VEHICLES select ([0, count OPFOR_GARAGE_VEHICLES - 1] call BIS_fnc_randomInt);
};

// Limit number of passive vehicles (arbitrary number)
if (count _vehList < 10) then {

	// Create the vehicle
	_vehArgs = [_newVehPos, _newVehDir, _newClassname, _side] call BIS_fnc_spawnVehicle;
	_veh = _vehArgs select 0;
	_group = _vehArgs select 2;
	_fullCrew = units _group;

	// Lock the vehicle immediately
	_veh lock true;
	_veh allowCrewInImmobile true;

	// Apply Event handlers
	{
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		[_x,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
	} forEach _fullCrew;
	_veh addEventHandler ["Killed","_this call FNC_EntityKilled"];
	[_veh,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
	
	// Add this group to the list of passive groups
	_grps = _grps + [_group];

	// Give the initial waypoint
	_group call FNC_UpdateVehicleWaypoint;

};
