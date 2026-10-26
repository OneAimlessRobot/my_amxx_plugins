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
#define NUM_OF_HANDS_IN_A_HUMAN 2

stock const event_files_elite[NUM_OF_HANDS_IN_A_HUMAN][] = {

	"events/elite_right.sc",
	"events/elite_left.sc"

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

#define is_weaponid_valid(%1) ((%1>0)&&(%1<=CSW_LAST_WEAPON)&&(%1!=CSW_GLOCK))

#define wpn_id_in_bs(%1,%2) ((%2 & (1 << %1)))

#define single_wpn_bs(%1) ((1 << %1))

	
native wlt_get_def_name(my_weapon_ids:wpn_id, wpn_name[], len)

native wlt_get_fruity_name(my_weapon_ids:wpn_id, wpn_name[], len);

native wlt_get_ammo_name(my_weapon_ids:wpn_id, wpn_name[], len)

native wlt_get_events_file(my_weapon_ids:wpn_id, wpn_name[], len);

native wlt_get_def_clip(wpn_id);

native wlt_get_def_bp_ammo(wpn_id);

native wlt_get_def_ammo_id(wpn_id);

native wlt_get_def_pos(wpn_id);

native wlt_get_def_slot(wpn_id);

native Float:wlt_get_def_prim_atk_delay(wpn_id);

native Float:wlt_get_def_scnd_atk_delay(wpn_id);

native Float:wlt_get_def_rld_delay(wpn_id);

stock list_weapons_in_bitsum(weapon_bitsum,bool:exclude_mode=false){
	
	new count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(weapon_bitsum)): (weapon_bitsum)
	
	static array_for_fruity_name[50]

	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<wpnId)))
		if ( do_eht && is_weaponid_valid(_:wpnId))
		{	
			count++
			wlt_get_fruity_name(my_weapon_ids:wpnId,array_for_fruity_name,charsmax(array_for_fruity_name))
			server_print("The weapon number %d (with id %d) in this bitsum is called: %s",count,wpnId,array_for_fruity_name);	
		}
	}
}