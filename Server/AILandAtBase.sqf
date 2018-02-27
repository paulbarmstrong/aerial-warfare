disableSerialization;

_man = leader _this;
_group = group _man;
_heli = vehicle _man;

_homePos = getMarkerPos "respawn_west";
if (side _this == east) then {
	_homePos = getMarkerPos "respawn_east";
};

_heli land "LAND";

_timePassed = 0;

while {!isTouchingGround _heli && _timePassed < 45} do {
	sleep 1;
	_timePassed = _timePassed + 1;
};


{
	_xUnit = _x select 0;
	if (!(_xUnit isEqualTo _man)) then {
		deleteVehicle _xUnit;
	};
} forEach (fullCrew _heli);
deleteVehicle _heli;

_man call FNC_AIRespawn;
