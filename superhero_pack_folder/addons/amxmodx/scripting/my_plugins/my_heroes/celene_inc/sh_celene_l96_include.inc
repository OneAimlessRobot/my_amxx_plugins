#if defined sh_celene_l96_include
  #endinput
#endif
#define sh_celene_l96_include

#define CELENE_WEAPON_CLASSID CSW_AWP
#define CELENE_PROJECTILE_CLASSNAME "celene_projectile"


#define CELENE_L96_SHOTSOUND "weapons/celene_rifle/shoot-1.wav"
#define CELENE_L96_WALLHIT_SOUND "weapons/xbow_hit1.wav"

#define CELENE_PROJECTILE_KNOCKBACK 300.0

#define CELENE_REVERB_SHOT_DELAY 0.1

#define CELENE_PROJECTILE_DAMAGE 130.0
#define CELENE_PROJECTILE_DAMAGE_FALLOFF_DIST 2500.0

#define CELENE_PROJECTILE_HEADSHOT_THRESHOLD_DIST 20.0

#define CELENE_PROJECTILE_DEPLOY_TIME 1.8888889
#define CELENE_PROJECTILE_SHOOT_PERIOD 0.66666667

#define CELENE_PROJECTILE_SHOOT_RANDOMNESS 0.3

#define CELENE_PROJECTILE_SPEED 6000.0
#define CELENE_PROJECTILE_GRAVITY_MULT 1.0
#define CELENE_PROJECTILE_PHYS_UPDATE_TIME 0.05

#define CELENE_PROJECTILE_MASS 1.0
#define CELENE_PROJECTILE_CAR 0.21
#define CELENE_PROJECTILE_DIAMETER 1.0
#define CELENE_PROJECTILE_AREA ((CELENE_PROJECTILE_DIAMETER*CELENE_PROJECTILE_DIAMETER)*M_PI)
#define CELENE_AIR_RESISTANCE 0.25
#define CELENE_PROJECTILE_DRAG_CONST (CELENE_PROJECTILE_AREA*CELENE_PROJECTILE_CAR*CELENE_AIR_RESISTANCE)

#define CELENE_L96_RECOIL 2.0



#define CELENE_L96_CLIP_SIZE 4

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
	CELENE_NO_ZOOM=0,
	CELENE_FIRST_ZOOM=1,
	CELENE_SECOND_ZOOM=2,
	CELENE_MAX_ZOOM=3
}
enum{
	SEQ_IDLE1=0,
 	SEQ_SHOOT1=1,
	SEQ_SHOOT2=2,
	SEQ_SHOOT3=3,
	SEQ_RELOAD=4,
	SEQ_DRAW=5
}
native celene_get_hero_id();
native celene_l96_set_num_bullets(id,value_to_set)
native celene_l96_get_num_bullets(id)
native celene_l96_dec_num_bullets(id)


