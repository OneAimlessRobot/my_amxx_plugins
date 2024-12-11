#if defined sh_d_barrel_funcs
  #endinput
#endif
#define sh_d_barrel_funcs

#define DAMAGE 325 // 325 for Zombie / 85 for Human

#define CLIP 2
#define BPAMMO 16

#define SPEED 0.35
#define RELOAD_TIME 1.5
#define KNOCKPOWER 1000

#define MODEL_V "models/shmod/supernoodle/dbarrel/v_dbarrel.mdl"
#define MODEL_P "models/shmod/supernoodle/dbarrel/p_dbarrel.mdl"

#define CSW_DBARREL CSW_M3
#define weapon_dbarrel "weapon_m3"

#define WEAPON_SECRETCODE 20106014
#define OLD_W_MODEL "models/w_m3.mdl"
#define OLD_EVENT "events/m3.sc"
#define ANIM_EXT "shotgun"

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))



native d_barrel_set_d_barrel(id)
native d_barrel_unset_d_barrel(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
