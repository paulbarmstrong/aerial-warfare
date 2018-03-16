disableSerialization;


_unit = _this select 0;
_unitSide = side (group _unit);
_killer = _this select 1;
_killerSide = side (group _killer);

_enemyTypes = 	["Man",		"Car",		"Tank",		"Helicopter"];
_enemyAwards = 	[100,		500,		1000,		2500];

_unitDisplayName = getText(configFile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
_award = 0;
for "_i" from 0 to (count _enemyTypes - 1) do {
	if (_unit isKindOf (_enemyTypes select _i)) then {
		_award = _enemyAwards select _i;
	};
};


_listOfAssists = _unit getVariable "listOfAssists";
_validAssists = [];
if (!(isNil "_listOfAssists")) then {
	{
		if ((!(isNil "_x")) && {playableUnits find _x > -1} && {isPlayer _x} && {side group _x != side group _unit} && {group _x != group _killer}) then {
			_validAssists = _validAssists + [_x];
		};
	} forEach (_unit getVariable "listOfAssists");
};

// Reward assists
{
	_x groupChat format["Assisted with enemy %2 | +$%1",_award/2,_unitDisplayName];
	(group _x) setVariable["Money",(group _x getVariable "Money") + (_award/2),true];

} forEach _validAssists;

// Reward killer
if (_unitSide != _killerSide) then {
	_killer groupChat format["Neutralized enemy %2 | +$%1",_award,_unitDisplayName];
	(group _killer) setVariable["Money",(group _killer getVariable "Money") + _award,true];
};



// Do things if this guy was guarding a base

for "_i" from 0 to (count TownMarkers - 1) do {
	if (((TownUnits select _i) find _unit) > -1) then {
		_numberAlive = 0;
		{
			if (alive _x) then {
				_numberAlive = _numberAlive + 1;
			};
		} forEach (units (TownGroups select _i));
		
		if (_numberAlive > 0) then {
			TownMarkers select _i setMarkerText format["%1: %2/%3",TownNames select _i,_numberAlive,count (TownTurrets select _i)];
		} else {
			TownMarkers select _i setMarkerColor "colorWhite";
			TownMarkers select _i setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
			_oldFlag = TownFlags select _i;
			_flagPos = position _oldFlag;
			deleteVehicle _oldFlag;
			_newFlag = "FlagPole_F" createVehicle _flagPos;
			_newFlag setPos _flagPos;
			TownFlags set[_i,_newFlag];
			TownGroups set[_i,grpNull];
		};
	};
};
