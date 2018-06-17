// Function Definitions:
//=========================================

FNC_PlayerRespawn = compileFinal preprocessFile "Client\PlayerRespawn.sqf";
FNC_DisplayHitmarker = compileFinal preprocessFile "Client\DisplayHitmarker.sqf";
FNC_ClientLoop = compileFinal preprocessFile "Client\ClientLoop.sqf";
FNC_ShowMarker = compileFinal preprocessFile "Client\ShowMarker.sqf";
FNC_HideMarker = compileFinal preprocessFile "Client\HideMarker.sqf";
FNC_KeyDown = compileFinal preprocessFile "Client\KeyDown.sqf";
FNC_HeliSelChanged = compileFinal preprocessFile "Client\HeliSelChanged.sqf";
FNC_ArmaSelChanged = compileFinal preprocessFile "Client\ArmaSelChanged.sqf";
FNC_SlingSelChanged = compileFinal preprocessFile "Client\SlingSelChanged.sqf";
FNC_SpawnButtonPressed = compileFinal preprocessFile "Client\SpawnButtonPressed.sqf";
FNC_InventoryOpened = compileFinal preprocessFile "Client\InventoryOpened.sqf";
FNC_Sortie = compileFinal preprocessFile "Client\Sortie.sqf";
FNC_DisplayHUDText = compileFinal preprocessFile "Client\DisplayHUDText.sqf";
FNC_RepairUpTo = compileFinal preprocessFile "Client\RepairUpTo.sqf";
FNC_HelipadService = compileFinal preprocessFile "Client\HelipadService.sqf";
FNC_SortieDelay = compileFinal preprocessFile "Client\SortieDelay.sqf";
FNC_GunnerLook = compileFinal preprocessFile "Client\GunnerLook.sqf";
FNC_UpdateSlingWaypoint = compileFinal preprocessFile "Client\UpdateSlingWaypoint.sqf";
FNC_SlingRopeAttach = compileFinal preprocessFile "Client\SlingRopeAttach.sqf";
FNC_DoneUnloadingTroops = {uiNameSpace setVariable ["isUnloadingTroops", false];};
FNC_PlayerAndCrewLocal = compileFinal preprocessFile "Client\PlayerAndCrewLocal.sqf";

FNC_LetTroopsOut = compileFinal preprocessFile "Server\LetTroopsOut.sqf";
FNC_DropTroops = compileFinal preprocessFile "Server\DropTroops.sqf";
FNC_KeepEngineAlive = compileFinal preprocessFile "Server\KeepEngineAlive.sqf";
FNC_DelayedWheelRepair = compileFinal preprocessFile "Server\DelayedWheelRepair.sqf";
FNC_InitializeVars = compileFinal preprocessFile "Server\InitializeVars.sqf";
FNC_EntityKilled = compileFinal preprocessFile "Server\EntityKilled.sqf";
FNC_AIRespawn = compileFinal preprocessFile "Server\AIRespawn.sqf";
FNC_SpawnPlayerAircraft = compileFinal preprocessFile "Server\SpawnPlayerAircraft.sqf";
FNC_ChangeMoney = compileFinal preprocessFile "Server\ChangeMoney.sqf";


//=========================================
// Disable saving:

enableSaving [false, false];


//=========================================
// Initialize variables

[] call FNC_InitializeVars;

uiNamespace setVariable ["repairState",2];
uiNamespace setVariable ["isUnloadingTroops",false];
uiNamespace setVariable ["hasSetSelection",false];
uiNameSpace setVariable ["trying_to_spawn", false];
uiNamespace setVariable ["aircraftSelection",0];
uiNamespace setVariable ["armamentSelection",0];

player addEventHandler ["Respawn","[] call FNC_PlayerRespawn"];
player addEventHandler ["InventoryOpened","[] call FNC_InventoryOpened;"];

//=========================================
// Marker stuff


waitUntil {!isNull (findDisplay 46)};

[] call FNC_PlayerRespawn;
[] spawn FNC_ClientLoop;

//How to find the categories a classname fits into:
//
//hint format["%1", [(configFile >> "CfgVehicles" >> "O_static_AA_F"), true] call BIS_fnc_returnParents];
//hint format["%1", [(configFile >> "CfgWeapons" >> "launch_O_Titan_F"), true] call BIS_fnc_returnParents];


//How to get the common name of a thing:
//_name = getText(configFile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
