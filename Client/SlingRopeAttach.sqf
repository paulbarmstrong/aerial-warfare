disableSerialization;

_heli = _this select 0;
_veh = _this select 2;

// Check to see if the action exists
_actionExists = false;
{
	if (((player actionParams _x) select 0) find "Unhook and roll out" != -1) then {
		_actionExists = true;
	};
} forEach actionIds player;

// If it doesn't, add an action for unhook and roll out
if (!_actionExists) then {
	player addAction ["Unhook and roll out",{
		(_this select 3 select 0) setVariable ["roll_out", true];
		(_this select 3 select 1) setSlingLoad objNull;
		(_this select 0) removeAction (_this select 2);
	}, [_veh, _heli], 8, false];
};

