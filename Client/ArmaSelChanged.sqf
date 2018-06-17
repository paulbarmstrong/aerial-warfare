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
_chosenHeli = _heliList lbText _heliIndex;

_armaList = (findDisplay 8366) displayCtrl 1300;
_armaIndex = lbCurSel _armaList;
_chosenArma = _armaList lbText _armaIndex;

if (_chosenArma != "") then {
	
	_slingList = (findDisplay 8366) displayCtrl 1400;
	_slingNum = (_slingNums select _heliIndex) select _armaIndex;
	
	// Reset and repopulate the list
	lbClear _slingList;
	for "_i" from 0 to _slingNum do {
		_displayName = "None";
		if (!((_slingables select _i) isEqualTo "")) then {
			_displayName = getText(configFile >> "CfgVehicles" >> (_slingables select _i) >> "displayName");
		};
		_specialAAIndex = SPECIAL_AA_SLINGABLES find (_slingables select _i);
		if (_specialAAIndex > -1) then {
			_displayName = SPECIAL_AA_SLING_NAMES select _specialAAIndex;
		};
		_currentIndex = _slingList lbAdd format["%1 ($%2)", _displayName, _slingPrices select _i];
	};
	_slingList lbSetCurSel 0;
	
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


