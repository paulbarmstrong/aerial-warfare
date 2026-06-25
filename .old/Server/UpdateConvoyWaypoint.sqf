disableSerialization;

_group = _this;
_side = side _group;
_groupPos = position leader _group;

//hint format["update convoy waypoint: %1",random 100];

_colonyGroups = Blufor_Convoy_Groups;
if (_side == east) then {
	_colonyGroups = Opfor_Convoy_Groups;
};

// Clear all of the group's waypoints
while {count (waypoints _group) > 0} do
{
	deleteWaypoint ((waypoints _group) select 0);
};

// Get all vehicles
_vehicles = [];
{
	if (vehicle _x != _x && {_vehicles find (vehicle _x) == -1}) then {
		_vehicles = _vehicles + [vehicle _x];
	};
} forEach units _group;

if (count _vehicles == 0) exitWith {
	deleteGroup _group;
};

_newVehPos = getPos (_vehicles select 0);
_newVehDir = getDir (_vehicles select 0);

// Reset the positions of the vehicles
for "_i" from 1 to (count _vehicles - 1) do {
	_newVehPos = [_newVehPos, 20, _newVehDir + 180] call BIS_fnc_relPos;
	_newVehPos = [_newVehPos, 0, 10] call BIS_fnc_findSafePos;
	(_vehicles select _i) setPos _newVehPos;
	(_vehicles select _i) setDir _newVehDir;
};

// Get closest town which isn't friendly
_bestIndex = 0;
_bestFactor = 0;
for "_i" from 0 to (count TownMarkers - 1) do {
	_townFactor = 100 - (((TownFlags select _i) distance2D _groupPos) / 1000);
	if (side (TownGroups select _i) != _side) then {
		_townFactor = _townFactor + 100;
	};
	
	{
		if (!(_x isEqualTo grpNull) && {waypointPosition ((waypoints _x) select 0) distance2D (position (TownFlags select _i)) < 150}) then {
			_townFactor = _townFactor - 50;
		};
	} forEach _colonyGroups;
	
	if (_townFactor > _bestFactor) then {
		_bestIndex = _i;
		_bestFactor = _townFactor;
	};
};


// Set waypoint to town
_moveWaypoint = _group addWaypoint[TownFlags select _bestIndex, 20];
_moveWaypoint setWaypointType "LOITER";

// Set behavior and formation
_group setBehaviour "SAFE";
_group setFormation "FILE";


