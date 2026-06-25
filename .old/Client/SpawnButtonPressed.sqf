disableSerialization;

if (uiNameSpace getVariable "trying_to_spawn" || {!alive player}) exitWith {};
uiNameSpace setVariable ["trying_to_spawn", true];

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
		[player, -_totalPrice] remoteExec ["FNC_ChangeMoney", 2, false];
		(findDisplay 8366) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "escapeHandler"];
		closeDialog 0;		

		// Call on the server to spawn the aircraft
		[player, _heliIndex, _armaIndex, _slingIndex] remoteExec ["FNC_SpawnPlayerAircraft", 2, false];

		player hideObject false;
		uiNamespace setVariable ["aircraftSelection",_heliIndex];
		uiNamespace setVariable ["armamentSelection",_armaIndex];
		uiNamespace setVariable ["hasSetSelection",false];
		
		_heliClassname = (_armaClassnames select _heliIndex) select _armaIndex;
		
		if (_heliClassname isKindOf "Plane") then {
			sleep 10;
		} else {
			sleep 5;
		};
		uiNamespace setVariable ["repairState",0];
		
	} else {
		hint "You do not have enough money to purchase this combination!";
	};
} else {
	hint "Invalid Combination";
};

uiNameSpace setVariable ["trying_to_spawn", false];



	//	hint format["%1",[(configFile >> "CfgVehicles" >> "B_HMG_01_high_F"),true ] call BIS_fnc_returnParents];
	//	copyToClipboard format["%1",_heli getCompatiblePylonMagazines 1];
	