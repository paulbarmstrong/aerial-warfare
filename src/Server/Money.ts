import { GameObject, getVariable, group, grpNull, isKindOf, setVariable, typeOf } from "js-to-sqf";
import { AIRCRAFT, LZ_KILL_AWARD, SLINGABLES, UNIT_KILL_AWARD_CATEGORIES } from "../Constants";
import { getTowns } from "./Towns";

export function changeMoney(unit: GameObject, delta: number) {
	const grp = group(unit)
	if (grp !== grpNull()) {
		const newMoney = (getVariable(grp, "Money") ?? 0) + delta;
		setVariable(grp, "Money", newMoney, true)
	}
}

export function getKillAward(unit: GameObject): number {
	const unitClassName: string = typeOf(unit)
	const towns = getTowns()
	const unitTown = towns.find(town => town.group === group(unit))
	
	if (unitTown !== undefined) {
		return LZ_KILL_AWARD
	}

	const aircraftPrice = AIRCRAFT.map(aircraft => {
		const armament = aircraft.armaments.find(armament => armament.className === unitClassName)
		if (armament !== undefined) {
			return aircraft.price + armament.price
		} else {
			return undefined
		}
	}).find(x => x !== undefined)
	if (aircraftPrice !== undefined) return aircraftPrice / 2
	
	const slingablePrice = SLINGABLES.find(slingable => slingable.className === unitClassName)?.price
	if (slingablePrice !== undefined) return slingablePrice / 2

	const awardCategory = UNIT_KILL_AWARD_CATEGORIES.find(x => isKindOf(unit, x.kind))
	if (awardCategory !== undefined) return awardCategory.money

	return 0
}