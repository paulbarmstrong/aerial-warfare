disableSerialization;

_veh = _this select 0;
_hitterVeh = vehicle (_this select 1);

_assistOwner = _hitterVeh getVariable "owner";
if (isPlayer (driver _hitterVeh)) then {
	_assistOwner = driver _hitterVeh;
};

// Just make sure its not redundant
if (((_veh getVariable "listOfAssists") find _assistOwner) == -1) then {
	_veh setVariable ["listOfAssists",(_veh getVariable "listOfAssists") + [_assistOwner]];
};
