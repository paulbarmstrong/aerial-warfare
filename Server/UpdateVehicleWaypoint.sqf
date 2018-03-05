disableSerialization;

_group = _this;

// Get closest town which isn't friendly
_closestIndex = 0;
for "_i" from 0 to (count TownMarkers -1 ) do {
	if (((TownFlags select _i) distance2D _veh < (TownFlags select _closestIndex) distance2D _veh)
		&& (side (TownGroups select _i) != _side)) then {
		
		_closestIndex = _i;
	};
};


// Set waypoint to town
_newWaypoint = _group addWaypoint[TownFlags select _closestIndex, 0];
_newWaypoint setWaypointType "HOLD";
_newWaypoint setWaypointStatements ["true", "


"];