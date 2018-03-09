disableSerialization;

_heliNames = BLUFOR_HELI_NAMES;
_heliPrices = BLUFOR_HELI_PRICES;
_armaNames = BLUFOR_ARMA_NAMES;
_armaPrices = BLUFOR_ARMA_PRICES;
if (side player == east) then {
	_heliNames = OPFOR_HELI_NAMES;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaNames = OPFOR_ARMA_NAMES;
	_armaPrices = OPFOR_ARMA_PRICES;
};

_spawnButton = (findDisplay 8366) displayCtrl 1600;

_heliList = (findDisplay 8366) displayCtrl 1200;
_armaList = (findDisplay 8366) displayCtrl 1300;
_heliIndex = lbCurSel _heliList;
_chosenHeli = _heliList lbText _heliIndex;

if (_chosenHeli != "") then {
	_totalPrice = _heliPrices select _heliIndex;

	// Introduce all of the armaments
	_specificArmaNames = _armaNames select _heliIndex;
	_specificArmaPrices = _armaPrices select _heliIndex;
	
	lbClear _armaList;
	for "_i" from 0 to (count _specificArmaNames - 1) do {
		_currentIndex = _armaList lbAdd format["%1 ($%2)",_specificArmaNames select _i,_specificArmaPrices select _i];
	};
	if (!(uiNameSpace getVariable "hasSetSelection")) then {
		_armaList lbSetCurSel (uiNameSpace getVariable "aircraftSelection");
		uiNameSpace setVariable ["hasSetSelection",true];
	} else {
		_armaList lbSetCurSel 0;
	};

	_spawnButton ctrlSetText format["Spawn in the %1 for $%2",_heliNames select _heliIndex,_totalPrice];
	if ((group player getVariable "Money") >= _totalPrice) then {
		_spawnButton ctrlSetTextColor [1,1,1,1];
	} else {
		_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
	};
} else {
	_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
};


