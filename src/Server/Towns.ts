import { addEventHandler, alive, allowDamage, assignAsGunner, attachTo, bis, createGroup, createGroupV2, createMarker, createVehicle, deleteVehicle, distance2D, east, GameObject, getDir, getMarkerColor, getMarkerPos, getVariable, globalChat, group, Group, groupChat, grpNull, gunner, hideObject, independent, leader, markerColor, missionNamespace, moveInGunner, nearestObject, nearestObjects, position, PositionAGLS, publicVariable, remoteExec, setDamage, setDir, setMarkerColor, setMarkerText, setMarkerType, setPos, setVariable, setVectorDir, setVehicleAmmo, side, Side, sleep, spawn, str, TurretPath, west } from "js-to-sqf"
import { CONTROL_NEARBY_LZ, getMarkerColorForSide, getTownFlagClassNameForSide, INCOME_PER_TOWN_TROOP, INITIAL_OCCUPATION, INITIAL_TOWN_TROOPS_DELAY_SECONDS, MINIMUM_INCOME, RIFLEMEN, TOWN_CAPTURE_AWARD, TOWNS_CONFIG, USE_HITMARKERS, USE_RHS } from "../Constants";
import { Town } from "../Types";
import { distributeHitmarker } from "./Hit";
import { changeMoney } from "./Money";
import { onUnitKilled } from "./EventHandlers";

export function setUpTowns() {
	setVariable(missionNamespace(), "BluforHelipads", nearestObjects(getMarkerPos("bluforMarker"), ["HeliH"], 200, true))
	setVariable(missionNamespace(), "OpforHelipads", nearestObjects(getMarkerPos("opforMarker"), ["HeliH"], 200, true))
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
			addEventHandler(turret, "GetIn", (turret: GameObject, role: string, man: GameObject) => onGetInTurret(turret, man, townIndex))
			addEventHandler(turret, "Fired", () => setVehicleAmmo(turret, 0))
		})

		const marker = createMarker(`townMarker_${townIndex}`, position(townConfig.flag))
		setMarkerText(marker, `${townConfig.name}: 0/${turrets.length}`)
		setMarkerType(marker, "mil_flag")
		setMarkerColor(marker, "colorWhite")
		setVectorDir(townConfig.flag, [0, 0, 0])
		
		const helipad: GameObject = nearestObject(flagPos, "HeliH")

		return {
			...townConfig,
			marker,
			helipad,
			turretHolder,
			turrets,
			group: grpNull()
		}
	})

	setVariable(missionNamespace, "Towns", towns, true)

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
			const {closestTowns, side} = entry
			const town: Town = closestTowns[i]
			if (town.group !== grpNull()) {
				const {closestTowns, side} = entry
				const newGroup: Group = createGroupV2(side, true)
				town.group = newGroup
				setCombatMode(newGroup, "RED")
				town.turrets.forEach(turret => {
					const riflemanClassName = RIFLEMEN.find(r => r.side === side && r.mod === (USE_RHS ? "RHS" : undefined))!.className
					const newUnit: GameObject = createUnit(newGroup, riflemanClassName, position(turret), [], 0, "NONE")
					addEventHandler(newUnit, "Killed", onKilled)
					if (USE_HITMARKERS) {
						addEventHandler(newUnit, "Hit", distributeHitmarker)
					}
					assignAsGunner(newUnit, turret)
					moveInGunner(newUnit, turret)
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

				for (let j = 0; j < town.turrets.length && j < maxUnits; j++) {
					const turret: GameObject = town.turrets[j]
					const riflemanClassName = RIFLEMEN.find(r => r.side === independent() && r.mod === (USE_RHS ? "RHS" : undefined))!.className
					const newUnit: GameObject = createUnit(newGroup, riflemanClassName, position(turret), [], 0, "NONE")
					setSkill(newUnit, 0.2)
					addEventHandler(newUnit, "Killed", onUnitKilled)
					if (USE_HITMARKERS) {
						addEventHandler(newUnit, "Hit", distributeHitmarker)
					}
					assignAsGunner(newUnit, turret)
					moveInGunner(newUnit, turret)
					sleep(INITIAL_TOWN_TROOPS_DELAY_SECONDS)
				}
			}
		})
	}
	setTowns(towns)
}

function onGetInTurret(turret: GameObject, man: GameObject, townIndex: number) {
	const towns: Array<Town> = getTowns()
	const town: Town = towns[townIndex]
	setDamage(man, 0)
	setVariable(man, "warfare_owner", grpNull)
	refreshTown(town, man)
}

export function refreshTown(town: Town, newUnit: GameObject | undefined) {
	const townUnits: Array<GameObject> = town.turrets.map(turret => gunner(turret)).filter(unit => unit !== undefined)
	const townSide: Side | undefined = townUnits.length > 0 ? side(townUnits[0]) : undefined
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
			town.group = grpNull
		}

		if (newUnit !== undefined) {
			const owner: GameObject = leader(getVariable(newUnit, "warfare_owner"))
			remoteExec([owner, `Captured ${town.name} | +$${TOWN_CAPTURE_AWARD}`], groupChat, owner, false)
			changeMoney(owner, TOWN_CAPTURE_AWARD)
			remoteExec([newUnit, `${town.name} has been captured by the ${townSide}`], globalChat, undefined, true)
		}

		// If all towns are friendly, the mission should end
		const allFriendly: boolean = getTowns().filter(town => markerColor(town.marker) !== getMarkerColorForSide(townSide)).length === 0
		if (allFriendly && townSide !== independent()) {
			bis.endMissionServer("EveryoneWon")
		}
		setTown(town)
	}

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
	return town.turrets.filter(turret => alive(gunner(turret))).length
}
