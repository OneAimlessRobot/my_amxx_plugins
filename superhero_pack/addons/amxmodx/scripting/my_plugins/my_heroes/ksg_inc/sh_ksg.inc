#if defined sh_ethereal_funcs
  #endinput
#endif
#define sh_ethereal_funcs

#define DAMAGE 26
#define CLIP 30
#define SPEED 1.0
#define RECOIL 0.75

#define CSW_ETHEREAL CSW_M4A1
#define weapon_ethereal "weapon_m4a1"
#define PLAYER_ANIMEXT "carbine"
#define ETHEREAL_OLDMODEL "models/w_m4a1.mdl"

#define V_MODEL "models/shmod/adriano/ethereal/v_ethereal.mdl"
#define P_MODEL "models/shmod/adriano/ethereal/p_ethereal.mdl"
#define W_MODEL "models/shmod/adriano/ethereal/w_ethereal.mdl"

new const Ethereal_Sounds[4][] = 
{
	"weapons/ethereal-1.wav",
	"weapons/ethereal_draw.wav",
	"weapons/ethereal_idle1.wav",
	"weapons/ethereal_reload.wav"
}

new const Ethereal_Resources[3][] = 
{
	"sprites/weapon_ethereal.txt",
	"sprites/640hud7_2.spr",
	"sprites/640hud74_2.spr"
}

#define MUZZLE_FLASH "sprites/muzzleflash7.spr"

enum
{
	E_ANIM_IDLE = 0,
	E_ANIM_RELOAD,
	E_ANIM_DRAW,
	E_ANIM_SHOOT1,
	E_ANIM_SHOOT2,
	E_ANIM_SHOOT3
}


// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))


native ethereal_set_ethereal(id)
native ethereal_unset_ethereal(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
