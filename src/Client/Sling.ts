import { actionIDs, actionParams, addAction, addWaypoint, deleteWaypoint, distance2D, doWatch, GameObject, getSlingLoad,
	getVariable, group, isNull, objNull, player, position, removeAction, setBehaviour, setFuel, setSlingLoad, setVariable,
	setWaypointType, spawn, units, waypoints, crew } from "@paulbarmstrong/js-to-sqf"
import { getTowns } from "../Server/Towns"

// Event handler entry points — see the note in Server/Vehicle.ts.

export function onRopeAttach(heli: GameObject, rope: any, veh: GameObject) {
	spawn([heli, rope, veh], slingRopeAttach)
}

export function onRopeBreak(heli: GameObject, rope: any, veh: GameObject) {
	spawn([heli, rope, veh], updateSlingWaypoint)
}

/** The "Unhook and roll out" action. Its `arguments` are `[veh, heli]`; nothing is read
 * from the scope that added the action, which by now is gone. */
function unhookAndRollOut(target: GameObject, caller: GameObject, actionId: number, args: Array<GameObject>) {
	setVariable(args[0], "roll_out", true)
	setSlingLoad(args[1], objNull())
	removeAction(target, actionId)
}

export async function slingRopeAttach(heli: GameObject, rope: any, veh: GameObject) {
	let actionExists = false
	actionIDs(player()).forEach(id => {
		if (actionParams(player(), id)[0] === "Unhook and roll out") {
			actionExists = true
		}
	})

	if (!actionExists) {
		addAction(player(), "Unhook and roll out", unhookAndRollOut, [veh, heli], 8, false)
	}
}

export async function updateSlingWaypoint(heli: GameObject, rope: any, veh: GameObject) {
	const crewMembers = crew(veh)

	actionIDs(player()).forEach(id => {
		if (actionParams(player(), id)[0] === "Unhook and roll out") {
			removeAction(player(), id)
		}
	})

	if (crewMembers.length > 0 && isNull(getSlingLoad(heli))) {
		const grp = group(crewMembers[0])

		while (waypoints(grp).length > 0) {
			deleteWaypoint(grp, 0)
		}

		const towns = getTowns()
		let bestIndex = 0
		towns.forEach((town, i) => {
			if (distance2D(veh, town.flag) < distance2D(veh, towns[bestIndex].flag)) {
				bestIndex = i
			}
		})

		const rollOut = getVariable(veh, "roll_out") ?? false

		if (rollOut) {
			setFuel(veh, 1)
			const moveWaypoint = addWaypoint(grp, towns[bestIndex].flag, 20)
			setWaypointType(moveWaypoint, "HOLD")
			setBehaviour(grp, "AWARE")
			doWatch(units(grp), objNull())
		} else {
			setFuel(veh, 0)
			doWatch(units(grp), position(towns[bestIndex].flag))
			setBehaviour(grp, "AWARE")
		}

		setVariable(veh, "roll_out", false)
	}
}
