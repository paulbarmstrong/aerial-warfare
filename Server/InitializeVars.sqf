disableSerialization;

BLUFOR_DEFAULT_RIFLEMAN = "B_Soldier_F";
BLUFOR_GARAGE_VEHICLES = ["B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"];

OPFOR_DEFAULT_RIFLEMAN = "O_Soldier_F";
OPFOR_GARAGE_VEHICLES = ["O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F"];


_name = [];
_price = [];
_armaNames = [];
_armaHeliClasses = [];
_armaPrice = [];
_armaManualFire = [];
_armaPylonClasses = [];
_armaPylonIsGunner = [];

_name = _name + ["MH-9 Hummingbird"];
_price = _price + [0];
_armaNames = _armaNames + [[					"Empty"]];
_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Light_01_F"]];
_armaPrice = _armaPrice + [[					0]];
_armaManualFire = _armaManualFire + [[			false]];
_armaPylonClasses = _armaPylonClasses + [[		[]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];


_name = _name + ["AH-9 Pawnee"];
_price = _price + [4000];
_armaNames = _armaNames + [[					"2x M134 Minigun",						"2x M134 Minigun, 24x DAR Missiles"]];
_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Light_01_dynamicLoadout_F",		"B_Heli_Light_01_dynamicLoadout_F"]];
_armaPrice = _armaPrice + [[					0,										500]];
_armaManualFire = _armaManualFire + [[			false,									false]];
_armaPylonClasses = _armaPylonClasses + [[		[],										["PylonRack_12Rnd_missiles","PylonRack_12Rnd_missiles"]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[false,false]]];


_name = _name + ["UH-80 Ghost Hawk"];
_price = _price + [3000];
_armaNames = _armaNames + [[					"2x M134 Gunners"]];
_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Transport_01_F"]];
_armaPrice = _armaPrice + [[					0]];
_armaManualFire = _armaManualFire + [[			false]];
_armaPylonClasses = _armaPylonClasses + [[		[]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];


_name = _name + ["AH-99 Blackfoot"];
_price = _price + [5000];
_armaNames = _armaNames + [[					"1x 20mm Gatling Gun",					"1x 20mm Gatling Gun, 24x DAGR Missiles"]];
_armaHeliClasses = _armaHeliClasses + [[		"B_Heli_Attack_01_dynamicLoadout_F",	"B_Heli_Attack_01_dynamicLoadout_F"]];
_armaPrice = _armaPrice + [[					0,										500]];
_armaManualFire = _armaManualFire + [[			true,									true]];
_armaPylonClasses = _armaPylonClasses + [[		[],										["PylonRack_12Rnd_PG_missiles","PylonRack_12Rnd_PG_missiles","",""]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true,true,true,true]]];


_name = _name + ["V-44 X Blackfish"];
_price = _price + [2000];
_armaNames = _armaNames + [[					"Empty"]];
_armaHeliClasses = _armaHeliClasses + [[		"B_T_VTOL_01_infantry_F"]];
_armaPrice = _armaPrice + [[					0]];
_armaManualFire = _armaManualFire + [[			false]];
_armaPylonClasses = _armaPylonClasses + [[		[]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];



BLUFOR_HELI_NAMES = _name;
BLUFOR_HELI_PRICES = _price;
BLUFOR_ARMA_NAMES = _armaNames;
BLUFOR_ARMA_CLASSNAMES = _armaHeliClasses;
BLUFOR_ARMA_PRICES = _armaPrice;
BLUFOR_ARMA_MANUALFIRE = _armaManualFire;
BLUFOR_ARMA_PYLONS = _armaPylonClasses;
BLUFOR_ARMA_ISGUNNER = _armaPylonIsGunner;




_name = [];
_price = [];
_armaNames = [];
_armaHeliClasses = [];
_armaPrice = [];
_armaManualFire = [];
_armaPylonClasses = [];
_armaPylonIsGunner = [];

_name = _name + ["PO-30 Orca"];
_price = _price + [0];
_armaNames = _armaNames + [[					"Empty",						"1x Minigun 6.5 mm",				"1x Minigun 6.5 mm, 12x DAGR Missiles"]];
_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Light_02_unarmed_F",	"O_Heli_Light_02_dynamicLoadout_F",	"O_Heli_Light_02_dynamicLoadout_F"]];
_armaPrice = _armaPrice + [[					0,								1000,								2000]];
_armaManualFire = _armaManualFire + [[			false,							false,								false]];
_armaPylonClasses = _armaPylonClasses + [[		[],								["PylonWeapon_2000Rnd_65x39_belt"],	["PylonWeapon_2000Rnd_65x39_belt","PylonRack_12Rnd_PG_missiles"]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[],								[false],							[false,false]]];


_name = _name + ["Mi-290 Taru"];
_price = _price + [1000];
_armaNames = _armaNames + [[					"Empty"]];
_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Transport_04_covered_F"]];
_armaPrice = _armaPrice + [[					0]];
_armaManualFire = _armaManualFire + [[			false]];
_armaPylonClasses = _armaPylonClasses + [[		[]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[]]];


_name = _name + ["Mi-48 Kajman"];
_price = _price + [5000];
_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",					"1x 30mm Gatling Gun, 38x Skyfire Missiles"]];
_armaHeliClasses = _armaHeliClasses + [[		"O_Heli_Attack_02_dynamicLoadout_F",	"O_Heli_Attack_02_dynamicLoadout_F"]];
_armaPrice = _armaPrice + [[					0,										1000]];
_armaManualFire = _armaManualFire + [[			true,									true]];
_armaPylonClasses = _armaPylonClasses + [[		[],										["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire",""]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true,true,true,true]]];

_name = _name + ["Y-32 Xi'an"];
_price = _price + [4000];
_armaNames = _armaNames + [[					"1x 30mm Gatling Gun",					"1x 30mm Gatling Gun, 38x Skyfire Missiles"]];
_armaHeliClasses = _armaHeliClasses + [[		"O_T_VTOL_02_infantry_dynamicLoadout_F","O_T_VTOL_02_infantry_dynamicLoadout_F"]];
_armaPrice = _armaPrice + [[					0,										1000]];
_armaManualFire = _armaManualFire + [[			true,									true]];
_armaPylonClasses = _armaPylonClasses + [[		[],										["","PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire",""]]];
_armaPylonIsGunner = _armaPylonIsGunner + [[	[],										[true,true,true,true]]];



OPFOR_HELI_NAMES = _name;
OPFOR_HELI_PRICES = _price;
OPFOR_ARMA_NAMES = _armaNames;
OPFOR_ARMA_CLASSNAMES = _armaHeliClasses;
OPFOR_ARMA_PRICES = _armaPrice;
OPFOR_ARMA_MANUALFIRE = _armaManualFire;
OPFOR_ARMA_PYLONS = _armaPylonClasses;
OPFOR_ARMA_ISGUNNER = _armaPylonIsGunner;







