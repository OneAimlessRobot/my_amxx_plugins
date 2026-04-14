#if defined sh_gat_funcs
  #endinput
#endif
#define sh_gat_funcs

#define YAKUI_WEAPON_NAME "weapon_m249"
#define YAKUI_WEAPON_CLASSID CSW_M249
#define PILL_CLASSNAME "pill_gatling_pill"
#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"

#define NUM_BARRELS 8
#define CLIP_SIZE 100
#define PILL_SPEED 1350.0

#define PILL_SHOOT_PERIOD_BASE 0.33
#define PILL_SHOOT_PERIOD (PILL_SHOOT_PERIOD_BASE/float(NUM_BARRELS))

#define PILL_DEPLOY_TIME 1.0

#define PILL_SHOOT_RANDOMNESS 0.0


#define PILL_MASS 100.0

enum {
	anim_idle,
	anim_idle2,
	anim_gentleidle,
	anim_stillidle,
	anim_draw,
	anim_holster,
	anim_spinup,
	anim_spindown,
	anim_spinidle,
	anim_spinfire,
	anim_spinidledown
}

enum {
	act_none,
	act_load_up,
	act_run
}
#define GAT_WINDUP_PERIOD 0.2

native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)

native clear_pills()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
