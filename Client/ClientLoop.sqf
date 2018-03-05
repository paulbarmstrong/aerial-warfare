disableSerialization;

_serviceLocations = BluforHelipads + [bluforJetSpot];
if (side player == east) then {
	_serviceLocations = OpforHelipads + [opforJetSpot];
};

while {true} do
{
	// Display the HUD text every time no matter what
	[] call FNC_DisplayHUDText;
	
	// If the aircraft is landed at base, spawn the landed at base function
	_isNearServiceLoc = false;
	{
		if ((vehicle player) distance2D _x < 12) then {
			_isNearServiceLoc = true;
		}
	} forEach _serviceLocations;
	if (_isNearServiceLoc && {isTouchingGround (vehicle player) && (uiNamespace getVariable "repairState") == 0}) then {
		uiNamespace setVariable ["repairState",1];
		[] spawn FNC_HelipadService;
	};
	
	// If the aircraft is landed at a zone, spawn the troop out function
	for "_i" from 0 to (count TownMarkers - 1) do {
	
		//hint format["TownGroups select 0: %1",TownGroups select 0];
	
		// If the aircraft is landed at a zone, spawn the troop out function
		if (isTouchingGround (vehicle player)) then {
			if ((TownGroups select _i isEqualTo grpNull || {side (TownGroups select _i) == side group player})
				&& {(position player) distance2D (TownFlags select _i) < TownSizes select _i && !(uiNamespace getVariable "isUnloadingTroops")}) then {
				uiNamespace setVariable ["isUnloadingTroops",true];
				_i spawn FNC_LetTroopsOut;
			};
		};
		
		
		
		// If the aircraft is flying above a town, create action to drop troops onto town
		if ((TownGroups select _i isEqualTo grpNull || {side (TownGroups select _i) == side group player})
		&& {((position vehicle player) vectorAdd ((velocity vehicle player) vectorMultiply 1.5)) distance2D (TownFlags select _i) < 1.5 * (TownSizes select _i) && (position vehicle player) select 2 > 125}) then {
			_actionExists = false;
			{
				if (((player actionParams _x) select 0) find format["onto %1",TownNames select _i] != -1) then {
					_actionExists = true;
				};
			} forEach actionIds player;
			
			if (!_actionExists) then {
				_actionText = format["Drop troops onto %1",TownNames select _i];
				player addAction [_actionText,{_this select 3 spawn FNC_DropTroops},_i,8,true];
			};
		} else {
			{
				if (((player actionParams _x) select 0) find format["onto %1",TownNames select _i] != -1) then {
					player removeAction  _x;
				};
			} forEach actionIds player;
		};
	};
	
	
	// Sleep for 0.5 seconds
	sleep 0.5;
};
