disableSerialization;

_weapon = _this select 1;
_shooter = _this select 7;
_projectile = _this select 6;

_range = 6;
if (_weapon isKindOf ["LauncherCore", configFile >> "CfgWeapons"]) then {
	_range = 10;
};
if (BIG_BOMBS find _weapon > -1) then {
	_range = 50;
};

// Get the position of the projectile until it blows up
_pos = position _projectile;
while {!(isNull _projectile)} do {
	_pos = position _projectile;
	sleep 0.05;
};

_turrets = nearestObjects[_pos, ["StaticWeapon"], _range];

{
	_gunner = gunner _x;
	if (alive _gunner) then {
		
		if (playableUnits find (driver vehicle _shooter) > -1 && {side group _shooter != side group _gunner}) then {
			[] remoteExec ["FNC_DisplayHitmarker", _shooter, false];
		};
		
		_explosionDamage = 1.7 - ((_pos distance (position _gunner)) / _range);
		
		_newDamage = (getDammage _gunner) + _explosionDamage;
		if (_newDamage > 1) then {
			[_gunner, _shooter] call FNC_EntityKilled;
		};
		_gunner setDamage _newDamage;
	};
	
} forEach _turrets;


