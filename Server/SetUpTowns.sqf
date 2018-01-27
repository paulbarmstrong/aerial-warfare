disableSerialization;

TownMarkers = 	["townMarker",		"townMarker_1"];
TownFlags = 	[townFlag,			townFlag_1];
TownNames = 	["Test Town 1",		"Test Town 2"];
TownSizes = 	[50,				50];
TownSizesSqr =	[];
TownUnits =		[[],				[]];
TownTurrets =	[[],				[]];
TownTHolders =	[objNull,			objNull];
TownGroups = 	[grpNull,			grpNull];

for "_i" from 0 to (count TownMarkers - 1) do {

	// Sort out markers
	_newMarker = createMarker[(TownMarkers select _i),position (TownFlags select _i)];
	_newMarker setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
	_newMarker setMarkerType "mil_flag";
	_newMarker setMarkerColor "colorKhaki";
	
	(TownFlags select _i) setVectorDir [0,0,0];
	
	// Add TownSizesSqr
	TownSizesSqr = TownSizesSqr + [(TownSizes select _i) * (TownSizes select _i)];
	
	// Create the turret holder
	_flagPos = position (TownFlags select _i);
	_tHolder = "Land_InfoStand_V2_F" createVehicle _flagPos;
	_tHolder hideObject true;
	
	// Add static turrets
	_turrets = nearestObjects[_flagPos,["StaticWeapon"],TownSizes select _i];
	
	{
		_x allowDamage false;
		_dir = getDir _x;
		_x attachTo [_tHolder];
		_x setDir _dir;
		_x addEventHandler ["GetIn",format["[_this select 0,_this select 2,%1] spawn FNC_ManEnteredTurret",_i]];
	} forEach _turrets;
	
	_emptyUnits = [];
	for "_j" from 0 to (count _turrets - 1) do {
		_emptyUnits = _emptyUnits + [objNull];
	};
	
	TownTHolders set[_i,_tHolder];
	TownTurrets set[_i,_turrets];
	TownUnits set[_i,_emptyUnits];
	_newMarker setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
};



/*



	if (typeOf (TownFlags select _i) == "Flag_Blue_F") then {
		_newMarker setMarkerColor "colorBlUFOR";
	} else { if (typeOf (TownFlags select _i) == "Flag_Red_F") then {
		_newMarker setMarkerColor "colorOPFOR";
	} else {
		_newMarker setMarkerColor "colorIndependent";
	}; };
	
	
	*/
