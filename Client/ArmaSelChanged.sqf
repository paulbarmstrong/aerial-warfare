disableSerialization;

_heliNames = BLUFOR_HELI_NAMES;
_heliPrices = BLUFOR_HELI_PRICES;
_armaPrices = BLUFOR_ARMA_PRICES;
if (side player == east) then {
	_heliNames = OPFOR_HELI_NAMES;
	_heliPrices = OPFOR_HELI_PRICES;
	_armaPrices = OPFOR_ARMA_PRICES;
};

_spawnButton = (findDisplay 8366) displayCtrl 1600;

_heliList = (findDisplay 8366) displayCtrl 1200;
_heliIndex = lbCurSel _heliList;
_chosenHeli = _heliList lbText _heliIndex;

_armaList = (findDisplay 8366) displayCtrl 1300;
_armaIndex = lbCurSel _armaList;
_chosenArma = _armaList lbText _armaIndex;

if (_chosenArma != "") then {

	_specificArmaPrices = _armaPrices select _heliIndex;
	_totalPrice = (_heliPrices select _heliIndex) + (_specificArmaPrices select _armaIndex);
	
	_spawnButton ctrlSetText format["Spawn in the %1 for $%2",_heliNames select _heliIndex,_totalPrice];
	if ((group player getVariable "Money") >= _totalPrice) then {
		_spawnButton ctrlSetTextColor [1,1,1,1];
	} else {
		_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
	};
} else {
	_spawnButton ctrlSetTextColor [0.5,0.5,0.5,1];
};

