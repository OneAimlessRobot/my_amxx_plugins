#if defined sh_h_rifle_funcs
  #endinput
#endif
#define sh_h_rifle_funcs

#define DAMAGE 91 // 191 for Zombie

#define H_RIFLE_CLIP 5
#define H_RIFLE_BPAMMO 45

#define H_RIFLE_SPEED 1.25

#define MODEL_V "models/shmod/supernoodle/hrifle/v_mosin.mdl"
#define MODEL_P "models/shmod/supernoodle/hrifle/p_mosin.mdl"
#define MODEL_W "models/shmod/supernoodle/hrifle/w_mosin.mdl"

#define CSW_MOSIN CSW_SCOUT
#define weapon_mosin "weapon_scout"

#define WEAPON_SECRETCODE 2892014
#define OLD_W_MODEL "models/w_scout.mdl"
#define OLD_EVENT "events/scout.sc"

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))



native h_rifle_set_h_rifle(id)
native h_rifle_unset_h_rifle(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
