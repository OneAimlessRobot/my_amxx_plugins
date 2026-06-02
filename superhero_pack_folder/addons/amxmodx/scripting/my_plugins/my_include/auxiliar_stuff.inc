#if defined auxiliar_stuff_inc
  #endinput
#endif
#define auxiliar_stuff_inc


#define enum_zero (any:0)
#define enum_one (any:1)


#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) (%1 |= (1 << (%2 & 31)))
#define UnSet_BitVar(%1,%2) (%1 &= ~(1 << (%2 & 31)))


#define Assign_BitVar(%1,%2,%3) ((%3) ? Set_BitVar(%1,%2) : UnSet_BitVar(%1,%2))

stock bool:true_for_macro=true,
	bool:false_for_macro=false


/*
#define Assign_BitVar(%1,%2,%3) ((%1) = ((%3)) ?(%1 | (1 << (%2 & 31))) : (%1 & ~(1 << (%2 & 31))) )

Im gonna try this one, instead

*/

#define SIZE_OF_BYTE 8

#define SIZE_OF_SHORT 16

#define SIZE_OF_INT 32

#define nth_power_of_two(%1) (1<<%1)

#define exhausted_bitsum (((nth_power_of_two(SIZE_OF_INT-1)-1))+nth_power_of_two(SIZE_OF_INT-1))

#define max_integer_limit (power(2,31)-1);
/*

#define HIT_GENERIC     0
#define HIT_HEAD        1
#define HIT_CHEST       2
#define HIT_STOMACH     3
#define HIT_LEFTARM     4
#define HIT_RIGHTARM    5
#define HIT_LEFTLEG     6
#define HIT_RIGHTLEG    7
#define HIT_SHIELD      8 // CS only
#define MAX_BODYHITS    9

*/
enum my_hitpoint_enum{

	MY_HIT_GENERIC=0,
	MY_HIT_HEAD,
    MY_HIT_CHEST,
    MY_HIT_STOMACH,
    MY_HIT_LEFTARM,
    MY_HIT_RIGHTARM,
    MY_HIT_LEFTLEG,
    MY_HIT_RIGHTLEG,
    MY_HIT_SHIELD

}

//boring primitive hit_regions
const hit_region_nowhere = 0
const hit_region_just_generic = (1<<_:MY_HIT_GENERIC)
const hit_region_just_head = (1<<_:MY_HIT_HEAD)
const hit_region_just_chest = (1<<_:MY_HIT_CHEST)
const hit_region_just_stomach = (1<<_:MY_HIT_STOMACH)
const hit_region_just_leftarm = (1<<_:MY_HIT_LEFTARM)
const hit_region_just_rightarm = (1<<_:MY_HIT_RIGHTARM)
const hit_region_just_leftleg = (1<<_:MY_HIT_LEFTLEG)
const hit_region_just_rightleg = (1<<_:MY_HIT_RIGHTLEG)
const hit_region_just_shield = (1<<_:MY_HIT_SHIELD)

//custom hitregions for plugins ^ ^ (bitsums of primitive hit_region defines)
const hit_region_anywhere   =        (
                                        hit_region_just_generic|hit_region_just_head|
                                        hit_region_just_chest|hit_region_just_stomach|
                                        hit_region_just_leftarm|hit_region_just_rightarm|
                                        hit_region_just_leftleg|hit_region_just_rightleg|
                                        hit_region_just_shield
                                        )                                                         

const hit_region_notbody        =           (hit_region_just_generic|hit_region_just_shield)

const hit_region_body          =            (hit_region_anywhere&(~hit_region_notbody))

const hit_region_limbs        =             (
                                        hit_region_just_leftarm|hit_region_just_rightarm|
                                        hit_region_just_leftleg|hit_region_just_rightleg
                                        )                                                     

const hit_region_upper_body      =          (hit_region_just_head|hit_region_just_chest)

const hit_region_lower_body      =          (
                                        hit_region_just_stomach|hit_region_just_leftleg|
                                        hit_region_just_rightleg)                                                      

const hit_region_not_head      =            (hit_region_body&(~hit_region_just_head))

/**

amx errors to help me debug

out of bounds is 4


its all from 0
in err none

to whatever the last one is

1 by 1

err exit is 1

err assert is 2, etc.


enum {
  AMX_ERR_NONE,
  // reserve the first 15 error codes for exit codes of the abstract machine //
  AMX_ERR_EXIT,         // forced exit //
  AMX_ERR_ASSERT,       // assertion failed //
  AMX_ERR_STACKERR,     // stack/heap collision //
  AMX_ERR_BOUNDS,       // index out of bounds //
  AMX_ERR_MEMACCESS,    // invalid memory access //
  AMX_ERR_INVINSTR,     // invalid instruction //
  AMX_ERR_STACKLOW,     // stack underflow //
  AMX_ERR_HEAPLOW,      // heap underflow //
  AMX_ERR_CALLBACK,     // no callback, or invalid callback //
  AMX_ERR_NATIVE,       // native function failed //
  AMX_ERR_DIVIDE,       // divide by zero //
  AMX_ERR_SLEEP,        // go into sleepmode - code can be restarted //
  AMX_ERR_INVSTATE,     // invalid state for this access //
  AMX_ERR_INVNATIVE,    // invalid native was used //

  AMX_ERR_MEMORY = 16,  // out of memory //
  AMX_ERR_FORMAT,       // invalid file format //
  AMX_ERR_VERSION,      // file is for a newer version of the AMX //
  AMX_ERR_NOTFOUND,     // function not found //
  AMX_ERR_INDEX,        // invalid index parameter (bad entry point) //
  AMX_ERR_DEBUG,        // debugger cannot run //
  AMX_ERR_INIT,         // AMX not initialized (or doubly initialized) //
  AMX_ERR_USERDATA,     // unable to set user data field (table full) //
  AMX_ERR_INIT_JIT,     // cannot initialize the JIT //
  AMX_ERR_PARAMS,       // parameter error //
  AMX_ERR_DOMAIN,       // domain error, expression result does not fit in range //
  AMX_ERR_GENERAL,      // general error (unknown or unspecific error) 
};



 */
enum my_weapon_slots{

    MY_SLOT_PRIMARY = 0,
    MY_SLOT_SECONDARY,
    MY_SLOT_KNIFE,
    MY_SLOT_GRENADE,
    MY_SLOT_C4,

}

#define MUL_TWO(%0,%1)                                                          \
    (                                                                           \
        (%0)                                                                    \
        *                                                                       \
        (%1)                                                                    \
    )

stock const hitzone_names[my_hitpoint_enum][28] = {

    "generic",
    "head",
    "chest",
    "stomach",
    "leftarm",
    "rigtharm",
    "leftleg",
    "rightleg",
    "shield"
};

/**
 * Parts of body for hits

#define HIT_GENERIC     0 //none
#define HIT_HEAD        1
#define HIT_CHEST       2
#define HIT_STOMACH     3
#define HIT_LEFTARM     4
#define HIT_RIGHTARM    5
#define HIT_LEFTLEG     6
#define HIT_RIGHTLEG    7
#define HIT_SHIELD      8
#define MAX_BODYHITS    9
*/
#define is_valid_hitzone(%1) ((%1)>=enum_zero && (%1)<=my_hitpoint_enum)

/**

 * IDs of weapons in CS

#define CSW_NONE            0
#define CSW_P228            1
#define CSW_GLOCK           2  // Unused by game, See CSW_GLOCK18.
#define CSW_SCOUT           3
#define CSW_HEGRENADE       4
#define CSW_XM1014          5
#define CSW_C4              6
#define CSW_MAC10           7
#define CSW_AUG             8
#define CSW_SMOKEGRENADE    9
#define CSW_ELITE           10
#define CSW_FIVESEVEN       11
#define CSW_UMP45           12
#define CSW_SG550           13
#define CSW_GALIL           14
#define CSW_FAMAS           15
#define CSW_USP             16
#define CSW_GLOCK18         17
#define CSW_AWP             18
#define CSW_MP5NAVY         19
#define CSW_M249            20
#define CSW_M3              21
#define CSW_M4A1            22
#define CSW_TMP             23
#define CSW_G3SG1           24
#define CSW_FLASHBANG       25
#define CSW_DEAGLE          26
#define CSW_SG552           27
#define CSW_AK47            28
#define CSW_KNIFE           29
#define CSW_P90             30
#define CSW_VEST            31  // Custom
#define CSW_VESTHELM        32  // Custom
#define CSW_SHIELDGUN       99
#define CSW_LAST_WEAPON     CSW_P90

 */


enum sh_weapon_data_struct{

	wpn_struct_weapon_name[25],
	Float:wpn_struct_primary_attack_delay,
	Float:wpn_struct_secondary_attack_delay,
	Float:wpn_struct_reload_delay,
	wpn_struct_max_clip,
	wpn_struct_ammo_id,
	wpn_struct_wpn_position,
	wpn_struct_max_bp_ammo


}
stock const weapon_data_structs_array[CSW_LAST_WEAPON+1][sh_weapon_data_struct] = {
	
	{ "", 0.000000, 0.000000, 0.00, -1, 0, -1 },

	{ "weapon_p228", 0.150000, 0.150000, 2.70, 13, 9, 3, 52 },

	{ "", 0.000000, 0.000000, 0.00, -1, 0, 0},

	{ "weapon_scout", 1.250000, 0.300000, 2.00, 10, 2, 9, 90 },
	
	{ "weapon_hegrenade", 0.000000, 0.000000, 0.00, 1,  12, 1, 1 },

	{ "weapon_xm1014", 0.250000, 0.250000, 0.55, 7,  5, 12, 32 },
	
	{ "weapon_c4", 0.000000, 0.000000, 0.00, 1,  0, 3, 1 },
	
	{ "weapon_mac10", 0.070000, 0.070000, 3.15, 30, 6, 13, 100 },
	
	{ "weapon_aug", 0.082500, 0.300000, 3.30, 30, 4, 14, 90 },
	
	{ "weapon_smokegrenade", 0.000000, 0.000000, 0.00, 1,  13, 3, 1 },
	
	{ "weapon_elite", 0.122000, 0.122000, 4.50, 30, 10, 5, 120 },
	
	{ "weapon_fiveseven", 0.150000, 0.150000, 2.70, 20, 7, 6, 100 },
	
	{ "weapon_ump45", 0.100000, 0.100000, 3.50, 25, 6, 15, 100 },

	{ "weapon_sg550", 0.250000, 0.300000, 3.35, 30, 4, 16, 90 },
	
	{ "weapon_galil", 0.087499, 0.087499, 2.45, 35, 4, 17, 90 },
	
	{ "weapon_famas", 0.082500, 0.300000, 3.30, 25, 4, 18, 90 },
	
	{ "weapon_usp", 0.149999, 3.130000, 2.70, 12, 6, 4, 100 },
	
	{ "weapon_glock18", 0.150000, 0.300000, 2.20, 20, 10, 2, 120 },
	
	{ "weapon_awp", 1.450000, 0.300000, 2.50, 10, 1, 2, 30 },
	
	{ "weapon_mp5navy", 0.075000, 0.075000, 2.63, 30, 10, 7, 120 },
	
	{ "weapon_m249", 0.100000, 0.100000, 4.70, 100, 3, 4, 200 },
	
	{ "weapon_m3", 0.875000, 0.875000, 0.55, 8,  5, 5, 32 },
	
	{ "weapon_m4a1", 0.087499, 2.000000, 3.05, 30, 4, 6, 90 },
	
	{ "weapon_tmp", 0.070000, 0.070000, 2.12, 30, 10, 11, 120 },
	
	{ "weapon_g3sg1", 0.250000, 0.300000, 3.50, 20, 2, 3, 90 },
	
	{ "weapon_flashbang", 0.000000, 0.000000, 0.00, 2,  11, 2, 2 },

	{ "weapon_deagle", 0.225000, 0.225000, 2.20, 7,  8, 1, 35 },
	
	{ "weapon_sg552", 0.082500, 0.300000, 3.00, 30, 4, 10, 90 },
	
	{ "weapon_ak47", 0.095499, 0.095499, 2.45, 30, 2, 1, 90 },

	{ "weapon_knife", 0.000000, 0.000000, 0.00, -1, 0, 1, -1 },

	{ "weapon_p90", 0.065999, 0.065999, 3.40, 50, 7, 8, 100 }

}

stock list_weapons_in_bitsum(weapon_bitsum,bool:exclude_mode=false){
	
	static count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(weapon_bitsum)): (weapon_bitsum)
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<wpnId)))
		if ( do_eht && (strlen(weapon_names_stock_arr[wpnId])>0))
		{	
			count++
			server_print("The weapon number %d (with id %d) in this bitsum is called: %s",count,wpnId,weapon_names_stock_arr[wpnId]);	
		}
	}
}

stock list_hitboxes_in_bitsum(hitbox_bitsum,bool:exclude_mode=false){
	
	static count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(hitbox_bitsum)): (hitbox_bitsum)
	for ( new my_hitpoint_enum:hit_point = enum_zero; hit_point < my_hitpoint_enum; hit_point++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<_:hit_point)))
		if ( do_eht && (strlen(hitzone_names[hit_point])>0))
		{	
			count++
			server_print("The hitbox %d (with id %d) in this bitsum is called: %s",count,_:hit_point,hitzone_names[hit_point]);	
		}
	}
}
stock list_activated_bits_in_bitsum(generic_bitsum,bool:exclude_mode=false){
	
	static count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(generic_bitsum)): (generic_bitsum)
	for ( new i=0;i<32;i++)
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<i)))
		if ( do_eht )
		{	
			count++
			server_print("The bit %d (on %d position) in this bitsum is the number: %d",count,i,(1<<i));	
		}
	}
}

//entity constants

#define PDATA_SAFE  2

#define client_is_within_range(%1) ((%1>0 && %1<=(SH_MAXSLOTS)))

#define ent_check(%1,%2) if(pev_valid(%1)!=PDATA_SAFE) return %2

/**


new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		id = the_players[i]
        
         */