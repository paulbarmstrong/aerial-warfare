disableSerialization;

// Draw the money UI
_money = (group player) getVariable "Money";
_income = 0;
if (side group player == west) then {
	_income = BluforIncome;
} else {
	_income = OpforIncome;
};

_numCapMen = 0;
{
	if ((_x getVariable "SoldierType") == "capture" && alive _x) then {
		_numCapMen = _numCapMen + 1;
	};
} forEach crew vehicle player;

_string = format["<t align='left'>Money: $%1 (+$%2/min)<br />Troops: %3</t>",_money,_income,_numCapMen];

[
	_string,
	safeZoneX,
	0,
	1,
	0,
	0,
	8364
] spawn BIS_fnc_dynamicText;



