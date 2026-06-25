disableSerialization;

_turret = _this select 0;
_man = _this select 1;
_i = _this select 2;
_side = side group _man;

_man setDamage 0;

// Update town pop, detect capture, etc

_numberAlive = 0;
for "_j" from 0 to ((count (TownUnits select _i)) - 1) do {
	if (alive (TownUnits select _i select _j)
			&& {vehicle (TownUnits select _i select _j) == TownTurrets select _i select _j}) then {
		_numberAlive = _numberAlive + 1;
	};
};
TownUnitCounts set [_i, _numberAlive];

[] call FNC_UpdateIncomes;

_markerColor = "colorBLUFOR";
_flagClassname = "Flag_Blue_F";
_convoyGroups = Blufor_Convoy_Groups;
if (_side == east) then {
	_markerColor = "colorOPFOR";
	_flagClassname = "Flag_Red_F";
	_convoyGroups = Opfor_Convoy_Groups;
};
if (_side == independent) then {
	_markerColor = "colorGreen";
	_flagClassname = "Flag_Green_F";
};

if (markerColor (TownMarkers select _i) == "colorWhite") then { // This means that _man just captured this town

	// Replace the flag
	_oldFlag = TownFlags select _i;
	TownMarkers select _i setMarkerColor _markerColor;
	_flagPos = position _oldFlag;
	
	deleteVehicle _oldFlag;
	
	_newFlag = _flagClassname createVehicle _flagPos;
	_newFlag setPos _flagPos;
	TownFlags set[_i,_newFlag];
	
	// Do income/dialog things
	if (str (_man getVariable "warfare_owner") != "") then {
		_owner = leader (_man getVariable "warfare_owner");
		[_owner, format["Captured %2 | +$%1", TOWN_CAPTURE_AWARD, TownNames select _i]] remoteExec ["groupChat", _owner, false];
		[_owner, TOWN_CAPTURE_AWARD] remoteExec ["FNC_ChangeMoney", 2, false];
	};
	_man globalChat format["%1 has been captured by the %2!",TownNames select _i, _side];
	
	// Tell convoys at the town to roll out
	
	if (!isNil "_convoyGroups") then {
		for "_j" from 0 to (count _convoyGroups - 1) do {
			if (!((_convoyGroups select _j) isEqualTo grpNull) && {count (waypoints (_convoyGroups select _j)) > 0}
				&& {(waypointPosition ((waypoints (_convoyGroups select _j)) select 0)) distance2D (TownFlags select _i) < 150}) then {
				(_convoyGroups select _j) spawn FNC_UpdateConvoyWaypoint;
			};
		};
	};
	
	// Check to see if all towns are now friendly
	_allFriendly = true;
	{
		if (side _x != _side) then {
			_allFriendly = false;
		};
	} forEach TownGroups;
	
	// If all towns are friendly, the mission should end
	if (_allFriendly && _side != independent) then {
		"EveryoneWon" call BIS_fnc_endMissionServer
	};
};
_man setVariable ["warfare_owner", grpNull];

// Update town alive count on map
TownMarkers select _i setMarkerText format["%1: %2/%3",TownNames select _i,_numberAlive,count (TownTurrets select _i)];

