// Function Definitions:
//=========================================

FNC_PlayerKilled = compileFinal preprocessFile "Client\PlayerKilled.sqf";
FNC_PlayerRespawn = compileFinal preprocessFile "Client\PlayerRespawn.sqf";
FNC_EnemyFromServer = compileFinal preprocessFile "Client\EnemyFromServer.sqf";
FNC_DisplayHitmarker = compileFinal preprocessFile "Client\DisplayHitmarker.sqf";
FNC_ClientLoop = compileFinal preprocessFile "Client\ClientLoop.sqf";
FNC_ShowMarker = compileFinal preprocessFile "Client\ShowMarker.sqf";
FNC_HideMarker = compileFinal preprocessFile "Client\HideMarker.sqf";
FNC_KeyDown = compileFinal preprocessFile "Client\KeyDown.sqf";
FNC_HeliSelChanged = compileFinal preprocessFile "Client\HeliSelChanged.sqf";
FNC_ArmaSelChanged = compileFinal preprocessFile "Client\ArmaSelChanged.sqf";
FNC_SpawnButtonPressed = compileFinal preprocessFile "Client\SpawnButtonPressed.sqf";
FNC_InventoryOpened = compileFinal preprocessFile "Client\InventoryOpened.sqf";
FNC_Sortie = compileFinal preprocessFile "Client\Sortie.sqf";
FNC_DisplayHUDText = compileFinal preprocessFile "Client\DisplayHUDText.sqf";
FNC_LetTroopsOut = compileFinal preprocessFile "Client\LetTroopsOut.sqf";
FNC_DropTroops = compileFinal preprocessFile "Client\DropTroops.sqf";
FNC_InitializeVars = compileFinal preprocessFile "Server\InitializeVars.sqf";
FNC_EntityKilled = compileFinal preprocessFile "Server\EntityKilled.sqf";
FNC_RepairUpTo = compileFinal preprocessFile "Client\RepairUpTo.sqf";
FNC_KeepEngineAlive = compileFinal preprocessFile "Client\KeepEngineAlive.sqf";
FNC_HelipadService = compileFinal preprocessFile "Client\HelipadService.sqf";
FNC_SortieDelay = compileFinal preprocessFile "Client\SortieDelay.sqf";


//=========================================

[] call FNC_InitializeVars;

uiNamespace setVariable ["repairState",2];
uiNamespace setVariable ["isUnloadingTroops",false];
uiNamespace setVariable ["hasSetSelection",false];
uiNamespace setVariable ["aircraftSelection",0];
uiNamespace setVariable ["armamentSelection",0];
(group player) setVariable["Money",10000,true];

player addEventHandler ["Killed","[] call FNC_PlayerKilled"];
player addEventHandler ["Respawn","[] call FNC_PlayerRespawn"];
player addEventHandler ["InventoryOpened","[] call FNC_InventoryOpened;"];

// Do EnemyFromServer for all units to compensate for "joining late"
{
	_x call FNC_EnemyFromServer;
} forEach allUnits;

//=========================================
// Marker stuff

_groupID = groupID (group player);
_newMarkerName = format["%1_%2_marker",side player,_groupID];
_newMarker = createMarker[_newMarkerName,position player];
_newMarker setMarkerType "mil_dot";
_newMarker setMarkerText (name player);
if (side player == west) then { _newMarker setMarkerColor "colorBLUFOR"; } else { _newMarker setMarkerColor "colorOPFOR"; };



_bluforMarkers = 	[	"respawn_west"
					];
_opforMarkers = 	[	"respawn_east"
					];

(_bluforMarkers + _opforMarkers) call FNC_HideMarker;

if (side player == west) then {
	_bluforMarkers call FNC_ShowMarker;
} else {
	_opforMarkers call FNC_ShowMarker;
};

waitUntil {!isNull (findDisplay 46)};

[] call FNC_PlayerRespawn;
[] spawn FNC_ClientLoop;

//How to find the categories a classname fits into:
//
//hint format["%1",[(configFile >> "CfgVehicles" >> "B_Soldier_F"),true ] call BIS_fnc_returnParents];


//How to get the common name of a thing:
//_name = getText(configFile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
