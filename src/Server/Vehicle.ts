import { alive, allowDamage, assignAsCargo, Config, configFile, deleteVehicle, distance, driver, fullCrew, GameObject,
	getAllHitPointsDamage, getDammage, getText, getVariable, group, groupChat, groupId, gunner, isKindOfV3, isNull,
	isObjectHidden, isPlayer, leader, moveInCargo, name, nearestObjects, PositionAGLS, playableUnits, position, remoteExec,
	setDamage, setFuel, setHitIndex, setMarkerAlpha, setVariable, side, sleep, systemChat, typeOf, unassignVehicle, vehicle,
	waypoints } from "@paulbarmstrong/js-to-sqf"
import { displayHitmarker } from "../Client/Hitmarker"
import { BIG_BOMB_CLASSNAMES } from "../Constants"
import { onUnitKilled } from "./EventHandlers"
import { changeMoney } from "./Money"

export async function keepEngineAlive(vehicle: GameObject) {
	const info: Array<any> = getAllHitPointsDamage(vehicle)
	const damageNames: Array<string> = info[1]
	const damageList: Array<number> = info[2]

	for (let i = 0; i < damageList.length; i++) {
		const damageName = damageNames[i]
		if (damageList[i] > 0.5) {
			if (damageName.includes("engine") || damageName.includes("avionics") || damageName.includes("rotor")) {
				setHitIndex(vehicle, i, 0.5, false)
			} else if (damageName === "fuel_hit") {
				setHitIndex(vehicle, i, 0, false)
			}
		}
	}
}

export async function delayedWheelRepair(vehicle: GameObject) {
	const info: Array<any> = getAllHitPointsDamage(vehicle)
	const damageNames: Array<string> = info[1]
	const damageList: Array<number> = info[2]

	const thingsToFix: Array<number> = []
	for (let i = 0; i < damageList.length; i++) {
		const damageName = damageNames[i]
		if (damageList[i] > 0.6 && (damageName.includes("wheel") || damageName.includes("engine") || damageName.includes("fuel"))) {
			thingsToFix.push(i)
		}
	}

	sleep(60)

	if (alive(vehicle)) {
		thingsToFix.forEach(i => setHitIndex(vehicle, i, 0.6, false))

		if (driver(vehicle) !== undefined && waypoints(group(driver(vehicle))).length > 0) {
			setFuel(vehicle, 1)
		}
	}
}

export async function trackExplosive(unit: GameObject, weapon: string, muzzle: string, mode: string, ammo: string,
		magazine: string, projectile: GameObject, shooter: GameObject) {
	let range = 6
	if (isKindOfV3(weapon, "LauncherCore", new Config(configFile(), "CfgWeapons"))) {
		range = 10
	}
	if (BIG_BOMB_CLASSNAMES.includes(weapon)) {
		range = 50
	}

	let pos: PositionAGLS = position(projectile)
	while (!isNull(projectile)) {
		pos = position(projectile)
		sleep(0.05)
	}

	const turrets: Array<GameObject> = nearestObjects(pos, ["StaticWeapon"], range)
	turrets.forEach(turret => {
		const turretGunner = gunner(turret)
		if (alive(turretGunner)) {
			if (playableUnits().includes(driver(vehicle(shooter))) && side(group(shooter)) !== side(group(turretGunner))) {
				remoteExec([], displayHitmarker, shooter, false)
			}

			const explosionDamage = 1.7 - (distance(pos, position(turretGunner)) / range)
			const newDamage = getDammage(turretGunner) + explosionDamage
			if (newDamage > 1) {
				onUnitKilled(turretGunner, shooter)
			}
			setDamage(turretGunner, newDamage)
		}
	})
}

export async function removeAfterMinute(vehicle: GameObject) {
	sleep(60)
	deleteVehicle(vehicle)
}

export async function addAssistMember(veh: GameObject, hitter: GameObject) {
	const hitterVeh = vehicle(hitter)
	let assistOwner: GameObject = leader(getVariable(hitterVeh, "warfare_owner"))
	if (isPlayer(driver(hitterVeh))) {
		assistOwner = driver(hitterVeh)
	}

	const listOfAssists: Array<GameObject> = getVariable(veh, "listOfAssists") ?? []
	if (!listOfAssists.includes(assistOwner)) {
		listOfAssists.push(assistOwner)
		setVariable(veh, "listOfAssists", listOfAssists)
	}
}

export async function getOutPunish(veh: GameObject, role: string, man: GameObject) {
	sleep(0.5)

	if (!isObjectHidden(man) && !isPlayer(man) && vehicle(man) === man && veh !== undefined) {
		const soldierType: string | undefined = getVariable(man, "SoldierType")
		if (soldierType === "capture") {
			remoteExec([man], unassignVehicle, veh, false)
			remoteExec([man, veh], assignAsCargo, veh, false)
			remoteExec([man, veh], moveInCargo, veh, false)
		} else {
			if (playableUnits().includes(man)) {
				remoteExec([man, -100], changeMoney, man, false)
			}
			allowDamage(man, true)
			setDamage(man, 1)
		}
	}
}

export async function vehicleKilled(veh: GameObject, killer: GameObject) {
	const killerSide = side(group(killer))

	const crewMembers: Array<GameObject> = fullCrew(veh).map((entry: Array<any>) => entry[0]).filter((u: GameObject) => u !== undefined)
	if (crewMembers.length > 0) {
		const unitSide = side(group(crewMembers[0]))
		let killCount = 0
		crewMembers.forEach(member => {
			const hasBeenHandled: boolean | undefined = getVariable(member, "death_has_been_handled")
			if (hasBeenHandled === undefined || !hasBeenHandled) {
				setVariable(member, "death_has_been_handled", true)
				allowDamage(member, true)
				remoteExec([member, true], allowDamage, member, false)
				killCount += 1
			}
		})

		onUnitKilled(veh, killer)

		const award = killCount * 50

		if (unitSide !== killerSide) {
			if (playableUnits().includes(driver(vehicle(killer)))) {
				const owner = driver(vehicle(killer))
				remoteExec([owner, `Neutralized ${killCount}x enemy occupants | +$${award}`], groupChat, owner, false)
				changeMoney(owner, award)
			} else if (playableUnits().includes(leader(getVariable(killer, "warfare_owner")))) {
				const owner = leader(getVariable(killer, "warfare_owner"))
				const killerDisplayName = getText(new Config(configFile(), "CfgVehicles", typeOf(vehicle(killer)), "displayName"))
				remoteExec([owner, `Your ${killerDisplayName} neutralized ${killCount}x enemy occupants | +$${award}`], groupChat, owner, false)
				changeMoney(owner, award)
			}
		}
	} else {
		onUnitKilled(veh, killer)
	}

	if (driver(veh) !== undefined) {
		allowDamage(driver(veh), true)
		remoteExec([driver(veh), true], allowDamage, driver(veh), false)
	}
}

export async function deathMessage(unit: GameObject, killer: GameObject) {
	if (!isPlayer(unit)) {
		let suffix = ""
		if (side(group(unit)) === side(group(killer))) {
			suffix = " (Friendly fire)"
		}

		if (playableUnits().includes(driver(vehicle(killer))) && vehicle(unit) !== vehicle(killer)) {
			const killerDisplayName = isPlayer(killer) ? name(killer) : `${name(killer)} (AI)`
			remoteExec([`${name(unit)} (AI) was killed by ${killerDisplayName}${suffix}`], systemChat, 0, false)
		} else {
			remoteExec([`${name(unit)} (AI) was killed${suffix}`], systemChat, 0, false)
		}
	}

	const marker = `${side(group(unit))} ${groupId(group(unit))}_marker`
	setMarkerAlpha(marker, 0)

	setDamage(vehicle(unit), 1)
}
