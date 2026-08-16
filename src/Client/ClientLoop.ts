import { actionIDs, actionParams, addAction, bis, distance2D, GameObject, getVariable, group, isTouchingGround,
	missionNamespace, player, position, remoteExec, removeAction, setVariable, side, sleep, spawn, typeOf, uiNamespace,
	vectorAdd, vectorMagnitude, vehicle, velocity, west } from "@paulbarmstrong/js-to-sqf"
import { getJetSpotForSide } from "../Constants"
import { dropTroops, letTroopsOut } from "../Server/Spawn"
import { getTowns } from "../Server/Towns"
import { displayHUDText } from "./Hud"
import { helipadService } from "./Vehicle"

/** The "Drop troops onto <town>" action. The town index rides along as the action's
 * `arguments` rather than being captured from the loop that added the action. */
function dropTroopsAction(target: GameObject, caller: GameObject, actionId: number, townIndex: number) {
	remoteExec([caller, townIndex], dropTroops, 2, false)
}

export async function clientLoop() {
	while (true) {
		displayHUDText()

		if (vehicle(player()) !== player() && getVariable(uiNamespace(), "isUnloadingTroops")) {
			remoteExec([vehicle(player()), "touching_ground", isTouchingGround(vehicle(player()))], setVariable, 2, false)
		}

		const playerSide = side(group(player()))
		const helipadsVarName = playerSide === west() ? "BluforHelipads" : "OpforHelipads"
		const helipads: Array<GameObject> = getVariable(missionNamespace(), helipadsVarName)
		const serviceLocations: Array<GameObject> = []
		helipads.forEach(helipad => serviceLocations.push(helipad))
		serviceLocations.push(getJetSpotForSide(playerSide))

		let isNearServiceLoc = false
		serviceLocations.forEach(loc => {
			if (distance2D(vehicle(player()), loc) < 100) {
				isNearServiceLoc = true
			}
		})
		if (isNearServiceLoc && isTouchingGround(vehicle(player())) && getVariable(uiNamespace(), "repairState") === 0) {
			setVariable(uiNamespace(), "repairState", 1)
			spawn([], helipadService)
		}

		const heliClassName = typeOf(vehicle(player()))
		const cargoCrewCount = bis.crewCount(heliClassName, true) - bis.crewCount(heliClassName, false)

		if (cargoCrewCount > 0) {
			const towns = getTowns()
			towns.forEach((town, i) => {
				if (isTouchingGround(vehicle(player())) && vectorMagnitude(velocity(vehicle(player()))) < 3
						&& distance2D(position(player()), position(town.flag)) < town.size
						&& !getVariable(uiNamespace(), "isUnloadingTroops")) {
					setVariable(uiNamespace(), "isUnloadingTroops", true)
					remoteExec([player(), i], letTroopsOut, 2, false)
				}

				const projectedPos = vectorAdd(position(vehicle(player())), velocity(vehicle(player())).map(v => v * 1.5))
				const actionText = `Drop troops onto ${town.name}`

				if (distance2D(projectedPos, position(town.flag)) < 1.5 * town.size && position(vehicle(player()))[2] > 125) {
					let actionExists = false
					actionIDs(player()).forEach(id => {
						if (actionParams(player(), id)[0] === actionText) {
							actionExists = true
						}
					})
					if (!actionExists) {
						addAction(player(), actionText, dropTroopsAction, i, 8, true)
					}
				} else {
					actionIDs(player()).forEach(id => {
						if (actionParams(player(), id)[0] === actionText) {
							removeAction(player(), id)
						}
					})
				}
			})
		}

		sleep(0.5)
	}
}
