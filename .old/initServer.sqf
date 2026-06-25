// Function Definitions:
//=========================================

FNC_EntityKilled = compileFinal preprocessFile "Server\EntityKilled.sqf";
FNC_AIRespawn = compileFinal preprocessFile "Server\AIRespawn.sqf";
FNC_ServerLoop = compileFinal preprocessFile "Server\ServerLoop.sqf";
FNC_TrackOnMap = compileFinal preprocessFile "Server\TrackOnMap.sqf";
FNC_InitializeVars = compileFinal preprocessFile "Server\InitializeVars.sqf";
FNC_SetUpTowns = compileFinal preprocessFile "Server\SetUpTowns.sqf";
FNC_ManEnteredTurret = compileFinal preprocessFile "Server\ManEnteredTurret.sqf";
FNC_UpdateWaypoint = compileFinal preprocessFile "Server\UpdateWaypoint.sqf";
FNC_AITroopLanding = compileFinal preprocessFile "Server\AITroopLanding.sqf";
FNC_AILandAtBase = compileFinal preprocessFile "Server\AILandAtBase.sqf";
FNC_CreateConvoy = compileFinal preprocessFile "Server\CreateConvoy.sqf";
FNC_UpdateConvoyWaypoint = compileFinal preprocessFile "Server\UpdateConvoyWaypoint.sqf";
FNC_DelayedWheelRepair = compileFinal preprocessFile "Server\DelayedWheelRepair.sqf";
FNC_KeepEngineAlive = compileFinal preprocessFile "Server\KeepEngineAlive.sqf";
FNC_AddAssistMember = compileFinal preprocessFile "Server\AddAssistMember.sqf";
FNC_RemoveAfterMinute = compileFinal preprocessFile "Server\RemoveAfterMinute.sqf";
FNC_GetOutPunish = compileFinal preprocessFile "Server\GetOutPunish.sqf";
FNC_UpdateIncomes = compileFinal preprocessFile "Server\UpdateIncomes.sqf";
FNC_VehicleKilled = compileFinal preprocessFile "Server\VehicleKilled.sqf";
FNC_TrackExplosive = compileFinal preprocessFile "Server\TrackExplosive.sqf";
FNC_SpawnPlayerAircraft = compileFinal preprocessFile "Server\SpawnPlayerAircraft.sqf";
FNC_ChangeMoney = compileFinal preprocessFile "Server\ChangeMoney.sqf";
FNC_LetTroopsOut = compileFinal preprocessFile "Server\LetTroopsOut.sqf";
FNC_DropTroops = compileFinal preprocessFile "Server\DropTroops.sqf";
FNC_DistributeHitmarkers = compileFinal preprocessFile "Server\DistributeHitmarkers.sqf";
FNC_DeathMessage = compileFinal preprocessFile "Server\DeathMessage.sqf";
FNC_PutOriginalTownMen = compileFinal preprocessFile "Server\PutOriginalTownMen.sqf";

FNC_PlayerAndCrewLocal = compileFinal preprocessFile "Client\PlayerAndCrewLocal.sqf";


//=========================================
// Disable saving:

enableSaving [false, false];


//=========================================
// Initialize global variables and towns:

[] call FNC_InitializeVars;
[] call FNC_SetUpTowns;

// Initialize playable AI stuff
//=========================================

{	
	// Create markers for all playable units
	_side = side _x;
	_groupID = groupID (group _x);
	_newMarkerName = format["%1_%2_marker", _side, _groupID];
	_newMarker = createMarker[_newMarkerName, position _x];
	_newMarker setMarkerType "mil_dot";
	if (isPlayer _x) then {
		_newMarker setMarkerText (name player);
	} else {
		_newMarker setMarkerText _groupID;
	};
	if (_side == west) then { _newMarker setMarkerColor "colorBLUFOR"; } else { _newMarker setMarkerColor "colorOPFOR"; };
	
	// Add EventHandlers for AI respawn
	_x addEventHandler ["Respawn","(_this select 0) spawn FNC_AIRespawn;"];
	_x addEventHandler ["Killed","_this spawn FNC_EntityKilled; _this spawn FNC_DeathMessage;"];
	if (USE_HITMARKERS) then {
		_x addEventHandler ["Hit", FNC_DistributeHitmarkers];
	};
	(group _x) setVariable["Money", "StartingMoney" call BIS_fnc_getParamValue, true];
//	if (name _x == "PULL") then {
//		(group _x) setVariable["Money", 200000, true];
//	};
	
	// Make flag to prevent duplicate AIRespawns
	(group _x) setVariable ["warfare_need_spawn", true];
		
	// Make the LastPosition to deal with ai getting stuck
	_x setVariable ["LastPosition", position _x];
	
} forEach playableUnits;


// Initialize income/economy stuff
//=========================================

BluforIncome = MINIMUM_INCOME;
OpforIncome = MINIMUM_INCOME;
publicVariable "BluforIncome";
publicVariable "OpforIncome";

// Passive Vehicle Convoys
//=========================================

Blufor_Convoy_Groups = [];
Opfor_Convoy_Groups = [];

for "_i" from 0 to (("NumConvoys" call BIS_fnc_getParamValue) - 1) do {
	Blufor_Convoy_Groups = Blufor_Convoy_Groups + [grpNull];
	Opfor_Convoy_Groups = Opfor_Convoy_Groups + [grpNull];
};


// Create markers for convoys
for "_i" from 0 to (count Blufor_Convoy_Groups - 1) do {
	_newMarkerName = format["blufor_convoy_marker_%1",_i];
	_newMarker = createMarker[_newMarkerName, [0,0,0]];
	_newMarker setMarkerType "mil_dot";
	_newMarker setMarkerColor "colorBLUFOR";
	_newMarker setMarkerAlpha 0;
};
for "_i" from 0 to (count Opfor_Convoy_Groups - 1) do {
	_newMarkerName = format["opfor_convoy_marker_%1",_i];
	_newMarker = createMarker[_newMarkerName, [0,0,0]];
	_newMarker setMarkerType "mil_dot";
	_newMarker setMarkerColor "colorOPFOR";
	_newMarker setMarkerAlpha 0;
};

// Run scripts
//=========================================

BluforIsSpawning = false;
OpforIsSpawning = false;

[] spawn FNC_ServerLoop;

{
	_x spawn FNC_AIRespawn;
} forEach playableUnits;


// Mission Event Handlers
//=========================================

addMissionEventHandler ["PlayerDisconnected", {
	BluforIsSpawning = false;
	OpforIsSpawning = false;
}];

// Plans
//=========================================

// Create a script to allow any airplane to perform a tailhook landing on the carrier

// There is some something causing the log to be spammed with message about destroy
// and it has something to do with playableAI behavior

// Sometimes LZ gets cleared, shows 0/4, white, no men there, but cannot be captured


