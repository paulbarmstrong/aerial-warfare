disableSerialization;

_vehicle = _this;

_info = getAllHitPointsDamage _vehicle;
_damageNames = _info select 1;
_damageList = _info select 2;

_thingsToFix = [];

for "_i" from 0 to (count _damageList - 1) do {
	_name = _damageNames select _i;
	if (_damageList select _i > 0.6) then {
		if (_name find "wheel" > -1 || {_name find "engine" > -1} || {_name find "fuel" > -1}) then {
			_thingsToFix = _thingsToFix + [_i];
		};
	};
};

sleep 60;


// Set the wheels to 0.5 so that the car can keep driving
if (alive _vehicle) then {
	for "_i" from 0 to (count _thingsToFix - 1) do {
		_vehicle setHitIndex[_i,0.6,false];
	};
	
	if (!((driver _vehicle) isEqualTo objNull) && {count (waypoints group driver _vehicle) > 0}) then {
		_vehicle setFuel 1;
	};
};

