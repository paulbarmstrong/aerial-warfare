disableSerialization;

_unit = _this select 0;
_moneyChange = _this select 1;
_grp = group _unit;

if ((playableUnits find _unit > -1) && !(_grp isEqualTo grpNull)) then {

	// Perform the change on the server
	_newMoney = (_grp getVariable "Money") + _moneyChange;
	_grp setVariable ["Money", _newMoney];

	// Push the change to clients
	[_grp, ["Money", _newMoney]] remoteExec ["setVariable", -2, false];

};