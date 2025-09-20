#if defined sh_d_barrel_funcs
  #endinput
#endif
#define sh_d_barrel_funcs


#define CSW_GATLING CSW_M3
#define weapon_gatling "weapon_m3"
#define WEAPON_ANIMEXT "shotgun"
#define DEFAULT_W_MODEL "models/w_m3.mdl"
#define WEAPON_SECRET_CODE 1942
#define old_event "events/m3.sc"

#define D_BARREL_DAMAGE 85
#define D_BARREL_SPEED 0.5
#define D_BARREL_RECOIL 0.7
#define D_BARREL_RELOAD_TIME 1.5
#define D_BARREL_DEFAULT_CLIP 2
#define D_BARREL_DEFAULT_BPAMMO 64
#define D_BARREL_KNOCKPOWER 1000

#define SUBMODEL -1


// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))


const PDATA_SAFE = 2
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_LINUX_PLAYER = 5
const OFFSET_WEAPONOWNER = 41
const m_iClip = 51
const m_fInReload = 54
const m_flNextAttack = 83
const m_szAnimExtention = 492
const m_szAnimExtention = 492

native d_barrel_set_d_barrel(id)
native d_barrel_unset_d_barrel(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
