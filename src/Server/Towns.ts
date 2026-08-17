import { addEventHandler, alive, allowDamage, assignAsGunner, attachTo, bis, createGroupV2, createMarker, createUnit, createVehicle, deleteVehicle, distance2D, driver, east, findV2, GameObject, getDir, getMarkerColor, getMarkerPos, getVariable, globalChat, Group, groupChat, grpNull, hideObject, independent, leader, markerColor, missionNamespace, moveInGunner, nearestObject, nearestObjects, objNull, playableUnits, position, PositionAGLS, remoteExec, round, setCombatMode, setDamage, setDir, setMarkerColor, setMarkerText, setMarkerType, setPos, setSkill, setVariable, setVectorDir, setVehicleAmmo, side, Side, sideUnknown, sleep, spawn, typeOf, vehicle, waypointPosition, waypoints, west } from "@paulbarmstrong/js-to-sqf"
import { CONTROL_NEARBY_LZ, getMarkerColorForSide, getTownFlagClassNameForSide, INCOME_PER_TOWN_TROOP, INITIAL_OCCUPATION, INITIAL_TOWN_TROOPS_DELAY_SECONDS, MINIMUM_INCOME, MOD, RIFLEMEN, TOWN_CAPTURE_AWARD, TOWN_CLEAR_AWARD, TOWNS_CONFIG, USE_HITMARKERS } from "../Constants";
import { Town } from "../Types";
import { distributeHitmarker } from "./Hit";
import { changeMoney } from "./Money";
import { onUnitKilled } from "./EventHandlers";
import { getWarfareOwnerGroup } from "./Spawn";
import { getConvoyGroupsForSide, updateConvoyWaypoint } from "./Convoy";

export function setUpTowns() {
	setVariable(missionNamespace(), "BluforHelipads", nearestObjects(getMarkerPos("bluforMarker"), ["HeliH"], 200, true), true)
	setVariable(missionNamespace(), "OpforHelipads", nearestObjects(getMarkerPos("opforMarker"), ["HeliH"], 200, true), true)
	const towns: Array<Town> = TOWNS_CONFIG.map((townConfig, townIndex) => {
		const flagPos: PositionAGLS = position(townConfig.flag)

		const turretHolder: GameObject = createVehicle("Land_InfoStand_V2_F", flagPos);
		hideObject(turretHolder)

		const turrets: Array<GameObject> = nearestObjects(flagPos, ["StaticWeapon"], townConfig.size)
		turrets.forEach(turret => {
			allowDamage(turret, false)
			const dir: number = getDir(turret)
			attachTo(turret, turretHolder)
			setDir(turret, dir)
			// An event handler's code is run by the engine long after this loop is gone, so it
			// can only use what it is handed. The town index has to travel on the turret.
			setVariable(turret, "townIndex", townIndex)
			addEventHandler(turret, "GetIn", onTurretGetIn)
			addEventHandler(turret, "Fired", onTurretFired)
		})

		const marker = createMarker(`townMarker_${townIndex}`, position(townConfig.flag))
		setMarkerText(marker, `${townConfig.name}: 0/${turrets.length}`)
		setMarkerType(marker, "mil_flag")
		setMarkerColor(marker, "colorWhite")
		setVectorDir(townConfig.flag, [0, 0, 0])
		
		const helipad: GameObject = nearestObject(flagPos, "HeliH")

		return {
			name: townConfig.name,
			size: townConfig.size,
			flag: townConfig.flag,
			marker,
			helipad,
			turretHolder,
			turrets,
			units: turrets.map(() => objNull()),
			group: grpNull()
		}
	})

	setVariable(missionNamespace(), "Towns", towns, true)

	spawn([], putOriginalTownMen)
}

function putOriginalTownMen() {
	const bluforHelipad: GameObject = getVariable(missionNamespace(), "BluforHelipads")[0]
	const opforHelipad: GameObject = getVariable(missionNamespace(), "OpforHelipads")[0]
	const towns = getTowns()

	const townDistances = towns.map((town, townIndex) => ({
		townIndex,
		bluforDistance: distance2D(town.flag, bluforHelipad),
		opforDistance: distance2D(town.flag, opforHelipad)
	}))

	const bluforClosestTowns: Array<Town> = townDistances.sort((a,b) => a.bluforDistance - b.bluforDistance).map(x => towns[x.townIndex])
	const opforClosestTowns: Array<Town> = townDistances.sort((a,b) => a.opforDistance - b.opforDistance).map(x => towns[x.townIndex])
	const avgTownDistance: number = townDistances.map(x => (x.bluforDistance + x.opforDistance) / 2).reduce((a,b) => a + b) / townDistances.length

	// Give blufor and opfor [_controlNearbyLZ] nearby towns
	for (let i = 0; i < CONTROL_NEARBY_LZ; i++) {
		[
			{closestTowns: bluforClosestTowns, side: west()},
			{closestTowns: opforClosestTowns, side: east()}
		].forEach(entry => {
			const town: Town = entry.closestTowns[i]
			if (town.group === grpNull()) {
				const side = entry.side
				const newGroup: Group = createGroupV2(side, true)
				town.group = newGroup
				setCombatMode(newGroup, "RED")
				town.turrets.forEach((turret, j) => {
					const riflemanClassName = RIFLEMEN.find(r => r.side === side && r.mod === MOD)!.className
					const newUnit: GameObject = createUnit(newGroup, riflemanClassName, position(turret), [], 0, "NONE")
					addEventHandler(newUnit, "Killed", onUnitKilled)
					if (USE_HITMARKERS) {
						addEventHandler(newUnit, "Hit", distributeHitmarker)
					}
					assignAsGunner(newUnit, turret)
					moveInGunner(newUnit, turret)
					town.units[j] = newUnit
					sleep(INITIAL_TOWN_TROOPS_DELAY_SECONDS)
				})
			}
		})
	}
	
	// If InitialOccupation is greater than 0, then make all empty towns independent
	if (INITIAL_OCCUPATION > 0) {
		towns.forEach(town => {
			if (town.group === grpNull()) {
				let maxUnits: number = 2
				if (INITIAL_OCCUPATION === 2) {
					maxUnits = 30
				} else if (INITIAL_OCCUPATION === 3) {
					if (distance2D(town.flag, bluforHelipad) < distance2D(town.flag, opforHelipad)) {
						maxUnits = round(8 * distance2D(town.flag, bluforHelipad) / avgTownDistance) - 4
					} else {
						maxUnits = round(8 * distance2D(town.flag, opforHelipad) / avgTownDistance) - 4
					}
				}

				const newGroup: Group = createGroupV2(independent(), true)
				town.group = newGroup
				setCombatMode(newGroup, "RED")

				// Leave AA turrets unmanned where possible, only filling them once every
				// non-AA turret is already spoken for and the quota still isn't met.
				const numAATurrets: number = town.turrets.filter(turret => findV2(typeOf(turret), "AA") > -1).length
				let numAANeedFill: number = maxUnits - (town.turrets.length - numAATurrets)
				let numFilled = 0
				let j = 0
				while (j < town.turrets.length && numFilled < maxUnits) {
					const turret: GameObject = town.turrets[j]
					const turretIsAA: boolean = findV2(typeOf(turret), "AA") > -1
					if (!turretIsAA || numAANeedFill > 0) {
						const riflemanClassName = RIFLEMEN.find(r => r.side === independent() && r.mod === MOD)!.className
						const newUnit: GameObject = createUnit(newGroup, riflemanClassName, position(turret), [], 0, "NONE")
						setSkill(newUnit, 0.2)
						addEventHandler(newUnit, "Killed", onUnitKilled)
						if (USE_HITMARKERS) {
							addEventHandler(newUnit, "Hit", distributeHitmarker)
						}
						assignAsGunner(newUnit, turret)
						moveInGunner(newUnit, turret)
						town.units[j] = newUnit
						numFilled += 1
						if (turretIsAA) {
							numAANeedFill -= 1
						}
						sleep(INITIAL_TOWN_TROOPS_DELAY_SECONDS)
					}
					j += 1
				}
			}
		})
	}
	setTowns(towns)
}

// Event handler entry points — see the note in Server/Vehicle.ts. The town index is read
// back off the turret it was stashed on in setUpTowns.

function onTurretGetIn(turret: GameObject, role: string, man: GameObject) {
	onGetInTurret(turret, man, getVariable(turret, "townIndex"))
}

function onTurretFired(turret: GameObject) {
	setVehicleAmmo(turret, 0)
}

function onGetInTurret(turret: GameObject, man: GameObject, townIndex: number) {
	const towns: Array<Town> = getTowns()
	const town: Town = towns[townIndex]
	const turretIndex: number = town.turrets.findIndex(x => x === turret)
	setDamage(man, 0)
	setVariable(man, "warfare_owner", grpNull())
	town.units[turretIndex] = man
	setTowns(towns)
	refreshTown(town, man)
}

/** A unit only counts as occupying a turret once it has actually walked there and gotten in -
 * being assigned/reserved (town.units[i]) isn't enough, since that happens the moment they're
 * tasked with the turret, before they've arrived. */
export function getTownOccupants(town: Town): Array<GameObject> {
	return town.units.filter((unit, i) => unit !== objNull() && alive(unit) && vehicle(unit) === town.turrets[i])
}

export function refreshTown(town: Town, newUnit: GameObject, killer: GameObject = objNull()) {
	const previousSide: Side = side(town.group)
	const townUnits: Array<GameObject> = getTownOccupants(town)
	let townSide: Side = sideUnknown()
	if (townUnits.length > 0) {
		townSide = side(townUnits[0])
	}
	setMarkerText(town.marker, `${town.name}: ${townUnits.length}/${town.turrets.length}`)

	if (getMarkerColor(town.marker) !== getMarkerColorForSide(townSide)) {
		setMarkerColor(town.marker, getMarkerColorForSide(townSide))

		const oldFlag: GameObject = town.flag
		const flagPos: PositionAGLS = position(oldFlag)
		deleteVehicle(oldFlag)
		const newFlag = createVehicle(getTownFlagClassNameForSide(townSide), flagPos)
		setPos(newFlag, flagPos)
		town.flag = newFlag

		if (townUnits.length === 0) {
			town.group = grpNull()

			// If a playable unit's side just cleared out the last defender, reward them
			if (killer !== objNull() && previousSide !== side(killer)) {
				const killerOwner: GameObject = leader(getWarfareOwnerGroup(killer))
				const clearer: GameObject = killerOwner !== objNull() ? killerOwner : driver(vehicle(killer))
				if (playableUnits().includes(clearer)) {
					remoteExec([clearer, `Cleared enemy landing zone ${town.name} | +$${TOWN_CLEAR_AWARD}`], groupChat, clearer, false)
					changeMoney(clearer, TOWN_CLEAR_AWARD)
				}
			}
		}

		if (newUnit !== objNull()) {
			const owner: GameObject = leader(getWarfareOwnerGroup(newUnit))
			remoteExec([owner, `Captured ${town.name} | +$${TOWN_CAPTURE_AWARD}`], groupChat, owner, false)
			changeMoney(owner, TOWN_CAPTURE_AWARD)
			remoteExec([newUnit, `${town.name} has been captured by the ${townSide}`], globalChat, 0, true)

			// Tell any convoys already headed to this town to roll out now that it's friendly
			;[...getConvoyGroupsForSide(west()), ...(getConvoyGroupsForSide(east()))].forEach(convoyGroup => {
				if (convoyGroup !== grpNull() && waypoints(convoyGroup).length > 0
						&& distance2D(waypointPosition(convoyGroup, 0), town.flag) < 150) {
					spawn([convoyGroup], updateConvoyWaypoint)
				}
			})
		}

		// If all towns are friendly, the mission should end
		const allFriendly: boolean = getTowns().filter(town => markerColor(town.marker) !== getMarkerColorForSide(townSide)).length === 0
		if (allFriendly && townSide !== independent()) {
			bis.endMissionServer("EveryoneWon")
		}
		setTown(town)
	}

	const towns: Array<Town> = getVariable(missionNamespace(), "Towns")
	const numBluforTownTroops: number = towns.flatMap(t => getTownOccupants(t)).filter(unit => side(unit) === west()).length
	const numOpforTownTroops: number = towns.flatMap(t => getTownOccupants(t)).filter(unit => side(unit) === east()).length
	setVariable(missionNamespace(), "BluforIncome", MINIMUM_INCOME + (numBluforTownTroops * INCOME_PER_TOWN_TROOP), true)
	setVariable(missionNamespace(), "OpforIncome", MINIMUM_INCOME + (numOpforTownTroops * INCOME_PER_TOWN_TROOP), true)
}

export function getTowns(): Array<Town> {
	return getVariable(missionNamespace(), "Towns")
}

export function setTowns(towns: Array<Town>) {
	return setVariable(missionNamespace(), "Towns", towns, true)
}

export function setTown(town: Town) {
	const towns: Array<Town> = getTowns()
	const townIndex: number = towns.findIndex(x => x.name === town.name)
	towns[townIndex] = town
	setTowns(towns)
}

export function getTownNumAlive(town: Town): number {
	return getTownOccupants(town).length
}
