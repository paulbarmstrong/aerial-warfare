import { action, addBackpack, addEventHandler, addMagazineTurret, addWeaponTurret, allowCrewInImmobile, allowDamage,
	allTurrets, assignAsCargo, assignAsDriver, assignAsGunner, bis, Config, configFile, createGroupV2, createMarker,
	createUnit, createVehicleCrew, createVehicleV2, deleteVehicle, diag_log, distance2D, fullCrew, GameObject, getDir,
	getPosASL, getText, getVariable, globalChat, group, Group, groupChat, grpNull, gunner, hideObjectV2, isKindOfV2, isPlayer,
	isTouchingGround, joinSilent, land, lock, missionNamespace, moveInCargo, moveInDriver, moveOut, name, nearestObjects, objNull, orderGetIn,
	owner, playableUnits, playSound, position, remoteExec, removeAllActions, removeWeaponTurret, setBehaviour, setCombatMode,
	setDir, setGroupOwner, setMarkerAlpha, setMarkerColor, setMarkerText, setMarkerType, setObjectTexture, setPosASL,
	setSlingLoad, setVariable, setVehicleAmmo, setVehicleLock, side, Side, sleep, spawn, systemChat, unassignVehicle, units, vectorAdd,
	vehicle, weaponsTurret, west } from "@paulbarmstrong/js-to-sqf"
import { AIRCRAFT, getDefaultRiflemanForSide, getJetSpotForSide, getMarkerColorForSide, getSpawnPosForSide,
	getUnitDisplayName, MOD, SLINGABLES, TEXTURE_REPLACEMENTS, TROOP_LANDING_AWARD, TROOP_PARACHUTE_AWARD, USE_HITMARKERS } from "../Constants"
import { AircraftConfig } from "../Types"
import { doneUnloadingTroops, playerAndCrewLocal } from "../Client/PlayerLocal"
import { onRopeAttach, onRopeBreak } from "../Client/Sling"
import { onUnitKilled } from "./EventHandlers"
import { distributeHitmarker } from "./Hit"
import { changeMoney } from "./Money"
import { getTowns } from "./Towns"
import { addAssistMember, onVehicleGetOut, onVehicleHit, onWheeledVehicleHit, trackExplosive,
	vehicleKilled } from "./Vehicle"
import { updateWaypoint } from "./Waypoint"

/** The "Fired" handler for a slung vehicle: keep it topped up with ammo, and follow any
 * launcher or cannon round so its impact can be scored. */
function onSlungVehicleFired(unit: GameObject, weapon: string, muzzle: string, mode: string, ammo: string,
		magazine: string, projectile: GameObject, shooter: GameObject) {
	setVehicleAmmo(unit, 1)
	if (isKindOfV2(weapon, "LauncherCore") || isKindOfV2(weapon, "CannonCore")) {
		spawn([unit, weapon, muzzle, mode, ammo, magazine, projectile, shooter], trackExplosive)
	}
}

function pickSpawnSpot(helipads: Array<GameObject>): GameObject {
	let spawnSpot = helipads[0]
	let bestHeliDistance = 0
	helipads.forEach(helipad => {
		const nearestHelis = nearestObjects(helipad, ["AllVehicles"], 100, true)
		if (nearestHelis.length === 0 || distance2D(nearestHelis[0], helipad) > bestHeliDistance) {
			spawnSpot = helipad
			if (nearestHelis.length > 0) {
				bestHeliDistance = distance2D(nearestHelis[0], helipad)
			}
		}
	})
	return spawnSpot
}

function pickAiAircraft(aiSide: Side, money: number): {aircraft: AircraftConfig, armamentIndex: number, price: number} {
	const candidates = AIRCRAFT.filter(a => a.sides.includes(aiSide) && !(a.jet ?? false) && !(a.disallowedForAi ?? false)
		&& a.mod === MOD)
	let hasBest: boolean = false
	let best: {aircraft: AircraftConfig, armamentIndex: number, price: number} =
		{aircraft: candidates[0], armamentIndex: 0, price: candidates[0].armaments[0].price + candidates[0].price}
	candidates.forEach(aircraft => {
		aircraft.armaments.forEach((armament, armamentIndex) => {
			const price = aircraft.price + armament.price
			if (price <= money * 0.75 && (!hasBest || price > best.price)) {
				hasBest = true
				best = {aircraft, armamentIndex, price}
			}
		})
	})
	return best
}

export function applyTextureReplacements(heli: GameObject, className: string, heliSide: Side) {
	TEXTURE_REPLACEMENTS.filter(t => t.className === className && t.side === heliSide).forEach(t => {
		remoteExec([heli, t.textureIndex, t.texture], setObjectTexture, 0, true)
	})
}

function attachCrewEventHandlers(crewMember: GameObject, owningGroup: any) {
	addEventHandler(crewMember, "Killed", onUnitKilled)
	if (USE_HITMARKERS) {
		addEventHandler(crewMember, "Hit", distributeHitmarker)
	}
	setVariable(crewMember, "warfare_owner", owningGroup)
	setVariable(crewMember, "death_has_been_handled", false)
}

function onHeliFired(unit: GameObject, weapon: string, muzzle: string, mode: string, ammo: string, magazine: string,
		projectile: GameObject, shooter: GameObject) {
	if (isKindOfV2(weapon, "LauncherCore") || isKindOfV2(weapon, "CannonCore")) {
		spawn([unit, weapon, muzzle, mode, ammo, magazine, projectile, shooter], trackExplosive)
	}
}

export async function aiRespawn(man: GameObject) {
	const grp = group(man)
	const respawnSide = side(grp)
	const needSpawn: boolean = getVariable(grp, "warfare_need_spawn") ?? false

	if (isPlayer(man) || !playableUnits().includes(man) || !needSpawn) return
	setVariable(grp, "warfare_need_spawn", false)

	const helipads: Array<GameObject> = getVariable(missionNamespace(), respawnSide === west() ? "BluforHelipads" : "OpforHelipads")

	allowDamage(man, false)
	hideObjectV2(man, false)
	removeAllActions(man)
	setPosASL(man, getPosASL(getSpawnPosForSide(respawnSide)))

	const pick = pickAiAircraft(respawnSide, getVariable(grp, "Money") ?? 0)
	const armament = pick.aircraft.armaments[pick.armamentIndex]

	const isSpawningVarName = respawnSide === west() ? "BluforIsSpawning" : "OpforIsSpawning"
	while (getVariable(missionNamespace(), isSpawningVarName)) {
		sleep(0.5)
	}
	setVariable(missionNamespace(), isSpawningVarName, true, false)

	changeMoney(man, -pick.price)
	setVariable(grp, "lettingOutTroops", false)
	setVariable(grp, "landingAtBase", false)

	let spawnSpot = pickSpawnSpot(helipads)
	let special = "FLY"
	let startHeight = 12
	if (pick.aircraft.jet ?? false) {
		spawnSpot = getJetSpotForSide(respawnSide)
		special = "NONE"
		startHeight = 0
	}

	const heli = createVehicleV2(armament.className, vectorAdd(getPosASL(spawnSpot), [0, 0, startHeight]), [], 0, special)
	allowDamage(heli, false)
	setVariable(heli, "price", pick.price)
	setPosASL(heli, vectorAdd(getPosASL(spawnSpot), [0, 0, startHeight]))
	setDir(heli, getDir(spawnSpot))

	applyTextureReplacements(heli, armament.className, respawnSide)

	createVehicleCrew(heli)
	fullCrew(heli).forEach(entry => {
		const crewMember: GameObject = entry[0]
		if (crewMember !== objNull()) {
			if (entry[1] === "driver") {
				deleteVehicle(crewMember)
			} else {
				allowDamage(crewMember, false)
			}
		}
	})

	assignAsDriver(man, heli)
	moveInDriver(man, heli)

	addEventHandler(heli, "Hit", onVehicleHit)
	addEventHandler(heli, "GetOut", onVehicleGetOut)
	lock(heli, true)
	setVehicleLock(heli, "LOCKED")

	const cargoCrewCount = bis.crewCount(armament.className, true) - bis.crewCount(armament.className, false)
	for (let i = 0; i < cargoCrewCount; i++) {
		const troop = createUnit(grp, getDefaultRiflemanForSide(respawnSide), spawnSpot, [], 0, "NONE")
		assignAsCargo(troop, heli)
		moveInCargo(troop, heli)
		setVariable(troop, "SoldierType", "capture")
		if (vehicle(troop) !== heli) {
			deleteVehicle(troop)
		}
	}

	fullCrew(heli).forEach(entry => {
		const crewMember: GameObject = entry[0]
		if (crewMember !== objNull() && crewMember !== man) {
			attachCrewEventHandlers(crewMember, grp)
			joinSilent([crewMember], grp)
		}
	})
	setVariable(heli, "listOfAssists", [])
	addEventHandler(heli, "Hit", addAssistMember)
	addEventHandler(heli, "Killed", vehicleKilled)
	addEventHandler(heli, "Fired", onHeliFired)
	if (USE_HITMARKERS) {
		addEventHandler(heli, "Hit", distributeHitmarker)
	}
	setVariable(heli, "death_has_been_handled", false)
	allowCrewInImmobile(heli, true)

	const genericHeliName = getText(new Config(configFile(), "CfgVehicles", armament.className, "displayName"))
	remoteExec([`${name(man)}[${genericHeliName}] spawned`], globalChat, 0, false)

	sleep(1)
	allowDamage(heli, true)

	setVariable(grp, "landingAtBase", false)
	setVariable(grp, "lettingOutTroops", false)
	setVariable(grp, "warfare_need_spawn", true)
	spawn([grp], updateWaypoint)

	setVariable(missionNamespace(), isSpawningVarName, false, false)
	setVariable(man, "warfare_respawn_lock", false)
}

export async function aiLandAtBase(man: GameObject) {
	const grp = group(man)
	const heli = vehicle(man)

	if (playableUnits().includes(man) && !(getVariable(grp, "lettingOutTroops") ?? false) && !(getVariable(grp, "landingAtBase") ?? false)) {
		setVariable(grp, "landingAtBase", true)

		land(heli, "LAND")

		let timePassed = 0
		while (!isTouchingGround(heli) && timePassed < 45) {
			sleep(1)
			timePassed += 1
		}

		hideObjectV2(man, false)
		const heliPrice: number = getVariable(heli, "price") ?? 0
		remoteExec([man, heliPrice], changeMoney, man, false)
		const crewMembers: Array<GameObject> = fullCrew(heli).map(entry => entry[0]).filter(u => u !== objNull())
		deleteVehicle(heli)
		crewMembers.forEach(crewMember => {
			if (!playableUnits().includes(crewMember)) {
				deleteVehicle(crewMember)
			}
		})

		setVariable(grp, "landingAtBase", false)

		spawn([man], aiRespawn)
	}
}

async function letOutCargoTroopsAtTown(player: GameObject, townIndex: number, award: number, message: string) {
	const heli = vehicle(player)
	const towns = getTowns()
	const town = towns[townIndex]

	const cargoCrew: Array<GameObject> = fullCrew(heli).map(entry => entry[0])
		.filter(u => u !== objNull() && (getVariable(u, "SoldierType") ?? "") === "capture")

	let turretSlotIndex = 0
	let heliManIndex = 0
	while (heliManIndex < cargoCrew.length && turretSlotIndex < town.turrets.length) {
		while (turretSlotIndex < town.turrets.length && gunner(town.turrets[turretSlotIndex]) !== objNull()) {
			turretSlotIndex += 1
		}
		if (turretSlotIndex < town.turrets.length) {
			const man = cargoCrew[heliManIndex]
			const turret = town.turrets[turretSlotIndex]

			unassignVehicle(man)
			moveOut(man)
			joinSilent([man], town.group)
			assignAsGunner(man, turret)
			orderGetIn([man], true)

			remoteExec([man], unassignVehicle, player, false)
			remoteExec([man], moveOut, player, false)
			remoteExec([[man], town.group], joinSilent, player, false)
			remoteExec([man, turret], assignAsGunner, player, false)
			remoteExec([[man], true], orderGetIn, player, false)

			remoteExec([man, "B_Parachute"], addBackpack, player, false)
			remoteExec(["pullNotification"], playSound, player, false)
			remoteExec([player, `${message} | +$${award}`], groupChat, player, false)
			changeMoney(player, award)

			sleep(1.25)
		}
		heliManIndex += 1
	}
}

export async function aiTroopLanding(man: GameObject) {
	const grp = group(man)
	const heli = vehicle(man)

	if (playableUnits().includes(man) && !getVariable(grp, "lettingOutTroops") && !getVariable(grp, "landingAtBase")) {
		setVariable(grp, "lettingOutTroops", true)

		land(heli, "LAND")

		let timePassed = 0
		while (!isTouchingGround(heli) && timePassed < 45) {
			sleep(1)
			timePassed += 1
		}

		const towns = getTowns()
		let closestTownIndex = 0
		let closestDistance = 999999999
		towns.forEach((town, i) => {
			const d = distance2D(heli, town.flag)
			if (d < closestDistance) {
				closestTownIndex = i
				closestDistance = d
			}
		})

		letOutCargoTroopsAtTown(man, closestTownIndex, TROOP_PARACHUTE_AWARD, "Parachute insertion")

		setVariable(grp, "lettingOutTroops", false)
		spawn([grp], updateWaypoint)
	}
}

export async function dropTroops(player: GameObject, townIndex: number) {
	letOutCargoTroopsAtTown(player, townIndex, TROOP_PARACHUTE_AWARD, "Parachute insertion")
}

export async function letTroopsOut(player: GameObject, townIndex: number) {
	letOutCargoTroopsAtTown(player, townIndex, TROOP_LANDING_AWARD, "Landing zone insertion")
	setVariable(vehicle(player), "touching_ground", true)
	remoteExec([], doneUnloadingTroops, player, false)
}

export async function spawnPlayerAircraft(player: GameObject, heliIndex: number, armamentIndex: number, slingIndex: number) {
	const playerSide = side(group(player))
	const aircraft = AIRCRAFT.filter(a => a.sides.includes(playerSide) && a.mod === MOD)[heliIndex]
	if (aircraft === undefined) return
	const armament = aircraft.armaments[armamentIndex]
	if (armament === undefined) return
	const slingablesList = SLINGABLES.filter(s => s.sides.includes(playerSide) && s.mod === MOD)

	const helipads: Array<GameObject> = getVariable(missionNamespace(), playerSide === west() ? "BluforHelipads" : "OpforHelipads")
	const spawnSpot = (aircraft.jet ?? false) ? getJetSpotForSide(playerSide) : pickSpawnSpot(helipads)

	const isSpawningVarName = playerSide === west() ? "BluforIsSpawning" : "OpforIsSpawning"
	while (getVariable(missionNamespace(), isSpawningVarName)) {
		sleep(0.5)
	}
	setVariable(missionNamespace(), isSpawningVarName, true, false)

	// The buying player's own machine creates and locally simulates the aircraft (and its crew), so it flies
	// smoothly for them; the server just waits for that machine to report back what it created.
	remoteExec([spawnSpot, heliIndex, armamentIndex, slingIndex], playerAndCrewLocal, player, false)

	while (getVariable(player, "pull_the_heli") === undefined) {
		sleep(0.5)
	}
	const heli: GameObject = getVariable(player, "pull_the_heli")
	const heliGroup: Group = getVariable(player, "pull_heli_group")

	fullCrew(heli).forEach(entry => {
		const crewMember: GameObject = entry[0]
		if (crewMember !== objNull() && !isPlayer(crewMember)) {
			attachCrewEventHandlers(crewMember, group(player))
			addEventHandler(crewMember, "Hit", distributeHitmarker)
		}
	})

	addEventHandler(heli, "RopeBreak", onRopeBreak)
	addEventHandler(heli, "RopeAttach", onRopeAttach)
	setVariable(heli, "listOfAssists", [])
	setVariable(heli, "warfare_owner", group(player))
	setVariable(heli, "death_has_been_handled", false)
	setVariable(heli, "touching_ground", true)
	if (USE_HITMARKERS) {
		addEventHandler(heli, "Hit", distributeHitmarker)
	}
	addEventHandler(heli, "Killed", vehicleKilled)
	addEventHandler(heli, "Hit", addAssistMember)
	addEventHandler(heli, "Fired", onHeliFired)
	addEventHandler(heli, "Hit", onVehicleHit)
	addEventHandler(heli, "GetOut", onVehicleGetOut)
	setCombatMode(heliGroup, "RED")

	if (armament.manualFire) {
		action(heli, ["ManualFire", heli])
		setBehaviour(heliGroup, "CARELESS")
	}

	let carDisplayName = ""
	if (slingIndex > 0) {
		sleep(0.2)

		const slingable = slingablesList[slingIndex - 1]
		const vehGroup = createGroupV2(playerSide, true)
		const vehArgs: Array<any> = bis.spawnVehicle(vectorAdd(position(spawnSpot), [0, 0, 200]), getDir(spawnSpot), slingable.className, vehGroup)
		const veh: GameObject = vehArgs[0]
		setPosASL(veh, vectorAdd(getPosASL(heli), [0, 0, -5]))

		carDisplayName = getUnitDisplayName(veh)

		if (slingable.antiAir) {
			const turretPath = allTurrets(veh)[0]
			removeWeaponTurret(veh, weaponsTurret(veh, turretPath)[0], turretPath)
			addWeaponTurret(veh, "missiles_titan_static", turretPath)
			addMagazineTurret(veh, "1Rnd_GAA_missiles", turretPath)
		}

		lock(veh, true)
		allowCrewInImmobile(veh, true)
		setGroupOwner(vehGroup, owner(player))

		setSlingLoad(heli, veh)

		units(vehGroup).forEach(unit => {
			addEventHandler(unit, "Killed", onUnitKilled)
			if (USE_HITMARKERS) {
				addEventHandler(unit, "Hit", distributeHitmarker)
			}
			allowDamage(unit, false)
			setVariable(unit, "warfare_owner", group(player))
			setVariable(unit, "death_has_been_handled", false)
		})
		addEventHandler(veh, "Hit", onWheeledVehicleHit)
		addEventHandler(veh, "Fired", onSlungVehicleFired)
		addEventHandler(veh, "Killed", vehicleKilled)
		addEventHandler(veh, "Hit", addAssistMember)
		addEventHandler(veh, "GetOut", onVehicleGetOut)
		setVariable(veh, "listOfAssists", [])
		setVariable(veh, "warfare_owner", group(player))
		setVariable(veh, "death_has_been_handled", false)
		if (USE_HITMARKERS) {
			addEventHandler(veh, "Hit", distributeHitmarker)
		}

		const slingMarkerTally: number = getVariable(missionNamespace(), "SlingMarkerTally")
		const carMarker = `sling_vehicle_marker_${slingMarkerTally}`
		createMarker(carMarker, position(veh))
		setMarkerType(carMarker, "mil_box")
		setMarkerText(carMarker, `${name(player)}'s ${carDisplayName}`)
		setMarkerColor(carMarker, getMarkerColorForSide(playerSide))
		setMarkerAlpha(carMarker, 0)

		const slingVehicles: Array<GameObject> = getVariable(missionNamespace(), "SlingVehicleArray") ?? []
		slingVehicles.push(veh)
		setVariable(missionNamespace(), "SlingVehicleArray", slingVehicles)
		const slingMarkers: Array<string> = getVariable(missionNamespace(), "SlingMarkerArray") ?? []
		slingMarkers.push(carMarker)
		setVariable(missionNamespace(), "SlingMarkerArray", slingMarkers)
		setVariable(missionNamespace(), "SlingMarkerTally", slingMarkerTally + 1)
	}

	const genericHeliName = getText(new Config(configFile(), "CfgVehicles", armament.className, "displayName"))
	let slingPrice = 0
	if (slingIndex > 0) {
		slingPrice = slingablesList[slingIndex - 1].price
	}
	remoteExec([player, `Purchased ${genericHeliName} and armaments | -$${aircraft.price + armament.price}`], groupChat, player, false)
	if (slingIndex > 0) {
		remoteExec([player, `Purchased ${carDisplayName} | -$${slingPrice}`], groupChat, player, false)
	}
	remoteExec([`${name(player)}[${genericHeliName}] spawned`], globalChat, 0, false)

	setVariable(missionNamespace(), isSpawningVarName, false, false)
}

export function getWarfareOwnerGroup(unit: GameObject): Group {
	return getVariable(unit, "warfare_owner") ?? grpNull
}