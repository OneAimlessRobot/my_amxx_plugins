#if defined auxiliar_stuff_inc
  #endinput
#endif
#define auxiliar_stuff_inc


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

#define MUL_TWO(%0,%1)                                                          \
    (                                                                           \
        (%0)                                                                    \
        *                                                                       \
        (%1)                                                                    \
    )

stock const hitzone_names[MAX_BODYHITS][128] = {

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
