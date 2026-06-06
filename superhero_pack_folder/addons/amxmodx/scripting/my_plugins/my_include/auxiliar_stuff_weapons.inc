#if defined auxiliar_stuff_weapons_inc
  #endinput
#endif
#define auxiliar_stuff_weapons_inc

enum my_weapon_ids{
	
	MY_CSW_NONE = 0,			//0
	MY_CSW_P228,				//1
	MY_CSW_GLOCK,				//2
	MY_CSW_SCOUT,				//3
	MY_CSW_HEGRENADE,			//4
	MY_CSW_XM1014,				//5
	MY_CSW_C4,					//6
	MY_CSW_MAC10,				//7
	MY_CSW_AUG,				//8
	MY_CSW_SMOKEGRENADE,		//9
	MY_CSW_ELITE,				//10
	MY_CSW_FIVESEVEN,			//11
	MY_CSW_UMP45,				//12
	MY_CSW_SG550,				//13
	MY_CSW_GALIL,				//14
	MY_CSW_FAMAS,				//15
	MY_CSW_USP,				//16
	MY_CSW_GLOCK18,			//17
	MY_CSW_AWP,				//18
	MY_CSW_MP5NAVY,			//19
	MY_CSW_M249,				//20
	MY_CSW_M3,					//21
	MY_CSW_M4A1,				//22
	MY_CSW_TMP,				//23
	MY_CSW_G3SG1,				//24
	MY_CSW_FLASHBANG,			//25
	MY_CSW_DEAGLE,				//26
	MY_CSW_SG552,				//27
	MY_CSW_AK47,				//28
	MY_CSW_KNIFE,				//29
	MY_CSW_P90					//30

};

enum my_weapon_slots{

    MY_SLOT_PRIMARY = 0,
    MY_SLOT_SECONDARY,
    MY_SLOT_KNIFE,
    MY_SLOT_GRENADE,
    MY_SLOT_C4,

}

enum my_ammo_ids{
	
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
	
	
	
}
enum sh_weapon_data_struct{

	wpn_struct_fruity_name[100],
	wpn_struct_weapon_name[25],
	Float:wpn_struct_primary_attack_delay,
	Float:wpn_struct_secondary_attack_delay,
	Float:wpn_struct_reload_delay,
	wpn_struct_max_clip,
	my_ammo_ids:wpn_struct_ammo_id,
	wpn_struct_wpn_position,
	wpn_struct_max_bp_ammo,
	wpn_struct_ammo_name[20],
    my_weapon_slots:wpn_struct_wpn_slot


}
stock const weapon_data_structs_array[my_weapon_ids][sh_weapon_data_struct] = {
	
	{ "", "", 0.000000, 0.000000, 0.00, -1, AMMOID_NONE, 0, -1, "", enum_minus_one },

	{ "SIG P228", "weapon_p228", 0.150000, 0.150000, 2.70, 13, AMMOID_357SIG, 3, 52, "357sig", MY_SLOT_SECONDARY },

	{ "", "", 0.000000, 0.000000, 0.00, -1, AMMOID_NONE, 0, 0, "", enum_minus_one},

	{ "Steyr Scout", "weapon_scout", 1.250000, 0.300000, 2.00, 10, AMMOID_762NATO, 9, 90, "762nato", MY_SLOT_PRIMARY },
	
	{ "HE Grenade", "weapon_hegrenade", 0.000000, 0.000000, 0.00, 1,  AMMOID_HEGRENADE, 1, 1, "", MY_SLOT_GRENADE },

	{ "XM1014 Auto Shotgun", "weapon_xm1014", 0.250000, 0.250000, 0.55, 7,  AMMOID_BUCKSHOT, 12, 32, "buckshot", MY_SLOT_PRIMARY },
	
	{ "C4 Explosive", "weapon_c4", 0.000000, 0.000000, 0.00, 1,  AMMOID_C4, 3, 1, "", MY_SLOT_C4 },
	
	{ "Ingram MAC-10", "weapon_mac10", 0.070000, 0.070000, 3.15, 30, AMMOID_45ACP, 13, 100, "45acp", MY_SLOT_PRIMARY },
	
	{ "Steyr AUG Bullpup", "weapon_aug", 0.082500, 0.300000, 3.30, 30, AMMOID_556NATO, 14, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "Smokegrenade", "weapon_smokegrenade", 0.000000, 0.000000, 0.00, 1,  AMMOID_SMOKEGRENADE, 3, 1, "", MY_SLOT_GRENADE },
	
	{ "Dual Elites", "weapon_elite", 0.122000, 0.122000, 4.50, 30, AMMOID_9MM, 5, 120, "9mm", MY_SLOT_SECONDARY },
	
	{ "Five-Seven", "weapon_fiveseven", 0.150000, 0.150000, 2.70, 20, AMMOID_57, 6, 100, "57mm", MY_SLOT_SECONDARY },
	
	{ "UMP-45", "weapon_ump45", 0.100000, 0.100000, 3.50, 25, AMMOID_45ACP, 15, 100, "45acp", MY_SLOT_PRIMARY },

	{ "SIG SG-550", "weapon_sg550", 0.250000, 0.300000, 3.35, 30, AMMOID_556NATO, 16, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "IDF Defender", "weapon_galil", 0.087499, 0.087499, 2.45, 35, AMMOID_556NATO, 17, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "Famasooom", "weapon_famas", 0.082500, 0.300000, 3.30, 25, AMMOID_556NATO, 18, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "HK USP", "weapon_usp", 0.149999, 3.130000, 2.70, 12, AMMOID_45ACP, 4, 100,"45acp", MY_SLOT_SECONDARY },
	
	{ "Glock-18", "weapon_glock18", 0.150000, 0.300000, 2.20, 20, AMMOID_9MM, 2, 120, "9mm", MY_SLOT_SECONDARY },
	
	{ "Arctic Warfare Police (AWP)", "weapon_awp", 1.450000, 0.300000, 2.50, 10, AMMOID_338MAGNUM, 2, 30, "338magnum", MY_SLOT_PRIMARY },
	
	{ "HK MP5", "weapon_mp5navy", 0.075000, 0.075000, 2.63, 30, AMMOID_9MM, 7, 120, "9mm", MY_SLOT_PRIMARY },
	
	{ "M249", "weapon_m249", 0.100000, 0.100000, 4.70, 100, AMMOID_556NATOBOX, 4, 200, "556natobox", MY_SLOT_PRIMARY },
	
	{ "M3 Pump Action", "weapon_m3", 0.875000, 0.875000, 0.55, 8,  AMMOID_BUCKSHOT, 5, 32, "buckshot", MY_SLOT_PRIMARY },
	
	{ "Colt M4A1", "weapon_m4a1", 0.087499, 2.000000, 3.05, 30, AMMOID_556NATO, 6, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "TMP", "weapon_tmp", 0.070000, 0.070000, 2.12, 30, AMMOID_9MM, 11, 120, "9mm", MY_SLOT_PRIMARY },
	
	{ "G3-SG1", "weapon_g3sg1", 0.250000, 0.300000, 3.50, 20, AMMOID_762NATO, 3, 90, "762nato", MY_SLOT_PRIMARY },
	
	{ "Flashbang", "weapon_flashbang", 0.000000, 0.000000, 0.00, 2,  AMMOID_FLASHBANG, 2, 2, "", MY_SLOT_GRENADE },

	{ "Desert Eagle", "weapon_deagle", 0.225000, 0.225000, 2.20, 7,  AMMOID_50AE, 1, 35, "50ae", MY_SLOT_SECONDARY },
	
	{ "SIG SG-552", "weapon_sg552", 0.082500, 0.300000, 3.00, 30, AMMOID_556NATO, 10, 90, "556nato", MY_SLOT_PRIMARY },
	
	{ "AK47 Kalashnikov", "weapon_ak47", 0.095499, 0.095499, 2.45, 30, AMMOID_762NATO, 1, 90, "762nato", MY_SLOT_PRIMARY },

	{ "The Knife", "weapon_knife", 0.000000, 0.000000, 0.00, -1, AMMOID_KNIFE, 1, -1, "", MY_SLOT_KNIFE },

	{ "P90", "weapon_p90", 0.065999, 0.065999, 3.40, 50, AMMOID_57, 8, 100, "57mm", MY_SLOT_PRIMARY }

}
#define PRIMARY_WEAPONS_BIT_SUM  ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90))

#define SECONDARY_WEAPONS_BIT_SUM  ((1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE))

#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define GUNS_BIT_SUM ((1<<CSW_P228) | (1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_ELITE) | (1<<CSW_FIVESEVEN) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_GALIL) | (1<<CSW_FAMAS) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_P90))

#define FAST_RELOAD_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define NOCLIP_WPN_BS	((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))

#define BURSTGUNS_BIT_SUM ((1<<CSW_FAMAS) | (1<<CSW_GLOCK18))

#define SHOTGUNS_BS	((1<<CSW_M3)|(1<<CSW_XM1014))

#define SILENT_BS	((1<<CSW_USP)|(1<<CSW_M4A1))

#define RIFLES_BS	((1<<CSW_SCOUT)|(1<<CSW_AUG)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_M249)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47))

#define single_shot_wpns_bs (GUNS_BIT_SUM& (~(SHOTGUNS_BS)))

#define is_weaponid_valid(%1) ((%1>0)&&(%1<=CSW_LAST_WEAPON)&&(%1!=2))



#define wlt_get_fruity_name(%1) (weapon_data_structs_array[%1][wpn_struct_fruity_name])

#define wlt_get_def_name(%1) (weapon_data_structs_array[%1][wpn_struct_weapon_name])

#define wlt_get_def_clip(%1) (weapon_data_structs_array[%1][wpn_struct_max_clip])

#define wlt_get_def_bp_ammo(%1) (weapon_data_structs_array[%1][wpn_struct_max_bp_ammo])

#define wlt_get_def_ammo_id(%1) (weapon_data_structs_array[%1][wpn_struct_ammo_id])

#define wlt_get_def_pos(%1) (weapon_data_structs_array[%1][wpn_struct_wpn_position])

#define wlt_get_def_slot(%1) (weapon_data_structs_array[%1][wpn_struct_wpn_slot])

#define wlt_get_def_prim_atk_delay(%1) (weapon_data_structs_array[%1][wpn_struct_primary_attack_delay])

#define wlt_get_def_scnd_atk_delay(%1) (weapon_data_structs_array[%1][wpn_struct_secondary_attack_delay])

#define wlt_get_def_rld_delay(%1) (weapon_data_structs_array[%1][wpn_struct_reload_delay])

stock list_weapons_in_bitsum(weapon_bitsum,bool:exclude_mode=false){
	
	new count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(weapon_bitsum)): (weapon_bitsum)
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<wpnId)))
		if ( do_eht && (strlen(weapon_data_structs_array[wpnId][wpn_struct_weapon_name])>0))
		{	
			count++
			server_print("The weapon number %d (with id %d) in this bitsum is called: %s",count,wpnId,weapon_names_stock_arr[wpnId]);	
		}
	}
}