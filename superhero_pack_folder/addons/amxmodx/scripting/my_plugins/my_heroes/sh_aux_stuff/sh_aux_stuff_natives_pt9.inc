#if defined sh_aux_natives_pt9
  #endinput
#endif
#define sh_aux_natives_pt9

/**

 Admin level constants
 
#define ADMIN_ALL           0       // everyone
#define ADMIN_IMMUNITY      (1<<0)  // flag "a"
#define ADMIN_RESERVATION   (1<<1)  // flag "b"
#define ADMIN_KICK          (1<<2)  // flag "c"
#define ADMIN_BAN           (1<<3)  // flag "d"
#define ADMIN_SLAY          (1<<4)  // flag "e"
#define ADMIN_MAP           (1<<5)  // flag "f"
#define ADMIN_CVAR          (1<<6)  // flag "g"
#define ADMIN_CFG           (1<<7)  // flag "h"
#define ADMIN_CHAT          (1<<8)  // flag "i"
#define ADMIN_VOTE          (1<<9)  // flag "j"
#define ADMIN_PASSWORD      (1<<10) // flag "k"
#define ADMIN_RCON          (1<<11) // flag "l"
#define ADMIN_LEVEL_A       (1<<12) // flag "m"
#define ADMIN_LEVEL_B       (1<<13) // flag "n"
#define ADMIN_LEVEL_C       (1<<14) // flag "o"
#define ADMIN_LEVEL_D       (1<<15) // flag "p"
#define ADMIN_LEVEL_E       (1<<16) // flag "q"
#define ADMIN_LEVEL_F       (1<<17) // flag "r"
#define ADMIN_LEVEL_G       (1<<18) // flag "s"
#define ADMIN_LEVEL_H       (1<<19) // flag "t"
#define ADMIN_MENU          (1<<20) // flag "u"
#define ADMIN_BAN_TEMP      (1<<21) // flag "v"
#define ADMIN_ADMIN         (1<<24) // flag "y"
#define ADMIN_USER          (1<<25) // flag "z"

*/

/**

make a bitsum of these for the admin flags:


#define ADMIN_ALL           0
#define ADMIN_IMMUNITY      (1<<0)
#define ADMIN_RESERVATION   (1<<1)
#define ADMIN_KICK          (1<<2)
#define ADMIN_BAN           (1<<3)
#define ADMIN_SLAY          (1<<4)
#define ADMIN_MAP           (1<<5)
#define ADMIN_CVAR          (1<<6)
#define ADMIN_CFG           (1<<7)
#define ADMIN_CHAT          (1<<8)
#define ADMIN_VOTE          (1<<9) 
#define ADMIN_PASSWORD      (1<<10)
#define ADMIN_RCON          (1<<11) 
#define ADMIN_LEVEL_A       (1<<12)
#define ADMIN_LEVEL_B       (1<<13) 
#define ADMIN_LEVEL_C       (1<<14) 
#define ADMIN_LEVEL_D       (1<<15) 
#define ADMIN_LEVEL_E       (1<<16) 
#define ADMIN_LEVEL_F       (1<<17) 
#define ADMIN_LEVEL_G       (1<<18) 
#define ADMIN_LEVEL_H       (1<<19) 
#define ADMIN_MENU          (1<<20) 
#define ADMIN_BAN_TEMP      (1<<21) 
#define ADMIN_ADMIN         (1<<24) 
#define ADMIN_USER          (1<<25)

default: ADMIN_LEVEL_A
-1 on num_pickable_times means unlimited times 

(its number of times pickable on entire server
one for each player to use it)

the message to show if the user got denied of picking the hero
 */

/*
setting a hero using this native will only make the immunity take effect AFTER the xp has been loaded!
(if they have the hero prior to the restriction being set

like, for example, from a previous map where the restriction was not in place,

it wont automatically drop it!
)
*/

native bool:sh_register_admin_only_hero(the_hero_id_to_register,
          admin_flags_required = ADMIN_IMMUNITY,
          num_pickable_times = -1,
          const unable_to_pick_msg[STRING_SIZE] = "Unable to pick")