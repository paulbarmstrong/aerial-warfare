import { addEventHandler, addMissionEventHandler, createMarker, defineMission, enableSaving, findDisplay,
	group, groupId, isNull, isPlayer, missionNamespace, name, playableUnits, player, position, setMarkerColor,
	setMarkerText, setMarkerType, setVariable, Side, side, spawn, uiNamespace, waitUntil } from "js-to-sqf"
import { getMarkerColorForSide, MINIMUM_INCOME } from "./Constants"
import { clientLoop } from "./Client/ClientLoop"
import { inventoryOpened, playerRespawn } from "./Client/PlayerLocal"
import { setUpConvoys } from "./Server/Convoy"
import { serverLoop } from "./Server/Loop"
import { setUpPlayer } from "./Server/Player"
import { aiRespawn } from "./Server/Spawn"
import { setUpTowns } from "./Server/Towns"

export default defineMission({
	initServer: () => {
		enableSaving(false)

		setUpTowns()

		playableUnits().forEach(unit => {
			const unitSide: Side = side(unit)
			const unitGroupId: string = groupId(group(unit))
			const newMarker = createMarker(`${unitSide} ${unitGroupId}_marker`, position(unit))
			setMarkerType(newMarker, "mil_dot")
			if (isPlayer(unit)) {
				setMarkerText(newMarker, name(player))
			} else {
				setMarkerText(newMarker, unitGroupId)
			}
			setMarkerColor(newMarker, getMarkerColorForSide(unitSide))

			setUpPlayer(unit)
		})

		// Initialize income/economy stuff
		//=========================================

		setVariable(missionNamespace(), "BluforIncome", MINIMUM_INCOME, true)
		setVariable(missionNamespace(), "OpforIncome", MINIMUM_INCOME, true)

		// Passive Vehicle Convoys
		//=========================================

		setUpConvoys()

		// Run scripts
		//=========================================

		spawn([], serverLoop)

		playableUnits().forEach(unit => {
			spawn([unit], aiRespawn)
		})

		// Mission Event Handlers
		//=========================================

		addMissionEventHandler("PlayerDisconnected", () => {
			setVariable(missionNamespace(), "BluforIsSpawning", false, false)
			setVariable(missionNamespace(), "OpforIsSpawning", false, false)
		})

		// Plans
		//=========================================

		// Create a script to allow any airplane to perform a tailhook landing on the carrier

		// There is some something causing the log to be spammed with message about destroy
		// and it has something to do with playableAI behavior

		// Sometimes LZ gets cleared, shows 0/4, white, no men there, but cannot be captured
	},
	initPlayerLocal: () => {
		setVariable(uiNamespace(), "repairState", 2)
		setVariable(uiNamespace(), "isUnloadingTroops", false)
		setVariable(uiNamespace(), "hasSetSelection", false)
		setVariable(uiNamespace(), "trying_to_spawn", false)
		setVariable(uiNamespace(), "aircraftSelection", 0)
		setVariable(uiNamespace(), "armamentSelection", 0)

		addEventHandler(player(), "Respawn", () => playerRespawn())
		addEventHandler(player(), "InventoryOpened", () => inventoryOpened())

		waitUntil(() => !isNull(findDisplay(46)))

		playerRespawn()
		spawn([], clientLoop)
	}
})

