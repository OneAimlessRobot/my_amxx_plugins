#if defined sh_pill_gat_funcs
  #endinput
#endif
#define sh_pill_gat_funcs

#define YAKUI_WEAPON_CLASSID CSW_M249
#define PILL_CLASSNAME "pill_gatling_pill"

#define NUM_BARRELS 8
#define PILLGATLING_CLIP_SIZE 100
#define PILL_SPEED 1350.0

#define PILL_SHOOT_PERIOD_BASE 0.33
#define PILL_SHOOT_PERIOD (PILL_SHOOT_PERIOD_BASE/float(NUM_BARRELS))

#define PILL_DEPLOY_TIME 1.0

#define PILL_SHOOT_RANDOMNESS 0.0

#define SHUTDOWN_TIME 1.7
#define PILL_MASS 100.0

#define PILLGATLING_RECOIL 0.1

enum yakui_pillgatling_anims{
	yakui_pillgatling_anim_idle = 0,
	yakui_pillgatling_anim_idle2,
	yakui_pillgatling_anim_gentleidle,
	yakui_pillgatling_anim_stillidle,
	yakui_pillgatling_anim_draw,
	yakui_pillgatling_anim_holster,
	yakui_pillgatling_anim_spinup,
	yakui_pillgatling_anim_spindown,
	yakui_pillgatling_anim_spinidle,
	yakui_pillgatling_anim_spinfire,
	yakui_pillgatling_anim_spinidledown
}

enum gatling_action{
	act_none = 0,
	act_load_up,
	act_run
}
enum fire_mode_enum{
	spin_shoot=0,
	spin_only

}
#define GAT_WINDUP_PERIOD 0.2

native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
