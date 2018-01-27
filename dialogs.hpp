////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by PULL, v1.063, #Pykolu)
////////////////////////////////////////////////////////
class HitmarkerDialog
{
	idd = 8365
	movingEnabled = false;
	class controls
	{
		class HitmarkerPicture: RscPicture
		{
			idc = 1200;
			text = "neon.paa";
			x = 0.45 * safezoneW + safezoneX;
			y = 0.45 * safezoneH + safezoneY;
			w = 0.1 * safezoneW;
			h = 0.1 * safezoneH;
			colorText[] = {1.0,1.0,1.0,1.0};
		};
	};
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////



////////////////////////////////////////////////////////  VehicleMenu thing
// GUI EDITOR OUTPUT START (by PULL, v1.063, #Reboky)
////////////////////////////////////////////////////////

class Sortie_Dialog
{
	idd = 8366;
	movingEnabled = false;
	class controls
	{
		class Background: RscPicture
		{
			idc = 1100;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.23703175 * safezoneW + safezoneX; // was 0.324688
			y = 0.291 * safezoneH + safezoneY; // was 0.335
			w = 0.5259375 * safezoneW; // was 0.350625
			h = 0.418 * safezoneH; // was 0.374
			//colorBackground[] = {0,0,0,0.6};
		};

		class MenuTitle: RscStructuredText
		{
			idc = 1101;
			text = "Aircraft Selection";
			x = 0.23703175 * safezoneW + safezoneX; // was 0.324688
			y = 0.291 * safezoneH + safezoneY;
			w = 0.5259375 * safezoneW; // was 0.350625
			h = 0.044 * safezoneH;
			colorBackground[] = {0,0.5,1,0.7};
		};
		
		// Vehicle listbox and button:
		class VehicleList: RscListbox
		{
			idc = 1200;
			text = "Test"; //--- ToDo: Localize;
			x = 0.24734375 * safezoneW + safezoneX;
			y = 0.396872 * safezoneH + safezoneY;
			w = 0.1278752 * safezoneW;
			h = 0.2 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
			colorActive[] = {0,0,0,0.6};
			
			colorSelect[] = {1,1,1,1};
			colorSelect2[] = {1,1,1,1};
			colorSelectBackground[] = {0,0.5,1,0.6};
			colorSelectBackground2[] = {0,0.5,1,0.6};
			
			onLBSelChanged = [] spawn FNC_HeliSelChanged;
		};
		class VehicleListTitle: RscStructuredText
		{
			idc = 1201;
			text = "Select Aircraft:"; //--- ToDo: Localize;
			x = 0.24734375 * safezoneW + safezoneX;
			y = 0.355624 * safezoneH + safezoneY;
			w = 0.1278752 * safezoneW;
			h = 0.030936 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
		};
		
		
		// Armament listbox and button:
		class ArmamentList: RscListbox
		{
			idc = 1300;
			text = "Test"; //--- ToDo: Localize;
			x = 0.38553095 * safezoneW + safezoneX;
			y = 0.396872 * safezoneH + safezoneY;
			w = 0.2289391 * safezoneW;
			h = 0.2 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
			colorActive[] = {0,0,0,0.6};
			
			colorSelect[] = {1,1,1,1};
			colorSelect2[] = {1,1,1,1};
			colorSelectBackground[] = {0,0.5,1,0.6};
			colorSelectBackground2[] = {0,0.5,1,0.6};
			
			onLBSelChanged = [] spawn FNC_ArmaSelChanged;
		};
		class ArmamentListTitle: RscStructuredText
		{
			idc = 1301;
			text = "Select Armament:"; //--- ToDo: Localize;
			x = 0.38553095 * safezoneW + safezoneX;
			y = 0.355624 * safezoneH + safezoneY;
			w = 0.2289391 * safezoneW;
			h = 0.030936 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
		};
		
		// Special troop selection placeholder
		class TroopList: RscListbox
		{
			idc = 1400;
			text = "Test"; //--- ToDo: Localize;
			x = 0.62478205 * safezoneW + safezoneX; // magic distance: 0.010312
			y = 0.396872 * safezoneH + safezoneY;
			w = 0.1278752 * safezoneW;
			h = 0.2 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
			colorActive[] = {0,0,0,0.6};
			
			colorSelect[] = {1,1,1,1};
			colorSelect2[] = {1,1,1,1};
			colorSelectBackground[] = {0,0.5,1,0.6};
			colorSelectBackground2[] = {0,0.5,1,0.6};
			
			onLBSelChanged = [] spawn FNC_HeliSelChanged;
		};
		class TroopListTitle: RscStructuredText
		{
			idc = 1401;
			text = "Select Troops:"; //--- ToDo: Localize;
			x = 0.62478205 * safezoneW + safezoneX;
			y = 0.355624 * safezoneH + safezoneY;
			w = 0.1278752 * safezoneW;
			h = 0.030936 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
		};
		
		// Spawn button which is full length
		class SpawnButton: RscButton
		{
			idc = 1600;
			text = "Select and Spawn"; //--- ToDo: Localize;
			x = 0.24734375 * safezoneW + safezoneX;
			y = 0.641 * safezoneH + safezoneY;
			w = 0.5053135 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = {0,0,0,0.6};
			action = [] spawn FNC_SpawnButtonPressed;
		};
	};
}
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////



