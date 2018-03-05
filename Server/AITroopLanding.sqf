disableSerialization;

_group = group _this;
_heli = vehicle _this;

// Use this flag to avoid duplicate calls from the WaypointStatements
if (!(_group getVariable "lettingOutTroops") && !(_group getVariable "landingAtBase")) then {
	_group setVariable ["lettingOutTroops", true];

	_homePos = getMarkerPos "respawn_west";
	if (side _this == east) then {
		_homePos = getMarkerPos "respawn_east";
	};

	_heli land "LAND";

	_closestTown = 0;
	for "_i" from 0 to (count TownFlags - 1) do {
		if (_heli distance2D (TownFlags select _i) < _heli distance2D (TownFlags select _closestTown)) then {
			_closestTown = _i;
		};
	};

	_timePassed = 0;

	while {!isTouchingGround _heli && _timePassed < 45} do {
		sleep 1;
		_timePassed = _timePassed + 1;
	};

	if (isTouchingGround _heli) then {


		// Get an array of all cargo crew
		_cargoCrew = [];
		{
			if (((_x select 0) getVariable "SoldierType") == "capture" && alive (_x select 0)) then {
				_cargoCrew = _cargoCrew + [_x select 0];
			};
		} forEach fullCrew _heli;

		_turrets = TownTurrets select _closestTown;
		_units = TownUnits select _closestTown;

		_turretSlotIndex = 0;
		_heliManIndex = 0;

		// While we are still touching the ground and there are turret slots open, let them out one at a time
		while {_heliManIndex < (count _cargoCrew) && _turretSlotIndex < (count _turrets)
						&& isTouchingGround _heli && vectorMagnitude velocity _heli < 5} do {
						
			while {_turretSlotIndex < count _turrets && ((_units select _turretSlotIndex) != objNull
						&& {alive (_units select _turretSlotIndex)})} do {
						
				_turretSlotIndex = _turretSlotIndex + 1;
			};
			if (_turretSlotIndex < count _turrets) then {
				_man = _cargoCrew select _heliManIndex;
				unassignVehicle _man;
				_man action ["eject",vehicle _man];
				
				_man assignAsGunner (_turrets select _turretSlotIndex);
				[_man] orderGetIn true;		
				_units set[_turretSlotIndex,_man];
				
				sleep 1.25;
			};
			_heliManIndex = _heliManIndex + 1;
		};
	};
	
	if (alive _heli) then {
		_heli land "NONE";
		_group setVariable ["lettingOutTroops", false];
		_group call FNC_UpdateWaypoint;
	};
};



