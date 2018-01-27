disableSerialization;

_helipad = bluforHelipad;
_jetSpot = bluforJetSpot;
_defaultRifleman = BLUFOR_DEFAULT_RIFLEMAN;
_heliPrices = BLUFOR_HELI_PRICES;
_armaPrices = BLUFOR_ARMA_PRICES;
_armaClassnames = BLUFOR_ARMA_CLASSNAMES;
_armaManualFire = BLUFOR_ARMA_MANUALFIRE;
_armaPylonIsGunner = BLUFOR_ARMA_ISGUNNER;
_armaPylons = BLUFOR_ARMA_PYLONS;
if (side player == east) then {
	_helipad = opforHelipad;
	_jetSpot = opforJetSpot;
	_defaultRifleman = OPFOR_DEFAULT_RIFLEMAN;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaPrices = OPFOR_ARMA_PRICES;
	_armaClassnames = OPFOR_ARMA_CLASSNAMES;
	_armaManualFire = OPFOR_ARMA_MANUALFIRE;
	_armaPylonIsGunner = OPFOR_ARMA_ISGUNNER;
	_armaPylons = OPFOR_ARMA_PYLONS;
};

_heliList = (findDisplay 8366) displayCtrl 1200;
_heliIndex = lbCurSel _heliList;

_armaList = (findDisplay 8366) displayCtrl 1300;
_armaIndex = lbCurSel _armaList;

if (_heliIndex > -1 && _armaIndex > -1) then {

	_specificArmaPrices = _armaPrices select _heliIndex;
	_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex);

	if ((group player getVariable "Money") >= _totalPrice) then {

		// Subtract the money and close the menu
		group player setVariable["Money",(group player getVariable "Money") - _totalPrice];
		(findDisplay 8366) displayRemoveEventHandler ["KeyDown",uiNamespace getVariable "escapeHandler"];
		closeDialog 0;
		
		// Fetch classname based on armaments
		_heliClassname = (_armaClassnames select _heliIndex) select _armaIndex;
		
		_spawnSpot = _helipad;
		_special = "FLY";
		if (_heliClassname isKindOf "Plane") then {
			_spawnSpot = _jetSpot;
			_special = "NONE";
		};
		
		// Create the vehicle
		_heli = createVehicle [_heliClassname, position player, [], 0, _special];
		_heli setVariable ["price",_totalPrice];
			
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
		_heliGroup = createGroup [side player,true];
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
			_man = _heliGroup createUnit[_defaultRifleman, position player, [], 0, "NONE"];
			_man assignAsCargo _heli;
			_man moveInCargo _heli;
			_man setVariable ["SoldierType","capture"];
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
		
		_heliGroup setBehaviour "AWARE";
		
		// Activate manual fire if supposed to
		if (_armaManualFire select _heliIndex select _armaIndex) then {
			_heli action ["ManualFire",_heli];
		};
		
	//	hint format["%1",[(configFile >> "CfgVehicles" >> "B_HMG_01_high_F"),true ] call BIS_fnc_returnParents];
	//	copyToClipboard format["%1",_heli getCompatiblePylonMagazines 1];

		
		// Announce to the server that the player has pulled the heli
		_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf _heli) >> "displayName");
		player groupChat format["Purchased %2 and armaments | -$%1",_totalPrice,_genericHeliName];
		player globalChat format["%1[%2] spawned",name player,_genericHeliName];
		
		uiNamespace setVariable ["aircraftSelection",_heliIndex];
		uiNamespace setVariable ["armamentSelection",_armaIndex];
		uiNamespace setVariable ["hasSetSelection",false];

		// To try to avoid players crashing when both pulling at the same time
		{ _heli disableCollisionWith _x; } forEach playableUnits;
		
	/*	_count = 0;
		while {_count < 40} do {
			_heli setVelocity [0,0,0];
			_heli setPos (position _spawnSpot);
			_count = _count + 1;
			sleep 0.05;
		}; */
		sleep 5;
		{ _heli enableCollisionWith _x; } forEach playableUnits;
		uiNamespace setVariable ["repairState",0];
	} else {
		hint "You do not have enough money to purchase this combination!";
	};
} else {
	hint "Invalid Combination";
};
