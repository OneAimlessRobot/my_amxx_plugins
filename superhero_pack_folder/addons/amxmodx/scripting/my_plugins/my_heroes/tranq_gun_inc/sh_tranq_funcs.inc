#if defined sh_tranq_funcs
#endinput
#endif
#define sh_tranq_funcs

#define DART_CLASSNAME "tranq_dart"


enum{
    seq_idle=0,
    seq_idle_leftempty,
    seq_shoot_left1,
    seq_shoot_left2,
    seq_shoot_left3,
    seq_shoot_left4,
    seq_shoot_left5,
    seq_shoot_leftlast,
    seq_shoot_right1,
    seq_shoot_right2,
    seq_shoot_right3,
    seq_shoot_right4,
    seq_shoot_right5,
    seq_shoot_rightlast,
    seq_reload,
    seq_draw
}



#define DART_DAMAGE 70.0
#define DART_DAMAGE_FALLOFF_DIST 2500.0
#define DART_HEADSHOT_THRESHOLD_DIST 20.0
#define DART_SPEED 3100.0

#define DART_SHOOT_PERIOD 0.5
#define DART_DEPLOY_TIME 1.0

#define DART_SHOOT_RANDOMNESS 0.0


#define DART_GRAVITY_MULT 1.0
#define DART_PHYS_UPDATE_TIME 0.05

#define DART_MASS 1.0
#define DART_CAR 0.4292
#define DART_DIAMETER 2.0
#define DART_AREA ((DART_DIAMETER*DART_DIAMETER)*MATH_PI)
#define TRANQ_AIR_RESISTANCE 0.25
#define DART_DRAG_CONST (DART_AREA*DART_CAR*TRANQ_AIR_RESISTANCE)

#define RECOIL 0.4
#define CLIP_SIZE 4

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
