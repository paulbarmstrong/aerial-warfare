disableSerialization;

BluforHelipads = nearestObjects[getMarkerPos "bluforMarker", ["HeliH"], 200, true];
OpforHelipads = nearestObjects[getMarkerPos "opforMarker", ["HeliH"], 200, true];

TownMarkers =	[];
TownUnits =		[];
TownTurrets =	[];
TownTHolders =	[];
TownHelipads = 	[];
TownGroups = 	[];
TownUnitCounts =[];


for "_i" from 0 to (count TownFlags - 1) do {

	// Sort out markers
	_newMarker = createMarker[format["townMarker_%1",_i], position (TownFlags select _i)];
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
	_newGroup = grpNull;
	for "_j" from 0 to (count _turrets - 1) do {
		_emptyUnits = _emptyUnits + [objNull];
	};
	
	// Find the town's primary helipad
	_townHelipad = nearestObject[_flagPos,"HeliH"];

	TownMarkers = TownMarkers + [_newMarker];
	TownTHolders = TownTHolders + [_tHolder];
	TownTurrets = TownTurrets + [_turrets];
	TownUnits = TownUnits + [_emptyUnits];
	TownHelipads = TownHelipads + [_townHelipad];
	TownGroups = TownGroups + [grpNull];
	TownUnitCounts = TownUnitCounts + [0];
	_newMarker setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
};

// Add the initial town depending on starting mode
[] spawn FNC_PutOriginalTownMen;

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


