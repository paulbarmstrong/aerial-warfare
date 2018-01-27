disableSerialization;

// Draw the money UI
_money = (group player) getVariable "Money";
_numCapMen = 0;
{
	if ((_x getVariable "SoldierType") == "capture" && alive _x) then {
		_numCapMen = _numCapMen + 1;
	};
} forEach crew vehicle player;

_string = format["<t align='left'>Money: $%1<br />Troops: %2</t>",_money,_numCapMen];

[
	//'<t size=''1'' shadow=''0'' />+(_string)+<\t>',
	//'<t size=''1'' shadow=''0'' text=_string />',
	_string,
	safeZoneX,
	0,
	1,
	0,
	0,
	8364
] spawn bis_fnc_dynamicText;



