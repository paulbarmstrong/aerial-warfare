import { alive, closeDialog, Config, configFile, Control, createDialog, crew, ctrlSetStructuredText, ctrlSetTextColor,
	ctrlSetTextV2, deleteVehicle, Display, displayAddEventHandler, displayCtrl, displayRemoveEventHandler, distance2D,
	findDisplay, fullCrew, GameObject, getPosASL, getSlingLoad, getText, getVariable, group, groupChat, hideObjectV2, hint,
	isNull, isPlayer, lbAddV2, lbClearV2, lbCurSelV2, lbSetCurSelV2, lbTextV2, missionNamespace, parseText, player,
	remoteExec, removeAllActions, removeAllWeapons, setDamage, setPosASL, setVariable, setVelocity, side, sleep, spawn,
	typeOf, uiNamespace, vehicle, waitUntil, west } from "@paulbarmstrong/js-to-sqf"
import { AIRCRAFT, getCurrentMod, getUnitDisplayName, SLINGABLES } from "../Constants"
import { AircraftConfig, SlingableConfig } from "../Types"
import { changeMoney } from "../Server/Money"
import { spawnPlayerAircraft } from "../Server/Spawn"

const SORTIE_DISPLAY_ID = 8366

function sortieDisplay(): Display {
	return findDisplay(SORTIE_DISPLAY_ID)
}
function heliListControl(): Control {
	return displayCtrl(sortieDisplay(), 1200)
}
function armaListControl(): Control {
	return displayCtrl(sortieDisplay(), 1300)
}
function slingListControl(): Control {
	return displayCtrl(sortieDisplay(), 1400)
}
function spawnButtonControl(): Control {
	return displayCtrl(sortieDisplay(), 1600)
}

function getAircraftForSide(playerSide: any): Array<AircraftConfig> {
	return AIRCRAFT.filter(a => a.sides.includes(playerSide) && a.mod === getCurrentMod())
}

function getSlingablesForSide(playerSide: any): Array<SlingableConfig> {
	return SLINGABLES.filter(s => s.sides.includes(playerSide) && s.mod === getCurrentMod())
}

function getSlingableDisplayName(slingable: SlingableConfig): string {
	if (slingable.name !== undefined) {
		return slingable.name
	}
	return getText(new Config(configFile(), "CfgVehicles", slingable.className, "displayName"))
}

export async function keyDown(display: Display, key: number, shift: boolean, ctrlKey: boolean, alt: boolean): Promise<boolean> {
	if (key === 1) {
		spawn([1], sortieDelay)
	}
	return false
}

export async function sortieDelay(delaySeconds: number) {
	sleep(delaySeconds)
	sortie()
}

export async function sortie() {
	setVariable(uiNamespace(), "trying_to_spawn", false)
	setDamage(player(), 0)
	removeAllActions(player())
	removeAllWeapons(player())

	crew(vehicle(player())).forEach((crewMember: GameObject) => {
		if (!isPlayer(crewMember)) {
			deleteVehicle(crewMember)
		}
	})

	if (getVariable(vehicle(player()), "price") !== undefined) {
		const reimbursement = getVariable(vehicle(player()), "price")
		remoteExec([player(), reimbursement], changeMoney, player(), false)
		groupChat(player(), `Aircraft refunded | +$${reimbursement}`)

		const slingLoad = getSlingLoad(vehicle(player()))
		const slingable = SLINGABLES.find(s => s.className === typeOf(slingLoad))
		if (slingable !== undefined) {
			remoteExec([player(), slingable.price], changeMoney, player(), false)
			groupChat(player(), `${getUnitDisplayName(slingLoad)} refunded | +$${slingable.price}`)
			fullCrew(slingLoad).forEach((entry: Array<any>) => deleteVehicle(entry[0]))
		}
		deleteVehicle(slingLoad)
	}

	if (vehicle(player()) !== player()) {
		deleteVehicle(vehicle(player()))
	}

	const playerSide = side(group(player()))
	const helipadsVarName = playerSide === west() ? "BluforHelipads" : "OpforHelipads"
	const helipads: Array<GameObject> = getVariable(missionNamespace(), helipadsVarName)
	let nearestHelipad = helipads[0]
	helipads.forEach(helipad => {
		if (distance2D(player(), helipad) < distance2D(player(), nearestHelipad)) {
			nearestHelipad = helipad
		}
	})

	hideObjectV2(player(), true)
	setPosASL(player(), getPosASL(nearestHelipad))
	setVelocity(player(), [0, 0, 0])

	if (!alive(player())) return

	createDialog("Sortie_Dialog")

	waitUntil(() => !isNull(findDisplay(SORTIE_DISPLAY_ID)))

	const escapeHandler = displayAddEventHandler(sortieDisplay(), "KeyDown", keyDown)
	setVariable(uiNamespace(), "escapeHandler", escapeHandler)

	ctrlSetStructuredText(displayCtrl(sortieDisplay(), 1101), parseText("Respawn Menu"))

	const aircraftList = getAircraftForSide(playerSide)
	const heliList = heliListControl()
	lbClearV2(heliList)
	aircraftList.forEach(aircraft => {
		lbAddV2(heliList, `${aircraft.name}, ($${aircraft.price})`)
	})

	lbSetCurSelV2(heliList, getVariable(uiNamespace(), "aircraftSelection"))
	lbSetCurSelV2(armaListControl(), getVariable(uiNamespace(), "armamentSelection"))
	ctrlSetTextV2(spawnButtonControl(), `Spawn in the ${aircraftList[0].name} for $0`)
}

export async function heliSelChanged() {
	const playerSide = side(group(player()))
	const aircraftList = getAircraftForSide(playerSide)

	const heliIndex = lbCurSelV2(heliListControl())
	const chosenHeli = lbTextV2(heliListControl(), heliIndex)

	if (chosenHeli !== "") {
		const aircraft = aircraftList[heliIndex]

		lbClearV2(armaListControl())
		aircraft.armaments.forEach(armament => {
			lbAddV2(armaListControl(), `${armament.name} ($${armament.price})`)
		})

		if (!getVariable(uiNamespace(), "hasSetSelection")) {
			lbSetCurSelV2(armaListControl(), getVariable(uiNamespace(), "armamentSelection"))
			setVariable(uiNamespace(), "hasSetSelection", true)
		} else {
			lbSetCurSelV2(armaListControl(), 0)
		}

		ctrlSetTextV2(spawnButtonControl(), `Spawn in the ${aircraft.name} for $${aircraft.price}`)
		if (getVariable(group(player()), "Money") >= aircraft.price) {
			ctrlSetTextColor(spawnButtonControl(), [1, 1, 1, 1])
		} else {
			ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
		}
	} else {
		ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
	}
}

export async function armaSelChanged() {
	const playerSide = side(group(player()))
	const aircraftList = getAircraftForSide(playerSide)
	const slingablesList = getSlingablesForSide(playerSide)

	const heliIndex = lbCurSelV2(heliListControl())
	const armaIndex = lbCurSelV2(armaListControl())
	const chosenArma = lbTextV2(armaListControl(), armaIndex)

	if (chosenArma !== "") {
		const aircraft = aircraftList[heliIndex]
		const armament = aircraft.armaments[armaIndex]
		const slingNum = armament.slingNum ?? 0

		lbClearV2(slingListControl())
		lbAddV2(slingListControl(), "None ($0)")
		for (let i = 0; i < slingNum; i++) {
			const slingable = slingablesList[i]
			lbAddV2(slingListControl(), `${getSlingableDisplayName(slingable)} ($${slingable.price})`)
		}
		lbSetCurSelV2(slingListControl(), 0)

		const totalPrice = aircraft.price + armament.price
		ctrlSetTextV2(spawnButtonControl(), `Spawn in the ${aircraft.name} for $${totalPrice}`)
		if (getVariable(group(player()), "Money") >= totalPrice) {
			ctrlSetTextColor(spawnButtonControl(), [1, 1, 1, 1])
		} else {
			ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
		}
	} else {
		ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
	}
}

export async function slingSelChanged() {
	const playerSide = side(group(player()))
	const aircraftList = getAircraftForSide(playerSide)
	const slingablesList = getSlingablesForSide(playerSide)

	const heliIndex = lbCurSelV2(heliListControl())
	const armaIndex = lbCurSelV2(armaListControl())
	const slingIndex = lbCurSelV2(slingListControl())

	if (slingIndex > -1) {
		const aircraft = aircraftList[heliIndex]
		const armament = aircraft.armaments[armaIndex]
		let slingPrice = 0
		if (slingIndex > 0) {
			slingPrice = slingablesList[slingIndex - 1].price
		}
		const totalPrice = aircraft.price + armament.price + slingPrice

		ctrlSetTextV2(spawnButtonControl(), `Spawn in the ${aircraft.name} for $${totalPrice}`)
		if (getVariable(group(player()), "Money") >= totalPrice) {
			ctrlSetTextColor(spawnButtonControl(), [1, 1, 1, 1])
		} else {
			ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
		}
	} else {
		ctrlSetTextColor(spawnButtonControl(), [0.5, 0.5, 0.5, 1])
	}
}

export async function spawnButtonPressed() {
	if (getVariable(uiNamespace(), "trying_to_spawn") || !alive(player())) return

	setVariable(uiNamespace(), "trying_to_spawn", true)

	const heliIndex = lbCurSelV2(heliListControl())
	const armaIndex = lbCurSelV2(armaListControl())
	const slingIndex = lbCurSelV2(slingListControl())

	if (heliIndex > -1 && armaIndex > -1 && slingIndex > -1) {
		const playerSide = side(group(player()))
		const aircraft = getAircraftForSide(playerSide)[heliIndex]
		const armament = aircraft.armaments[armaIndex]
		const slingablesList = getSlingablesForSide(playerSide)
		let slingPrice = 0
		if (slingIndex > 0) {
			slingPrice = slingablesList[slingIndex - 1].price
		}
		const totalPrice = aircraft.price + armament.price + slingPrice

		if (getVariable(group(player()), "Money") >= totalPrice) {
			remoteExec([player(), -totalPrice], changeMoney, player(), false)
			displayRemoveEventHandler(sortieDisplay(), "KeyDown", getVariable(uiNamespace(), "escapeHandler"))
			closeDialog(0)

			remoteExec([player(), heliIndex, armaIndex, slingIndex], spawnPlayerAircraft, 2, false)

			hideObjectV2(player(), false)
			setVariable(uiNamespace(), "aircraftSelection", heliIndex)
			setVariable(uiNamespace(), "armamentSelection", armaIndex)
			setVariable(uiNamespace(), "hasSetSelection", false)

			if (aircraft.jet) {
				sleep(10)
			} else {
				sleep(5)
			}
			setVariable(uiNamespace(), "repairState", 0)
		} else {
			hint("You do not have enough money to purchase this combination!")
		}
	} else {
		hint("Invalid Combination")
	}

	setVariable(uiNamespace(), "trying_to_spawn", false)
}
