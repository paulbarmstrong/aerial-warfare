disableSerialization;

_initialOccupation = "InitialOccupation" call BIS_fnc_getParamValue;
_controlNearbyLZ = "ControlNearbyLZ" call BIS_fnc_getParamValue;
_delayBetweenMen = 0.02;

// Populate _bluforClosestTowns and _opforClosestTowns with all towns
// and get the average town distance from base
_averageTownDistance = 0;
_bluforClosestTowns = [];
_opforClosestTowns = [];
for "_i" from 0 to (count TownFlags - 1) do {
	_averageTownDistance = _averageTownDistance + ((TownFlags select _i) distance2D (BluforHelipads select 0))
												+ ((TownFlags select _i) distance2D (OpforHelipads select 0));
	_bluforClosestTowns = _bluforClosestTowns + [_i];
	_opforClosestTowns = _opforClosestTowns + [_i];
};
_averageTownDistance = _averageTownDistance / (2 * (count TownFlags));

// Sort by closest towns to base
_bluforClosestTowns = _bluforClosestTowns apply {[(TownFlags select _x) distance2D (BluforHelipads select 0), _x]};
_opforClosestTowns = _opforClosestTowns apply {[(TownFlags select _x) distance2D (OpforHelipads select 0), _x]};
_bluforClosestTowns sort true;
_opforClosestTowns sort true;

for "_i" from 0 to (count TownFlags - 1) do {
	_bluforClosestTowns set [_i, _bluforClosestTowns select _i select 1];
	_opforClosestTowns set [_i, _opforClosestTowns select _i select 1];
};

// Give blufor and opfor [_controlNearbyLZ] nearby towns
for "_i" from 0 to (_controlNearbyLZ - 1) do {
	if ((TownGroups select (_bluforClosestTowns select _i)) isEqualTo grpNull) then {
		_newGroup = createGroup [west, true];
		_newGroup setCombatMode "RED";
		_turrets = TownTurrets select (_bluforClosestTowns select _i);
		_units = [];
		for "_j" from 0 to (count _turrets - 1) do {
			_newUnit = _newGroup createUnit[BLUFOR_DEFAULT_RIFLEMAN, position (_turrets select _j), [], 0, "NONE"];
			_newUnit addEventHandler ["Killed", FNC_EntityKilled];
			if (USE_HITMARKERS) then {
				_newUnit addEventHandler ["Hit", FNC_DistributeHitmarkers];
			};
			_units = _units + [_newUnit]; 
		};
		TownGroups set [_bluforClosestTowns select _i, _newGroup];
		TownUnits set [_bluforClosestTowns select _i, _units];
		for "_j" from 0 to (count _units - 1) do {
			(_units select _j) assignAsGunner (_turrets select _j);
			(_units select _j) moveInGunner (_turrets select _j);
			sleep _delayBetweenMen;
		};
	};
	
	if ((TownGroups select (_opforClosestTowns select _i)) isEqualTo grpNull) then {
		_newGroup = createGroup [east, true];
		_newGroup setCombatMode "RED";
		_turrets = TownTurrets select (_opforClosestTowns select _i);
		_units = [];
		for "_j" from 0 to (count _turrets - 1) do {
			_newUnit = _newGroup createUnit[OPFOR_DEFAULT_RIFLEMAN, position (_turrets select _j), [], 0, "NONE"];
			_newUnit addEventHandler ["Killed", FNC_EntityKilled];
			if (USE_HITMARKERS) then {
				_newUnit addEventHandler ["Hit", FNC_DistributeHitmarkers];
			};
			_units = _units + [_newUnit];
		};
		TownGroups set [_opforClosestTowns select _i, _newGroup];
		TownUnits set [_opforClosestTowns select _i, _units];
		for "_j" from 0 to (count _units - 1) do {
			(_units select _j) assignAsGunner (_turrets select _j);
			(_units select _j) moveInGunner (_turrets select _j);
			sleep _delayBetweenMen;
		};
	};
};


// If InitialOccupation is greater than 0, then make all empty towns independent
if (_initialOccupation > 0) then {
	for "_i" from 0 to (count TownFlags - 1) do {
		
		if ((TownGroups select _i) isEqualTo grpNull) then {
			
			_maxUnits = 2;
			if (_initialOccupation == 2) then {
				_maxUnits = 30;
			};
			if (_initialOccupation == 3) then {
				if ((TownFlags select _i) distance2D (BluforHelipads select 0) < (TownFlags select _i) distance2D (OpforHelipads select 0)) then {
					_maxUnits = round (8 * ((TownFlags select _i) distance2D (BluforHelipads select 0)) / _averageTownDistance) - 4;
				} else {
					_maxUnits = round (8 * ((TownFlags select _i) distance2D (OpforHelipads select 0)) / _averageTownDistance) - 4;
				};
			};
			
			_newGroup = createGroup [independent, true];
			_newGroup setCombatMode "RED";
			_turrets = TownTurrets select _i;
			_units = TownUnits select _i;
			_numFilled = 0;
			_j = 0;
			
			// Get the number of AA turrets we need to fill
			_numAATurrets = 0;
			{
				if ((typeOf (_x)) find "AA" > -1) then {
					_numAATurrets = _numAATurrets + 1;
				};
			} forEach _turrets;
			_numAANeedFill = _maxUnits - (count _turrets - _numAATurrets);
			
			//while {(_j < count _turrets) && (_numFilled < ((count _turrets - 1) / 2))} do {
			while {(_j < count _turrets) && (_numFilled < _maxUnits)} do {
				
				// Exclude turrets with AA in the classname
				if (typeOf (_turrets select _j) find "AA" == -1 || _numAANeedFill > 0) then {
				
					_newUnit = _newGroup createUnit[INDEP_DEFAULT_RIFLEMAN, position (_turrets select _j), [], 0, "NONE"];
					_newUnit setSkill 0.2;
					if (USE_HITMARKERS) then {
						_newUnit addEventHandler ["Killed", FNC_EntityKilled];
					};
					_newUnit addEventHandler ["Hit", FNC_DistributeHitmarkers];
					_units set [_j, _newUnit];
					_numFilled = _numFilled + 1;
					if (typeOf (_turrets select _j) find "AA" > -1) then {
						_numAANeedFill = _numAANeedFill - 1;
					};
				
				};
				_j = _j + 1;
			};
			
			TownGroups set [_i, _newGroup];
			TownUnits set [_i, _units];
			for "_j" from 0 to (count _units - 1) do {
				if (_units select _j != objNull) then {
					(_units select _j) assignAsGunner (_turrets select _j);
					(_units select _j) moveInGunner (_turrets select _j);
					sleep _delayBetweenMen;
				};
			};
		};
	};
};

// Send out the variables!

publicVariable "BluforHelipads";
publicVariable "OpforHelipads";

publicVariable "TownFlags";
publicVariable "TownNames";
publicVariable "TownSizes";
publicVariable "TownMarkers";
publicVariable "TownUnits";
publicVariable "TownTurrets";
publicVariable "TownTHolders";
publicVariable "TownHelipads";
publicVariable "TownGroups";
publicVariable "TownUnitCounts";