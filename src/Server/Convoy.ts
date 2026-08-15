import { addEventHandler, addWaypoint, allowCrewInImmobile, bis, createGroupV2, createMarker, deleteGroup, deleteWaypoint,
	distance2D, enableRopeAttach, GameObject, getDir, getVariable, Group, grpNull, leader, limitSpeed, lock, missionNamespace,
	position, setBehaviour, setFormation, setMarkerAlpha, setMarkerColor, setMarkerType, setVariable, setWaypointType, side,
	Side, spawn, units, vehicle, waypointPosition, waypoints, west } from "js-to-sqf"
import { getConvoyVehicles, getCurrentMod, getGarageForSide, NUM_CONVOYS, USE_HITMARKERS } from "../Constants"
import { onUnitKilled } from "./EventHandlers"
import { distributeHitmarker } from "./Hit"
import { getTowns } from "./Towns"
import { addAssistMember, delayedWheelRepair, removeAfterMinute } from "./Vehicle"

export function setUpConvoys() {
	const bluforGroups: Array<Group> = []
	const opforGroups: Array<Group> = []
	for (let i = 0; i < NUM_CONVOYS; i++) {
		bluforGroups.push(grpNull())
		opforGroups.push(grpNull())

		const bluforMarker = createMarker(`blufor_convoy_marker_${i}`, [0, 0, 0])
		setMarkerType(bluforMarker, "mil_dot")
		setMarkerColor(bluforMarker, "colorBLUFOR")
		setMarkerAlpha(bluforMarker, 0)

		const opforMarker = createMarker(`opfor_convoy_marker_${i}`, [0, 0, 0])
		setMarkerType(opforMarker, "mil_dot")
		setMarkerColor(opforMarker, "colorOPFOR")
		setMarkerAlpha(opforMarker, 0)
	}
	setVariable(missionNamespace(), "BluforConvoyGroups", bluforGroups, true)
	setVariable(missionNamespace(), "OpforConvoyGroups", opforGroups, true)
	setVariable(missionNamespace(), "BluforIsSpawning", false, true)
	setVariable(missionNamespace(), "OpforIsSpawning", false, true)
}

function convoyGroupsVarName(convoySide: Side): string {
	return convoySide === west() ? "BluforConvoyGroups" : "OpforConvoyGroups"
}

export function getConvoyGroupsForSide(convoySide: Side): Array<Group> {
	return getVariable(missionNamespace(), convoyGroupsVarName(convoySide))
}

export function setConvoyGroupsForSide(convoySide: Side, groups: Array<Group>) {
	setVariable(missionNamespace(), convoyGroupsVarName(convoySide), groups, true)
}

export async function createConvoy(convoySide: Side) {
	const groups = getConvoyGroupsForSide(convoySide)
	const vehicleList = getConvoyVehicles(getCurrentMod(), convoySide)
	const garage = getGarageForSide(convoySide)
	let newVehPos = position(garage)
	const newVehDir = getDir(garage)

	const groupIndex = groups.findIndex(g => g === grpNull())
	if (groupIndex === -1) return

	const group = createGroupV2(convoySide, true)
	groups[groupIndex] = group
	setConvoyGroupsForSide(convoySide, groups)

	vehicleList.forEach(className => {
		const vehArgs: Array<any> = bis.spawnVehicle(newVehPos, newVehDir, className, group)
		const veh: GameObject = vehArgs[0]

		lock(veh, true)
		allowCrewInImmobile(veh, true)
		enableRopeAttach(veh, false)

		newVehPos = bis.relPos(newVehPos, 20, newVehDir + 180)

		units(group).forEach(member => {
			addEventHandler(member, "GetOutMan", (crewVeh: GameObject) => spawn([crewVeh], removeAfterMinute))
			addEventHandler(member, "Killed", onUnitKilled)
			if (USE_HITMARKERS) {
				addEventHandler(member, "Hit", distributeHitmarker)
			}
		})
		addEventHandler(veh, "Hit", (hitVeh: GameObject) => spawn([hitVeh], delayedWheelRepair))
		addEventHandler(veh, "Killed", onUnitKilled)
		addEventHandler(veh, "Hit", addAssistMember)
		setVariable(veh, "listOfAssists", [])
		if (USE_HITMARKERS) {
			addEventHandler(veh, "Hit", distributeHitmarker)
		}
		limitSpeed(veh, 60)
	})

	updateConvoyWaypoint(group)
}

export async function updateConvoyWaypoint(group: Group) {
	const convoySide = side(group)
	const groupPos = position(leader(group))
	const colonyGroups = getConvoyGroupsForSide(convoySide)

	while (waypoints(group).length > 0) {
		deleteWaypoint(group, 0)
	}

	const groupHasVehicle = units(group).some(unit => vehicle(unit) !== unit)
	if (!groupHasVehicle) {
		deleteGroup(group)
		return
	}
	// NOTE: the original also respaced the convoy's vehicles relative to each other here using
	// BIS_fnc_findSafePos; skipped as cosmetic initial-spacing logic that doesn't affect gameplay.

	const towns = getTowns()
	let bestIndex = 0
	let bestFactor = 0
	towns.forEach((town, i) => {
		let townFactor = 100 - (distance2D(town.flag, groupPos) / 1000)
		if (side(town.group) !== convoySide) {
			townFactor += 100
		}

		colonyGroups.forEach(colonyGroup => {
			if (colonyGroup !== grpNull() && waypoints(colonyGroup).length > 0
					&& distance2D(waypointPosition(colonyGroup, 0), position(town.flag)) < 150) {
				townFactor -= 50
			}
		})

		if (townFactor > bestFactor) {
			bestIndex = i
			bestFactor = townFactor
		}
	})

	const moveWaypoint = addWaypoint(group, towns[bestIndex].flag, 20)
	setWaypointType(moveWaypoint, "LOITER")

	setBehaviour(group, "SAFE")
	setFormation(group, "FILE")
}
