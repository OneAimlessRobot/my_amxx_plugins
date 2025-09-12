#if defined sh_lena_l96_include
  #endinput
#endif
#define sh_lena_l96_include

#define LENA_WEAPON "weapon_awp"
#define LENA_WEAPON_CLASSID CSW_AWP
#define LENA_PROJECTILE_CLASSNAME "lena_projectile"


#define LENA_L96_SHOTSOUND "weapons/lena_rifle/shoot-1.wav"
#define LENA_L96_WALLHIT_SOUND "weapons/xbow_hit1.wav"

#define LENA_PROJECTILE_KNOCKBACK 300



#define LENA_PROJECTILE_DAMAGE 99.0
#define LENA_PROJECTILE_DAMAGE_FALLOFF_DIST 2500.0

#define LENA_PROJECTILE_HEADSHOT_THRESHOLD_DIST 30.0

#define LENA_PROJECTILE_DEPLOY_TIME 1.0
#define LENA_PROJECTILE_SHOOT_PERIOD 1.0

#define LENA_PROJECTILE_SHOOT_RANDOMNESS 0.3

#define LENA_PROJECTILE_RELOAD_TASKID 5762341
#define LENA_PROJECTILE_REM_TASKID 12816212

#define LENA_PROJECTILE_TRAIL_TASKID 12342318

#define LENA_PROJECTILE_SPEED_TASKID 123712

#define LENA_ZOOM_TASKID 52132112

#define LENA_PROJECTILE_REM_TIME 0.001

#define LENA_PROJECTILE_LIFE 40.0

#define LENA_PROJECTILE_SPEED 3000.0
#define LENA_PROJECTILE_GRAVITY_MULT 1.0
#define LENA_PROJECTILE_PHYS_UPDATE_TIME 0.05

#define LENA_PROJECTILE_MASS 1.0
#define LENA_PROJECTILE_CAR 0.4292
#define LENA_PROJECTILE_DIAMETER 2.0
#define LENA_PROJECTILE_AREA ((LENA_PROJECTILE_DIAMETER*LENA_PROJECTILE_DIAMETER)*MATH_PI)
#define LENA_AIR_RESISTANCE 200.0
#define LENA_PROJECTILE_DRAG_CONST (LENA_PROJECTILE_AREA*LENA_PROJECTILE_CAR*LENA_AIR_RESISTANCE)

#define MATH_PI  3.1415926535897932384626433832795028841971
#define RECOIL 10.0



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
enum{
	SEQ_IDLE1=0,
	SEQ_SHOOT1=1,
	SEQ_SHOOT2=2,
	SEQ_SHOOT3=3,
	SEQ_RELOAD=4,
	SEQ_DRAW=5
}
native lena_shoot_l96(id);
native lena_get_hero_id();
native lena_l96_clear_bullets();
native lena_l96_set_num_bullets(id,value_to_set)
native lena_l96_get_num_bullets(id)
native lena_l96_dec_num_bullets(id)


