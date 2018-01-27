disableSerialization;

if (side group _this != side group player) then
{
	_unit addEventHandler ["Hit","
		if (driver (vehicle (_this select 1)) == player) then
		{
			[] spawn FNC_DisplayHitmarker;
		};"
	];
};


