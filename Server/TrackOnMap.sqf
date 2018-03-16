{
	_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _x) >> "displayName");
	_marker = format["%1_%2_marker",side group _x,groupID (group _x)];
	_marker setMarkerText format["%1 [%2]",name _x,_genericHeliName];
	_marker setMarkerPos (position _x);
} forEach playableUnits;


for "_i" from 0 to (count Blufor_Convoy_Groups - 1) do {
	_marker = format["blufor_convoy_marker_%1", _i];
	_grp = Blufor_Convoy_Groups select _i;
	if (!(_grp isEqualTo grpNull) && {!((leader _grp) isEqualTo objNull)}) then {
		_marker setMarkerText format["Blufor Convoy %1", _i + 1];
		_marker setMarkerPos (position leader _grp);
		_marker setMarkerAlpha 1;
	} else {
		_marker setMarkerAlpha 0;
	};
};

for "_i" from 0 to (count Opfor_Convoy_Groups - 1) do {
	_marker = format["opfor_convoy_marker_%1", _i];
	_grp = Opfor_Convoy_Groups select _i;
	if (!(_grp isEqualTo grpNull) && {!((leader _grp) isEqualTo objNull)}) then {
		_marker setMarkerText format["Opfor Convoy %1", _i + 1];
		_marker setMarkerPos (position leader _grp);
		_marker setMarkerAlpha 1;
	} else {
		_marker setMarkerAlpha 0;
	};
};