import { allowDamage, assignAsCargo, bis, createGroupV2, createUnit, createVehicleCrew, createVehicleV2,
	crew, deleteVehicle, GameObject, getDir, getPosASL, group, hideObjectV2, isPlayer, joinSilent,
	lock, moveInCargo, moveInDriver, player, position, remoteExec, setDir, setPosASL, setPylonLoadout, setVariable, side,
	uiNamespace, vectorAdd, vehicle } from "js-to-sqf"
import { AIRCRAFT, getCurrentMod, getDefaultRiflemanForSide, getJetSpotForSide, SLINGABLES } from "../Constants"
import { applyTextureReplacements } from "../Server/Spawn"
import { sortie } from "./Sortie"

export async function playerRespawn() {
	setVariable(uiNamespace(), "repairState", 2)
	sortie()
}

export async function inventoryOpened(): Promise<boolean> {
	return true
}

export async function doneUnloadingTroops() {
	setVariable(uiNamespace(), "isUnloadingTroops", false)
}

export async function playerAndCrewLocal(spawnSpot: GameObject, heliIndex: number, armaIndex: number, slingIndex: number) {
	const playerSide = side(group(player()))
	const aircraft = AIRCRAFT.filter(a => a.sides.includes(playerSide) && a.mod === getCurrentMod())[heliIndex]
	const armament = aircraft.armaments[armaIndex]
	const slingablesList = SLINGABLES.filter(s => s.sides.includes(playerSide) && s.mod === getCurrentMod())

	let actualSpawnSpot = spawnSpot
	let special = "FLY"
	let startHeight = 12
	if (aircraft.jet) {
		actualSpawnSpot = getJetSpotForSide(playerSide)
		special = "NONE"
		startHeight = 0
	}

	let slingPrice = 0
	if (slingIndex > 0) {
		slingPrice = slingablesList[slingIndex - 1].price
	}
	const totalPrice = aircraft.price + armament.price + slingPrice
	const heliPrice = totalPrice - slingPrice

	const heli = createVehicleV2(armament.className, vectorAdd(getPosASL(actualSpawnSpot), [0, 0, startHeight]), [], 0, special)
	setVariable(heli, "price", heliPrice)
	remoteExec([heli, "price", heliPrice], setVariable, 2, false)

	setPosASL(heli, vectorAdd(getPosASL(actualSpawnSpot), [0, 0, startHeight]))
	setDir(heli, getDir(actualSpawnSpot))

	if (armament.pylons !== undefined) {
		armament.pylons.forEach((pylon, pylonIndex) => {
			if (pylon.isGunner) {
				setPylonLoadout(heli, pylonIndex, pylon.className, true, [0])
			} else {
				setPylonLoadout(heli, pylonIndex, pylon.className, true)
			}
		})
	}

	applyTextureReplacements(heli, armament.className, playerSide)

	moveInDriver(player(), heli)
	lock(heli, true)
	hideObjectV2(player(), false)
	allowDamage(player(), false)

	const heliGroup = createGroupV2(playerSide, true)
	createVehicleCrew(heli)
	crew(heli).forEach((crewMember: GameObject) => {
		if (!isPlayer(crewMember)) {
			joinSilent([crewMember], heliGroup)
			allowDamage(crewMember, false)
		}
	})

	const cargoCrewCount = bis.crewCount(armament.className, true) - bis.crewCount(armament.className, false)
	for (let i = 0; i < cargoCrewCount; i++) {
		const troop = createUnit(heliGroup, getDefaultRiflemanForSide(playerSide), position(player()), [], 0, "NONE")
		assignAsCargo(troop, heli)
		moveInCargo(troop, heli)
		setVariable(troop, "SoldierType", "capture")
		remoteExec([troop, "SoldierType", "capture"], setVariable, 2, false)
		if (vehicle(troop) !== heli) {
			deleteVehicle(troop)
		}
	}

	remoteExec([player(), "pull_the_heli", heli], setVariable, 2, false)
	remoteExec([player(), "pull_heli_group", heliGroup], setVariable, 2, false)
}
