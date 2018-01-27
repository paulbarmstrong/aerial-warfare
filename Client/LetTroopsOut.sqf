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

// While we are still touching the ground and there are turret slots open, let them out one at a time
while {_heliManIndex < (count _cargoCrew) && _turretSlotIndex < count _turrets
				&& isTouchingGround (vehicle player) && vectorMagnitude velocity vehicle player < 5} do {
				
	while {_turretSlotIndex < count _turrets && ((_units select _turretSlotIndex) != objNull
				&& {alive (_units select _turretSlotIndex)})} do {
				
		_turretSlotIndex = _turretSlotIndex + 1;
	};
	if (_turretSlotIndex < count _turrets) then {
		_man = _cargoCrew select _heliManIndex;
		unassignVehicle _man;
		_man action ["eject",vehicle _man];
		//doGetOut _man;
		
		_man assignAsGunner (_turrets select _turretSlotIndex);
		[_man] orderGetIn true;		
		_units set[_turretSlotIndex,_man];
		
		_landingReward = 100;
		playSound "pullNotification";
		player groupChat format["Landing zone insertion | +$%1",_landingReward];
		group player setVariable["Money",(group player getVariable "Money") + _landingReward];
		
		sleep 1.25;
	};
	_heliManIndex = _heliManIndex + 1;
};


uiNameSpace setVariable ["isUnloadingTroops",false];

