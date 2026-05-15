#if defined sh_track_fx
  #endinput
#endif
#define sh_track_fx

#define RADIOACTIVE_DAMAGE_HEALTH_PCT 0.1
#define RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF 0.40

native track_user(id,attacker,do_damage=0,Float:damage_health_pct=0.1,Float:period,Float:time,track_color=LTBLUE);
native unradioactive_user(id)