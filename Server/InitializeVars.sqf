disableSerialization;

//=========================================
// Manually entered town info

TownFlags = 	[townFlag_0,	townFlag_1,		townFlag_2,		townFlag_3,			townFlag_4,		townFlag_5,				townFlag_6];
TownNames = 	["Agia Maria",	"Camp Maxwell",	"LZ Connor",	"Air Station Mike", "Camp Rogain",	"Kamino Firing Range",	"Camp Tempest"];
TownSizes = 	[50,			50,				100,			100,				100,			100,					50];

//=========================================
// Constant Award Values

TROOP_KILL_AWARD = 50;
LZ_KILL_AWARD = 100;
TROOP_LANDING_AWARD = 50;
TROOP_PARACHUTE_AWARD = 30;
TOWN_CAPTURE_AWARD = 500;
TOWN_CLEAR_AWARD = 500;
MINIMUM_INCOME = 0;
INCOME_PER_TOWN_TROOP = "TroopIncomeFactor" call BIS_fnc_getParamValue;

SlingMarkerTally = 0;
SlingMarkerArray = [];
SlingVehicleArray = [];

//=========================================
// Misc Values

INDEP_DEFAULT_RIFLEMAN = "I_soldier_F";

BLUFOR_DEFAULT_RIFLEMAN = "B_Soldier_F";
BLUFOR_CONVOY_VEHICLES = ["B_MRAP_01_hmg_F",			"B_MRAP_01_gmg_F",		"B_MRAP_01_hmg_F"];

BLUFOR_SLINGABLES = [		"",	"B_G_Offroad_01_armed_F",	"B_G_Offroad_01_AT_F",	"B_LSV_01_AT_F",	"B_MRAP_01_hmg_F",	"B_MRAP_01_gmg_F"];
BLUFOR_SLINGABLE_PRICES = [	0,	100,						250,					1000,					500,				500];


OPFOR_DEFAULT_RIFLEMAN = "O_Soldier_F";
OPFOR_CONVOY_VEHICLES = ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F"];

OPFOR_SLINGABLES = [		"",	"O_G_Offroad_01_armed_F",	"O_G_Offroad_01_AT_F",	"O_LSV_02_AT_F",	"O_MRAP_02_hmg_F",	"O_MRAP_02_gmg_F"];
OPFOR_SLINGABLE_PRICES = [	0,	100,					 	250,					1000,					500,				500];

SPECIAL_AA_SLING_NAMES =	["Prowler (AA)",	"Qilin (AA)"];
SPECIAL_AA_SLINGABLES =		["B_LSV_01_AT_F",	"O_LSV_02_AT_F"];

//					Pawnee								Unarmed Huron
AI_HELI_BLACKLIST = ["B_Heli_Light_01_dynamicLoadout_F","B_Heli_Transport_03_unarmed_F",
//					Armed Orca							Airlift taru				Transport Taru
					"O_Heli_Light_02_dynamicLoadout_F", "O_Heli_Transport_04_F",	"O_Heli_Transport_04_covered_F"];
					
// These are considered big bombs by certain damage handlers
BIG_BOMBS = ["Bomb_04_Plane_CAS_01_F", "Bomb_03_Plane_CAS_02_F"];


//=========================================
// Misc Values Overwritten if using RHS
if (("UseRHS" call BIS_fnc_getParamValue) == 1) then {


	INDEP_DEFAULT_RIFLEMAN = "rhsgref_ins_g_rifleman";

	BLUFOR_DEFAULT_RIFLEMAN = "rhsusf_usmc_marpat_wd_rifleman_m4";
	BLUFOR_CONVOY_VEHICLES = ["rhsusf_m1025_w_m2",			"rhsusf_m1025_w_mk19",		"rhsusf_m1025_w_m2"];
	
	BLUFOR_SLINGABLES = [		"",	"rhsusf_m1025_w_m2",	"rhsusf_m1025_w_mk19", "B_T_LSV_01_AT_F"];
	BLUFOR_SLINGABLE_PRICES = [	0,	500,					500,					1000];


	OPFOR_DEFAULT_RIFLEMAN = "rhs_vdv_flora_rifleman";
	OPFOR_CONVOY_VEHICLES = ["rhs_tigr_sts_vdv", "rhs_tigr_sts_vdv", "rhs_tigr_sts_vdv"];

	OPFOR_SLINGABLES = [		"",	"rhsgref_ins_uaz_dshkm",	"rhsgref_ins_uaz_ags",	"rhsgref_ins_uaz_spg9"];
	OPFOR_SLINGABLE_PRICES = [	0,	250,					 	250,					1000];

	SPECIAL_AA_SLING_NAMES =	["Prowler (AA)",	"Qilin (AA)",		"UAZ-3151 (AA)"];
	SPECIAL_AA_SLINGABLES =		["B_T_LSV_01_AT_F",	"O_T_LSV_02_AT_F",	"rhsgref_ins_uaz_spg9"];

	//					Unarmed Mi-8			Unarmed Black hawk	Black hawk with pylons	Sea Stallion
	AI_HELI_BLACKLIST = ["RHS_Mi8mt_Cargo_vvsc","RHS_UH60M2",		"RHS_UH60M_ESSS2",		"rhsusf_CH53E_USMC",
	//					AH-6M				Chinook
						"RHS_MELB_AH6M", "RHS_CH_47F_10"];
						
	// These are considered big bombs by certain damage handlers
	BIG_BOMBS = ["Bomb_04_Plane_CAS_01_F", "Bomb_03_Plane_CAS_02_F", "rhs_mag_gbu12", "rhs_mag_fab250"];

};


//=========================================
// Heli texture replacements

// CSAT Orca
_texClasses = [		"O_Heli_Light_02_unarmed_F"];
_texSides = [		east];
_texIndicies = [	0];
_texTextures = [	"a3\air_f\heli_light_02\data\heli_light_02_ext_opfor_co.paa"];

// CSAT Ghost Hawk
_texClasses = _texClasses + [		"B_Heli_Transport_01_F",			"B_Heli_Transport_01_F"];
_texSides = _texSides +	[			east,								east];
_texIndicies = _texIndicies + [		0,									1];
_texTextures = _texTextures + [		"Images\opfor_hex_camo_2048.jpg",	"Images\opfor_hex_camo_2048.jpg"];

TEX_REPLACE_CLASSNAMES = _texClasses;
TEX_REPLACE_SIDES = _texSides;
TEX_REPLACE_INDICES = _texIndicies;
TEX_REPLACE_TEXTURES = _texTextures;

//=========================================
// Blufor Helicopter Definitions

_name = [];
_price = [];
_armaNames = [];
_armaHeliClasses = [];
_armaPrice = [];
_armaManualFire = [];
_armaPylonClasses = [];
_armaPylonIsGunner = [];
_slingNum = [];

if (("UseRHS" call BIS_fnc_getParamValue) == 0) then {
	
	_name = _name + ["MH-9 Hummingbird"];
	_price = _price + [0];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Light_01_F"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						0]];

	_name = _name + ["AH-9 Pawnee"];
	_price = _price + [1500];
	_armaNames = _armaNames + [[					"2x M134 Minigun",						"2x M134 Minigun, 24x DAR Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Light_01_dynamicLoadout_F",		"B_Heli_Light_01_dynamicLoadout_F"]];
	_armaPrice = _armaPrice + [[					0,										1000]];
	_armaManualFire = _armaManualFire + [[			false,									false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],										["PylonRack_12Rnd_missiles","PylonRack_12Rnd_missiles"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[false,false]]];
	_slingNum = _slingNum + [[						0,										0]];


	_name = _name + ["UH-80 Ghost Hawk"];
	_price = _price + [2500];
	_armaNames = _armaNames + [[					"2x M134 Gunners"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Transport_01_F"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						2]];


	_name = _name + ["CH-67 Huron"];
	_price = _price + [3000];
	_armaNames = _armaNames + [[					"None",								"2x M134 Gunners"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Transport_03_unarmed_F",	"B_Heli_Transport_03_F"]];
	_armaPrice = _armaPrice + [[					0,									1000]];
	_armaManualFire = _armaManualFire + [[			false,								false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],									[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],									[]]];
	_slingNum = _slingNum + [[						5,									5]];


	_name = _name + ["V-44 X Blackfish"];
	_price = _price + [4000];
	_armaNames = _armaNames + [[					"None",						"105mm, 40mm, and 20mm Cannons"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_T_VTOL_01_infantry_F",	"B_T_VTOL_01_armed_F"]];
	_armaPrice = _armaPrice + [[					0,							6000]];
	_armaManualFire = _armaManualFire + [[			false,						false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],							[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],							[]]];
	_slingNum = _slingNum + [[						0,							0]];


	_name = _name + ["AH-99 Blackfoot"];
	_price = _price + [6000];
	_armaNames = _armaNames + [[					"1x 20mm Gatling Gun",					"1x 20mm Gatling Gun, 12x DAGR Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Attack_01_dynamicLoadout_F",	"B_Heli_Attack_01_dynamicLoadout_F"]];
	_armaPrice = _armaPrice + [[					0,										500]];
	_armaManualFire = _armaManualFire + [[			true,									true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],										["PylonRack_12Rnd_PG_missiles"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true]]];
	_slingNum = _slingNum + [[						0,										0]];


	if (("IncludeJets" call BIS_fnc_getParamValue) == 1) then {

		_name = _name + ["A-164 Wipeout"];
		_price = _price + [10000];
		_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",				"1x 30mm Gatling Gun, 4x GBU-12 Bombs"]];
		_armaHeliClasses = _armaHeliClasses + [[		"B_Plane_CAS_01_dynamicLoadout_F",	"B_Plane_CAS_01_dynamicLoadout_F"]];
		_armaPrice = _armaPrice + [[					0,									2000]];
		_armaManualFire = _armaManualFire + [[			false,								false]];
		_armaPylonClasses = _armaPylonClasses + [[		[],									["", "", "", "PylonMissile_1Rnd_Bomb_04_F",
				"PylonMissile_1Rnd_Bomb_04_F","PylonMissile_1Rnd_Bomb_04_F","PylonMissile_1Rnd_Bomb_04_F"]]];
		_armaPylonIsGunner = _armaPylonIsGunner + [[	[],									[false, false, false, false, false, false, false]]];
		_slingNum = _slingNum + [[						0,									0]];
		
	};
	
} else {

	_name = _name + ["MH-6M Little Bird"];
	_price = _price + [0];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_MELB_MH6M"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						0]];
	
		
	_name = _name + ["UH-1Y Venom"];
	_price = _price + [500];
	_armaNames = _armaNames + [[					"None",					"2x M134 Gunners",		"2x M134 Gunners, 14x Hydra Rockets"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_UH1Y_UNARMED",		"RHS_UH1Y",				"RHS_UH1Y"]];
	_armaPrice = _armaPrice + [[					0,						1500,					2500]];
	_armaManualFire = _armaManualFire + [[			false,					false,					false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],						[],						["rhs_mag_M151_7_green","rhs_mag_M151_7_green"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],						[],						[false, false]]];
	_slingNum = _slingNum + [[						0,						0,						0]];

	
	_name = _name + ["CH-53E Sea Stallion"];
	_price = _price + [1000];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"rhsusf_CH53E_USMC"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						2]];

	
	_name = _name + ["UH-60M Black Hawk"];
	_price = _price + [1500];
	_armaNames = _armaNames + [[					"None",					"2x M134 Gunners",		"38x Hydra Rockets"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_UH60M2",			"RHS_UH60M",			"RHS_UH60M_ESSS2"]];
	_armaPrice = _armaPrice + [[					0,						1500,					2500]];
	_armaManualFire = _armaManualFire + [[			false,					false,					false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],						[],						["rhs_mag_M151_19","rhs_mag_M151_19"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],						[],						[false, false]]];
	_slingNum = _slingNum + [[						2,						2,						2]];

	
	_name = _name + ["AH-6M Little Bird"];
	_price = _price + [2000];
	_armaNames = _armaNames + [[					"2x M134 Minigun",												"2x M134 Minigun, 14x Hydra Rockets"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_MELB_AH6M",												"RHS_MELB_AH6M"]];
	_armaPrice = _armaPrice + [[					0,																1000]];
	_armaManualFire = _armaManualFire + [[			false,															false]];
	_armaPylonClasses = _armaPylonClasses + [[		["","rhs_mag_m134_pylon_3000","rhs_mag_m134_pylon_3000",""],	["rhs_mag_M151_7",
															"rhs_mag_m134_pylon_3000","rhs_mag_m134_pylon_3000","rhs_mag_M151_7"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[false, false, false, false],									[false, false, false, false]]];
	_slingNum = _slingNum + [[						0,																0]];
	
	
	_name = _name + ["CH-47F Chinook"];
	_price = _price + [3000];
	_armaNames = _armaNames + [[					"2x M134 Gunners"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_CH_47F_10"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						3]];
	
	
	_name = _name + ["AH-1Z Viper"];
	_price = _price + [7000];
	_armaNames = _armaNames + [[					"1x M197 Electric",	"1x M197 Electric, 38x Hydra, 8x AGM-114, 2x AIM-9"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_AH1Z",			"RHS_AH1Z"]];
	_armaPrice = _armaPrice + [[					0,					2000]];
	_armaManualFire = _armaManualFire + [[			true,				true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],					["rhs_mag_Sidewinder_heli_2","rhs_mag_AGM114K_4",
					"rhs_mag_M151_19_green","rhs_mag_M151_19_green","rhs_mag_AGM114K_4","rhs_mag_Sidewinder_heli_2"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],					[true, true, true, true, true, true]]];
	_slingNum = _slingNum + [[						0,					0]];
	
	_name = _name + ["AH-64D Longbow"];
	_price = _price + [8000];
	_armaNames = _armaNames + [[					"1x M230 Cannon",	"1x M230 Cannon, 38x Hydra Rockets, 8x AGM-114s"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_AH64D",		"RHS_AH64D"]];
	_armaPrice = _armaPrice + [[					0,					2000]];
	_armaManualFire = _armaManualFire + [[			true,				true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],					["","rhs_mag_M151_19","rhs_mag_AGM114K_4",
												"rhs_mag_AGM114K_4","rhs_mag_M151_19",""]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],					[false, true, true, true, true, false]]];
	_slingNum = _slingNum + [[						0,					0]];
	
	
	_name = _name + ["C-130J Super Hercules"];
	_price = _price + [1000];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_C130J"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						0]];

	
	if (("IncludeJets" call BIS_fnc_getParamValue) == 1) then {

		_name = _name + ["A-10 Warthog"];
		_price = _price + [10000];
		_armaNames = _armaNames + [[					"1x GAU-8 30mm Gatling Gun",		"1x GAU-8 30mm Gatling Gun, 4x GBU-12 Bombs"]];
		_armaHeliClasses = _armaHeliClasses + [[		"RHS_A10",							"RHS_A10"]];
		_armaPrice = _armaPrice + [[					0,									2000]];
		_armaManualFire = _armaManualFire + [[			false,								false]];
		_armaPylonClasses = _armaPylonClasses + [[		[],									["", "", "", "rhs_mag_gbu12",
				"rhs_mag_gbu12","","rhs_mag_gbu12","rhs_mag_gbu12"]]];
		_armaPylonIsGunner = _armaPylonIsGunner + [[	[],									[false, false, false, false, false, false, false, false]]];
		_slingNum = _slingNum + [[						0,									0]];
		
	};
};


BLUFOR_HELI_NAMES = _name;
BLUFOR_HELI_PRICES = _price;
BLUFOR_ARMA_NAMES = _armaNames;
BLUFOR_ARMA_CLASSNAMES = _armaHeliClasses;
BLUFOR_ARMA_PRICES = _armaPrice;
BLUFOR_ARMA_MANUALFIRE = _armaManualFire;
BLUFOR_ARMA_PYLONS = _armaPylonClasses;
BLUFOR_ARMA_ISGUNNER = _armaPylonIsGunner;
BLUFOR_SLING_NUMS = _slingNum;



//=========================================
// Opfor Helicopter Definitions

_name = [];
_price = [];
_armaNames = [];
_armaHeliClasses = [];
_armaPrice = [];
_armaManualFire = [];
_armaPylonClasses = [];
_armaPylonIsGunner = [];
_slingNum = [];

if (("UseRHS" call BIS_fnc_getParamValue) == 0) then {

	_name = _name + ["PO-30 Orca"];
	_price = _price + [0];
	_armaNames = _armaNames + [[					"None",							"1x Minigun 6.5 mm",				"1x Minigun 6.5 mm, 12x DAR Missiles", 								"24x DAR Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Light_02_unarmed_F",	"O_Heli_Light_02_dynamicLoadout_F",	"O_Heli_Light_02_dynamicLoadout_F",									"O_Heli_Light_02_dynamicLoadout_F"]];
	_armaPrice = _armaPrice + [[					0,								500,								1500,																2000]];
	_armaManualFire = _armaManualFire + [[			false,							false,								false,																false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],								["PylonWeapon_2000Rnd_65x39_belt"],	["PylonWeapon_2000Rnd_65x39_belt","PylonRack_12Rnd_missiles"],	["PylonRack_12Rnd_missiles","PylonRack_12Rnd_missiles"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],								[false],							[false,false],														[false,false]]];
	_slingNum = _slingNum + [[						2,								2,									2,																	2]];


	_name = _name + ["Mi-290 Taru"];
	_price = _price + [1500];
	_armaNames = _armaNames + [[					"Troop Transport",					"Sling Loading"]];
	_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Transport_04_covered_F",	"O_Heli_Transport_04_F"]];
	_armaPrice = _armaPrice + [[					0,									0]];
	_armaManualFire = _armaManualFire + [[			false,								false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],									[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],									[]]];
	_slingNum = _slingNum + [[						0,									5]];


	_name = _name + ["UH-80 Ghost Hawk"];
	_price = _price + [2500];
	_armaNames = _armaNames + [[					"2x M134 Gunners"]];
	_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Transport_01_F"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						2]];


	_name = _name + ["Mi-48 Kajman"];
	_price = _price + [7000];
	_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",					"1x 30mm Gatling Gun, 38x Skyfire Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Attack_02_dynamicLoadout_F",	"O_Heli_Attack_02_dynamicLoadout_F"]];
	_armaPrice = _armaPrice + [[					0,										1000]];
	_armaManualFire = _armaManualFire + [[			true,									true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],										["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire",""]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true,true,true,true]]];
	_slingNum = _slingNum + [[						0,										0]];


	if (("IncludeJets" call BIS_fnc_getParamValue) == 1) then {

		_name = _name + ["Y-32 Xi'an"];
		_price = _price + [7000];
		_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",					"1x 30mm Gatling Gun, 38x Skyfire Missiles"]];
		_armaHeliClasses = _armaHeliClasses + [[		"O_T_VTOL_02_infantry_dynamicLoadout_F","O_T_VTOL_02_infantry_dynamicLoadout_F"]];
		_armaPrice = _armaPrice + [[					0,										1000]];
		_armaManualFire = _armaManualFire + [[			true,									true]];
		_armaPylonClasses = _armaPylonClasses + [[		[],										["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire"]]];
		_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true,true,true]]];
		_slingNum = _slingNum + [[						0,										0]];


		_name = _name + ["To-199 Neophron"];
		_price = _price + [10000];
		_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",				"1x 30mm Gatling Gun, 4x LOM-250G Bombs"]];
		_armaHeliClasses = _armaHeliClasses + [[		"O_Plane_CAS_02_dynamicLoadout_F",	"O_Plane_CAS_02_dynamicLoadout_F"]];
		_armaPrice = _armaPrice + [[					0,									2000]];
		_armaManualFire = _armaManualFire + [[			false,								false]];
		_armaPylonClasses = _armaPylonClasses + [[		[],									["", "", "", "PylonMissile_1Rnd_Bomb_03_F",
				"PylonMissile_1Rnd_Bomb_03_F", "PylonMissile_1Rnd_Bomb_03_F", "PylonMissile_1Rnd_Bomb_03_F"]]];
		_armaPylonIsGunner = _armaPylonIsGunner + [[	[],									[false, false, false, false, false, false, false]]];
		_slingNum = _slingNum + [[						0,									0]];

	};
	
} else {

	_name = _name + ["Ka-60"];
	_price = _price + [0];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"rhs_ka60_c"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						3]];
	
	
	_name = _name + ["AN-2"];
	_price = _price + [0];
	_armaNames = _armaNames + [[					"None"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_AN2"]];
	_armaPrice = _armaPrice + [[					0]];
	_armaManualFire = _armaManualFire + [[			false]];
	_armaPylonClasses = _armaPylonClasses + [[		[]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];
	_slingNum = _slingNum + [[						0]];

	
	_name = _name + ["Mi-8MT"];
	_price = _price + [500];
	_armaNames = _armaNames + [[				"None",					"2x PKT Gunners",	"3x PKT Gunners, 80x S-8",	"3x PKT Gunners, 40x S-8, 2x GSh-23 Cannons"]];
	_armaHeliClasses = _armaHeliClasses + [[	"RHS_Mi8mt_Cargo_vvsc",	"RHS_Mi8mt_vvsc",	"RHS_Mi8MTV3_vvsc",			"RHS_Mi8MTV3_vvsc"]];
	_armaPrice = _armaPrice + [[				0,						500,				2000,						4000]];
	_armaManualFire = _armaManualFire + [[		false,					false,				false,						false]];
	_armaPylonClasses = _armaPylonClasses + [[	[],						[],					["rhs_mag_b8v20a_s8kom",
			"rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom"],["rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom","rhs_mag_upk23_ofz","rhs_mag_upk23_ofz"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[[],						[],					[false,false,false,false],	[false, false, false, false]]];
	_slingNum = _slingNum + [[					3,						3,					3,							3]];
	
	
	_name = _name + ["Mi-24V"];
	_price = _price + [4000];
	_armaNames = _armaNames + [[					"1x YakB 12.7mm Cannon",	"1x YakB 12.7mm Cannon, 80x S-8, 4x 9M120 Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_MI24V_vvsc",			"RHS_MI24V_vvsc"]];
	_armaPrice = _armaPrice + [[					0,							2000]];
	_armaManualFire = _armaManualFire + [[			true,						true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],							["rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom",
		"rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom","rhs_mag_9M120M_Mi24_2x","rhs_mag_9M120M_Mi24_2x"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],							[true, true, true, true, true, true]]];
	_slingNum = _slingNum + [[						0,							0]];
	
	
	_name = _name + ["Mi-24P"];
	_price = _price + [5000];
	_armaNames = _armaNames + [[					"1x GSh30 Fixed Cannon",	"1x GSh30 Fixed Cannon, 80x S-8, 4x 9M120M Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_MI24P_vvsc",			"RHS_MI24P_vvsc"]];
	_armaPrice = _armaPrice + [[					0,							2000]];
	_armaManualFire = _armaManualFire + [[			false,						false]];
	_armaPylonClasses = _armaPylonClasses + [[		[],							["rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom",
		"rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom","rhs_mag_9M120M_Mi24_2x","rhs_mag_9M120M_Mi24_2x"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],							[false, false, false, false, false, false]]];
	_slingNum = _slingNum + [[						0,							0]];
	

	_name = _name + ["Ka-52"];
	_price = _price + [5500];
	_armaNames = _armaNames + [[					"1x 2A42 Cannon",			"1x 2A42 Cannon, 40x S-8, 12x 9K121M Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"RHS_Ka52_vvsc",			"RHS_Ka52_vvsc"]];
	_armaPrice = _armaPrice + [[					0,							2000]];
	_armaManualFire = _armaManualFire + [[			true,						true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],							["rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom",
		"rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom","rhs_mag_9M120M_Mi24_2x","rhs_mag_9M120M_Mi24_2x"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],							[true, true, true, true, true, true]]];
	_slingNum = _slingNum + [[						0,							0]];
	
	
	_name = _name + ["Mi-28N"];
	_price = _price + [7000];
	_armaNames = _armaNames + [[					"1x 2A42 Cannon",			"1x 2A42 Cannon, 40x S-8 Missiles, 16x 9M120M Missiles"]];
	_armaHeliClasses = _armaHeliClasses + [[		"rhs_mi28n_vvsc",			"rhs_mi28n_vvsc"]];
	_armaPrice = _armaPrice + [[					0,							2000]];
	_armaManualFire = _armaManualFire + [[			true,						true]];
	_armaPylonClasses = _armaPylonClasses + [[		[],							["rhs_mag_b8v20a_s8kom","rhs_mag_b8v20a_s8kom",
											"rhs_mag_9M120M_Mi28_8x","rhs_mag_9M120M_Mi28_8x"]]];
	_armaPylonIsGunner = _armaPylonIsGunner + [[	[],							[true, true, true, true]]];
	_slingNum = _slingNum + [[						0,							0]];
	
	
	if (("IncludeJets" call BIS_fnc_getParamValue) == 1) then {

		_name = _name + ["Su-25"];
		_price = _price + [10000];
		_armaNames = _armaNames + [[					"1x GSh30 Cannon",		"1x GSh30 Cannon, 4x FAB-250 Bombs"]];
		_armaHeliClasses = _armaHeliClasses + [[		"RHS_Su25SM_vvsc",		"RHS_Su25SM_vvsc"]];
		_armaPrice = _armaPrice + [[					0,						2000]];
		_armaManualFire = _armaManualFire + [[			false,					false]];
		_armaPylonClasses = _armaPylonClasses + [[		[],						["rhs_mag_fab250",
				"rhs_mag_fab250","rhs_mag_fab250","rhs_mag_fab250"]]];
		_armaPylonIsGunner = _armaPylonIsGunner + [[	[],						[false, false, false, false]]];
		_slingNum = _slingNum + [[						0,						0]];
		
	};
	
};

OPFOR_HELI_NAMES = _name;
OPFOR_HELI_PRICES = _price;
OPFOR_ARMA_NAMES = _armaNames;
OPFOR_ARMA_CLASSNAMES = _armaHeliClasses;
OPFOR_ARMA_PRICES = _armaPrice;
OPFOR_ARMA_MANUALFIRE = _armaManualFire;
OPFOR_ARMA_PYLONS = _armaPylonClasses;
OPFOR_ARMA_ISGUNNER = _armaPylonIsGunner;
OPFOR_SLING_NUMS = _slingNum;


//=========================================
// Bounty classnames created by concatenating slingable and heli arrays

BOUNTY_CLASSNAMES = BLUFOR_SLINGABLES + OPFOR_SLINGABLES;
BOUNTY_PRICES = BLUFOR_SLINGABLE_PRICES + OPFOR_SLINGABLE_PRICES;

for "_i" from 0 to (count BLUFOR_HELI_PRICES - 1) do {
	BOUNTY_CLASSNAMES = BOUNTY_CLASSNAMES + [(BLUFOR_ARMA_CLASSNAMES select _i) select 0];
};
BOUNTY_PRICES = BOUNTY_PRICES + BLUFOR_HELI_PRICES;


for "_i" from 0 to (count OPFOR_HELI_PRICES - 1) do {
	BOUNTY_CLASSNAMES = BOUNTY_CLASSNAMES + [(OPFOR_ARMA_CLASSNAMES select _i) select 0];
};
BOUNTY_PRICES = BOUNTY_PRICES + OPFOR_HELI_PRICES;

for "_i" from 0 to (count BOUNTY_PRICES - 1) do {
	BOUNTY_PRICES set [_i, (BOUNTY_PRICES select _i) / 2];
};

