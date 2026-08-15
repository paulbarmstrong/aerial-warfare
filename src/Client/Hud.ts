import { alive, bis, fullCrew, getVariable, group, missionNamespace, player, safeZoneX, side, vehicle, west } from "@paulbarmstrong/js-to-sqf"

export async function displayHUDText() {
	const money = getVariable(group(player()), "Money")
	let income = getVariable(missionNamespace(), "OpforIncome")
	if (side(group(player())) === west()) {
		income = getVariable(missionNamespace(), "BluforIncome")
	}

	const numCapMen = fullCrew(vehicle(player())).map(entry => entry[0])
		.filter(u => u !== undefined && getVariable(u, "SoldierType") === "capture" && alive(u)).length

	const text = `<t align='left'>Money: $${money} (+$${income}/min)<br />Troops: ${numCapMen}</t>`

	bis.dynamicText(text, safeZoneX(), 0, 1, 0, 0, 8364)
}
