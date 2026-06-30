import { configFile, driver, GameObject, getDammage, getText, getVariable, group, groupChat, isKindOf, isNil, isPlayer, leader, playableUnits, remoteExec, setDamage, setVariable, Side, side, typeOf, vehicle } from "js-to-sqf";
import { displayHitmarker } from "../Client/Hitmarker";
import { getUnitDisplayName } from "../Constants";
import { changeMoney, getKillAward } from "./Money";

export async function distributeHitmarker(unit: GameObject, hitter: GameObject) {
	if (isPlayer(driver(vehicle(hitter))) && side(group(hitter)) !== side(group(unit))) {
		remoteExec([], displayHitmarker, hitter, false)
	}
}

export async function onUnitKilled(unit: GameObject, killer: GameObject) {
	const unitSide: Side = side(group(unit))
	const killerSide: Side = side(group(killer))
	const killerOwner: GameObject = leader(getVariable(killer, "warfare_owner"))
	const hasBeenHandled: boolean = getVariable(unit, "death_has_been_handled")
	if (killerOwner !== undefined && hasBeenHandled === undefined) {
		setVariable(unit, "death_has_been_handled", true)
	}

	const unitDisplayName: string = getUnitDisplayName(unit)
	const killerDisplayName: string = getUnitDisplayName(killer)

	if (getDammage(unit) < 1) {
		setDamage(unit, 1)
	}

	const award: number = getKillAward(unit)
	const listOfAssists: Array<GameObject> | undefined = getVariable(unit, "listOfAssists")
	if (listOfAssists !== undefined) {
		listOfAssists
			.filter(assist => playableUnits().includes(assist)
				&& side(group(assist)) !== side(group(unit))
				&& group(assist) !== group(killer)
				&& killerOwner !== assist)
			.forEach(assist => {
				remoteExec([assist, `Assisted with enemy ${unitDisplayName} | +$${award/2}`], groupChat, assist, false)
				changeMoney(assist, award/2)
			})
	}

	if (unitSide !== killerSide) {
		if (playableUnits().includes(driver(vehicle(killer)))) {
			const owner = driver(vehicle(killer))
			remoteExec([owner, `Neutralized enemy ${unitDisplayName} | +$${award}`], groupChat, owner, false)
			changeMoney(owner, award)
		} else {
			if (playableUnits().includes(leader(getVariable(killer, "warfare_owner")))) {
				const owner = leader(getVariable(killer, "warfare_owner"))
				remoteExec([owner, `Your ${killerDisplayName} neutralized an enemy ${unitDisplayName} | +$${award}`], groupChat, owner, false)
				changeMoney(owner, award)
			}
		}
	}
}

// Do things if this guy was guarding a base

for "_i" from 0 to (count TownMarkers - 1) do {
	if (((TownUnits select _i) find _unit) > -1) then {
	
		_numberAlive = 0;
		for "_j" from 0 to ((count (TownUnits select _i)) - 1) do {
			if (alive (TownUnits select _i select _j)
					&& {vehicle (TownUnits select _i select _j) == TownTurrets select _i select _j}) then {
				_numberAlive = _numberAlive + 1;
			};
		};
		TownUnitCounts set [_i, _numberAlive];

		[] call FNC_UpdateIncomes;
		
		if (_numberAlive > 0) then {
			TownMarkers select _i setMarkerText format["%1: %2/%3",TownNames select _i,_numberAlive,count (TownTurrets select _i)];
		} else {
			deleteGroup (TownGroups select _i);
			TownGroups set[_i,grpNull];
			if (getMarkerColor (TownMarkers select _i) != "colorWhite") then {
				// Town has been lost
				TownMarkers select _i setMarkerColor "colorWhite";
				TownMarkers select _i setMarkerText format["%1: 0/%2",TownNames select _i,count (TownTurrets select _i)];
				_oldFlag = TownFlags select _i;
				_flagPos = position _oldFlag;
				deleteVehicle _oldFlag;
				_newFlag = "FlagPole_F" createVehicle _flagPos;
				_newFlag setPos _flagPos;
				TownFlags set[_i,_newFlag];
				
				// If the killer's driver was a playableAI
				// (means the playableAI's vehicle cleared the lz), reward them
				_owner = leader (_killer getVariable "warfare_owner");
				if (isNil "_owner") then {
					_owner = driver vehicle _killer;
				};
				if (playableUnits find _owner > -1 && {_unitSide != _killerSide}) then {
					[_owner, format["Cleared enemy landing zone %1 | +$%2", TownNames select _i, TOWN_CLEAR_AWARD]]
							remoteExec ["groupChat", _owner, false];
					[_owner, TOWN_CLEAR_AWARD] remoteExec ["FNC_ChangeMoney", 2, false];
				};
			};
		};
	};
};

// If they were a playable unit blow up their helicopter
if (playableUnits find _unit > -1) then {
	(vehicle _unit) setDamage 1;
};

// If they were someone's car, let them know it got rekt
_carOwner = leader (_unit getVariable "warfare_owner");
if (!isNil "_carOwner" && {_unit isKindOf "Tank" || _unit isKindOf "Car"}) then {
	_carName = getText(configFile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "displayName");
	[_carOwner, format["Your %1 was destroyed.", _carName]] remoteExec ["groupChat", _carOwner, false];
	
};
