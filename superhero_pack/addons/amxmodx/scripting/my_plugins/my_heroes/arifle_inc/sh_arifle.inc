#if defined sh_arifle_funcs
  #endinput
#endif
#define sh_arifle_funcs

#define DAMAGE 50
#define CLIP 100
#define RESERVE 400
#define SPEED 1.0
#define RECOIL 0.75

#define CSW_ARIFLE CSW_M249
#define weapon_arifle "weapon_m249"
#define PLAYER_ANIMEXT "m249"
#define ARIFLE_OLDMODEL "models/w_m249.mdl"

#define V_MODEL "/models/shmod/supernoodle/arifle/v_arifle.mdl"
#define P_MODEL "models/p_m249.mdl"
#define W_MODEL "models/w_m60.mdl"


new const Arifle_Sounds[4][] = 
{
	"weapons/m60-1.wav",
	"weapons/ethereal_draw.wav",
	"weapons/ethereal_idle1.wav",
	"weapons/ethereal_reload.wav"
}

new const Arifle_Resources[3][] = 
{
	"sprites/weapon_ethereal.txt",
	"sprites/640hud7_2.spr",
	"sprites/640hud74_2.spr"
}

#define MUZZLE_FLASH "sprites/muzzleflash7.spr"


enum
{
	anim_idle,
	anim_shoot1,
	anim_shoot2,
	anim_reload,
	anim_draw,
}

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))


native arifle_set_arifle(id)
native arifle_unset_arifle(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
