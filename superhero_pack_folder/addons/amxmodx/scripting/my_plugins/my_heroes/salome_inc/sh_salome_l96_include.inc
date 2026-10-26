#if defined sh_salome_l96_include
  #endinput
#endif
#define sh_salome_l96_include

#define SALOME_WEAPON_CLASSID CSW_AWP
#define SALOME_PROJECTILE_CLASSNAME "salome_projectile"


#define SALOME_L96_SHOTSOUND "weapons/salome_rifle/shoot-1.wav"
#define SALOME_L96_WALLHIT_SOUND "weapons/xbow_hit1.wav"

#define SALOME_PROJECTILE_KNOCKBACK 300.0

#define SALOME_REVERB_SHOT_DELAY 0.1

#define SALOME_PROJECTILE_DAMAGE 130.0
#define SALOME_PROJECTILE_DAMAGE_FALLOFF_DIST 2500.0

#define SALOME_PROJECTILE_HEADSHOT_THRESHOLD_DIST 20.0

#define SALOME_PROJECTILE_DEPLOY_TIME 1.8888889
#define SALOME_PROJECTILE_SHOOT_PERIOD 0.66666667

#define SALOME_PROJECTILE_SHOOT_RANDOMNESS 0.3

#define SALOME_PROJECTILE_SPEED 6000.0
#define SALOME_PROJECTILE_GRAVITY_MULT 1.0
#define SALOME_PROJECTILE_PHYS_UPDATE_TIME 0.05

#define SALOME_PROJECTILE_MASS 1.0
#define SALOME_PROJECTILE_CAR 0.21
#define SALOME_PROJECTILE_DIAMETER 1.0
#define SALOME_PROJECTILE_AREA ((SALOME_PROJECTILE_DIAMETER*SALOME_PROJECTILE_DIAMETER)*M_PI)
#define SALOME_AIR_RESISTANCE 0.25
#define SALOME_PROJECTILE_DRAG_CONST (SALOME_PROJECTILE_AREA*SALOME_PROJECTILE_CAR*SALOME_AIR_RESISTANCE)

#define SALOME_L96_RECOIL 2.0



#define SALOME_L96_CLIP_SIZE 4

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
	SALOME_NO_ZOOM=0,
	SALOME_FIRST_ZOOM=1,
	SALOME_SECOND_ZOOM=2,
	SALOME_MAX_ZOOM=3
}
enum{
	SEQ_IDLE1=0,
 	SEQ_SHOOT1=1,
	SEQ_SHOOT2=2,
	SEQ_SHOOT3=3,
	SEQ_RELOAD=4,
	SEQ_DRAW=5
}
native salome_get_hero_id();
native salome_l96_set_num_bullets(id,value_to_set)
native salome_l96_get_num_bullets(id)
native salome_l96_dec_num_bullets(id)


