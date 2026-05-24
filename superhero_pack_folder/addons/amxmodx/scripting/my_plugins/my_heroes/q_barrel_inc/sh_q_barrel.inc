#if defined sh_q_barrel_funcs
  #endinput
#endif
#define sh_q_barrel_funcs

#define Q_BARREL_DAMAGE 325 // 325 for Zombie / 85 for Human

#define Q_BARREL_CLIP 4
#define Q_BARREL_BPAMMO 100

#define Q_BARREL_SPEED 0.35
#define Q_BARREL_RELOAD_TIME 3.0
#define Q_BARREL_KNOCKPOWER 1000
#define Q_BARREL_RECOIL 1.25

#define Q_BARREL_MODEL_V "models/shmod/graciete/qbarrel/v_qbarrel.mdl"
#define Q_BARREL_MODEL_P "models/shmod/graciete/qbarrel/p_qbarrel.mdl"
#define Q_BARREL_MODEL_W "models/shmod/graciete/qbarrel/w_qbarrel.mdl"

#define CSW_QUADBARREL CSW_M3

#define QUAD_BARREL_WEAPON_SECRETCODE 20132014
#define OLD_W_MODEL_Q_BARREL "models/w_m3.mdl"
#define OLD_EVENT_Q_BARREL "events/m3.sc"
#define ANIM_EXT "shotgun"




native q_barrel_set_q_barrel(id)
native q_barrel_unset_q_barrel(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
