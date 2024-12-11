#if defined sh_q_barrel_funcs
  #endinput
#endif
#define sh_q_barrel_funcs

#define DAMAGE 325 // 325 for Zombie / 85 for Human

#define CLIP 4
#define BPAMMO 100

#define SPEED 0.35
#define RELOAD_TIME 3.0
#define KNOCKPOWER 1000

#define MODEL_V "models/shmod/graciete/qbarrel/v_qbarrel.mdl"
#define MODEL_P "models/shmod/graciete/qbarrel/p_qbarrel.mdl"
#define MODEL_W "models/shmod/graciete/qbarrel/w_qbarrel.mdl"

#define CSW_QUADBARREL CSW_M3
#define weapon_quadbarrel "weapon_m3"

#define WEAPON_SECRETCODE 20102014
#define OLD_W_MODEL "models/w_m3.mdl"
#define OLD_EVENT "events/m3.sc"
#define ANIM_EXT "shotgun"

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))



native q_barrel_set_q_barrel(id)
native q_barrel_unset_q_barrel(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
