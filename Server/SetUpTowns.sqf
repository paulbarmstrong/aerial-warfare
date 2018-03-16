disableSerialization;

BluforHelipads = nearestObjects[getMarkerPos "respawn_west", ["HeliH"], 100];
OpforHelipads = nearestObjects[getMarkerPos "respawn_east", ["HeliH"], 100];

TownMarkers = 	["townMarker",					"townMarker_1",				"townMarker_2"];
TownFlags = 	[townFlag_0,					townFlag_1,					townFlag_2];
TownNames = 	["Agia Maria Landing Zone",		"Camp Maxwell Landing Zone","Landing Zone Connor"];
TownSizes = 	[50,							50,							50];


TownUnits =		[];
TownTurrets =	[];
TownTHolders =	[];
TownHelipads = 	[];
TownGroups = 	[];

for "_i" from 0 to (count TownMarkers - 1) do {

	// Sort out markers
	_newMarker = createMarker[(TownMarkers select _i), position (TownFlags select _i)];
	_newMarker setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
	_newMarker setMarkerType "mil_flag";
	_newMarker setMarkerColor "colorWhite";
	
	(TownFlags select _i) setVectorDir [0,0,0];
		
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
		_x addEventHandler ["Fired","(_this select 0) setVehicleAmmo 1;"];
	} forEach _turrets;
	
	// Find the town's primary helipad
	
	_townHelipad = nearestObject[_flagPos,"HeliH"];

	
	_emptyUnits = [];
	for "_j" from 0 to (count _turrets - 1) do {
		_emptyUnits = _emptyUnits + [objNull];
	};
	
	// Find the town's primary helipad
	_townHelipad = nearestObject[_flagPos,"HeliH"];

	
	TownTHolders = TownTHolders + [_tHolder];
	TownTurrets = TownTurrets + [_turrets];
	TownUnits = TownUnits + [_emptyUnits];
	TownHelipads = TownHelipads + [_townHelipad];
	TownGroups = TownGroups + [grpNull];
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
