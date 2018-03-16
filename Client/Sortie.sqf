disableSerialization;

_helipads = BluforHelipads;
_heliNames = BLUFOR_HELI_NAMES;
_heliPrices = BLUFOR_HELI_PRICES;
_slingables = BLUFOR_SLINGABLES;
_slingPrices = BLUFOR_SLINGABLE_PRICES;
if (side player == east) then {
	_helipads = OpforHelipads;
	_heliNames = OPFOR_HELI_NAMES;
	_heliPrices = OPFOR_HELI_PRICES;
	_slingables = OPFOR_SLINGABLES;
	_slingPrices = OPFOR_SLINGABLE_PRICES;
};

player setDamage 0;
removeAllActions player;
removeAllWeapons player;
{
	_xUnit = _x select 0;
	if (!isPlayer _xUnit) then {
		deleteVehicle _xUnit;
	};
} forEach (fullCrew (vehicle player));

if (str ((vehicle player) getVariable "price") != "") then {
	
	// Apply reimbursement for the aircraft
	_reimbursement = (vehicle player) getVariable "price";
	group player setVariable["Money",(group player getVariable "Money") + _reimbursement];
	_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "displayName");
	player groupChat format["Aircraft refunded | +$%1",_reimbursement,_genericHeliName];
	
	// If there is a valid sling vehicle, sell it
	_slingLoad = getSlingLoad (vehicle player);
	_slingIndex = _slingables find (typeOf _slingLoad);
	
	_slingValue = 0;
	if (BLUFOR_SLINGABLES find (typeOf _slingLoad) > -1) then {
		_slingValue = BLUFOR_SLINGABLE_PRICES select (BLUFOR_SLINGABLES find (typeOf _slingLoad));
	} else {
		if (OPFOR_SLINGABLES find (typeOf _slingLoad) > -1) then {
			_slingValue = OPFOR_SLINGABLE_PRICES select (OPFOR_SLINGABLES find (typeOf _slingLoad));
		};
	};
	
	if (_slingValue > 0) then {
		group player setVariable["Money",(group player getVariable "Money") + _slingValue];
		_genericSlingName = getText(configFile >> "CfgVehicles" >> (typeOf _slingLoad) >> "displayName");
		player groupChat format["%1 refunded | +$%2", _genericSlingName, _slingValue];
		{
			deleteVehicle (_x select 0);
		} forEach (fullCrew _slingLoad);
	};
	
	deleteVehicle _slingLoad;
};
deleteVehicle (vehicle player);

_nearestHelipad = _heliPads select 0;
{
	if (player distance2D _x < player distance2D _nearestHelipad) then {
		_nearestHelipad = _x;
	}
} forEach _helipads;

player hideObject true;
player setPos (position _nearestHelipad);
player setVelocity [0,0,0];

createDialog "Sortie_Dialog";

waitUntil {!isNull (findDisplay 8366);};

_escapeHandler = (findDisplay 8366) displayAddEventHandler ["KeyDown","(_this select 1) call FNC_KeyDown;"];
uiNamespace setVariable ["escapeHandler",_escapeHandler];

((findDisplay 8366) displayCtrl 1101) ctrlSetStructuredText (parseText "Respawn Menu");

_heliList = (findDisplay 8366) displayCtrl 1200;
_armaList = (findDisplay 8366) displayCtrl 1300;
_spawnButton = (findDisplay 8366) displayCtrl 1600;

_ownedHelis = profileNameSpace getVariable "ownedHelis";

for "_i" from 0 to (count _heliNames - 1) do {
	_currentIndex = _heliList lbAdd format["%1, ($%2)",_heliNames select _i,_heliPrices select _i];
};

_heliList lbSetCurSel (uiNameSpace getVariable "aircraftSelection");
_armaList lbSetCurSel (uiNameSpace getVariable "armaSelection");
_spawnButton ctrlSetText format["Spawn in the %1 for $0",_heliNames select 0];


