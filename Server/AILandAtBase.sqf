disableSerialization;

_man = _this;
_group = group _man;
_heli = vehicle _man;

// Use this flag to avoid duplicate calls from the WaypointStatements
if (!(_group getVariable "lettingOutTroops") && !(_group getVariable "landingAtBase")) then {
	_group setVariable ["landingAtBase", true];

	_homePos = getMarkerPos "respawn_west";
	if (side _this == east) then {
		_homePos = getMarkerPos "respawn_east";
	};

	_heli land "LAND";

	_timePassed = 0;

	while {!isTouchingGround _heli && _timePassed < 45} do {
		sleep 1;
		_timePassed = _timePassed + 1;
	};

	{
		_xUnit = _x select 0;
		if (playableUnits find _xUnit < 0) then {
			deleteVehicle _xUnit;
		};
	} forEach (fullCrew _heli);
	deleteVehicle _heli;

	_man call FNC_AIRespawn;

	_group setVariable ["landingAtBase", false];
	
	if (alive _heli) then {
		_heli land "NONE";
		_group setVariable ["landingAtBase", false];
		_group call FNC_UpdateWaypoint;
	};
};
