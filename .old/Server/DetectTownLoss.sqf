for "_i" from 0 to (count TownMarkers - 1) do {
	_flag = TownFlags select _i;
	if (typeOf _flag != "FlagPole_F") then {
		_allDead = true;
		{
			if (alive _x) then {
				_allDead = false;
			};
		} forEach (units TownGroups select _i);
		
		if (_allDead) then {
			TownMarkers select _i setMarkerColor "colorKhaki";
			_flagPos = position _flag;
			deleteVehicle _flag;
			_newFlag = "FlagPole_F" createVehicle _flagPos;
			_newFlag setPos _flagPos;
			TownFlags set[_i,_newFlag];
			TownGroups set[_i,grpNull];
		};
	};
};


