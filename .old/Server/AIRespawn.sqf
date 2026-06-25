disableSerialization;

_man = _this;
_group = group _this;
_side = side _group;
_needSpawn = _group getVariable "warfare_need_spawn";

// Exit if called on anything but an AI-controlled playable unit
if ((!isServer) || {isPlayer _man} || {owner _man != 2} || {playableUnits find _man < 0} || {isNil "_needSpawn"} || {!_needSpawn}) exitWith {
};
_group setVariable ["warfare_need_spawn", false];


_unitSpawnPos = bluforSpawnPos;
_helipads = BluforHelipads;
_jetSpot = bluforJetSpot;
_defaultRifleman = BLUFOR_DEFAULT_RIFLEMAN;
_heliPrices = BLUFOR_HELI_PRICES;
_armaPrices = BLUFOR_ARMA_PRICES;
_armaClassnames = BLUFOR_ARMA_CLASSNAMES;
_armaManualFire = BLUFOR_ARMA_MANUALFIRE;
_armaPylonIsGunner = BLUFOR_ARMA_ISGUNNER;
_armaPylons = BLUFOR_ARMA_PYLONS;
if (_side == east) then {
	_unitSpawnPos = opforSpawnPos;
	_helipads = OpforHelipads;
	_jetSpot = opforJetSpot;
	_defaultRifleman = OPFOR_DEFAULT_RIFLEMAN;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaPrices = OPFOR_ARMA_PRICES;
	_armaClassnames = OPFOR_ARMA_CLASSNAMES;
	_armaManualFire = OPFOR_ARMA_MANUALFIRE;
	_armaPylonIsGunner = OPFOR_ARMA_ISGUNNER;
	_armaPylons = OPFOR_ARMA_PYLONS;
};

_man allowDamage false;
_man hideObject false;
removeAllActions _man;
_man setPosASL (getPosASL (_unitSpawnPos));

// Determine which vehicle ai should buy
_heliIndex = 0;
_armaIndex = 0;
_bestPrice = 0;
for "_i" from 0 to (count _heliPrices - 1) do {
	for "_j" from 0 to (count (_armaPrices select _i) - 1) do {
		_tempClassname = _armaClassnames select _i select _j;
		_tempPrice = (_heliPrices select _i) + (_armaPrices select _i select _j);
		
		// If the heli is valid and the price of the heli is good, use it
		if (!(_tempClassname isKindOf "Plane") && {AI_HELI_BLACKLIST find _tempClassname == -1}
				&& {_tempPrice > _bestPrice}
				&& {_tempPrice <= (((group _man) getVariable "Money") * 0.75)}) then {
			
			_heliIndex = _i;
			_armaIndex = _j;
			_bestPrice = _tempPrice;
		};
	};
};

// Use boolean flag so that helis don't spawn at the same exact time
if (_side == west) then {
	while {BluforIsSpawning} do { sleep 0.5; };
	BluforIsSpawning = true;
} else {
	while {OpforIsSpawning} do { sleep 0.5; };
	OpforIsSpawning = true;
};


// Calculate total price
_specificArmaPrices = _armaPrices select _heliIndex;
_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex);

// Subtract the money
[_man, -_totalPrice] remoteExec ["FNC_ChangeMoney", 2, false];

_group setVariable ["lettingOutTroops", false];
_group setVariable ["landingAtBase", false];

// Fetch classname based on armaments
_heliClassname = (_armaClassnames select _heliIndex) select _armaIndex;

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


// Special spawn location for airplane
_special = "FLY";
_startHeight = 12;
if (_heliClassname isKindOf "Plane") then {
	_spawnSpot = _jetSpot;
	_special = "NONE";
	_startHeight = 0;
};

// Create the vehicle
_heli = createVehicle [_heliClassname, (getPosASL _spawnSpot) vectorAdd [0, 0, _startHeight], [], 0, _special];
_heli allowDamage false;
_heli setVariable ["price", _totalPrice];


// Set position, rotation explicitly
_heli setPosASL ((getPosASL _spawnSpot) vectorAdd [0, 0, _startHeight]);
_heli setDir (direction _spawnSpot);

// Replace heli texture if applicable
for "_i" from 0 to (count TEX_REPLACE_CLASSNAMES - 1) do {
	if ((TEX_REPLACE_CLASSNAMES select _i == _heliClassname) && {TEX_REPLACE_SIDES select _i == _side}) then {
	
		//_heli setObjectTextureGlobal [TEX_REPLACE_INDICES select _i, TEX_REPLACE_TEXTURES select _i];
		[_heli, [TEX_REPLACE_INDICES select _i, TEX_REPLACE_TEXTURES select _i]] remoteExec ["setObjectTexture", 0, true];

	};
};

// Create the crew (copilot, gunners...) and remove the pilot
createVehicleCrew _heli;
{
	if ((assignedVehicleRole _x) select 0 == "Driver") then {
		deleteVehicle _x;
	} else {
		_x allowDamage false;
	};
} forEach (crew _heli);


// Move man in, lock them in, and make them visible
_man assignAsDriver _heli;
_man moveInDriver _heli;

// Heli lock and lock-related heli eventhandlers
_heli lock true;
_heli setVehicleLock "LOCKED";
_heli addEventHandler ["Hit", "(vehicle (_this select 0)) call FNC_KeepEngineAlive;"];
_heli addEventHandler ["GetOut", "_this spawn FNC_GetOutPunish"];

// Create the men in cargo (troops to capture bases, set up mortar...)
_cargoCrewCount = ([_heliClassname,true] call BIS_fnc_crewCount) - ([_heliClassname,false] call BIS_fnc_crewCount);

for "_i" from 0 to (_cargoCrewCount - 1) do {
	_troop = _group createUnit[_defaultRifleman, position _spawnSpot, [], 0, "NONE"];
	_troop assignAsCargo _heli;
	_troop moveInCargo _heli;
	_troop setVariable ["SoldierType", "capture"];
	
	if (vehicle _troop != _heli) then {
		deleteVehicle _troop; 
	};
};

// Take care of EventHandlers
{
	if (_x != _man) then {
		_x addEventHandler ["Killed", "_this call FNC_EntityKilled"];
		if (USE_HITMARKERS) then {
			_x addEventHandler ["Hit", FNC_DistributeHitmarkers];
		};
		_x setVariable ["warfare_owner", group _man];
		[_x] joinSilent _group;
	};
	_x setVariable ["death_has_been_handled", false];
} forEach (crew _heli);
_heli addEventHandler ["Hit","_this call FNC_AddAssistMember"];
_heli setVariable ["listOfAssists", []];
_heli addEventHandler ["Killed", "_this call FNC_VehicleKilled"];
_heli addEventHandler ["Fired", {
	_weapon = _this select 1;
	if (_weapon isKindOf ['LauncherCore', configFile >> 'CfgWeapons']
			|| {_weapon isKindOf ['CannonCore', configFile >> 'CfgWeapons']}) then {
		_this spawn FNC_TrackExplosive;
	};
}];
if (USE_HITMARKERS) then {
	_heli addEventHandler ["Hit", FNC_DistributeHitmarkers];
};

_heli setVariable ["death_has_been_handled", false];
_heli allowCrewInImmobile true;

// Announce to the server
_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf _heli) >> "displayName");


[player, format["%1[%2] spawned",name _man,_genericHeliName]] remoteExec ["globalChat", 0, false];

// Sleep to allow things to settle, then make finishing adjustments
sleep 1;
_heli allowDamage true;

_group setVariable ["landingAtBase", false];
_group setVariable ["lettingOutTroops", false];
_group setVariable ["warfare_need_spawn", true];
_group spawn FNC_UpdateWaypoint;

if (_side == west) then {
	BluforIsSpawning = false;
} else {
	OpforIsSpawning = false;
};
_man setVariable ["warfare_respawn_lock", false];

/*

_ragdoll = (findDisplay 46) displayAddEventHandler ["KeyUp", {
	if (_this select 1 == 0x22) then {
		private "_tripObj";
		_tripObj = "Land_CanV3_F" createVehicleLocal [0,0,0];
		_tripObj setMass 300000;
		_tripObj attachTo [player, [0,0,0], "Spine3"];
		_tripObj setVelocity [0,0,-20];
		player allowDamage false;
		_fnc = _tripObj spawn {
			deleteVehicle _this;
			sleep 30;
			player allowDamage true;
		};
	};
]; */

