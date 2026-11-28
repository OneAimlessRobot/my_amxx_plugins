#if defined sh_molly_fx
  #endinput
#endif
#define sh_molly_fx


#define BURN_DAMAGE 6.0
#define MOLLY_PROPAGATE_RADIUS 100.0
#define BURN_TIME 15.0


native sh_molly_user(id,attacker,
          Float:the_time=BURN_TIME,
          Float:damage_per_tick = BURN_DAMAGE,
          Float:propagate_radius = MOLLY_PROPAGATE_RADIUS,
          bool:should_spread = true,
          custom_wpn_id = -1)

native sh_unmolly_user(id)


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
