import { Config, configFile, driver, GameObject, getDammage, getText, getVariable, group, groupChat, gunner, isKindOf, isNil, isPlayer, leader, playableUnits, remoteExec, setDamage, setVariable, Side, side, typeOf, vehicle } from "js-to-sqf";
import { displayHitmarker } from "../Client/Hitmarker";
import { getUnitDisplayName } from "../Constants";
import { changeMoney, getKillAward } from "./Money";
import { getTowns, refreshTown } from "./Towns";

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
		} else if (playableUnits().includes(leader(getVariable(killer, "warfare_owner")))) {
			const owner = leader(getVariable(killer, "warfare_owner"))
			remoteExec([owner, `Your ${killerDisplayName} neutralized an enemy ${unitDisplayName} | +$${award}`], groupChat, owner, false)
			changeMoney(owner, award)
		}
	}

	// Do things if this guy was guarding a base
	const towns = getTowns()
	for (const town of towns) {
		for (const turret of town.turrets) {
			if (unit === gunner(turret)) {
				refreshTown(town, undefined)
			}
		}
	}

	if (playableUnits().includes(unit)) {
		setDamage(vehicle(unit), 1)
	}

	// If they were someone's car, let them know it got destroyed
	const carOwner: GameObject = leader(getVariable(unit, "warfare_owner"))
	if (carOwner !== undefined && (isKindOf(unit, "Tank") || isKindOf(unit, "Car"))) {
		const carName: string = getText(new Config(configFile(), "CfgVehicles", typeOf(vehicle(unit)), "displayName"))
		remoteExec([carOwner, `Your ${carName} was destroyed.`], groupChat, carOwner, false)
	}
}