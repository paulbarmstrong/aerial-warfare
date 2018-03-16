_man = _this;
_group = group _this;
_side = side _group;

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
removeAllActions _man;


// Determine which vehicle ai should buy
_heliIndex = 0;
_armaIndex = 0;


// Sleep random so helis don't often spawn in the exact same tick
sleep (random 3);


// Calculate total price
_specificArmaPrices = _armaPrices select _heliIndex;
_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex);

// Subtract the money
_group setVariable["Money",(group _man getVariable "Money") - _totalPrice];

_group setVariable ["lettingOutTroops", false];
_group setVariable ["landingAtBase", false];

// Fetch classname based on armaments
_heliClassname = (_armaClassnames select _heliIndex) select _armaIndex;

// Determine the best location to spawn
_spawnSpot = _helipads select 0;
_bestHeliDistance = 0;
{
	_nearestHeli = nearestObject[position _x,"Helicopter"];
	if (_nearestHeli isEqualTo objNull || {_nearestHeli distance2D _x > _bestHeliDistance}) then {
		_spawnSpot = _x;
		if (!(_nearestHeli isEqualTo objNull)) then {
			_bestHeliDistance = _nearestHeli distance2D _x;
		}
	}
} forEach _helipads;

// Special spawn location for airplane
_special = "FLY";
if (_heliClassname isKindOf "Plane") then {
	_spawnSpot = _jetSpot;
	_special = "NONE";
};

// Create the vehicle
_newVehiclePosition = position _spawnSpot findEmptyPosition[0,100,_heliClassname];
_heli = createVehicle [_heliClassname, position _man, [], 0, _special];
_heli allowDamage false;
_heli setVariable ["price",_totalPrice];


// Set position, rotation, and gear explicitly
_heli setPos (_newVehiclePosition);
_heli setDir (direction _spawnSpot);
_heli action ["LandGear", _heli];

// Replace heli texture if applicable
_texNum = TEX_REPLACE_CLASSNAMES find _heliClassname;
if (_texNum > -1) then {
	_heli setObjectTexture [TEX_REPLACE_INDICES select _texNum, TEX_REPLACE_TEXTURES select _texNum];
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
_man moveInDriver _heli;

// Heli lock and lock-related heli eventhandlers
_heli lock true;
_heli setVehicleLock "LOCKED";
_heli setVariable ["assigned_group",_group];
_heli addEventHandler ["Killed","
	{
		_x allowDamage true;
		if (vehicle _x == _x) then {
			_x setDamage 1;
		};
	} forEach units ((_this select 0) getVariable 'assigned_group');
"];
_heli addEventHandler ["Hit","(vehicle (_this select 0)) call FNC_KeepEngineAlive;"];

// Create the men in cargo (troops to capture bases, set up mortar...)
_cargoCrewCount = ([_heliClassname,true] call BIS_fnc_crewCount) - ([_heliClassname,false] call BIS_fnc_crewCount);

for "_i" from 0 to (_cargoCrewCount - 1) do {
	_troop = _group createUnit[_defaultRifleman, position _spawnSpot, [], 0, "NONE"];
	_troop assignAsCargo _heli;
	_troop moveInCargo _heli;
	_troop setVariable ["SoldierType","capture"];
};

// Take care of EventHandlers
{
	if (_x != _man) then { // 			if (!((group driver (_this select 2)) getVariable 'lettingOutTroops') || (((_this select 0) getVariable 'SoldierType') != 'capture')) then {

		_x addEventHandler ["GetOutMan","
			if (((_this select 0) getVariable 'SoldierType') != 'capture') then {
				(_this select 0) allowDamage true;
				(_this select 0) setDamage 1;
			};"
		];
		_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
		[_x,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
		_x setVariable ["owner",_man];
		[_x] joinSilent _group;
	};
} forEach (crew _heli);
_heli addEventHandler ["Hit","_this call FNC_AddAssistMember"];
_heli setVariable ["listOfAssists",[]];
_heli addEventHandler ["Killed","_this call FNC_EntityKilled"];
[_heli,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
_heli allowCrewInImmobile true;

sleep 4;

// If heli is still alive, make it damageable
if (alive _heli) then {
	_heli allowDamage true;
	_group spawn FNC_UpdateWaypoint;
};


/*

else {
	// Otherwise, delete everything and respawn again
	deleteVehicle _heli;
	{
		deleteVehicle _x;
	} forEach units _group;
	_man allowDamage true;
	_man setDamage 1;
};

*/
