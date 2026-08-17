import { GameObject, Group, Side } from "@paulbarmstrong/js-to-sqf"

export type RiflemanConfig = {
	side: Side,
	mod: "vanilla" | "RHS",
	className: string,
}

export type SlingableConfig = {
	className: string,
	mod: "vanilla" | "RHS",
	price: number,
	sides: Array<Side>,
	name?: string,
	antiAir?: boolean
}

export type AircraftConfig = {
	name: string,
	price: number,
	sides: Array<Side>,
	jet?: boolean,
	mod: "vanilla" | "RHS",
	disallowedForAi?: boolean,
	armaments: Array<{
		name: string,
		className: string,
		price: number,
		manualFire?: boolean,
		pylons?: Array<{
			className: string,
			isGunner?: boolean
		}>,
		slingNum?: number
	}>
}

export type Town = {
    marker: string;
    helipad: GameObject;
    turretHolder: GameObject;
    turrets: GameObject[];
    // The unit assigned/reserved to each turret slot, index-aligned with `turrets`. This is set
    // as soon as a unit is assigned to a turret, before they've physically walked there and
    // gotten in - so it is NOT the same as "who is currently sitting in the turret" (use
    // getTownOccupants/getTownNumAlive for that).
    units: GameObject[];
    group: Group;
    name: string;
    size: number;
    flag: GameObject;
}