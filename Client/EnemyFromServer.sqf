disableSerialization;

if (side group _this != side group player && side group _this != civilian) then
{
	_this addEventHandler ["Hit","
		if (driver (vehicle (_this select 1)) == player) then
		{
			[] spawn FNC_DisplayHitmarker;
		};"
	];
};


