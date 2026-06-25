import { Side } from "js-to-sqf"

export type RiflemanConfig = {
	side: Side | "independent",
	mod?: "RHS",
	className: string,
}

export type SlingableConfig = {
	className: string,
	mod?: "RHS",
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
	mod?: "RHS",
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