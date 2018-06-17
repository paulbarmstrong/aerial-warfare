disableSerialization;

_pos = _this;

// Get nearest non-friendly town
_bestIndex = 0;
for "_i" from 0 to (count TownMarkers - 1) do {
	if ((_veh distance2D (TownFlags select _i)) < (_veh distance2D (TownFlags select _bestIndex))
			&& {side (TownGroups select _i) != side _group}) then {
		_bestIndex = _i;
	};
};

