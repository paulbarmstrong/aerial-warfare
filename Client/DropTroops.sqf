disableSerialization;

_i = _this;

// Get an array of all cargo crew
_cargoCrew = [];
{
	if (((_x select 0) getVariable "SoldierType") == "capture" && alive (_x select 0)) then {
		_cargoCrew = _cargoCrew + [_x select 0];
	};
} forEach fullCrew (vehicle player);

_turrets = TownTurrets select _i;
_units = TownUnits select _i;

_turretSlotIndex = 0;
_heliManIndex = 0;

// Let them out one at a time
while {_heliManIndex < (count _cargoCrew) && _turretSlotIndex < count _turrets} do {
	while {_turretSlotIndex < count _turrets && ((_units select _turretSlotIndex) != objNull && {alive (_units select _turretSlotIndex)})} do {
		_turretSlotIndex = _turretSlotIndex + 1;
	};
	if (_turretSlotIndex < count _turrets) then {
		_man = _cargoCrew select _heliManIndex;
		unassignVehicle _man;
		_man assignAsGunner (_turrets select _turretSlotIndex);
		[_man] orderGetIn true;
		
		removeBackpack _man;
		_man addBackpack "B_Parachute";
		_man action ["eject",vehicle _man];
		
		_units set[_turretSlotIndex,_man];
		
		_dropReward = 30;
		playSound "pullNotification";
		player groupChat format["Parachute insertion | +$%1",_dropReward];
		group player setVariable["Money",(group player getVariable "Money") + _dropReward];
		
		sleep 1;
	};
	_heliManIndex = _heliManIndex + 1;
};

