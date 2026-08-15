import { alive, Config, configFile, deleteMarker, distance2D, east, GameObject, getPosASL, getPosATL, getText,
	getVariable, group, groupChat, groupId, gunner, isPlayer, leader, missionNamespace, moveInGunner, name, orderGetIn,
	playableUnits, position, remoteExec, setBehaviour, setDamage, setMarkerAlpha, setMarkerPos, setMarkerText,
	setVariable, side, sleep, spawn, typeOf, units, vehicle, west } from "js-to-sqf"
import { getConvoyGroupsForSide, updateConvoyWaypoint } from "./Convoy"
import { changeMoney } from "./Money"
import { getTowns } from "./Towns"
import { updateWaypoint } from "./Waypoint"

export async function trackOnMap() {
	while (true) {
		// Update markers for playable units
		playableUnits().forEach(unit => {
			const marker = `${side(group(unit))} ${groupId(group(unit))}_marker`
			if (alive(unit)) {
				const genericHeliName = getText(new Config(configFile(), "CfgVehicles", typeOf(vehicle(unit)), "displayName"))
				setMarkerText(marker, `${name(unit)} [${genericHeliName}]`)
				setMarkerPos(marker, position(vehicle(unit)))
				setMarkerAlpha(marker, 1)
			} else {
				setMarkerAlpha(marker, 0)
			}
		})

		// Update markers for sling vehicles
		let slingMarkers: Array<string> = getVariable(missionNamespace(), "SlingMarkerArray") ?? []
		let slingVehicles: Array<GameObject> = getVariable(missionNamespace(), "SlingVehicleArray") ?? []
		const keptMarkers: Array<string> = []
		const keptVehicles: Array<GameObject> = []
		slingMarkers.forEach((marker, i) => {
			const car = slingVehicles[i]
			if (car !== undefined && alive(car)) {
				if (getPosATL(car)[2] < 3 || getPosASL(car)[2] < 3) {
					setMarkerPos(marker, position(car))
					setMarkerAlpha(marker, 1)
				} else {
					setMarkerAlpha(marker, 0)
				}
				keptMarkers.push(marker)
				keptVehicles.push(car)
			} else {
				deleteMarker(marker)
			}
		})
		setVariable(missionNamespace(), "SlingMarkerArray", keptMarkers)
		setVariable(missionNamespace(), "SlingVehicleArray", keptVehicles)

		// Update markers for convoys
		getConvoyGroupsForSide(west()).forEach((convoyGroup, i) => {
			const marker = `blufor_convoy_marker_${i}`
			const convoyUnits = units(convoyGroup)
			const aliveUnit = convoyUnits.find(unit => alive(unit))
			if (convoyUnits.length > 0 && aliveUnit !== undefined) {
				setMarkerText(marker, `Blufor Convoy ${i + 1}`)
				setMarkerPos(marker, position(aliveUnit))
				setMarkerAlpha(marker, 1)
			} else {
				setMarkerAlpha(marker, 0)
			}
		})
		getConvoyGroupsForSide(east()).forEach((convoyGroup, i) => {
			const marker = `opfor_convoy_marker_${i}`
			if (units(convoyGroup).length > 0 && alive(leader(convoyGroup))) {
				setMarkerText(marker, `Opfor Convoy ${i + 1}`)
				setMarkerPos(marker, position(leader(convoyGroup)))
				setMarkerAlpha(marker, 1)
			} else {
				setMarkerAlpha(marker, 0)
			}
		})

		sleep(1)
	}
}

export async function serverLoop() {
	let count = 1

	while (true) {
		// Make sure convoys aren't too far apart from their leader
		if (count % 10 === 0) {
			getConvoyGroupsForSide(west()).forEach(convoyGroup => {
				units(convoyGroup).forEach(unit => {
					if (alive(unit) && distance2D(unit, leader(convoyGroup)) > 250) {
						updateConvoyWaypoint(convoyGroup)
					}
				})
			})
			getConvoyGroupsForSide(east()).forEach(convoyGroup => {
				units(convoyGroup).forEach(unit => {
					if (alive(unit) && distance2D(unit, leader(convoyGroup)) > 250) {
						updateConvoyWaypoint(convoyGroup)
					}
				})
			})
		}

		// Make sure playable units aren't stuck
		if (count % 60 === 59) {
			playableUnits().forEach(unit => {
				const lastPos = getVariable(unit, "LastPosition")
				if (!isPlayer(unit) && lastPos !== undefined && distance2D(lastPos, unit) < 10) {
					const grp = group(unit)
					setVariable(grp, "lettingOutTroops", false)
					setVariable(grp, "landingAtBase", false)
					spawn([grp], updateWaypoint)
				}
				setVariable(unit, "LastPosition", position(unit))
			})
		}

		// Handle town-specific turret occupancy on a staggered schedule
		const towns = getTowns()
		if (towns.length > 0) {
			const town = towns[count % towns.length]
			town.turrets.forEach(turret => {
				const turretGunner = gunner(turret)
				if (turretGunner !== undefined && alive(turretGunner) && vehicle(turretGunner) !== turret) {
					setDamage(turretGunner, 0)
					orderGetIn([turretGunner], true)
					if (distance2D(turretGunner, turret) < 5) {
						moveInGunner(turretGunner, turret)
					}
					setBehaviour(town.group, "AWARE")
				}
			})
		}

		// Award income every 60 seconds
		if (count % 60 === 0) {
			playableUnits().forEach(unit => {
				let income = getVariable(missionNamespace(), "OpforIncome")
				if (side(group(unit)) === west()) {
					income = getVariable(missionNamespace(), "BluforIncome")
				}
				if (income > 0) {
					remoteExec([unit, `Income from town occupation | +$${income}`], groupChat, unit, false)
					changeMoney(unit, income)
				}
			})
		}

		sleep(1)
		count += 1
	}
}
