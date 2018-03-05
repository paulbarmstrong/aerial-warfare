disableSerialization;

_countdown = 5;
_heli = vehicle player;

sleep 1;

while {isTouchingGround (vehicle player) && vectorMagnitude velocity vehicle player < 5 && _countdown > 0} do {

_string = format["<t color='#f4c542'>Servicing aircraft in %1 seconds.</t>",_countdown];

[_string, -1, -1, 1, 0, 0, 8365] spawn bis_fnc_dynamicText;

_countdown = _countdown - 1;

sleep 1;
};

if (isTouchingGround (vehicle player) && vectorMagnitude velocity vehicle player < 5 && alive _heli) then {
	uiNamespace setVariable ["repairState",2];
	[] spawn FNC_Sortie;
} else {
	uiNamespace setVariable ["repairState",0];
};


