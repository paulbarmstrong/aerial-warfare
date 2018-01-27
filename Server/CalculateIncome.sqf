_bluforTemp = 0;
_opforTemp = 0;
for "_i" from 0 to (count TownMarkers - 1) do
{
	if (markerColor (TownMarkers select _i) == "colorBLUFOR") then
	{
		_bluforTemp = _bluforTemp + (TownIncomes select _i);
	} else {
		if (markerColor (TownMarkers select _i) == "colorOPFOR") then
		{
			_opforTemp = _opforTemp + (TownIncomes select _i);
		};
	};
};
BluforIncome = _bluforTemp;
OpforIncome = _opforTemp;
