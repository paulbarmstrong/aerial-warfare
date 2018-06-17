disableSerialization;

_unit = _this select 0;
_hitter = _this select 1;

if (playableUnits find (driver vehicle _hitter) > -1 && {!local (driver vehicle _hitter) || isPlayer (driver vehicle _hitter)}
		&& {side group _hitter != side group _unit} && {side group _unit != civilian}) then {
		
	[] remoteExec ["FNC_DisplayHitmarker", _hitter, false];
	
};

