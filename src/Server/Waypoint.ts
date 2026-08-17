import { addWaypoint, bis, deleteWaypoint, distance2D, east, fullCrew, GameObject, getVariable, Group, land, leader,
	playableUnits, position, setBehaviour, setVariable, setWaypointStatements, setWaypointType, side, spawn, typeOf,
	vehicle, waypointPosition, waypoints, west,
	objNull} from "@paulbarmstrong/js-to-sqf"
import { getSpawnPosForSide } from "../Constants"
import { aiLandAtBase, aiTroopLanding } from "./Spawn"
import { getTownNumAlive, getTowns } from "./Towns"

// A waypoint statement is SQF source the engine compiles and runs on its own, so it cannot
// see anything local to the function that set it up. Each is a named function instead,
// receiving the waypoint's `this` — the group leader — as its only argument.

function waypointReached(): boolean {
	return true
}

function landAtBaseStatement(man: GameObject) {
	spawn([man], aiLandAtBase)
}

function troopLandingStatement(man: GameObject) {
	spawn([man], aiTroopLanding)
}

export async function updateWaypoint(group: Group) {
	const man = leader(group)
	const heli = vehicle(man)
	const groupSide = side(group)
	const maxTroops = bis.crewCount(typeOf(heli), true) - bis.crewCount(typeOf(heli), false)
	const isTransportHeli = maxTroops > 0
	const troopCount = fullCrew(heli).filter(entry => entry[0] !== objNull() && (getVariable(entry[0], "SoldierType") ?? "") === "capture").length

	const homePos = position(getSpawnPosForSide(groupSide))

	while (waypoints(group).length > 0) {
		deleteWaypoint(group, 0)
	}

	if (isTransportHeli) {
		if (troopCount < 4) {
			setVariable(group, "landingAtBase", false)
			const newWaypoint = addWaypoint(group, homePos, 0)
			setWaypointType(newWaypoint, "MOVE")
			setWaypointStatements(newWaypoint, waypointReached, landAtBaseStatement)
		} else {
			const towns = getTowns()
			let bestIndex = 0
			let bestFactor = 0
			towns.forEach((town, i) => {
				let townFactor = 100 - (distance2D(town.flag, man) / 1000)
				if (side(town.group) !== groupSide || town.units.some(unit => unit === objNull())) {
					townFactor += 100
				}
				if (side(town.group) !== groupSide && getTownNumAlive(town) > 0) {
					townFactor -= 20
				}
				playableUnits().forEach(unit => {
					if (side(unit) === groupSide && waypoints(unit).length > 0
							&& distance2D(waypointPosition(unit, 0), town.flag) < 150) {
						townFactor -= 50
					}
				})

				if (townFactor > bestFactor) {
					bestIndex = i
					bestFactor = townFactor
				}
			})

			land(heli, "NONE")
			setVariable(group, "lettingOutTroops", false)
			const newWaypoint = addWaypoint(group, towns[bestIndex].helipad, 0)
			setWaypointType(newWaypoint, "MOVE")
			setWaypointStatements(newWaypoint, waypointReached, troopLandingStatement)
		}
	} else {
		const towns = getTowns()
		let bestIndex = 0
		let bestDistance = 100000
		towns.forEach((town, i) => {
			const d = distance2D(town.flag, man)
			if (d < bestDistance && side(town.group) !== groupSide && getTownNumAlive(town) > 0) {
				bestIndex = i
				bestDistance = d
			}
		})

		if (bestDistance === 100000) {
			const enemyBasePos = position(getSpawnPosForSide(groupSide === west() ? east() : west()))
			towns.forEach((town, i) => {
				const d = distance2D(town.flag, enemyBasePos)
				if (d < bestDistance && side(town.group) !== groupSide && getTownNumAlive(town) > 0) {
					bestIndex = i
					bestDistance = d
				}
			})
			const newWaypoint = addWaypoint(group, position(towns[bestIndex].flag), 0)
			setWaypointType(newWaypoint, "MOVE")
		}

		const newWaypoint = addWaypoint(group, homePos, 0)
		setWaypointType(newWaypoint, "MOVE")
		setWaypointStatements(newWaypoint, waypointReached, landAtBaseStatement)
	}

	setBehaviour(group, "AWARE")
}
