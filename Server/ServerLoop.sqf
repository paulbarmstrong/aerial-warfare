_count = 0;

while {true} do
{
	// Update markers on the map
	[] call FNC_TrackOnMap;
	
	// Spawn vehicle units every so often
//	if (count mod 60 == 5) then {
//		west spawn FNC_CreatePassiveVehicle;
//		east spawn FNC_CreatePassiveVehicle;
//	};
	
	// Handle town-specific operations on a staggered schedule
	_i = _count mod (count TownNames);
	for "_j" from 0 to (count (TownUnits select _i) - 1) do {
		if (alive (TownUnits select _i select _j) && {vehicle (TownUnits select _i select _j) != (TownTurrets select _i select _j)}) then {
			if (assignedVehicle (TownUnits select _i select _j) != TownTurrets select _i select _j) then {
				(TownUnits select _i select _j) assignAsGunner (TownTurrets select _i select _j);
			};
			[TownUnits select _i select _j] orderGetIn true;
		};
	};
	
	sleep 1;
	_count = _count + 1;
};