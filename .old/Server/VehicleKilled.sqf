disableSerialization;

_veh = _this select 0;
_killer = _this select 1;
_killerSide = side group _killer;

// Perform a special award message for multiple heli occupants
_crew = crew _veh;
if (count _crew > 0) then {
	_unitSide = side group (_crew select 0);
	_killCount = 0;
	{
		_hasBeenHandled = _x getVariable "death_has_been_handled";
		if (isNil "_hasBeenHandled" || {!_hasBeenHandled}) then {
			_x setVariable ["death_has_been_handled", true];
			_x allowDamage true;
			[_x, true] remoteExec ["allowDamage", owner _x, false];
			//_x setDamage 1;
			_killCount = _killCount + 1;
		};
	} forEach crew _veh;

	// Call EntityKilled for the actual vehicle
	_this call FNC_EntityKilled;
	
	_award = _killCount * TROOP_KILL_AWARD;

	// Reward killer
	if (_unitSide != _killerSide) then {
		// If the killer is in a playableUnit's vehicle, award the kill to playableUnit
		if (playableUnits find (driver vehicle _killer) > -1) then {
			_owner = driver vehicle _killer;
			[_owner, format["Neutralized %1x enemy occupants | +$%2", _killCount, _award]] remoteExec ["groupChat", _owner, false];
			[_owner, _award] remoteExec ["FNC_ChangeMoney", 2, false];
			
		} else {
		
			// If the owner of the killer is a playableUnit, award the kill to playableUnit
			_killerDisplayName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _killer) >> "displayName");
			_specialAAIndex = SPECIAL_AA_SLINGABLES find (typeOf vehicle _killer);
			if (_specialAAIndex > -1) then {
				_killerDisplayName = SPECIAL_AA_SLING_NAMES select _specialAAIndex;
			};

			if (playableUnits find (leader (_killer getVariable "warfare_owner")) > -1) then {
				_owner = leader (_killer getVariable "warfare_owner");				
				[_owner, format["Your %1 neutralized %2x enemy occupants | +$%3", _killerDisplayName, _killCount, _award]]
						remoteExec ["groupChat", _owner, false];
				[_owner, _award] remoteExec ["FNC_ChangeMoney", 2, false];
			};
		};
	};
} else {
	// Call EntityKilled for the actual vehicle
	_this call FNC_EntityKilled;
};

// Kill the driver for sure though
if (!(driver _veh isEqualTo objNull)) then {
	(driver _veh) allowDamage true;
	[driver _veh, true] remoteExec ["allowDamage", driver _veh, false];
};
