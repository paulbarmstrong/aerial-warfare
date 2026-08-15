import { alive, bis, doWatch, GameObject, getAllHitPointsDamage, group, isTouchingGround, player, screenToWorld,
	setBehaviour, setHitIndex, setVariable, sleep, spawn, uiNamespace, vectorMagnitude, vehicle, velocity } from "js-to-sqf"
import { sortie } from "./Sortie"

export async function repairUpTo(vehicle: GameObject, damageFloor: number) {
	const damageList: Array<number> = getAllHitPointsDamage(vehicle)[2]
	for (let i = 0; i < damageList.length; i++) {
		if (damageList[i] > damageFloor) {
			setHitIndex(vehicle, i, damageFloor, false)
		}
	}
}

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

export async function helipadService() {
	let countdown = 5
	const heli = vehicle(player())

	sleep(1)

	while (isTouchingGround(vehicle(player())) && vectorMagnitude(velocity(vehicle(player()))) < 5 && countdown > 0) {
		bis.dynamicText(`<t color='#f4c542'>Servicing aircraft in ${countdown} seconds.</t>`, -1, -1, 1, 0, 0, 8365)
		countdown -= 1
		sleep(1)
	}

	if (isTouchingGround(vehicle(player())) && vectorMagnitude(velocity(vehicle(player()))) < 5 && alive(heli)) {
		setVariable(uiNamespace(), "repairState", 2)
		spawn([], sortie)
	} else {
		setVariable(uiNamespace(), "repairState", 0)
	}
}

export async function gunnerLook(man: GameObject) {
	while (alive(man)) {
		setBehaviour(group(man), "CARELESS")
		doWatch(man, screenToWorld([0.5, 0.5]))
		sleep(1)
	}
}
