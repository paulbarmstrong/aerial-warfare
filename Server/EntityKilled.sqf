disableSerialization;

_unit = _this select 0;
_killer = _this select 1;

_unitSide = side (group _unit);
_killerSide = side (group _killer);
_killerOwner = leader (_killer getVariable "warfare_owner");
if (isNil "_killerOwner") then {
	_killerOwner = objNull;
};

// If the death has been handled, do nothing more
_hasBeenHandled = _unit getVariable "death_has_been_handled";
if (!isNil "_hasBeenHandled" && {_hasBeenHandled}) exitWith {};
_unit setVariable ["death_has_been_handled", true];

_enemyTypes = 	["Man",					"Car",		"Tank",		"Helicopter"];
_enemyAwards = 	[TROOP_KILL_AWARD,		500,		1000,		500];

_unitDisplayName = getText(configFile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
_specialAAIndex = SPECIAL_AA_SLINGABLES find (typeOf _unit);
if (_specialAAIndex > -1) then {
	_unitDisplayName = SPECIAL_AA_SLING_NAMES select _specialAAIndex;
};


// Make sure this thing is dead
if (getDammage _unit < 1) then {
	_unit setDamage 1;
};

// First use the enemy types catagories to find the bounty
_award = 0;
for "_i" from 0 to (count _enemyTypes - 1) do {
	if (_unit isKindOf (_enemyTypes select _i)) then {
		_award = _enemyAwards select _i;
	};
};

// Additionally, if the killed unit/vehicle is in the bounty classnames,
// use the bounty price as the award
_bountyIndex = BOUNTY_CLASSNAMES find (typeOf _unit);
if (_bountyIndex > -1 && {BOUNTY_PRICES select _bountyIndex > 0}) then {
	_award = BOUNTY_PRICES select _bountyIndex;
};

// Finally, if the killed unit is a town guardian, use the special award
_townNum = TownGroups find (group _unit);
if (_townNum > -1) then {
	_unitNum = (TownUnits select _townNum) find _unit;
	if (_unitNum > -1 && {_unit distance2D (TownTurrets select _townNum select _unitNum) < 5}) then {
		_turret = TownTurrets select _townNum select _unitNum;
		_award = LZ_KILL_AWARD;
		_unitDisplayName = format["%1 gunner", getText(configFile >> "CfgVehicles" >> (typeOf vehicle _turret) >> "displayName")];
	};
};


_listOfAssists = _unit getVariable "listOfAssists";
_validAssists = [];
if (!(isNil "_listOfAssists")) then {
	{
		if ((!(isNil "_x")) && {playableUnits find _x > -1} && {side group _x != side group _unit} && {group _x != group _killer}
				&& {!(_killerOwner isEqualTo _x)}) then {
			_validAssists = _validAssists + [_x];
		};
	} forEach (_unit getVariable "listOfAssists");
};

// Reward assists
{
	[_x, format["Assisted with enemy %2 | +$%1", _award/2, _unitDisplayName]] remoteExec ["groupChat", _x, false];
	[_x, _award / 2] remoteExec ["FNC_ChangeMoney", 2, false];

} forEach _validAssists;

// Reward killer
if (_unitSide != _killerSide) then {
	// If the killer is in a playableUnit's vehicle, award the kill to playableUnit
	if (playableUnits find (driver vehicle _killer) > -1) then {
		_owner = driver vehicle _killer;		
		[_owner, format["Neutralized enemy %2 | +$%1", _award,_unitDisplayName]] remoteExec ["groupChat", _owner, false];
		[_owner, _award] remoteExec ["FNC_ChangeMoney", 2, false];
	} else {
	
		// If the owner of the killer is a playableUnit, award the kill to playableUnit
		_killerDisplayName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _killer) >> "displayName");
		_specialAAIndex = SPECIAL_AA_SLINGABLES find (typeOf vehicle _killer);
		if (_specialAAIndex > -1) then {
			_killerDisplayName = SPECIAL_AA_SLING_NAMES select _specialAAIndex;
		};

		if (playableUnits find (leader (_killer getVariable "warfare_owner")) > -1) then {
			_owner = leader (_killer getVariable "warfare_owner");
			[_owner, format["Your %1 neutralized an enemy %2 | +$%3", _killerDisplayName, _unitDisplayName, _award]]
					remoteExec ["groupChat", _owner, false];
			[_owner, _award] remoteExec ["FNC_ChangeMoney", 2, false];
		};
	};
};


// Do things if this guy was guarding a base

for "_i" from 0 to (count TownMarkers - 1) do {
	if (((TownUnits select _i) find _unit) > -1) then {
	
		_numberAlive = 0;
		for "_j" from 0 to ((count (TownUnits select _i)) - 1) do {
			if (alive (TownUnits select _i select _j)
					&& {vehicle (TownUnits select _i select _j) == TownTurrets select _i select _j}) then {
				_numberAlive = _numberAlive + 1;
			};
		};
		TownUnitCounts set [_i, _numberAlive];

		[] call FNC_UpdateIncomes;
		
		if (_numberAlive > 0) then {
			TownMarkers select _i setMarkerText format["%1: %2/%3",TownNames select _i,_numberAlive,count (TownTurrets select _i)];
		} else {
			deleteGroup (TownGroups select _i);
			TownGroups set[_i,grpNull];
			if (getMarkerColor (TownMarkers select _i) != "colorWhite") then {
				// Town has been lost
				TownMarkers select _i setMarkerColor "colorWhite";
				TownMarkers select _i setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
				_oldFlag = TownFlags select _i;
				_flagPos = position _oldFlag;
				deleteVehicle _oldFlag;
				_newFlag = "FlagPole_F" createVehicle _flagPos;
				_newFlag setPos _flagPos;
				TownFlags set[_i,_newFlag];
				
				// If the killer's driver was a playableAI
				// (means the playableAI's vehicle cleared the lz), reward them
				_owner = leader (_killer getVariable "warfare_owner");
				if (isNil "_owner") then {
					_owner = driver vehicle _killer;
				};
				if (playableUnits find _owner > -1 && {_unitSide != _killerSide}) then {
					[_owner, format["Cleared enemy landing zone %1 | +$%2", TownNames select _i, TOWN_CLEAR_AWARD]]
							remoteExec ["groupChat", _owner, false];
					[_owner, TOWN_CLEAR_AWARD] remoteExec ["FNC_ChangeMoney", 2, false];
				};
			};
		};
	};
};

// If they were a playable unit blow up their helicopter
if (playableUnits find _unit > -1) then {
	(vehicle _unit) setDamage 1;
};

// If they were someone's car, let them know it got rekt
_carOwner = leader (_unit getVariable "warfare_owner");
if (!isNil "_carOwner" && {_unit isKindOf "Tank" || _unit isKindOf "Car"}) then {
	_carName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "displayName");
	[_carOwner, format["Your %1 was destroyed.", _carName]] remoteExec ["groupChat", _carOwner, false];
	
};
