_unit = _this select 0;
_unitSide = side (group _unit);
_killer = _this select 1;
_killerSide = side (group _killer);

_enemyTypes = 	["Man",		"Car",		"Tank",		"Helicopter"];
_enemyAwards = 	[100,		500,		1000,		2500];

if ((playableUnits) find (driver (vehicle _killer)) > -1 && _unitSide != _killerSide) then
{
	_name = getText(configFile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
	_award = 0;
	for "_i" from 0 to (count _enemyTypes - 1) do
	{
		if (_unit isKindOf (_enemyTypes select _i)) then
		{
			_award = _enemyAwards select _i;
		};
	};
	_killer groupChat format["Neutralized enemy %2 | +$%1",_award,_name];
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
			TownMarkers select _i setMarkerColor "colorKhaki";
			TownMarkers select _i setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
			_oldFlag = TownFlags select _i;
			_flagPos = position _oldFlag;
			deleteVehicle _oldFlag;
			_newFlag = "FlagPole_F" createVehicle _flagPos;
			_newFlag setPos _flagPos;
			TownFlags set[_i,_newFlag];
		};
	};
};
