#if defined sh_lena_l96_include
  #endinput
#endif
#define sh_lena_l96_include

#define LENA_WEAPON "weapon_awp"
#define LENA_WEAPON_CLASSID CSW_AWP
#define LENA_PROJECTILE_CLASSNAME "lena_projectile"

//#define LENA_L96_SHOTSOUND "weapons/awp1.wav"
#define LENA_L96_SHOTSOUND "shmod/erica/silent_tranq/silent.wav"
#define LENA_L96_WALLHIT_SOUND "weapons/xbow_hit1.wav"
#define LENA_L96_BODYHIT_SOUND  "weapons/xbow_hitbod2.wav"

#define LENA_PROJECTILE_KNOCKBACK 300



#define LENA_PROJECTILE_DAMAGE 99.0
#define LENA_PROJECTILE_DAMAGE_FALLOFF_DIST 2500.0

#define LENA_PROJECTILE_HEADSHOT_THRESHOLD_DIST 30.0
#define LENA_PROJECTILE_SPEED 3500.0

#define LENA_PROJECTILE_SHOOT_PERIOD 1.0

#define LENA_PROJECTILE_SHOOT_RANDOMNESS 0.0

#define LENA_PROJECTILE_RELOAD_TASKID 5762341
#define LENA_PROJECTILE_REM_TASKID 12816212

#define LENA_PROJECTILE_REM_TASKID 12816212

#define LENA_ZOOM_TASKID 52132112

#define LENA_PROJECTILE_REM_TIME 0.001

#define RECOIL 0.4
#define CLIP_SIZE 4

/*
enum
{
    CS_RESET_ZOOM = 0,      // Reset any zoom blocking (mode has no effect)
    CS_SET_NO_ZOOM,         // Disable any sort of zoom
    CS_SET_FIRST_ZOOM,      // Set first zoom level (AWP style)
    CS_SET_SECOND_ZOOM,     // Set second zoom level (AWP style)
    CS_SET_AUGSG552_ZOOM,   // Set AUG/SG552 zoom style
};
*/

enum{
	LENA_NO_ZOOM=0,
	LENA_FIRST_ZOOM=1,
	LENA_SECOND_ZOOM=2,
	LENA_MAX_ZOOM=3
}

native lena_shoot_l96(id);
native lena_get_hero_id();
native lena_l96_clear_bullets();
native lena_l96_set_num_bullets(id,value_to_set)
native lena_l96_get_num_bullets(id)
native lena_l96_dec_num_bullets(id)
native lena_l96_set_user_zoom(id)
native lena_l96_reset_user_zoom(id)
native lena_l96_remove_user_zoom(id)
native lena_l96_get_user_zoom(id)
