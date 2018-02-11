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

_man setDamage 1;
deleteVehicle _heli;

_man call FNC_AIRespawn;
