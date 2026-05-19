#if defined auxiliar_stuff_inc
  #endinput
#endif
#define auxiliar_stuff_inc


#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) (%1 |= (1 << (%2 & 31)))
#define UnSet_BitVar(%1,%2) (%1 &= ~(1 << (%2 & 31)))

stock bool:true_for_macro=true,
	bool:false_for_macro=false

#define Assign_BitVar(%1,%2,%3) ((%1) = ((%3)) ?(%1 | (1 << (%2 & 31))) : (%1 & ~(1 << (%2 & 31))) )

#define SIZE_OF_BYTE 8

#define SIZE_OF_SHORT 16

#define SIZE_OF_INT 32

#define nth_power_of_two(%1) (1<<%1)
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
#define is_valid_hitzone(%1) ((%1)>=0 && (%1)<=8)


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
    MY_HIT_SHIELD,
    MY_MAX_HITPOINT

}
#define MUL_TWO(%0,%1)                                                          \
    (                                                                           \
        (%0)                                                                    \
        *                                                                       \
        (%1)                                                                    \
    )

stock const hitzone_names[MAX_BODYHITS][28] = {

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
stock const weapon_names_stock_arr[CSW_LAST_WEAPON+1][] = {
    "",
    "weapon_p228",
    "",
    "weapon_scout",
    "weapon_hegrenade",
    "weapon_xm1014",
    "weapon_c4",
    "weapon_mac10",
    "weapon_aug",
    "weapon_smokegrenade",
    "weapon_elite",
    "weapon_fiveseven",
    "weapon_ump45",
    "weapon_sg550",
    "weapon_galil",
    "weapon_famas",
    "weapon_usp",
    "weapon_glock18",
    "weapon_awp",
    "weapon_mp5navy",
    "weapon_m249",
    "weapon_m3",
    "weapon_m4a1",
    "weapon_tmp",
    "weapon_g3sg1",
    "weapon_flashbang",
    "weapon_deagle",
    "weapon_sg552",
    "weapon_ak47",
    "weapon_knife",
    "weapon_p90"
}