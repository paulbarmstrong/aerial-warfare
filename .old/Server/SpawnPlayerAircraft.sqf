disableSerialization;

_player = _this select 0;
_heliIndex = _this select 1;
_armaIndex = _this select 2;
_slingIndex = _this select 3;
_carDisplayName = "";

_helipads = BluforHelipads;
_jetSpot = bluforJetSpot;
_defaultRifleman = BLUFOR_DEFAULT_RIFLEMAN;
_heliPrices = BLUFOR_HELI_PRICES;
_armaPrices = BLUFOR_ARMA_PRICES;
_armaClassnames = BLUFOR_ARMA_CLASSNAMES;
_armaManualFire = BLUFOR_ARMA_MANUALFIRE;
_armaPylonIsGunner = BLUFOR_ARMA_ISGUNNER;
_armaPylons = BLUFOR_ARMA_PYLONS;
_slingables = BLUFOR_SLINGABLES;
_slingPrices = BLUFOR_SLINGABLE_PRICES;
_slingNums = BLUFOR_SLING_NUMS;
_sideMarkerColor = "colorBLUFOR";
if (side _player == east) then {
	_helipads = OpforHelipads;
	_jetSpot = opforJetSpot;
	_defaultRifleman = OPFOR_DEFAULT_RIFLEMAN;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaPrices = OPFOR_ARMA_PRICES;
	_armaClassnames = OPFOR_ARMA_CLASSNAMES;
	_armaManualFire = OPFOR_ARMA_MANUALFIRE;
	_armaPylonIsGunner = OPFOR_ARMA_ISGUNNER;
	_armaPylons = OPFOR_ARMA_PYLONS;
	_slingables = OPFOR_SLINGABLES;
	_slingPrices = OPFOR_SLINGABLE_PRICES;
	_slingNums = OPFOR_SLING_NUMS;
	_sideMarkerColor = "colorOPFOR";
};


_specificArmaPrices = _armaPrices select _heliIndex;
_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex) + (_slingPrices select _slingIndex);

// Fetch classname based on armaments
_heliClassname = (_armaClassnames select _heliIndex) select _armaIndex;

// Wait for permission to spawn
if (side group _player == west) then {
	while {BluforIsSpawning} do { sleep 0.5;};
	BluforIsSpawning = true;
} else {
	while {OpforIsSpawning} do { sleep 0.5;};
	OpforIsSpawning = true;
};


// Determine the best location to spawn
_spawnSpot = _helipads select 0;
_bestHeliDistance = 0;
{
	_nearestHelis = nearestObjects[getPosASL _x, ["AllVehicles"], 100, true];
	if (count _nearestHelis == 0 || {(_nearestHelis select 0) distance2D _x > _bestHeliDistance}) then {
		_spawnSpot = _x;
		if (count _nearestHelis > 0) then {
			_bestHeliDistance = (_nearestHelis select 0) distance2D _x;
		};
	};
} forEach _helipads;

_delayBeforeService = 5;
if (_heliClassname isKindOf "Plane") then {
	_delayBeforeService = 10;
};

// Call on the client to create heli and crew
_player setVariable ["pull_the_heli", objNull];
[_jetSpot, _heliClassname, _totalPrice, _slingPrices, _slingIndex,
_armaIndex, _defaultRifleman, _spawnSpot, _armaPylons, _heliIndex, _armaPylonIsGunner]
		remoteExec ["FNC_PlayerAndCrewLocal", _player, false];

while {(_player getVariable "pull_the_heli") isEqualTo objNull} do {
	sleep 0.5;
};
_heli = _player getVariable "pull_the_heli";
_heliGroup = _player getVariable "pull_heli_group";

// Take care of EventHandlers
{
	if (!isPlayer _x) then {
		_x setVariable ["warfare_owner", group _player];
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		_x addEventHandler ["Hit", FNC_DistributeHitmarkers];
	};
	_x setVariable ["death_has_been_handled", false];
	
} forEach (crew _heli);
[_heli, ["RopeBreak", {_this spawn FNC_UpdateSlingWaypoint;}]] remoteExec ["addEventHandler", _player, false];
[_heli, ["RopeAttach", {_this spawn FNC_SlingRopeAttach;}]] remoteExec ["addEventHandler", _player, false];
_heli addEventHandler ["Killed", { _this call FNC_VehicleKilled; }];
_heli addEventHandler ["Hit", { _this call FNC_AddAssistMember; }];
_heli addEventHandler ["Fired", {
	_weapon = _this select 1;
	if (_weapon isKindOf ['LauncherCore', configFile >> 'CfgWeapons']
			|| {_weapon isKindOf ['CannonCore', configFile >> 'CfgWeapons']}) then {
		_this spawn FNC_TrackExplosive;
	};
}];
_heli setVariable ["listOfAssists", []];
_heli setVariable ["warfare_owner", group _player];
_heli setVariable ["death_has_been_handled", false];
_heli setVariable ["touching_ground", true];
if (USE_HITMARKERS) then {
	_heli addEventHandler ["Hit", FNC_DistributeHitmarkers];
};
[_heliGroup, "RED"] remoteExec ["setCombatMode", _player, false];

[_heli, ["Hit", {(_this select 0) spawn FNC_KeepEngineAlive;}]] remoteExec ["addEventHandler", _player, false];
_heli addEventHandler ["GetOut","_this spawn FNC_GetOutPunish"];

// Activate manual fire if supposed to
if (_armaManualFire select _heliIndex select _armaIndex) then {
	[_heli, ["ManualFire",_heli]] remoteExec ["action", _player, false];
	[_heliGroup, "CARELESS"] remoteExec ["setBehaviour", _player, false];
};


// Add the sling load
if (_slingIndex > 0) then {

	// Sleep a little before doing sling to prevent some lag problems
	sleep 0.2;

	// Create the sling load
	_vehGroup = createGroup [side group _player , true];
	_vehClassname = _slingables select _slingIndex;
	_vehArgs = [(position _spawnSpot) vectorAdd [0,0,200], direction _spawnSpot, _vehClassname, _vehGroup] call BIS_fnc_spawnVehicle;
	_veh = _vehArgs select 0;
	//_veh setPosASL (getPosASL _spawnSpot);
	_veh setPosASL ((getPosASL _heli) vectorAdd [0, 0, -5]);
	
	// Get the display name and add the AA man in special AA slingables
	_carDisplayName = getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName");
	_specialAAIndex = SPECIAL_AA_SLINGABLES find (typeOf _veh);
	if (_specialAAIndex > -1) then {
		_carDisplayName = SPECIAL_AA_SLING_NAMES select _specialAAIndex;
		
		_turretPath = (allTurrets [_veh, false]) select 0;

		_veh removeWeaponTurret [(_veh weaponsTurret _turretPath) select 0, _turretPath];
		_veh addWeaponTurret ["missiles_titan_static", _turretPath];
		_veh addMagazineTurret ["1Rnd_GAA_missiles", _turretPath];
	};

	// Lock the vehicle immediately
	_veh lock true;
	_veh allowCrewInImmobile true;
	_vehGroup setGroupOwner (owner _player);
	
	// Perform the sling loading
	[_heli, _veh] remoteExec ["setSlingLoad", _player, false];
	
	// Do Event handlers
	{
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		if (USE_HITMARKERS) then {
			_x addEventHandler ["Hit", FNC_DistributeHitmarkers];
		};
		_x allowDamage false;
		_x setVariable ["warfare_owner", group _player];
		_x setVariable ["death_has_been_handled", false];
		//_x setSkill 0.75;

	} forEach (units _vehGroup);
	[_veh, ["Hit", {(_this select 0) spawn FNC_DelayedWheelRepair;}]] remoteExec ["addEventHandler", _player, false];
	
	_veh addEventHandler ["Fired", {
		(_this select 0) setVehicleAmmo 1;
		_weapon = _this select 1;
		if (_weapon isKindOf ['LauncherCore', configFile >> 'CfgWeapons']
				|| {_weapon isKindOf ['CannonCore', configFile >> 'CfgWeapons']}) then {
			_this spawn FNC_TrackExplosive;
		};
	}];
	_veh addEventHandler ["Killed", "_this call FNC_VehicleKilled"];
	_veh addEventHandler ["Hit", "_this call FNC_AddAssistMember"];
	_veh addEventHandler ["GetOut", "_this spawn FNC_GetOutPunish"];
	_veh addEventHandler ["Fired", {
		_weapon = _this select 1;
		if (_weapon isKindOf ['LauncherCore', configFile >> 'CfgWeapons']
				|| {_weapon isKindOf ['CannonCore', configFile >> 'CfgWeapons']}) then {
			_this spawn FNC_TrackExplosive;
		};
	}];
	_veh setVariable ["listOfAssists", []];
	_veh setVariable ["warfare_owner", group _player];
	_veh setVariable ["death_has_been_handled", false];
	if (USE_HITMARKERS) then {
		_veh addEventHandler ["Hit", FNC_DistributeHitmarkers];
	};
	
	// Create a marker for the vehicle
	_carMarker = format["sling_vehicle_marker_%1", SlingMarkerTally];
	createMarker [_carMarker, position _veh];
	_carMarker setMarkerType "mil_box";
	_carMarker setMarkerText format["%1's %2", name _player, _carDisplayName];
	_carMarker setMarkerColor _sideMarkerColor;
	_carMarker setMarkerAlpha 0;
	
	SlingVehicleArray = SlingVehicleArray + [_veh];
	SlingMarkerArray = SlingMarkerArray + [_carMarker];
	SlingMarkerTally = SlingMarkerTally + 1;
};

// Announce to the server that the _player has pulled the heli
_genericHeliName = getText (configFile >> "CfgVehicles" >> (typeOf _heli) >> "displayName");

_purchaseText = format["Purchased %2 and armaments | -$%1",_totalPrice - (_slingPrices select _slingIndex), _genericHeliName];
[_player, _purchaseText] remoteExec ["groupChat", _player, false];

if (_slingIndex > 0) then {	
	[_player, format["Purchased %2 | -$%1", (_slingPrices select _slingIndex), _carDisplayName]] remoteExec ["groupChat", _player, false];
};
[_player, format["%1[%2] spawned", name _player, _genericHeliName]] remoteExec ["globalChat", 0, false];

if (side group _player  == west) then {
	BluforIsSpawning = false;
} else {
	OpforIsSpawning = false;
};





