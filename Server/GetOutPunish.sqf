disableSerialization;

_veh = _this select 0;
_man = _this select 2;

// Find the closest town
_closestTown = 0;
for '_i' from 0 to (count TownFlags - 1) do {
	if (_man distance2D (TownFlags select _i) < _man distance2D (TownFlags select _closestTown)) then {
		_closestTown = _i;
	};
};

sleep 0.5;

// If the man getting out isn't assigned to that town, either kill him or put him back in
if (!(isObjectHidden _man) && !(isPlayer _man) && (vehicle _man == _man) && {(TownUnits select _closestTown) find _man == -1}
		&& {_veh != objNull}) then {
	
	//hint format["closestTown: %1, TownUnits: %2, random: %3", _closestTown, TownUnits select _closestTown, random 100];

	_type = _man getVariable "SoldierType";
	if (!isNil "_type" && {_type == "capture"}) then {
		
		[_man] remoteExec ["unassignVehicle", owner _veh, false];
		[_man, _veh] remoteExec ["assignAsCargo", owner _veh, false];
		[_man, _veh] remoteExec ["moveInCargo", owner _veh, false];
		
	} else {
		_man allowDamage true;
		_man setDamage 1;
	};
};


/*
sleep 10;

// If the man getting out isn't assigned to that town, kill him
if (!(isObjectHidden _man) && !(isPlayer _man) && (vehicle _man == _man) && {(TownUnits select _closestTown) find _man == -1}) then {
	_man allowDamage true;
	_man setDamage 1;
};

*/