
// Update markers for playableUnits
{
	if (alive _x) then {
		_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _x) >> "displayName");
		_marker = format["%1_%2_marker",side group _x,groupID (group _x)];
		_marker setMarkerText format["%1 [%2]",name _x,_genericHeliName];
		_marker setMarkerPos (position vehicle _x);
		_marker setMarkerAlpha 1;
	} else {
		_marker setMarkerAlpha 0;
	};
} forEach playableUnits;

// Update markers for sling vehicles
for "_i" from 0 to (count SlingMarkerArray - 1) do {
	_marker = SlingMarkerArray select _i;
	_car = SlingVehicleArray select _i;
	if (!isNil "_car" && {alive _car}) then {
	
		// If the car is below 3 meters, track on map
		if (((getPosATL _car) select 2 < 3) || ((getPosASL _car) select 2 < 3)) then {
			_marker setMarkerPos (position _car);
			_marker setMarkerAlpha 1;
		} else {
			_marker setMarkerAlpha 0;
		};
	} else {
		deleteMarker _marker;
		SlingMarkerArray = SlingMarkerArray - [_marker];
		SlingVehicleArray = SlingVehicleArray - [_car];
	};
};



// Update markers for convoys
for "_i" from 0 to (count Blufor_Convoy_Groups - 1) do {
	_marker = format["blufor_convoy_marker_%1", _i];
	_grp = Blufor_Convoy_Groups select _i;
	if (!(_grp isEqualTo grpNull) && {count units _grp > 0}) then {
	
		_aliveIndex = 0;
		while {!alive ((units _grp) select _aliveIndex) && _aliveIndex < count units _grp} do {
			_aliveIndex = _aliveIndex + 1;
		};
		if (_aliveIndex < count units _grp) then {
			_marker setMarkerText format["Blufor Convoy %1", _i + 1];
			_marker setMarkerPos (position ((units _grp) select _aliveIndex));
			_marker setMarkerAlpha 1;
		} else {
			_marker setMarkerAlpha 0;
		};
	} else {
		_marker setMarkerAlpha 0;
	};
};
for "_i" from 0 to (count Opfor_Convoy_Groups - 1) do {
	_marker = format["opfor_convoy_marker_%1", _i];
	_grp = Opfor_Convoy_Groups select _i;
	if (!(_grp isEqualTo grpNull) && {!((leader _grp) isEqualTo objNull)} && {alive (leader _grp)}) then {
		_marker setMarkerText format["Opfor Convoy %1", _i + 1];
		_marker setMarkerPos (position leader _grp);
		_marker setMarkerAlpha 1;
	} else {
		_marker setMarkerAlpha 0;
	};
};
