disableSerialization;

// Tally up the number of blufor and opfor troops in towns
_bluforTownTally = 0;
_opforTownTally = 0;
for "_i" from 0 to (count TownFlags - 1) do {
	if (typeOf (TownFlags select _i) == "Flag_Blue_F") then {
		_bluforTownTally = _bluforTownTally + (TownUnitCounts select _i);
	} else {
		if (typeOf (TownFlags select _i) == "Flag_Red_F") then {
			_opforTownTally = _opforTownTally + (TownUnitCounts select _i);
		};
	};
};

// Apply to the incomes
BluforIncome = MINIMUM_INCOME + (_bluforTownTally * INCOME_PER_TOWN_TROOP);
OpforIncome = MINIMUM_INCOME + (_opforTownTally * INCOME_PER_TOWN_TROOP);
publicVariable "BluforIncome";
publicVariable "OpforIncome";
