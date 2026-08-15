import { driver, GameObject, group, isPlayer, remoteExec, side, vehicle } from "@paulbarmstrong/js-to-sqf";
import { displayHitmarker } from "../Client/Hitmarker";

export async function distributeHitmarker(unit: GameObject, hitter: GameObject) {
	if (isPlayer(driver(vehicle(hitter))) && side(group(hitter)) !== side(group(unit))) {
		remoteExec([], displayHitmarker, hitter, false)
	}
}