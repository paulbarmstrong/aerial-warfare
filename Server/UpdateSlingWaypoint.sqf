disableSerialization;

_veh = _this select 2;
_crew = crew _veh;
if (count _crew > 0) then {

	_group = group (_crew select 0);

	// Clear all of the group's waypoints
	while {count (waypoints _group) > 0} do
	{
		deleteWaypoint ((waypoints _group) select 0);
	};

	// Get closest town
	_bestIndex = 0;
	for "_i" from 0 to (count TownMarkers - 1) do {
		if ((_veh distance2D (TownFlags select _i)) < (_veh distance2D (TownFlags select _bestIndex))) then {
			_bestIndex = _i;
		};
	};


	// Set waypoint to town
	_moveWaypoint = _group addWaypoint[TownFlags select _bestIndex, 20];
	_moveWaypoint setWaypointType "LOITER";

	// Set behavior
	_group setBehaviour "AWARE";


} else {

	sleep 10;
	deleteVehicle _veh;
};

