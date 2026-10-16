#if defined auxiliar_stuff_hitpoints_inc
  #endinput
#endif
#define auxiliar_stuff_hitpoints_inc


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

stock list_hitboxes_in_bitsum(hitbox_bitsum,bool:exclude_mode=false){
	
	new count=0
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

