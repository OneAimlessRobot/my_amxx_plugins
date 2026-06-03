/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __WEAPON_LOOKUP_TABLE_H__
#define __WEAPON_LOOKUP_TABLE_H__

#define min(a,b) ((a < b) ? a : b)
#define max(a,b) ((a > b) ? a : b)

typedef uint32_t state_cell_type_t;

typedef enum {

    MY_SLOT_PRIMARY = 0,
    MY_SLOT_SECONDARY,
    MY_SLOT_KNIFE,
    MY_SLOT_GRENADE,
    MY_SLOT_C4

}my_weapon_slots;

typedef enum {
	
	CSW_NONE = 0,			//0
	CSW_P228,				//1
	CSW_GLOCK,				//2
	CSW_SCOUT,				//3
	CSW_HEGRENADE,			//4
	CSW_XM1014,				//5
	CSW_C4,					//6
	CSW_MAC10,				//7
	CSW_AUG,				//8
	CSW_SMOKEGRENADE,		//9
	CSW_ELITE,				//10
	CSW_FIVESEVEN,			//11
	CSW_UMP45,				//12
	CSW_SG550,				//13
	CSW_GALIL,				//14
	CSW_FAMAS,				//15
	CSW_USP,				//16
	CSW_GLOCK18,			//17
	CSW_AWP,				//18
	CSW_MP5NAVY,			//19
	CSW_M249,				//20
	CSW_M3,					//21
	CSW_M4A1,				//22
	CSW_TMP,				//23
	CSW_G3SG1,				//24
	CSW_FLASHBANG,			//25
	CSW_DEAGLE,				//26
	CSW_SG552,				//27
	CSW_AK47,				//28
	CSW_KNIFE,				//29
	CSW_P90					//30

}my_weapon_ids;

typedef enum{
	
	AMMOID_KNIFE = -1,		//-1
	AMMOID_NONE,			//0
	
	/*
	 * 
	 * One, two, three...
	 *
	*/
	
	AMMOID_338MAGNUM,  		//1
	AMMOID_762NATO,    		//2
	AMMOID_556NATOBOX, 		//3
	AMMOID_556NATO,    		//4
	AMMOID_BUCKSHOT,   		//5
	AMMOID_45ACP,	   		//6
	AMMOID_57,	       		//7
	AMMOID_50AE,	   		//8
	AMMOID_357SIG,	   		//9
	AMMOID_9MM,	   	   		//10
	AMMOID_FLASHBANG,  		//11
	AMMOID_HEGRENADE,  		//12
	AMMOID_SMOKEGRENADE,	//13
	AMMOID_C4				//14
	
	
	
}my_ammo_ids;

#define CSW_LAST_WEAPON     CSW_P90


#define is_valid_cs_weapon(a) ((a > CSW_NONE) && (a != CSW_GLOCK) && (a <= CSW_P90))

typedef struct def_weapon_data_struct{
	
	float wpn_struct_primary_attack_delay,
		wpn_struct_secondary_attack_delay,
		wpn_struct_reload_delay;
	
	uint16_t wpn_struct_max_clip;
	
	my_ammo_ids wpn_struct_ammo_id;
	
	uint16_t wpn_struct_wpn_position,
		wpn_struct_max_bp_ammo;
    
    my_weapon_slots wpn_slot;
	
}def_weapon_data_struct;

const def_weapon_data_struct weapon_data_structs_array[CSW_LAST_WEAPON+1] = {
	
	{ 0.000000f, 0.000000f, 0.00f, 0, AMMOID_NONE, 0, 0, MY_SLOT_PRIMARY },

	{ 0.150000f, 0.150000f, 2.70f, 13, AMMOID_357SIG, 3, 52, MY_SLOT_SECONDARY },

	{ 0.000000f, 0.000000f, 0.00f, 0, AMMOID_NONE, 0, 0, MY_SLOT_PRIMARY},

	{ 1.250000f, 0.300000f, 2.00f, 10, AMMOID_762NATO, 9, 90, MY_SLOT_PRIMARY },
	
	{ 0.000000f, 0.000000f, 0.00f, 1,  AMMOID_HEGRENADE, 1, 1, MY_SLOT_GRENADE },

	{ 0.250000f, 0.250000f, 0.55f, 7,  AMMOID_BUCKSHOT, 12, 32, MY_SLOT_PRIMARY },
	
	{ 0.000000f, 0.000000f, 0.00f, 1,  AMMOID_C4, 3, 1, MY_SLOT_C4 },
	
	{ 0.070000f, 0.070000f, 3.15f, 30, AMMOID_45ACP, 13, 100, MY_SLOT_PRIMARY },
	
	{ 0.082500f, 0.300000f, 3.30f, 30, AMMOID_556NATO, 14, 90, MY_SLOT_PRIMARY },
	
	{ 0.000000f, 0.000000f, 0.00f, 1,  AMMOID_SMOKEGRENADE, 3, 1, MY_SLOT_GRENADE },
	
	{ 0.122000f, 0.122000f, 4.50f, 30, AMMOID_9MM, 5, 120, MY_SLOT_SECONDARY },
	
	{ 0.150000f, 0.150000f, 2.70f, 20, AMMOID_57, 6, 100, MY_SLOT_SECONDARY },
	
	{ 0.100000f, 0.100000f, 3.50f, 25, AMMOID_45ACP, 15, 100, MY_SLOT_PRIMARY },

	{ 0.250000f, 0.300000f, 3.35f, 30, AMMOID_556NATO, 16, 90, MY_SLOT_PRIMARY },
	
	{ 0.087499f, 0.087499f, 2.45f, 35, AMMOID_556NATO, 17, 90, MY_SLOT_PRIMARY },
	
	{ 0.082500f, 0.300000f, 3.30f, 25, AMMOID_556NATO, 18, 90, MY_SLOT_PRIMARY },
	
	{ 0.149999f, 3.130000f, 2.70f, 12, AMMOID_45ACP, 4, 100, MY_SLOT_SECONDARY },
	
	{ 0.150000f, 0.300000f, 2.20f, 20, AMMOID_9MM, 2, 120, MY_SLOT_SECONDARY },
	
	{ 1.450000f, 0.300000f, 2.50f, 10, AMMOID_338MAGNUM, 2, 30, MY_SLOT_PRIMARY },
	
	{ 0.075000f, 0.075000f, 2.63f, 30, AMMOID_9MM, 7, 120, MY_SLOT_PRIMARY },
	
	{ 0.100000f, 0.100000f, 4.70f, 100, AMMOID_556NATOBOX, 4, 200, MY_SLOT_PRIMARY },
	
	{ 0.875000f, 0.875000f, 0.55f, 8,  AMMOID_BUCKSHOT, 5, 32, MY_SLOT_PRIMARY },
	
	{ 0.087499f, 2.000000f, 3.05f, 30, AMMOID_556NATO, 6, 90, MY_SLOT_PRIMARY },
	
	{ 0.070000f, 0.070000f, 2.12f, 30, AMMOID_9MM, 11, 120, MY_SLOT_PRIMARY },
	
	{ 0.250000f, 0.300000f, 3.50f, 20, AMMOID_762NATO, 3, 90, MY_SLOT_PRIMARY },
	
	{ 0.000000f, 0.000000f, 0.00f, 2,  AMMOID_FLASHBANG, 2, 2, MY_SLOT_GRENADE },

	{ 0.225000f, 0.225000f, 2.20f, 7,  AMMOID_50AE, 1, 35, MY_SLOT_SECONDARY },
	
	{ 0.082500f, 0.300000f, 3.00f, 30, AMMOID_556NATO, 10, 90, MY_SLOT_PRIMARY },
	
	{ 0.095499f, 0.095499f, 2.45f, 30, AMMOID_762NATO, 1, 90, MY_SLOT_PRIMARY },

	{ 0.000000f, 0.000000f, 0.00f, 0, AMMOID_KNIFE, 1, 0, MY_SLOT_KNIFE },

	{ 0.065999f, 0.065999f, 3.40f, 50, AMMOID_57, 8, 100, MY_SLOT_PRIMARY }

};
#endif


/**
 * 
 * 
 * 
 * I feel like I may need this stuff one day
 * 
enum sh_weapon_data_struct{

	wpn_struct_weapon_name[25],
	wpn_struct_ammo_name[20]


}
stock const weapon_data_structs_array[CSW_LAST_WEAPON+1][sh_weapon_data_struct] = {
	
	{ "", "" },

	{ "weapon_p228",  "357sig" },

	{ "",  ""},

	{ "weapon_scout", "762nato" },
	
	{ "weapon_hegrenade", ""},

	{ "weapon_xm1014","buckshot" },
	
	{ "weapon_c4","" },
	
	{ "weapon_mac10", "45acp" },
	
	{ "weapon_aug", "556nato" },
	
	{ "weapon_smokegrenade", "" },
	
	{ "weapon_elite", "9mm" },
	
	{ "weapon_fiveseven", "57mm" },
	
	{ "weapon_ump45", "45acp" },

	{ "weapon_sg550", "556nato" },
	
	{ "weapon_galil", "556nato" },
	
	{ "weapon_famas", "556nato" },
	
	{ "weapon_usp", "45acp" },
	
	{ "weapon_glock18", "9mm" },
	
	{ "weapon_awp", "338magnum" },
	
	{ "weapon_mp5navy", "9mm" },
	
	{ "weapon_m249", "556natobox" },
	
	{ "weapon_m3", "buckshot" },
	
	{ "weapon_m4a1", "556nato" },
	
	{ "weapon_tmp", "9mm"},
	
	{ "weapon_g3sg1", "762nato"},
	
	{ "weapon_flashbang", ""},

	{ "weapon_deagle", "50ae"},
	
	{ "weapon_sg552", "556nato"},
	
	{ "weapon_ak47", "762nato"},

	{ "weapon_knife", ""},

	{ "weapon_p90", "57mm"}

}

enum sh_weapon_data_struct{

	wpn_struct_weapon_name[25],
	wpn_struct_ammo_name[20],
	Float:wpn_struct_primary_attack_delay,
	Float:wpn_struct_secondary_attack_delay,
	Float:wpn_struct_reload_delay,
	wpn_struct_max_clip,
	wpn_struct_ammo_id,
	wpn_struct_wpn_position,
	wpn_struct_max_bp_ammo,
    my_weapon_slots:wpn_slot


}
stock const weapon_data_structs_array[CSW_LAST_WEAPON+1][sh_weapon_data_struct] = {
	
	{ "", 0.000000, 0.000000, 0.00, -1, 0, -1, "", enum_minus_one },

	{ "weapon_p228", 0.150000, 0.150000, 2.70, 13, 9, 3, 52, "357sig", MY_SLOT_SECONDARY },

	{ "", 0.000000, 0.000000, 0.00, -1, 0, 0, "", enum_minus_one},

	{ "weapon_scout", 1.250000, 0.300000, 2.00, 10, 2, 9, 90, "762nato", MY_SLOT_PRIMARY },
	
	{ "weapon_hegrenade", 0.000000, 0.000000, 0.00, 1,  12, 1, 1, "", MY_SLOT_GRENADE },

	{ "weapon_xm1014", 0.250000, 0.250000, 0.55, 7,  5, 12, 32, "buckshot", MY_SLOT_PRIMARY },
	
	{ "weapon_c4", 0.000000, 0.000000, 0.00, 1,  0, 3, 1, "", MY_SLOT_C4 },
	
	{ "weapon_mac10", 0.070000, 0.070000, 3.15, 30, 6, 13, 100, "45acp", MY_SLOT_PRIMARY },
	
	{ "weapon_aug", 0.082500, 0.300000, 3.30, 30, 4, 14, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_smokegrenade", 0.000000, 0.000000, 0.00, 1,  13, 3, 1, "", MY_SLOT_GRENADE },
	
	{ "weapon_elite", 0.122000, 0.122000, 4.50, 30, 10, 5, 120, "9mm", MY_SLOT_SECONDARY },
	
	{ "weapon_fiveseven", 0.150000, 0.150000, 2.70, 20, 7, 6, 100, "57mm", MY_SLOT_SECONDARY },
	
	{ "weapon_ump45", 0.100000, 0.100000, 3.50, 25, 6, 15, 100, "45acp", MY_SLOT_PRIMARY },

	{ "weapon_sg550", 0.250000, 0.300000, 3.35, 30, 4, 16, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_galil", 0.087499, 0.087499, 2.45, 35, 4, 17, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_famas", 0.082500, 0.300000, 3.30, 25, 4, 18, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_usp", 0.149999, 3.130000, 2.70, 12, 6, 4, 100,"45acp", MY_SLOT_SECONDARY },
	
	{ "weapon_glock18", 0.150000, 0.300000, 2.20, 20, 10, 2, 120, "9mm", MY_SLOT_SECONDARY },
	
	{ "weapon_awp", 1.450000, 0.300000, 2.50, 10, 1, 2, 30, "338magnum", MY_SLOT_PRIMARY },
	
	{ "weapon_mp5navy", 0.075000, 0.075000, 2.63, 30, 10, 7, 120, "9mm", MY_SLOT_PRIMARY },
	
	{ "weapon_m249", 0.100000, 0.100000, 4.70, 100, 3, 4, 200, "556natobox", MY_SLOT_PRIMARY },
	
	{ "weapon_m3", 0.875000, 0.875000, 0.55, 8,  5, 5, 32, "buckshot", MY_SLOT_PRIMARY },
	
	{ "weapon_m4a1", 0.087499, 2.000000, 3.05, 30, 4, 6, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_tmp", 0.070000, 0.070000, 2.12, 30, 10, 11, 120, "9mm", MY_SLOT_PRIMARY },
	
	{ "weapon_g3sg1", 0.250000, 0.300000, 3.50, 20, 2, 3, 90, "762nato", MY_SLOT_PRIMARY },
	
	{ "weapon_flashbang", 0.000000, 0.000000, 0.00, 2,  11, 2, 2, "", MY_SLOT_GRENADE },

	{ "weapon_deagle", 0.225000, 0.225000, 2.20, 7,  8, 1, 35, "50ae", MY_SLOT_SECONDARY },
	
	{ "weapon_sg552", 0.082500, 0.300000, 3.00, 30, 4, 10, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "weapon_ak47", 0.095499, 0.095499, 2.45, 30, 2, 1, 90, "762nato", MY_SLOT_PRIMARY },

	{ "weapon_knife", 0.000000, 0.000000, 0.00, -1, 0, 1, -1, "", MY_SLOT_KNIFE },

	{ "weapon_p90", 0.065999, 0.065999, 3.40, 50, 7, 8, 100, "57mm", MY_SLOT_PRIMARY }

}
*/