disableSerialization;

_group = _this;
_man = leader _group;
_heli = vehicle _man;
_side = side _group;
_maxTroops = ([typeOf _heli, true] call BIS_fnc_crewCount) - ([typeOf _heli,false] call BIS_fnc_crewCount);
_isTransportHeli = (_maxTroops > 0);
_troopCount = 0;
{
	if (((_x select 0) getVariable "SoldierType") == "capture" && alive (_x select 0)) then {
		_troopCount = _troopCount + 1;
	};
} forEach fullCrew _heli;

_homePos = position (BluforHelipads select 0);
_enemyBasePos = position (OpforHelipads select 0);
if (_side == east) then {
	_homePos = position (OpforHelipads select 0);
	_enemyBasePos = position (BluforHelipads select 0);
};

// Clear all of the group's waypoints
while {count (waypoints _group) > 0} do
{
	deleteWaypoint ((waypoints _group) select 0);
};

if (_isTransportHeli) then {
	if (_troopCount < 4) then {
	
		// Add waypoint to return to base and respawn
		_group setVariable ["landingAtBase", false];
		_newWaypoint = _group addWaypoint[_homePos,0];
		_newWaypoint setWaypointType "MOVE";
		_newWaypoint setWaypointStatements ["true", "this spawn FNC_AILandAtBase"];
	} else {
		// Get closest town which isn't fully populated with friendly units
		_bestIndex = 0;
		_bestFactor = 0;
		for "_i" from 0 to (count TownMarkers - 1) do {
			_townFactor = 100 - (((TownFlags select _i) distance2D _man) / 1000);
			if (side (TownGroups select _i) != _side || (TownUnits select _i) find objNull > -1) then {
				_townFactor = _townFactor + 100;
			};
			if (side (TownGroups select _i) != _side && TownUnitCounts select _i > 0) then {
				_townFactor = _townFactor - 20;
			};
			{
				if (side group _x == side _group && (count waypoints group _x) > 0) then { 
					if ((waypointPosition [group _x,0]) distance2D (position (TownFlags select _i)) < 150) then {
						_townFactor = _townFactor - 50;
					};
				};
			} forEach playableUnits;
			
			if (_townFactor > _bestFactor) then {
				_bestIndex = _i;
				_bestFactor = _townFactor;
			};
		};
		
		// Tell them to go land there
		_heli land "NONE";
		_group setVariable ["lettingOutTroops", false];
		_newWaypoint = _group addWaypoint[TownHelipads select _bestIndex, 0];
		_newWaypoint setWaypointType "MOVE";
		_newWaypoint setWaypointStatements ["true", "this spawn FNC_AITroopLanding"];

	};
} else {
	
	// Get closest town which isn't friendly
	_bestIndex = 0;
	_bestDistance = 100000;
	for "_i" from 0 to (count TownMarkers - 1) do {
		if (((TownFlags select _i) distance2D _man < _bestDistance)
			&& (side (TownGroups select _i) != _side) && (TownUnitCounts select _i > 0)) then {
			
			_bestIndex = _i;
			_bestDistance = (TownFlags select _i) distance2D _man;
		};
	};
	// Otherwise, go to the town closest to enemy base
	if (_bestDistance == 100000) then {
		for "_i" from 0 to (count TownMarkers - 1) do {
			if (((TownFlags select _i) distance2D _enemyBasePos < _bestDistance)
				&& (side (TownGroups select _i) != _side) && TownUnitCounts select _i > 0) then {
				
				_bestIndex = _i;
				_bestDistance = (TownFlags select _i) distance2D _enemyBasePos;
			};
		};
		_newWaypoint = _group addWaypoint[position (TownFlags select _bestIndex), 0];
		_newWaypoint setWaypointType "MOVE";
	};
	
	// Add waypoints to destroy all enemies there (causes log spam)
	/*{
		if (!(_x isEqualTo objNull)) then {
			_newWaypoint = _group addWaypoint[_x,0];
			_newWaypoint setWaypointType "DESTROY";
		};
	} forEach (units (TownGroups select _bestIndex)); */
	
	// Add final waypoint to return to base and respawn
	_newWaypoint = _group addWaypoint[_homePos,0];
	_newWaypoint setWaypointType "MOVE";
	_newWaypoint setWaypointStatements ["true", "this spawn FNC_AILandAtBase"];
};

_group setBehaviour "AWARE";


/*
// Get closest town which isn't friendly
_closestIndex = 0;
for "_i" from 0 to (count TownMarkers -1 ) do {
	if (((TownFlags select _i) distance2D _man < (TownFlags select _closestIndex) distance2D _man)
		&& (side (TownGroups select _i) != _side)) then { //|| count units (TownGroups select _i) < count (TownTurrets select _i))) then {
		
		_closestIndex = _i;
	}
};

// Tell them to go land there
_newWaypoint = _group addWaypoint[TownHelipads select _closestIndex,0];
_newWaypoint setWaypointType "MOVE";
_newWaypoint setWaypointStatements ["true", "this spawn FNC_AITroopLanding"];
_group setBehaviour "AWARE";
*/
