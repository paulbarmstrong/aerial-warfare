import { addEventHandler, GameObject, group, position, setVariable, spawn } from "js-to-sqf"
import { STARTING_MONEY, USE_HITMARKERS } from "../Constants"
import { onUnitKilled } from "./EventHandlers"
import { distributeHitmarker } from "./Hit"
import { aiRespawn } from "./Spawn"
import { deathMessage } from "./Vehicle"

export function setUpPlayer(unit: GameObject) {
	addEventHandler(unit, "Respawn", (respawnedUnit: GameObject) => spawn([respawnedUnit], aiRespawn))
	addEventHandler(unit, "Killed", (killedUnit: GameObject, killer: GameObject) => {
		spawn([killedUnit, killer], onUnitKilled)
		spawn([killedUnit, killer], deathMessage)
	})
	if (USE_HITMARKERS) {
		addEventHandler(unit, "Hit", distributeHitmarker)
	}

	setVariable(group(unit), "Money", STARTING_MONEY, true)

	// Make flag to prevent duplicate AIRespawns
	setVariable(group(unit), "warfare_need_spawn", true)

	// Make the LastPosition to deal with ai getting stuck
	setVariable(unit, "LastPosition", position(unit))
}
