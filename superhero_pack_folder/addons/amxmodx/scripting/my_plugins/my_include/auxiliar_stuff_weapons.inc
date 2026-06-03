#if defined auxiliar_stuff_weapons_inc
  #endinput
#endif
#define auxiliar_stuff_weapons_inc


enum sh_weapon_strings_struct{

	wpn_struct_weapon_name[20],
	wpn_struct_ammo_name[11]


}
stock const weapon_data_strings_array[CSW_LAST_WEAPON+1][sh_weapon_strings_struct] = {
	
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

#define is_weaponid_valid(%1) ((%1>0)&&(%1<=CSW_LAST_WEAPON))


enum my_weapon_slots{

    MY_SLOT_PRIMARY = 0,
    MY_SLOT_SECONDARY,
    MY_SLOT_KNIFE,
    MY_SLOT_GRENADE,
    MY_SLOT_C4,

}
/**

    len is max len of your buff


*/
native wlt_get_def_clip(wpn_id);

native wlt_get_def_bp_ammo(wpn_id);

native wlt_get_def_ammo_id(wpn_id);

native wlt_get_def_pos(wpn_id);

native wlt_get_def_slot(wpn_id);

native Float:wlt_get_def_prim_atk_delay(wpn_id);

native Float:wlt_get_def_scnd_atk_delay(wpn_id);

native Float:wlt_get_def_rld_delay(wpn_id);



stock list_weapons_in_bitsum(weapon_bitsum,bool:exclude_mode=false){
	
	static count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(weapon_bitsum)): (weapon_bitsum)
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<wpnId)))
		if ( do_eht && (strlen(weapon_data_strings_array[wpnId][wpn_struct_weapon_name])>0))
		{	
			count++
			server_print("The weapon number %d (with id %d) in this bitsum is called: %s",count,wpnId,weapon_names_stock_arr[wpnId]);	
		}
	}
}