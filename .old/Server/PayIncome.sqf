while {true} do
{
	{
		if (side _x == west) then
		{
			_x setVariable["Money",(_x getVariable "Money") + BluforIncome,true];
		} else {
			if (side _x == east) then
			{
				_x setVariable["Money",(_x getVariable "Money") + OpforIncome,true];
			};
		};
	} forEach allGroups;
	
	sleep 60;
};
