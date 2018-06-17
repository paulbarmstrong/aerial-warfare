disableSerialization;

_player = _this select 0;
_i = _this select 1;

// Get an array of all cargo crew
_cargoCrew = [];
{
	if (((_x select 0) getVariable "SoldierType") == "capture" && alive (_x select 0)) then {
		_cargoCrew = _cargoCrew + [_x select 0];
	};
} forEach fullCrew (vehicle _player);

_turrets = TownTurrets select _i;
_units = TownUnits select _i;

_turretSlotIndex = 0;
_heliManIndex = 0;

if ((TownGroups select _i) isEqualTo grpNull || {side (TownGroups select _i) == (side group _player)}) then {

	// Let them out one at a time
	while {_heliManIndex < (count _cargoCrew) && _turretSlotIndex < count _turrets} do {
		while {_turretSlotIndex < count _turrets && ((_units select _turretSlotIndex) != objNull && {alive (_units select _turretSlotIndex)})} do {
			_turretSlotIndex = _turretSlotIndex + 1;
		};
		if (_turretSlotIndex < count _turrets) then {
			_man = _cargoCrew select _heliManIndex;
			
			if ((TownGroups select _i) isEqualTo grpNull || {count units (TownGroups select _i) == 0}) then {
				_newGroup = createGroup [side group _man, true];
				_newGroup setCombatMode "RED";
				_newGroup setGroupOwner 2;
				TownGroups set [_i, _newGroup];
			};
			_units set[_turretSlotIndex, _man];

			
			// Do "go to turret" things on server
			removeBackpack _man;
			unassignVehicle _man;
			moveOut _man;
			[_man] joinSilent (TownGroups select _i);
			_man assignAsGunner (_turrets select _turretSlotIndex);
			[_man] orderGetIn true;
			
			// Do "go to turret" things again on client
			[_man] remoteExec ["unassignVehicle", _player, false];
			[_man] remoteExec ["moveOut", _player, false];
			[[_man], (TownGroups select _i)] remoteExec ["joinSilent", _player, false];
			[_man, _turrets select _turretSlotIndex] remoteExec ["assignAsGunner", _player, false];
			[[_man], true] remoteExec ["orderGetIn", _player, false];
			
			// Give him a parachute
			//[_man] remoteExec ["removeBackpack", _player, false];
			[_man, "B_Parachute"] remoteExec ["addBackpack", _player, false];
			
			// Give award
			"pullNotification" remoteExec ["playSound", _player, false];		
			[_player, format["Parachute insertion | +$%1", TROOP_PARACHUTE_AWARD]] remoteExec ["groupChat", _player, false];
			[_player, TROOP_PARACHUTE_AWARD] remoteExec ["FNC_ChangeMoney", 2, false];
			
			sleep 1;
		};
		_heliManIndex = _heliManIndex + 1;
	};
	(TownGroups select _i) setGroupOwner 2;
};

