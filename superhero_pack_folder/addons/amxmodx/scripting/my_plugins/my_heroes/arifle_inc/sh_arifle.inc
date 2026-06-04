#if defined sh_arifle_funcs
  #endinput
#endif
#define sh_arifle_funcs

#define ARIFLE_SECRET_CODE 184128
#define A_RIFLE_DAMAGE 78
#define A_RIFLE_CLIP 67
#define A_RIFLE_RESERVE 103
#define A_RIFLE_SPEED 0.75
#define A_RIFLE_RECOIL 1.5

#define CSW_ARIFLE MY_CSW_M249
#define ARIFLE_PLAYER_ANIMEXT "m249"
#define ARIFLE_OLDMODEL "models/w_m249.mdl"

#define ARIFLE_V_MODEL "models/shmod/supernoodle/arifle/v_arifle.mdl"
#define ARIFLE_P_MODEL "models/shmod/supernoodle/arifle/p_arifle.mdl"
#define ARIFLE_W_MODEL "models/shmod/supernoodle/arifle/w_arifle.mdl"

#define MUZZLE_FLASH "sprites/muzzleflash7.spr"


enum
{
	anim_idle,
	anim_shoot1,
	anim_shoot2,
	anim_reload,
	anim_draw,
}


native arifle_set_arifle(id)
native arifle_unset_arifle(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
