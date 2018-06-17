disableSerialization;

_group = group _this;
_heli = vehicle _this;

// Use this flag to avoid duplicate calls from the WaypointStatements
if ((playableUnits find _this > -1) && !(_group getVariable "lettingOutTroops") && !(_group getVariable "landingAtBase")) then {
	_group setVariable ["lettingOutTroops", true];
	
	_heli land "LAND";

	_closestTown = 0;
	for "_i" from 0 to (count TownFlags - 1) do {
		if (_heli distance2D (TownFlags select _i) < _heli distance2D (TownFlags select _closestTown)) then {
			_closestTown = _i;
		};
	};

	// If there are hostiles at this town, target them and make an effort to kill them
	if (side (TownGroups select _closestTown) != (side _group) && {(TownUnitCounts select _closestTown) > 0}) then {
		
		// Add waypoints to destroy all enemies there
		/*
		{
			if (!(_x isEqualTo objNull)) then {
				_newWaypoint = _group addWaypoint[_x,0];
				_newWaypoint setWaypointType "DESTROY";
			};
		} forEach (units (TownGroups select _closestTown)); */
		
	};
		
	_timePassed = 0;
	while {!isTouchingGround _heli && _timePassed < 45} do {
		sleep 1;
		_timePassed = _timePassed + 1;
	};

	if (isTouchingGround _heli && {(TownGroups select _closestTown) isEqualTo grpNull || (side (TownGroups select _closestTown)) == (side _group)}) then {


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
				_units set[_turretSlotIndex,_man];
				unassignVehicle _man;
				
				if ((TownGroups select _closestTown) isEqualTo grpNull || {count units (TownGroups select _closestTown) == 0}) then {
					_newGroup = createGroup [side _man, true];
					_newGroup setCombatMode "RED";
					_newGroup setGroupOwner 2;
					TownGroups set [_closestTown,_newGroup];
				};
				
				[_man] join (TownGroups select _closestTown);
				
				_man action ["eject", vehicle _man];
				
				_man assignAsGunner (_turrets select _turretSlotIndex);
				[_man] orderGetIn true;
								
				[leader _group, TROOP_LANDING_AWARD] remoteExec ["FNC_ChangeMoney", 2, false];
				
				sleep 1.25;
			};
			_heliManIndex = _heliManIndex + 1;
		};
	};
	
	if (alive _heli) then {
		_heli land "NONE";
		_group setVariable ["lettingOutTroops", false];
		_group spawn FNC_UpdateWaypoint;
	};
};



