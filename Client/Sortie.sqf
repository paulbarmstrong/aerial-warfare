disableSerialization;

_helipad = bluforHelipad;
_heliNames = BLUFOR_HELI_NAMES;
_heliPrices = BLUFOR_HELI_PRICES;

if (side player == east) then {
	_helipad = opforHelipad;
	_heliNames = OPFOR_HELI_NAMES;
	_heliPrices = OPFOR_HELI_PRICES;
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
	_reimbursement = (vehicle player) getVariable "price";
	group player setVariable["Money",(group player getVariable "Money") + _reimbursement];
	
	_genericHeliName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "displayName");
	player groupChat format["Helicopter refunded | +$%1",_reimbursement,_genericHeliName];
};
deleteVehicle (vehicle player);

player hideObject true;
player setPos (position _helipad);
player setDir (direction _helipad);
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


