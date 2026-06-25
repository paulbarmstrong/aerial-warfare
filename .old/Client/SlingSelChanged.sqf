disableSerialization;

_heliNames = BLUFOR_HELI_NAMES;
_heliPrices = BLUFOR_HELI_PRICES;
_armaPrices = BLUFOR_ARMA_PRICES;
_slingables = BLUFOR_SLINGABLES;
_slingPrices = BLUFOR_SLINGABLE_PRICES;
_slingNums = BLUFOR_SLING_NUMS;
if (side player == east) then {
	_heliNames = OPFOR_HELI_NAMES;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaPrices = OPFOR_ARMA_PRICES;
	_slingables = OPFOR_SLINGABLES;
	_slingPrices = OPFOR_SLINGABLE_PRICES;
	_slingNums = OPFOR_SLING_NUMS;
};


_spawnButton = (findDisplay 8366) displayCtrl 1600;

_heliList = (findDisplay 8366) displayCtrl 1200;
_heliIndex = lbCurSel _heliList;

_armaList = (findDisplay 8366) displayCtrl 1300;
_armaIndex = lbCurSel _armaList;

_slingList = (findDisplay 8366) displayCtrl 1400;
_slingNum = (_slingNums select _heliIndex) select _armaIndex;
_slingIndex = lbCurSel _slingList;
_chosenSling = _slingList lbText _armaIndex;

if (_slingIndex > -1) then {
	
	// Calculate the total price
	_slingIndex = lbCurSel _slingList;
	_specificArmaPrices = _armaPrices select _heliIndex;
	_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex) + (_slingPrices select _slingIndex);
	
	_spawnButton ctrlSetText format["Spawn in the %1 for $%2",_heliNames select _heliIndex,_totalPrice];
	if ((group player getVariable "Money") >= _totalPrice) then {
		_spawnButton ctrlSetTextColor [1,1,1,1];
	} else {
		_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
	};
} else {
	_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
};


