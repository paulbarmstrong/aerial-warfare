disableSerialization;

_count = 1;

while {true} do
{
	// Update markers on the map
	[] call FNC_TrackOnMap;
	
	// Spawn a new convoy every so often
	if (_count mod 60 == 5) then {
		west spawn FNC_CreateConvoy;
		east spawn FNC_CreateConvoy;
	};
	
	// Make sure convoys aren't too far apart
	if (_count mod 10 == 0) then {
		{
			for "_i" from 0 to (count units _x) do {
				if (alive ((units _x) select _i) && ((units _x) select _i) distance2D (leader _x) > 250) then {
					_x call FNC_UpdateConvoyWaypoint;
				};
			};
		} forEach (Blufor_Convoy_Groups + Opfor_Convoy_Groups);
	};
	
	// Sometimes check to make sure playableUnits aren't stuck
	if (_count mod 60 == 59) then {
		{
			_lastPos = _x getVariable "LastPosition";
			if (!isPlayer _x && {local _x} && {!isNil "_lastPos"} && {_lastPos distance (position _x) < 10}) then {
				(group _x) setVariable ["lettingOutTroops", false];
				(group _x) setVariable ["landingAtBase", false];
				(group _x) spawn FNC_UpdateWaypoint;
			};
			_x setVariable ["LastPosition", position _x];
		} forEach playableUnits;
	};
	
	// Handle town-specific operations on a staggered schedule
	_i = _count mod (count TownNames);
	for "_j" from 0 to (count (TownUnits select _i) - 1) do {
	
		// Make sure town units are in fact getting to their turrets
		if (alive (TownUnits select _i select _j) && {vehicle (TownUnits select _i select _j) != (TownTurrets select _i select _j)}) then {
			(TownUnits select _i select _j) setDamage 0;
			if (assignedVehicle (TownUnits select _i select _j) != TownTurrets select _i select _j) then {
				if (vehicle (TownUnits select _i select _j) != TownTurrets select _i select _j) then {
					[TownUnits select _i select _j] remoteExec ["unassignVehicle", TownUnits select _i select _j, false];
					[TownUnits select _i select _j, TownTurrets select _i select _j] remoteExec ["assignAsGunner", TownUnits select _i select _j, false];
				};
			};
			
			[[TownUnits select _i select _j]] remoteExec ["orderGetIn", TownUnits select _i select _j, false];
			
			if ((TownUnits select _i select _j) distance2D (TownTurrets select _i select _j) < 5) then {
				(TownUnits select _i select _j) moveInGunner (TownTurrets select _i select _j);
			};
			(TownGroups select _i) setBehaviour "AWARE";
		};
	};
	
	// Award income every 60 seconds
	if (_count mod 60 == 0) then {
		{
			_income = 0;
			if (side group _x == west) then {
				_income = BluforIncome;
			} else {
				_income = OpforIncome;
			};
			if (_income > 0) then {
				_x groupChat format["Income from town occupation | +$%1", _income];
				[_x, _income] remoteExec ["FNC_ChangeMoney", 2, false];
			};
		} forEach playableUnits;
	};
	
	sleep 1;
	_count = _count + 1;
};