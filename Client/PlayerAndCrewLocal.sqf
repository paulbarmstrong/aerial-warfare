disableSerialization;

_jetSpot = _this select 0;
_heliClassname = _this select 1;
_totalPrice = _this select 2;
_slingPrices = _this select 3;
_slingIndex = _this select 4;
_armaIndex = _this select 5;
_defaultRifleman = _this select 6;
_spawnSpot = _this select 7;
_armaPylons = _this select 8;
_heliIndex = _this select 9;
_armaPylonIsGunner = _this select 10;

// Special spawn location for airplane
_special = "FLY";
_delayBeforeService = 5;
_startHeight = 12;
if (_heliClassname isKindOf "Plane") then {
	_spawnSpot = _jetSpot;
	_special = "NONE";
	_delayBeforeService = 10;
	_startHeight = 0;
};

// Create the aircraft
_heli = createVehicle [_heliClassname, (getPosASL _spawnSpot) vectorAdd [0, 0, _startHeight], [], 0, _special];
_heli setVariable ["price", _totalPrice - (_slingPrices select _slingIndex)];
[_heli, ["price", _totalPrice - (_slingPrices select _slingIndex)]] remoteExec ["setVariable", 2, false];

// Set position/rotation explicitly
_heli setPosASL ((getPosASL _spawnSpot) vectorAdd [0, 0, _startHeight]);
_heli setDir (direction _spawnSpot);
	
// Do some arma wizardry to get an array of the heli's available pylons
_helisPylons = "true" configClasses (configFile >> "CfgVehicles" >> _heliClassname >> "Components" >> "TransportPylonsComponent" >> "pylons") apply {configName _x};

_newAttachments = (_armaPylons select _heliIndex) select _armaIndex;

// Get rid of all weapons currently on the pylons
{
	_weaponName = getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon");
	_heli removeWeaponGlobal _weaponName;
} forEach getPylonMagazines _heli;

// Replace all of the pylons with the armament's new attachments
for "_pylonIndex" from 0 to (count _helisPylons - 1) do {
	if (_pylonIndex < (count _newAttachments)) then {
		if (_armaPylonIsGunner select _heliIndex select _armaIndex select _pylonIndex) then {
			_heli setPylonLoadout [_helisPylons select _pylonIndex,_newAttachments select _pylonIndex, true,[0]];
		} else {
			_heli setPylonLoadout [_helisPylons select _pylonIndex,_newAttachments select _pylonIndex, true,[]];
		};
	} else {
		_heli setPylonLoadout [_helisPylons select _pylonIndex,""];
	};
};

// Print available pylons for debug
//copyToClipboard str ((_heli getCompatiblePylonMagazines 0) select 0);

// Replace heli texture if applicable
for "_i" from 0 to (count TEX_REPLACE_CLASSNAMES - 1) do {
	if ((TEX_REPLACE_CLASSNAMES select _i == _heliClassname) && {TEX_REPLACE_SIDES select _i == side group player}) then {

		[_heli, [TEX_REPLACE_INDICES select _i, TEX_REPLACE_TEXTURES select _i]] remoteExec ["setObjectTexture", 0, true];
		
	};
};


// Move player in, lock them in, and make them visible
player moveInDriver _heli;
_heli lock true;
player hideObject false;
player allowDamage false;

// Create the crew (copilot, gunners...)
_heliGroup = createGroup [side group player, true];
createVehicleCrew _heli;

{
	if (!isPlayer _x) then {
		[_x] joinSilent _heliGroup;
		_x allowDamage false;
	};
} forEach (crew _heli);

// Create the men in cargo (troops to capture bases)
_cargoCrewCount = ([_heliClassname,true] call BIS_fnc_crewCount) - ([_heliClassname,false] call BIS_fnc_crewCount);

for "_i" from 0 to (_cargoCrewCount - 1) do {
	_troop = _heliGroup createUnit[_defaultRifleman, position player, [], 0, "NONE"];
	_troop assignAsCargo _heli;
	_troop moveInCargo _heli;
	_troop setVariable ["SoldierType", "capture"];
	[_troop, ["SoldierType", "capture"]] remoteExec ["setVariable", 2, false];
	
	if (vehicle _troop != _heli) then {
		deleteVehicle _troop; 
	};
};

/*
// Add the tailhook action if applicable
if (_heliClassname isKindOf "Plane") then {
	player addAction ["Lower tailhook", ];
}; */

// When done, remoteExec setVariable to let the server know
[player, ["pull_the_heli", _heli]] remoteExec ["setVariable", 2, false];
[player, ["pull_heli_group", _heliGroup]] remoteExec ["setVariable", 2, false];

