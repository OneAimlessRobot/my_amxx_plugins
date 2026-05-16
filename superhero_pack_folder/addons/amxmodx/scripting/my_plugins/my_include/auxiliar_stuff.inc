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
