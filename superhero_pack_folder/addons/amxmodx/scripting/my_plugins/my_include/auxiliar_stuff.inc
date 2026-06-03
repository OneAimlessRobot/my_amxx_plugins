#if defined auxiliar_stuff_all_inc
  #endinput
#endif
#define auxiliar_stuff_all_inc
/**
DEFINES FOR COMPILE TIME OPTIMIZATION:

(#define AUX_STUFF_GIVE_MACROS) -> macros. this should always be on so I enable it by default

(#define AUX_STUFF_GIVE_WEAPONS) -> enables weapon helper stocks
                                    and the huge table with all of their data

(#define AUX_STUFF_GIVE_HITPOINTS) -> enables hitpoint helper stocks
                                    and the huge table with all of their data

(#define AUX_STUFF_GIVE_ENT_STOCKS) -> enables hitpoint helper stocks
                                    and the huge table with all of their data


*/

#define AUX_STUFF_GIVE_MACROS

#if defined AUX_STUFF_GIVE_MACROS
#include "auxiliar_stuff_macros.inc"
#endif

#if defined AUX_STUFF_GIVE_WEAPONS
#include "auxiliar_stuff_weapons.inc"
#endif

#if defined AUX_STUFF_GIVE_HITPOINTS
#include "auxiliar_stuff_hitpoints.inc"
#endif

#if defined AUX_STUFF_GIVE_ENT_STOCKS
#include "auxiliar_stuff_ent_stocks.inc"
#endif


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
