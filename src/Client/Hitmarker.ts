import { bis } from "js-to-sqf"

export async function displayHitmarker() {
	bis.dynamicText(`<img size="1" shadow="0" image="Images\\goodhitmarker.paa" />`, -1, -1, 0.5, 0, 0, 3090)
}