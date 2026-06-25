disableSerialization;

_unit = _this select 0;
_killer = _this select 1;

// If the unit isn't a player, announce the death

if (!isPlayer _unit) then {

	// Suffix to show if it was friendly fire or not
	_suffix = "";
	if (side group _unit == side group _killer) then {
		_suffix = " (Friendly fire)";
	};

	// If the unit was killed by a playableUnit, kill message includes killer
	if ((playableUnits find (driver vehicle _killer) > -1) && {(vehicle _unit != vehicle _killer)}) then {
	
		// Find the correct display name for the killer
		_killerDisplayName = format["%1 (AI)", name _killer];
		if (isPlayer _killer) then {
			_killerDisplayName = name _killer;
		};

		// Give the message
		[format["%1 (AI) was killed by %2%3", name _unit, _killerDisplayName, _suffix]] remoteExec ["systemChat", 0, false];
	
	// Otherwise the message doesn't mention the killer
	} else {
		
		[format["%1 (AI) was killed%2", name _unit, _suffix]] remoteExec ["systemChat", 0, false];
	};
};

// Make their map marker invisible
_marker = format["%1_%2_marker",side group _unit, groupID (group _unit)];
_marker setMarkerAlpha 0;

// Make sure the vehicle dies though
(vehicle _unit) setDamage 1;
