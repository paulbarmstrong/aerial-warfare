// Function Definitions:
//=========================================

FNC_EntityKilled = compileFinal preprocessFile "Server\EntityKilled.sqf";
FNC_AIRespawn = compileFinal preprocessFile "Server\AIRespawn.sqf";
FNC_ServerLoop = compileFinal preprocessFile "Server\ServerLoop.sqf";
FNC_PayIncome = compileFinal preprocessFile "Server\PayIncome.sqf";
FNC_CalculateIncome = compileFinal preprocessFile "Server\CalculateIncome.sqf";
FNC_TrackOnMap = compileFinal preprocessFile "Server\TrackOnMap.sqf";
FNC_InitializeVars = compileFinal preprocessFile "Server\InitializeVars.sqf";
FNC_SetUpTowns = compileFinal preprocessFile "Server\SetUpTowns.sqf";
FNC_DetectTownLoss = compileFinal preprocessFile "Server\DetectTownLoss.sqf";
FNC_ManEnteredTurret = compileFinal preprocessFile "Server\ManEnteredTurret.sqf";
FNC_UpdateWaypoint = compileFinal preprocessFile "Server\UpdateWaypoint.sqf";
FNC_AITroopLanding = compileFinal preprocessFile "Server\AITroopLanding.sqf";
FNC_AILandAtBase = compileFinal preprocessFile "Server\AILandAtBase.sqf";
FNC_CreatePassiveVehicle = compileFinal preprocessFile "Server\CreatePassiveVehicle.sqf";
FNC_UpdateVehicleWaypoint = compileFinal preprocessFile "Server\UpdateVehicleWaypoint.sqf";



// Quickly Initialize some global variables:
[] call FNC_InitializeVars;

// Initialize town stuff
//=========================================

[] call FNC_SetUpTowns;

// Initialize playable AI stuff
//=========================================

{	
	// Create markers for all playable units
	_side = side _x;
	_groupID = groupID (group _x);
	_newMarkerName = format["%1_%2_marker",_side,_groupID];
	_newMarker = createMarker[_newMarkerName,position _x];
	_newMarker setMarkerType "mil_dot";
	if (isPlayer _x) then {
		_newMarker setMarkerText (name player);
	} else {
		_newMarker setMarkerText _groupID;
	};
	if (_side == west) then { _newMarker setMarkerColor "colorBLUFOR"; } else { _newMarker setMarkerColor "colorOPFOR"; };
	//_newMarker setMarkerColor "colorUNKNOWN";
	
	// Add EventHandlers for AI respawn
	if (!(isPlayer _x)) then {
		_x addEventHandler ["Respawn","(_this select 0) spawn FNC_AIRespawn"];
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		[_x,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
	};
} forEach playableUnits;


// Initialize income/economy stuff
//=========================================

BluforIncome = 0;
OpforIncome = 0;

// Passive Vehicles
//=========================================

Blufor_Passive_Groups = [];
Opfor_Passive_Groups = [];


// Run scripts
//=========================================

[] spawn FNC_ServerLoop;
[] spawn FNC_PayIncome;

{
	if (!(isPlayer _x)) then
	{
		_x spawn FNC_AIRespawn;
	};
} forEach playableUnits;



// Plans
//=========================================

// Create system for AI vehicles to spawn and go to towns




