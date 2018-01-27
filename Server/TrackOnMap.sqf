{
	_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _x) >> "displayName");
	_marker = format["%1_%2_marker",side _x,groupID (group _x)];
	_marker setMarkerText format["%1 [%2]",name _x,_genericHeliName];
	_marker setMarkerPos (position _x);
} forEach playableUnits;
