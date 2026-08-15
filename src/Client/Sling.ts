import { actionIDs, actionParams, addAction, addWaypoint, deleteWaypoint, distance2D, doWatch, GameObject, getSlingLoad,
	getVariable, group, isNull, objNull, player, position, removeAction, setBehaviour, setFuel, setSlingLoad, setVariable,
	setWaypointType, units, waypoints, crew } from "js-to-sqf"
import { getTowns } from "../Server/Towns"

export async function slingRopeAttach(heli: GameObject, rope: any, veh: GameObject) {
	let actionExists = false
	actionIDs(player()).forEach(id => {
		if (actionParams(player(), id)[0] === "Unhook and roll out") {
			actionExists = true
		}
	})

	if (!actionExists) {
		addAction(player(), "Unhook and roll out", (target, caller, actionId, args: Array<GameObject>) => {
			setVariable(args[0], "roll_out", true)
			setSlingLoad(args[1], objNull())
			removeAction(target, actionId)
		}, [veh, heli], 8, false)
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

		const rollOut = getVariable(veh, "roll_out")

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
