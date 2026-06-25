disableSerialization;

_man = _this;
_group = group _man;
_heli = vehicle _man;

// Use this flag to avoid duplicate calls from the WaypointStatements
if ((playableUnits find _man > -1) && !(_group getVariable "lettingOutTroops") && !(_group getVariable "landingAtBase")) then {
	_group setVariable ["landingAtBase", true];

	_heli land "LAND";

	_timePassed = 0;

	while {!isTouchingGround _heli && _timePassed < 45} do {
		sleep 1;
		_timePassed = _timePassed + 1;
	};

	_man hideObject false;
	[_man, _heli getVariable "price"] remoteExec ["FNC_ChangeMoney", 2, false];
	_crew = crew _heli;
	deleteVehicle _heli;
	{
		if (playableUnits find _x < 0) then {
			deleteVehicle _x;
		};
	} forEach _crew;
	
	_group setVariable ["landingAtBase", false];
	
	if (alive _man && alive _heli) then {
		_man spawn FNC_AIRespawn;
	};
};
