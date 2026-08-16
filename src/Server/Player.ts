import { addEventHandler, GameObject, group, position, setVariable, spawn } from "@paulbarmstrong/js-to-sqf"
import { STARTING_MONEY, USE_HITMARKERS } from "../Constants"
import { onUnitKilled } from "./EventHandlers"
import { distributeHitmarker } from "./Hit"
import { aiRespawn } from "./Spawn"
import { deathMessage } from "./Vehicle"

// Event handler entry points — see the note in Server/Vehicle.ts.

function onPlayerUnitRespawn(unit: GameObject) {
	spawn([unit], aiRespawn)
}

function onPlayerUnitKilled(unit: GameObject, killer: GameObject) {
	spawn([unit, killer], onUnitKilled)
	spawn([unit, killer], deathMessage)
}

export function setUpPlayer(unit: GameObject) {
	addEventHandler(unit, "Respawn", onPlayerUnitRespawn)
	addEventHandler(unit, "Killed", onPlayerUnitKilled)
	if (USE_HITMARKERS) {
		addEventHandler(unit, "Hit", distributeHitmarker)
	}

	setVariable(group(unit), "Money", STARTING_MONEY, true)

	// Make flag to prevent duplicate AIRespawns
	setVariable(group(unit), "warfare_need_spawn", true)

	// Make the LastPosition to deal with ai getting stuck
	setVariable(unit, "LastPosition", position(unit))
}
