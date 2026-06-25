disableSerialization;

_vehicle = _this select 0;
_damageList = (getAllHitPointsDamage _vehicle) select 2;
_damageFloor = _this select 1;

for "_i" from 0 to (count _damageList - 1) do {
	if (_damageList select _i > _damageFloor) then {
		_vehicle setHitIndex[_i,_damageFloor,false];
	};
};

