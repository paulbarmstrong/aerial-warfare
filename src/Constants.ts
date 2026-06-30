import { bis, getGameObjectByVariableName, missionNamespace, setVariable, west, east, Side, independent } from "js-to-sqf"
import { AircraftConfig, RiflemanConfig, SlingableConfig } from "./Types"

export function getConvoyVehicles(mod: "RHS" | undefined, side: Side): Array<String> {
	if (mod === "RHS") {
		if (side === west()) {
			return ["rhsusf_m1025_w_m2", "rhsusf_m1025_w_mk19", "rhsusf_m1025_w_m2"]
		} else {
			return ["rhs_tigr_sts_vdv", "rhs_tigr_sts_vdv", "rhs_tigr_sts_vdv"]
		}
	} else {
		if (side === west()) {
			return ["B_MRAP_01_hmg_F", "B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"]
		} else {
			return ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F"]
		}
	}
}

export function getMarkerColorForSide(side: Side | undefined) {
	if (side === west()) {
		return "colorBLUFOR"
	} else if (side === east()) {
		return "colorOPFOR"
	} else if (side === independent()) {
		return "colorGreen"
	} else {
		return "colorWhite"
	}
}

export function getTownFlagClassNameForSide(side: Side | undefined) {
	if (side === west()) {
		return "Flag_Blue_F"
	} else if (side === east()) {
		return "Flag_Red_F"
	} else if (side === independent()) {
		return "Flag_Green_F"
	} else {
		return "FlagPole_F"
	}
}

export const TOWNS_CONFIG = [
	{name: "Agia Maria", size: 50, flag: getGameObjectByVariableName(`townFlag_0`)},
	{name: "Camp Maxwell", size: 50, flag: getGameObjectByVariableName(`townFlag_1`)},
	{name: "LZ Connor", size: 100, flag: getGameObjectByVariableName(`townFlag_2`)},
	{name: "Air Station Mike", size: 100, flag: getGameObjectByVariableName(`townFlag_3`)},
	{name: "Camp Rogain", size: 100, flag: getGameObjectByVariableName(`townFlag_4`)},
	{name: "Kamino Firing Range", size: 100, flag: getGameObjectByVariableName(`townFlag_5`)},
	{name: "Camp Tempest", size: 50, flag: getGameObjectByVariableName(`townFlag_6`)}
]

export const TROOP_KILL_AWARD = 50
export const LZ_KILL_AWARD = 100
export const TROOP_LANDING_AWARD = 50
export const TROOP_PARACHUTE_AWARD = 30
export const TOWN_CAPTURE_AWARD = 500
export const TOWN_CLEAR_AWARD = 500
export const MINIMUM_INCOME = 0
export const INITIAL_TOWN_TROOPS_DELAY_SECONDS = 0.02
export const INCOME_PER_TOWN_TROOP = bis.getParamValue("TroopIncomeFactor")
export const USE_HITMARKERS = bis.getParamValue("UseHitmarkers") === 1
export const USE_RHS = bis.getParamValue("UseRHS") === 1
export const MODS = USE_RHS ? ["RHS"] : []
export const INITIAL_OCCUPATION = bis.getParamValue("InitialOccupation")
export const CONTROL_NEARBY_LZ = bis.getParamValue("ControlNearbyLZ")

setVariable(missionNamespace(), "SlingMarkerTally", 0)
setVariable(missionNamespace(), "SlingMarkerArray", [])
setVariable(missionNamespace(), "SlingVehicleArray", [])

export const RIFLEMEN: Array<RiflemanConfig> = [
	{side: "independent", className: "I_soldier_F"},
	{side: west(), className: "B_Soldier_F"},
	{side: east(), className: "O_Soldier_F"},
	{side: "independent", mod: "RHS", className: "rhsgref_ins_g_rifleman"},
	{side: west(), mod: "RHS", className: "rhsusf_usmc_marpat_wd_rifleman_m4"},
	{side: east(), mod: "RHS", className: "rhs_vdv_flora_rifleman"},
]

const SLINGABLES: Array<SlingableConfig> = [
	{sides: [west()], className: "B_G_Offroad_01_armed_F", price: 100},
	{sides: [west()], className: "B_G_Offroad_01_AT_F", price: 250},
	{sides: [west()], className: "B_LSV_01_AT_F", price: 1000, name: "Prowler (AA)", antiAir: true},
	{sides: [west()], className: "B_MRAP_01_hmg_F", price: 500},
	{sides: [west()], className: "B_MRAP_01_gmg_F", price: 500},
	{sides: [east()], className: "O_G_Offroad_01_armed_F", price: 100},
	{sides: [east()], className: "O_G_Offroad_01_AT_F", price: 250},
	{sides: [east()], className: "O_LSV_02_AT_F", price: 1000, name: "Qilin (AA)", antiAir: true},
	{sides: [east()], className: "O_MRAP_02_hmg_F", price: 500},
	{sides: [east()], className: "O_MRAP_02_gmg_F", price: 500},
	{sides: [west()], mod: "RHS", className: "rhsusf_m1025_w_m2", price: 500},
	{sides: [west()], mod: "RHS", className: "rhsusf_m1025_w_mk19", price: 500},
	{sides: [west()], mod: "RHS", className: "B_T_LSV_01_AT_F", price: 1000, name: "Prowler (AA)", antiAir: true},
	{sides: [east()], mod: "RHS", className: "rhsgref_ins_uaz_dshkm", price: 250},
	{sides: [east()], mod: "RHS", className: "rhsgref_ins_uaz_ags", price: 250},
	{sides: [east()], mod: "RHS", className: "rhsgref_ins_uaz_spg9", price: 1000, name: "UAZ-3151 (AA)", antiAir: true},
]
					
const BIG_BOMB_CLASSNAMES = ["Bomb_04_Plane_CAS_01_F", "Bomb_03_Plane_CAS_02_F", "Bomb_04_Plane_CAS_01_F",
	"Bomb_03_Plane_CAS_02_F", "rhs_mag_gbu12", "rhs_mag_fab250"];

export const TEXTURE_REPLACEMENTS = [
	// CSAT Orca
	{className: "O_Heli_Light_02_unarmed_F", side: east(), textureIndex: 0, texture: "a3\air_f\heli_light_02\data\heli_light_02_ext_opfor_co.paa"},
	// CSAT Ghost Hawk
	{className: "B_Heli_Transport_01_F", side: east(), textureIndex: 0, texture: "Images\\opfor_hex_camo_2048.jpg"},
	{className: "B_Heli_Transport_01_F", side: east(), textureIndex: 1, texture: "Images\\opfor_hex_camo_2048.jpg"}
]

const AIRCRAFT: Array<AircraftConfig> = [
	{
		name: "MH-9 Hummingbird",
		price: 0,
		sides: [west()],
		armaments: [
			{
				name: "None",
				className: "B_Heli_Light_01_F",
				price: 0,
			}
		]
	}, {
		name: "AH-9 Pawnee",
		price: 1500,
		sides: [west()],
		disallowedForAi: true,
		armaments: [
			{
				name: "2x M134 Minigun",
				className: "B_Heli_Light_01_dynamicLoadout_F",
				price: 0,
			}, {
				name: "2x M134 Minigun, 24x DAR Missiles",
				className: "B_Heli_Light_01_dynamicLoadout_F",
				price: 1000,
				pylons: [
					{className: "PylonRack_12Rnd_missiles", isGunner: false},
					{className: "PylonRack_12Rnd_missiles", isGunner: false},
				]
			}
		]
	}, {
		name: "UH-80 Ghost Hawk",
		price: 2500,
		sides: [west(), east()],
		armaments: [
			{
				name: "2x M134 Gunners",
				className: "B_Heli_Transport_01_F",
				price: 0,
				slingNum: 2,
			}
		]
	}, {
		name: "CH-67 Huron",
		price: 3000,
		sides: [west()],
		disallowedForAi: true,
		armaments: [
			{
				name: "None",
				className: "B_Heli_Transport_03_unarmed_F",
				price: 0,
				slingNum: 5,
			}, {
				name: "2x M134 Gunners",
				className: "B_Heli_Transport_03_F",
				price: 1000,
				slingNum: 5,
			}
		]
	}, {
		name: "V-44 X Blackfish",
		price: 4000,
		sides: [west()],
		armaments: [
			{
				name: "None",
				className: "B_T_VTOL_01_infantry_F",
				price: 0,
			}, {
				name: "105mm, 40mm, and 20mm Cannons",
				className: "B_T_VTOL_01_armed_F",
				price: 6000,
			}
		]
	}, {
		name: "AH-99 Blackfoot",
		price: 6000,
		sides: [west()],
		armaments: [
			{
				name: "1x 20mm Gatling Gun",
				className: "B_Heli_Attack_01_dynamicLoadout_F",
				price: 0,
			}, {
				name: "1x 20mm Gatling Gun, 12x DAGR Missiles",
				className: "B_Heli_Attack_01_dynamicLoadout_F",
				price: 500,
				pylons: [{className: "PylonRack_12Rnd_PG_missiles", isGunner: true}]
			}
		]
	}, {
		name: "A-164 Wipeout",
		price: 10000,
		sides: [west()],
		jet: true,
		armaments: [
			{
				name: "1x 30mm Gatling Gun",
				className: "B_Plane_CAS_01_dynamicLoadout_F",
				price: 0,
			}, {
				name: "1x 30mm Gatling Gun, 4x GBU-12 Bombs",
				className: "B_Plane_CAS_01_dynamicLoadout_F",
				price: 2000,
				pylons: ["", "", "", "PylonMissile_1Rnd_Bomb_04_F", "PylonMissile_1Rnd_Bomb_04_F","PylonMissile_1Rnd_Bomb_04_F",
					"PylonMissile_1Rnd_Bomb_04_F"].map(className => ({className}))
			}
		]
	}, {
		name: "MH-6M Little Bird",
		price: 0,
		sides: [west()],
		armaments: [
			{
				name: "None",
				className: "RHS_MELB_MH6M",
				price: 0,
			}
		]
	}, {
		name: "MH-6M Little Bird",
		price: 0,
		sides: [west()],
		mod: "RHS",
		armaments: [
			{
				name: "None",
				className: "RHS_MELB_MH6M",
				price: 0,
			}
		]
	}, {
		name: "UH-1Y Venom",
		price: 500,
		sides: [west()],
		mod: "RHS",
		armaments: [
			{
				name: "None",
				className: "RHS_UH1Y_UNARMED",
				price: 0,
			}, {
				name: "2x M134 Gunners",
				className: "RHS_UH1Y",
				price: 1500,
			}, {
				name: "2x M134 Gunners, 14x Hydra Rockets",
				className: "RHS_UH1Y",
				price: 2500,
				pylons: ["rhs_mag_M151_7_green", "rhs_mag_M151_7_green"].map(className => ({className}))
			}
		]
	}, {
		name: "CH-53E Sea Stallion",
		price: 1000,
		sides: [west()],
		mod: "RHS",
		disallowedForAi: true,
		armaments: [
			{
				name: "None",
				className: "rhsusf_CH53E_USMC",
				price: 0,
				slingNum: 2,
			}
		]
	}, {
		name: "UH-60M Black Hawk",
		price: 1500,
		sides: [west()],
		mod: "RHS",
		disallowedForAi: true,
		armaments: [
			{
				name: "None",
				className: "RHS_UH60M2",
				price: 0,
				slingNum: 2,
			}, {
				name: "2x M134 Gunners",
				className: "RHS_UH60M",
				price: 1500,
				slingNum: 2,
			}, {
				name: "38x Hydra Rockets",
				className: "RHS_UH60M_ESSS2",
				price: 2500,
				pylons: ["rhs_mag_M151_19", "rhs_mag_M151_19"].map(className => ({className})),
				slingNum: 2,
			}
		]
	}, {
		name: "AH-6M Little Bird",
		price: 2000,
		sides: [west()],
		mod: "RHS",
		disallowedForAi: true,
		armaments: [
			{
				name: "2x M134 Minigun",
				className: "RHS_MELB_AH6M",
				price: 0,
				pylons: ["", "rhs_mag_m134_pylon_3000", "rhs_mag_m134_pylon_3000", ""].map(className => ({className}))
			}, {
				name: "2x M134 Minigun",
				className: "RHS_MELB_AH6M",
				price: 1000,
				pylons: ["rhs_mag_M151_7", "rhs_mag_m134_pylon_3000", "rhs_mag_m134_pylon_3000", "rhs_mag_M151_7"].map(className => ({className}))
			}
		]
	}, {
		name: "CH-47F Chinook",
		price: 3000,
		sides: [west()],
		mod: "RHS",
		disallowedForAi: true,
		armaments: [
			{
				name: "2x M134 Gunners",
				className: "RHS_CH_47F_10",
				price: 0,
				slingNum: 3,
			}
		]
	}, {
		name: "AH-1Z Viper",
		price: 7000,
		sides: [west()],
		mod: "RHS",
		armaments: [
			{
				name: "1x M197 Electric",
				className: "RHS_AH1Z",
				price: 0,
				manualFire: true
			}, {
				name: "1x M197 Electric, 38x Hydra, 8x AGM-114, 2x AIM-9",
				className: "RHS_AH1Z",
				price: 2000,
				manualFire: true,
				pylons: ["rhs_mag_Sidewinder_heli_2", "rhs_mag_AGM114K_4", "rhs_mag_M151_19_green", "rhs_mag_M151_19_green",
					"rhs_mag_AGM114K_4","rhs_mag_Sidewinder_heli_2"].map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "AH-64D Longbow",
		price: 8000,
		sides: [west()],
		mod: "RHS",
		armaments: [
			{
				name: "1x M230 Cannon",
				className: "RHS_AH64D",
				price: 0,
				manualFire: true
			}, {
				name: "1x M230 Cannon, 38x Hydra Rockets, 8x AGM-114s",
				className: "RHS_AH64D",
				price: 2000,
				manualFire: true,
				pylons: [
					{className: "", isGunner: false},
					{className: "rhs_mag_M151_19", isGunner: true},
					{className: "rhs_mag_AGM114K_4", isGunner: true},
					{className: "rhs_mag_AGM114K_4", isGunner: true},
					{className: "rhs_mag_M151_19", isGunner: true},
					{className: "", isGunner: false},
				]
			}
		]
	}, {
		name: "C-130J Super Hercules",
		price: 1000,
		sides: [west()],
		mod: "RHS",
		armaments: [
			{
				name: "None",
				className: "RHS_C130J",
				price: 0
			}
		]
	}, {
		name: "A-10 Warthog",
		price: 10000,
		sides: [west()],
		jet: true,
		mod: "RHS",
		armaments: [
			{
				name: "1x GAU-8 30mm Gatling Gun",
				className: "RHS_A10",
				price: 0
			}, {
				name: "1x GAU-8 30mm Gatling Gun, 4x GBU-12 Bombs",
				className: "RHS_A10",
				price: 2000,
				pylons: ["", "", "", "rhs_mag_gbu12", "rhs_mag_gbu12", "", "rhs_mag_gbu12", "rhs_mag_gbu12"].map(className => ({className}))
			}
		]
	}, {
		name: "PO-30 Orca",
		price: 0,
		sides: [east()],
		disallowedForAi: true,
		armaments: [
			{
				name: "None",
				className: "O_Heli_Light_02_unarmed_F",
				price: 0,
				slingNum: 2,
			}, {
				name: "1x Minigun 6.5 mm",
				className: "O_Heli_Light_02_dynamicLoadout_F",
				price: 500,
				pylons: ["PylonWeapon_2000Rnd_65x39_belt"].map(className => ({className})),
				slingNum: 2,
			}, {
				name: "1x Minigun 6.5 mm, 12x DAR Missiles",
				className: "O_Heli_Light_02_dynamicLoadout_F",
				price: 1500,
				pylons: ["PylonWeapon_2000Rnd_65x39_belt","PylonRack_12Rnd_missiles"].map(className => ({className})),
				slingNum: 2,
			}, {
				name: "24x DAR Missiles",
				className: "O_Heli_Light_02_dynamicLoadout_F",
				price: 2000,
				pylons: ["PylonRack_12Rnd_missiles","PylonRack_12Rnd_missiles"].map(className => ({className})),
				slingNum: 2,
			}
		]
	}, {
		name: "Mi-290 Taru",
		price: 1500,
		sides: [east()],
		disallowedForAi: true,
		armaments: [
			{
				name: "Troop Transport",
				className: "O_Heli_Transport_04_covered_F",
				price: 0,
			}, {
				name: "Sling Loading",
				className: "O_Heli_Transport_04_F",
				price: 0,
				pylons: ["PylonWeapon_2000Rnd_65x39_belt"].map(className => ({className})),
				slingNum: 5
			}
		]
	}, {
		name: "Mi-48 Kajman",
		price: 7000,
		sides: [east()],
		armaments: [
			{
				name: "1x 30mm Gatling Gun",
				className: "O_Heli_Attack_02_dynamicLoadout_F",
				price: 0,
				manualFire: true,
			}, {
				name: "1x 30mm Gatling Gun, 38x Skyfire Missiles",
				className: "O_Heli_Attack_02_dynamicLoadout_F",
				price: 1000,
				manualFire: true,
				pylons: ["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire",""].map(className => ({className, isGunner: true})),
			}
		]
	}, {
		name: "Y-32 Xi'an",
		price: 7000,
		sides: [east()],
		jet: true,
		armaments: [
			{
				name: "1x 30mm Gatling Gun",
				className: "O_T_VTOL_02_infantry_dynamicLoadout_F",
				price: 0,
				manualFire: true,
			}, {
				name: "1x 30mm Gatling Gun, 38x Skyfire Missiles",
				className: "O_T_VTOL_02_infantry_dynamicLoadout_F",
				price: 1000,
				manualFire: true,
				pylons: ["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire"].map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "To-199 Neophron",
		price: 10000,
		sides: [east()],
		jet: true,
		armaments: [
			{
				name: "1x 30mm Gatling Gun",
				className: "O_Plane_CAS_02_dynamicLoadout_F",
				price: 0,
			}, {
				name: "1x 30mm Gatling Gun, 4x LOM-250G Bombs",
				className: "O_Plane_CAS_02_dynamicLoadout_F",
				price: 2000,
				pylons: ["", "", "", "PylonMissile_1Rnd_Bomb_03_F", "PylonMissile_1Rnd_Bomb_03_F", "PylonMissile_1Rnd_Bomb_03_F",
					"PylonMissile_1Rnd_Bomb_03_F"].map(className => ({className}))
			}
		]
	}, {
		name: "Ka-60",
		price: 0,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "None",
				className: "rhs_ka60_c",
				price: 0,
				slingNum: 3
			},
		]
	}, {
		name: "AN-2",
		price: 0,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "None",
				className: "RHS_AN2",
				price: 0
			},
		]
	}, {
		name: "Mi-8MT",
		price: 500,
		sides: [east()],
		mod: "RHS",
		disallowedForAi: true,
		armaments: [
			{
				name: "None",
				className: "RHS_Mi8mt_Cargo_vvsc",
				price: 0,
				slingNum: 3,
			}, {
				name: "2x PKT Gunners",
				className: "RHS_Mi8mt_vvsc",
				price: 500,
				slingNum: 3,
			}, {
				name: "3x PKT Gunners, 80x S-8",
				className: "RHS_Mi8MTV3_vvsc",
				price: 2000,
				slingNum: 3,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom"]
					.map(className => ({className}))
			}, {
				name: "3x PKT Gunners, 40x S-8, 2x GSh-23 Cannons",
				className: "RHS_Mi8MTV3_vvsc",
				price: 4000,
				slingNum: 3,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_upk23_ofz", "rhs_mag_upk23_ofz"]
					.map(className => ({className}))
			},
		]
	}, {
		name: "Mi-24V",
		price: 4000,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "1x YakB 12.7mm Cannon",
				className: "RHS_MI24V_vvsc",
				price: 0,
				manualFire: true,
			}, {
				name: "1x YakB 12.7mm Cannon, 80x S-8, 4x 9M120 Missiles",
				className: "RHS_MI24V_vvsc",
				price: 2000,
				manualFire: true,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom",
					"rhs_mag_9M120M_Mi24_2x", "rhs_mag_9M120M_Mi24_2x"].map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "Mi-24P",
		price: 5000,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "1x GSh30 Fixed Cannon",
				className: "RHS_MI24P_vvsc",
				price: 0,
			}, {
				name: "1x GSh30 Fixed Cannon, 80x S-8, 4x 9M120M Missiles",
				className: "RHS_MI24P_vvsc",
				price: 2000,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_9M120M_Mi24_2x",
					"rhs_mag_9M120M_Mi24_2x"].map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "Ka-52",
		price: 5500,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "1x 2A42 Cannon",
				className: "RHS_Ka52_vvsc",
				price: 0,
				manualFire: true,
			}, {
				name: "1x 2A42 Cannon, 40x S-8, 12x 9K121M Missiles",
				className: "RHS_Ka52_vvsc",
				price: 2000,
				manualFire: true,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom",
					"rhs_mag_9M120M_Mi24_2x", "rhs_mag_9M120M_Mi24_2x"].map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "Mi-28N",
		price: 7000,
		sides: [east()],
		mod: "RHS",
		armaments: [
			{
				name: "1x 2A42 Cannon",
				className: "rhs_mi28n_vvsc",
				price: 0,
				manualFire: true,
			}, {
				name: "1x 2A42 Cannon, 40x S-8 Missiles, 16x 9M120M Missiles",
				className: "rhs_mi28n_vvsc",
				price: 2000,
				manualFire: true,
				pylons: ["rhs_mag_b8v20a_s8kom", "rhs_mag_b8v20a_s8kom", "rhs_mag_9M120M_Mi28_8x", "rhs_mag_9M120M_Mi28_8x"]
					.map(className => ({className, isGunner: true}))
			}
		]
	}, {
		name: "Su-25",
		price: 10000,
		sides: [east()],
		mod: "RHS",
		jet: true,
		armaments: [
			{
				name: "1x GSh30 Cannon",
				className: "RHS_Su25SM_vvsc",
				price: 0,
			}, {
				name: "1x GSh30 Cannon, 4x FAB-250 Bombs",
				className: "RHS_Su25SM_vvsc",
				price: 2000,
				pylons: ["rhs_mag_fab250", "rhs_mag_fab250","rhs_mag_fab250", "rhs_mag_fab250"]
					.map(className => ({className}))
			}
		]
	},
]	
