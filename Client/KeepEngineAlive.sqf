disableSerialization;

_vehicle = _this;

_info = getAllHitPointsDamage _vehicle;
_damageNames = _info select 1;
_damageList = _info select 2;

//hint str _damageNames;


// Set the engine and avionics to 0.5 so that the aircraft keeps flying

for "_i" from 0 to (count _damageList - 1) do {
	_name = _damageNames select _i;
	if (_damageList select _i > 0.5) then {
		if (_name == "engine_hit" || _name == "engine_2_hit" || _name == "avionics_hit" || _name == "main_rotor_hit") then {
			_vehicle setHitIndex[_i,0.5,false];
		} else {
			if (_name == "fuel_hit") then {
				_vehicle setHitIndex[_i,0,false];
			};
		};
	};
};



/*
	// If the damage goes above 0.7, it should have died, destroy it
	if (damage _vehicle > 0.7) then {
		_vehicle setDamage 1;
	}
*/
