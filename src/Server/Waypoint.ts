import { addWaypoint, bis, deleteWaypoint, distance2D, east, fullCrew, gunner, getVariable, Group, land, leader,
	playableUnits, position, setBehaviour, setVariable, setWaypointStatements, setWaypointType, side, spawn, typeOf,
	vehicle, waypointPosition, waypoints, west } from "@paulbarmstrong/js-to-sqf"
import { getSpawnPosForSide } from "../Constants"
import { aiLandAtBase, aiTroopLanding } from "./Spawn"
import { getTowns } from "./Towns"

export async function updateWaypoint(group: Group) {
	const man = leader(group)
	const heli = vehicle(man)
	const groupSide = side(group)
	const maxTroops = bis.crewCount(typeOf(heli), true) - bis.crewCount(typeOf(heli), false)
	const isTransportHeli = maxTroops > 0
	const troopCount = fullCrew(heli).filter(entry => entry[0] !== undefined && getVariable(entry[0], "SoldierType") === "capture").length

	const homePos = position(getSpawnPosForSide(groupSide))

	while (waypoints(group).length > 0) {
		deleteWaypoint(group, 0)
	}

	if (isTransportHeli) {
		if (troopCount < 4) {
			setVariable(group, "landingAtBase", false)
			const newWaypoint = addWaypoint(group, homePos, 0)
			setWaypointType(newWaypoint, "MOVE")
			setWaypointStatements(newWaypoint, () => true, () => spawn([man], aiLandAtBase))
		} else {
			const towns = getTowns()
			let bestIndex = 0
			let bestFactor = 0
			towns.forEach((town, i) => {
				let townFactor = 100 - (distance2D(town.flag, man) / 1000)
				if (side(town.group) !== groupSide || town.turrets.some(turret => gunner(turret) === undefined)) {
					townFactor += 100
				}
				if (side(town.group) !== groupSide && town.turrets.length > 0) {
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
			setWaypointStatements(newWaypoint, () => true, () => spawn([man], aiTroopLanding))
		}
	} else {
		const towns = getTowns()
		let bestIndex = 0
		let bestDistance = 100000
		towns.forEach((town, i) => {
			const d = distance2D(town.flag, man)
			if (d < bestDistance && side(town.group) !== groupSide && town.turrets.length > 0) {
				bestIndex = i
				bestDistance = d
			}
		})

		if (bestDistance === 100000) {
			const enemyBasePos = position(getSpawnPosForSide(groupSide === west() ? east() : west()))
			towns.forEach((town, i) => {
				const d = distance2D(town.flag, enemyBasePos)
				if (d < bestDistance && side(town.group) !== groupSide && town.turrets.length > 0) {
					bestIndex = i
					bestDistance = d
				}
			})
			const newWaypoint = addWaypoint(group, position(towns[bestIndex].flag), 0)
			setWaypointType(newWaypoint, "MOVE")
		}

		const newWaypoint = addWaypoint(group, homePos, 0)
		setWaypointType(newWaypoint, "MOVE")
		setWaypointStatements(newWaypoint, () => true, () => spawn([man], aiLandAtBase))
	}

	setBehaviour(group, "AWARE")
}
