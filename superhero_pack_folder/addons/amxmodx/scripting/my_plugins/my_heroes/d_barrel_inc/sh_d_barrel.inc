#if defined sh_d_barrel_funcs
  #endinput
#endif
#define sh_d_barrel_funcs


#define CSW_GATLING CSW_M3
#define WEAPON_ANIMEXT "shotgun"
#define DEFAULT_W_MODEL "models/w_m3.mdl"
#define CSW_GATLING_SECRET_CODE 1942
#define old_event "events/m3.sc"

#define D_BARREL_DAMAGE 85
#define D_BARREL_SPEED 1.0
#define D_BARREL_RECOIL 2.0
#define D_BARREL_RELOAD_TIME 2.0
#define D_BARREL_DEFAULT_CLIP 2
#define D_BARREL_DEFAULT_BPAMMO 64
#define D_BARREL_KNOCKPOWER 1000

#define D_BARREL_SUBMODEL -1

native d_barrel_set_d_barrel(id)
native d_barrel_unset_d_barrel(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
