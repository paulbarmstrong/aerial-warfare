disableSerialization;

_turret = _this select 0;
_man = _this select 1;
_i = _this select 2;

_oldGroup = group _man;

if (TownGroups select _i isEqualTo grpNull) then {
	_newGroup = createGroup [side _man,true];
	TownGroups set [_i,_newGroup];
};
[_man] joinSilent (TownGroups select _i);

if (count units _oldGroup == 0) then {
	deleteGroup _oldGroup;
};

// Update town pop, detect capture, etc

_numberAlive = count units (TownGroups select _i);

_markerColor = "colorBLUFOR";
_flagClassname = "Flag_Blue_F";
if (side _man == east) then {
	_markerColor = "colorOPFOR";
	_flagClassname = "Flag_Red_F";
};

if (_numberAlive == 1) then { // This means that _man just captured this town
	_oldFlag = TownFlags select _i;
	TownMarkers select _i setMarkerColor _markerColor;
	_flagPos = position _oldFlag;
	
	deleteVehicle _oldFlag;
	
	_newFlag = _flagClassname createVehicle _flagPos;
	_newFlag setPos _flagPos;
	TownFlags set[_i,_newFlag];
	
	if (str (_man getVariable "owner") != "") then {
		_owner = _man getVariable "owner";
		(group _owner) setVariable["Money",((group _owner) getVariable "Money") + 1000];
		_owner groupChat format["Captured %2 | +$%1",1000,TownNames select _i];
	};
	
	_man globalChat format["%1 has been captured by the %2!",TownNames select _i,side _man];
};

TownMarkers select _i setMarkerText format["%1: %2/%3",TownNames select _i,_numberAlive,count (TownTurrets select _i)];