removeAllActions _this;
_group = group _this;
_side = side _this;

_baseloc = getMarkerPos "respawn_west";
_shopObjects = BLUFOR_COMMANDER_BUILDINGS;
_vehiclePrices = BLUFOR_VEHICLE_PRICES;
_vehicleClassnames = BLUFOR_VEHICLE_CLASSNAMES;
_vehicleArrow = bluforVehicleArrow;

if (side _this == east) then
{
//	_baseloc = getMarkerPos "respawn_east";
//	_shopObjects = OPFOR_COMMANDER_BUILDINGS;
//	_vehiclePrices = OPFOR_VEHICLE_PRICES;
//	_vehicleClassnames = OPFOR_VEHICLE_CLASSNAMES;
//	_vehicleArrow = _opforVehicleArrow;
};
_this setPos _baseLoc;

if (!(isObjectHidden ((_shopObjects select 2) select 0))) then // vehicle shop is bought
{
	// Determine if the AI should by a vehicle, and which one
	_bestVehicle = -1;
	for "_i" from 0 to (count _vehiclePrices - 1) do
	{
		if ((_group getVariable "Money") / 2 >= _vehiclePrices select _i) then
		{
			_bestVehicle = _i;
		};
	};
	
	// Buy the vehicle if there is one
	if (_bestVehicle > -1) then
	{
		_group setVariable["Money",(_group getVariable "Money") - (_itemPrices select _bestVehicle),true];
		_newVehiclePosition = position _vehicleArrow findEmptyPosition[0,100,_vehicleClassnames select _bestVehicle];
		_vehArgs = [_newVehiclePosition,getDir _vehicleArrow,_vehicleClassnames select _bestVehicle,_group] call BIS_fnc_spawnVehicle;
		_newVeh = _vehArgs select 0;
		{
			if ((assignedVehicleRole _x) select 0 == "Driver") then {
				deleteVehicle _x;
			};
			_x addEventHandler ["Killed","_this call FNC_EntityKilled"];
			if (_side != west) then {[_x,"FNC_EnemyFromServer",west,false,true] call BIS_fnc_MP;};
			if (_side != east) then {[_x,"FNC_EnemyFromServer",east,false,true] call BIS_fnc_MP;};
		} forEach crew _newVeh;
		_newVeh addEventHandler ["Killed","_this call FNC_EntityKilled"];
		if (_side != west) then {[_newVeh,"FNC_EnemyFromServer",west,false,true] call BIS_fnc_MP;};
		if (_side != east) then {[_newVeh,"FNC_EnemyFromServer",east,false,true] call BIS_fnc_MP;};
		_this moveInDriver _newVeh;
	};
	
	// Clear all waypoints and give them the waypoint to "guard" (capture) towns
	while {count (waypoints _group) > 0} do
	{
		deleteWaypoint ((waypoints _group) select 0);
	};
	_group setBehaviour "AWARE";
	_newWaypoint = _group addWaypoint[position _this,0];
	_newWaypoint setWaypointType "GUARD";
};
