import { alive, getVariable, Group, grpNull, gunner, missionNamespace, setVariable, side } from "js-to-sqf";
import { Town } from "../Types";
import { INCOME_PER_TOWN_TROOP, MINIMUM_INCOME } from "../Constants";

export function changeMoney(group: Group, delta: number) {
	if (group !== grpNull()) {
		const newMoney = getVariable(group, "Money") + delta;
		setVariable(group, "Money", newMoney, true)
	}
}

export function updateIncomes() {
	const towns: Array<Town> = getVariable(missionNamespace, "Towns")

	const numBluforTownTroops: number = towns
		.flatMap(town => town.turrets)
		.filter(turret => alive(gunner(turret)) && side(gunner(turret)) === "west")
		.length

	const numOpforTownTroops: number = towns
		.flatMap(town => town.turrets)
		.filter(turret => alive(gunner(turret)) && side(gunner(turret)) === "east")
		.length
	
	setVariable(missionNamespace, "BluforIncome", MINIMUM_INCOME + (numBluforTownTroops * INCOME_PER_TOWN_TROOP), true)
	setVariable(missionNamespace, "OpforIncome", MINIMUM_INCOME + (numOpforTownTroops * INCOME_PER_TOWN_TROOP), true)
}