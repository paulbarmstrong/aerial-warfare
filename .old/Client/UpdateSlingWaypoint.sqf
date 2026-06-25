disableSerialization;

_veh = _this select 2;
_crew = crew _veh;


// Remove any action for unhook and roll out
{
	if (((player actionParams _x) select 0) isEqualTo "Unhook and roll out") then {
		player removeAction _x;
	};
} forEach actionIds player;

// If there is no crew or the car wasn't actually dropped, do nothing
if (count _crew > 0 && { (getSlingLoad (_this select 0)) isEqualTo objNull }) then {

	_group = group (_crew select 0);

	// Clear all of the group's waypoints
	while {count (waypoints _group) > 0} do
	{
		deleteWaypoint ((waypoints _group) select 0);
	};
	
	// Get nearest non-friendly town
	_bestIndex = 0;
	for "_i" from 0 to (count TownMarkers - 1) do {
		if ((_veh distance2D (getMarkerPos (TownMarkers select _i))) < (_veh distance2D (getMarkerPos (TownMarkers select _bestIndex)))) then {
			_bestIndex = _i;
		};
	};
		
	_rollOut = _veh getVariable "roll_out";
	
	if (!isNil "_rollOut" && {_rollOut}) then {
		_veh setFuel 1;
	
		// Set waypoint to town
		_moveWaypoint = _group addWaypoint[getMarkerPos (TownMarkers select _bestIndex), 20];
		_moveWaypoint setWaypointType "HOLD";

		// Set behavior
		_group setBehaviour "AWARE";
		
		(units _group) doWatch objNull;

		
	// Otherwise, remove all fuel and watch nearest hostile lz
	} else {
		
		_veh setFuel 0;
		
		(units _group) doWatch (getMarkerPos (TownMarkers select _bestIndex));
		
		// Not sure if aware is the best behavior setting
		_group setBehaviour "AWARE";
	};
	
	// Reset the flag
	_veh setVariable ["roll_out", false];
};

