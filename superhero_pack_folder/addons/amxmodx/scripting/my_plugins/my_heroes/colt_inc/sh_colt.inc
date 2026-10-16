#if defined sh_colt_funcs
  #endinput
#endif
#define sh_colt_funcs


#define ID_M1911A1 7634198
#define STRN_M1911A1 "weapon_m1911a1"
#define CLIP_M1911A1 8
#define MAXAMMO_M1911A1 100

enum
{
	ANIM_IDLE,
	ANIM_IDLE_EMPTY,
	ANIM_SHOOT1,
	ANIM_SHOOT2,
	ANIM_SHOOT_EMPTY,
	ANIM_RELOAD,
	ANIM_RELOAD_EMPTY,
	ANIM_DRAW,
	ANIM_DRAW_EMPTY
}

#define VIEWMODEL "models/shmod/adriano/colt/v_m1911a1.mdl"
#define WEAPONMODEL "models/shmod/adriano/colt/p_m1911a1.mdl"
#define WORLDMODEL "models/shmod/adriano/colt/w_m1911a1.mdl"

#define SHOOTSOUND "weapons/adriano/colt/deagle-1.wav"
stock const colt_sounds[6][]={"weapons/adriano/colt/deagle-1.wav",
"weapons/adriano/colt/deagle-2.wav",
"weapons/adriano/colt/m1911_clipin.wav",
"weapons/adriano/colt/m1911_clipout.wav",
"weapons/adriano/colt/m1911_slideback.wav",
"weapons/adriano/colt/m1911_sliderelease.wav"}

native colt_set_colt(id)
native colt_unset_colt(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
