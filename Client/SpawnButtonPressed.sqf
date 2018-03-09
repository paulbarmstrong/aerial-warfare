disableSerialization;

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
if (side player == east) then {
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
};

_heliList = (findDisplay 8366) displayCtrl 1200;
_heliIndex = lbCurSel _heliList;

_armaList = (findDisplay 8366) displayCtrl 1300;
_armaIndex = lbCurSel _armaList;

_slingList = (findDisplay 8366) displayCtrl 1400;
_slingIndex = lbCurSel _slingList;


if (_heliIndex > -1 && _armaIndex > -1 && _slingIndex > -1) then {

	_specificArmaPrices = _armaPrices select _heliIndex;
	_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex) + (_slingPrices select _slingIndex);
	
	if ((group player getVariable "Money") >= _totalPrice) then {

		// Subtract the money and close the menu
		group player setVariable["Money",(group player getVariable "Money") - _totalPrice];
		(findDisplay 8366) displayRemoveEventHandler ["KeyDown",uiNamespace getVariable "escapeHandler"];
		closeDialog 0;
		
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
		_delayBeforeService = 5;
		if (_heliClassname isKindOf "Plane") then {
			_spawnSpot = _jetSpot;
			_special = "NONE";
			_delayBeforeService = 10;
		};
		
		// Create the aircraft
		_heli = createVehicle [_heliClassname, position player, [], 0, _special];
		_heli setVariable ["price",_totalPrice - (_slingPrices select _slingIndex)];
			
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
					_heli setPylonLoadout [_helisPylons select _pylonIndex,_newAttachments select _pylonIndex,true,[0]];
				} else {
					_heli setPylonLoadout [_helisPylons select _pylonIndex,_newAttachments select _pylonIndex,true,[]];
				};
			} else {
				_heli setPylonLoadout [_helisPylons select _pylonIndex,""];
			};
		};
		
		// Set position/rotation explicitly
		_heli setPos (position _spawnSpot);
		_heli setDir (direction _spawnSpot);
		_heli action ["LandGear", _heli];
		
		// Create the crew (copilot, gunners...) and remove the pilot
		_heliGroup = createGroup [side group player,true];
		createVehicleCrew _heli;
		{
			if ((assignedVehicleRole _x) select 0 == "Driver") then {
				deleteVehicle _x;
			} else {
				_x allowDamage false;
			};
		} forEach (crew _heli);
		
		// Move player in, lock them in, and make them visible
		player moveInDriver _heli;
		_heli lock true;
		player hideObject false;
		player allowDamage false;
		_heli addEventHandler ["Killed","{_x setDamage 1} forEach crew vehicle player; player setDamage 1;"];
		_heli addEventHandler ["Hit","(vehicle player) call FNC_KeepEngineAlive;"];


		// Create the men in cargo (troops to capture bases, set up mortar...)
		_cargoCrewCount = ([_heliClassname,true] call BIS_fnc_crewCount) - ([_heliClassname,false] call BIS_fnc_crewCount);
		
		for "_i" from 0 to (_cargoCrewCount - 1) do {
			_troop = _heliGroup createUnit[_defaultRifleman, position player, [], 0, "NONE"];
			_troop assignAsCargo _heli;
			_troop moveInCargo _heli;
			_troop setVariable ["SoldierType","capture"];
		};

		// Take care of EventHandlers
		{
			_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
			[_x,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
			if (!isPlayer _x) then {
				_x setVariable ["owner",player];
				[_x] joinSilent _heliGroup;
			};
		} forEach (crew _heli);
		_heli addEventHandler ["Killed","_this call FNC_EntityKilled"];
		[_heli,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
		
		_heliGroup setBehaviour "CARELESS";
		
		// Activate manual fire if supposed to
		if (_armaManualFire select _heliIndex select _armaIndex) then {
			_heli action ["ManualFire",_heli];
		};
		
	//	hint format["%1",[(configFile >> "CfgVehicles" >> "B_HMG_01_high_F"),true ] call BIS_fnc_returnParents];
	//	copyToClipboard format["%1",_heli getCompatiblePylonMagazines 1];
	
		if (_slingIndex > 0) then {
		
			// Elevate the heli
			_heli setPos ((position _spawnSpot) vectorAdd [0,0,10]);
		
			// Create the sling load
			_vehGroup = createGroup [side group player , true];
			_vehClassname = _slingables select _slingIndex;
			_vehArgs = [position _spawnSpot, direction _spawnSpot, _vehClassname, _vehGroup] call BIS_fnc_spawnVehicle;
			_veh = _vehArgs select 0;
			_fullCrew = units _vehGroup;

			// Lock the vehicle immediately
			_veh lock true;
			_veh allowCrewInImmobile true;
			
			// Perform the sling loading
			_heli setSlingLoad _veh;
			
			// Do Event handlers
			{
				_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
				[_x,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
				_x setVariable ["owner", player];
			} forEach _fullCrew;
			_veh addEventHandler ["Killed","_this call FNC_EntityKilled"];
			[_veh,"FNC_EnemyFromServer",true,false,false] call BIS_fnc_MP;
		
		};

		
		// Announce to the server that the player has pulled the heli
		_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf _heli) >> "displayName");
		player groupChat format["Purchased %2 and armaments | -$%1",_totalPrice,_genericHeliName];
		player globalChat format["%1[%2] spawned",name player,_genericHeliName];
		
		uiNamespace setVariable ["aircraftSelection",_heliIndex];
		uiNamespace setVariable ["armamentSelection",_armaIndex];
		uiNamespace setVariable ["hasSetSelection",false];
		sleep _delayBeforeService;
		uiNamespace setVariable ["repairState",0];
	} else {
		hint "You do not have enough money to purchase this combination!";
	};
} else {
	hint "Invalid Combination";
};
