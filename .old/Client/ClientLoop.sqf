disableSerialization;

_serviceLocations = BluforHelipads + [bluforJetSpot];
if (side player == east) then {
	_serviceLocations = OpforHelipads + [opforJetSpot];
};

while {true} do
{
	// Display the HUD text every time no matter what
	[] call FNC_DisplayHUDText;
	
	// If the player is letting out troops, update that vehicle's touchingGround on serverside
	if ((vehicle player != player) && {uiNamespace getVariable "isUnloadingTroops"}) then {
		[vehicle player, ["touching_ground", (isTouchingGround (vehicle player))]] remoteExec ["setVariable", 2, false];
	};
	
	// If the aircraft is landed at base, spawn the landed at base function
	_isNearServiceLoc = false;
	{
		if ((vehicle player) distance2D _x < 100) then {
			_isNearServiceLoc = true;
		}
	} forEach _serviceLocations;
	if (_isNearServiceLoc && {isTouchingGround (vehicle player) && (uiNamespace getVariable "repairState") == 0}) then {
		uiNamespace setVariable ["repairState",1];
		[] spawn FNC_HelipadService;
	};
	
	// If the player's vehicle has cargo seats, check to see if it is at a town
	_cargoCrewCount = ([typeOf vehicle player, true] call BIS_fnc_crewCount) - ([typeOf vehicle player, false] call BIS_fnc_crewCount);

	if (_cargoCrewCount > 0) then {
		for "_i" from 0 to (count TownMarkers - 1) do {
		
			// If the aircraft is landed at a zone, spawn the troop out function
			if (isTouchingGround (vehicle player) && {vectorMagnitude velocity vehicle player < 3}
					&& {(position player) distance2D (getMarkerPos (TownMarkers select _i)) < TownSizes select _i}
					&& {!(uiNamespace getVariable "isUnloadingTroops")}) then {
				
				uiNamespace setVariable ["isUnloadingTroops",true];
				
				[player, _i] remoteExec ["FNC_LetTroopsOut", 2, false];
			};
			
			
			// If the aircraft is flying above a town, create action to drop troops onto town
			if ((((position vehicle player) vectorAdd ((velocity vehicle player) vectorMultiply 1.5)) distance2D (getMarkerPos (TownMarkers select _i))) < (1.5 * (TownSizes select _i)) && {(position vehicle player) select 2 > 125}) then {
				_actionExists = false;
				{
					if (((player actionParams _x) select 0) find format["onto %1",TownNames select _i] != -1) then {
						_actionExists = true;
					};
				} forEach actionIds player;
				
				if (!_actionExists) then {
					_actionText = format["Drop troops onto %1",TownNames select _i];
					player addAction [_actionText,{
						[_this select 1, _this select 3] remoteExec ["FNC_DropTroops", 2, false];
					},_i,8,true];
				};
			} else {
				{
					if (((player actionParams _x) select 0) find format["onto %1",TownNames select _i] != -1) then {
						player removeAction  _x;
					};
				} forEach actionIds player;
			};
		};
	};
	
	// Sleep for 0.5 seconds
	sleep 0.5;
};
