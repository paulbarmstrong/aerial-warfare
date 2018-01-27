disableSerialization;

_helipad = bluforHelipad;
_jetSpot = bluforJetSpot;
if (side player == east) then {
	_helipad = opforHelipad;
	_jetSpot = opforJetSpot;
};

_countdown = 5;

sleep 1;

while {(((vehicle player) distance2D _helipad) < 10 || ((vehicle player) distance2D _jetSpot) < 15) && isTouchingGround (vehicle player) && _countdown > 0} do {

_string = format["<t color='#f4c542'>Servicing aircraft in %1 seconds.</t>",_countdown];

[_string, -1, -1, 1, 0, 0, 8365] spawn bis_fnc_dynamicText;

_countdown = _countdown - 1;

sleep 1;
};

if ((((vehicle player) distance2D _helipad) < 10 || ((vehicle player) distance2D _jetSpot) < 15) && isTouchingGround (vehicle player)) then {
	uiNamespace setVariable ["repairState",2];
	[] spawn FNC_Sortie;
} else {
	uiNamespace setVariable ["repairState",0];
};


