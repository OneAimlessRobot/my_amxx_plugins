#if defined sh_yandere_jet_funcs
  #endinput
#endif
#define sh_yandere_jet_funcs




#define JETPLANE_FUSELAGE_CLASSNAME "yandere_jet"
#define JETPLANE_SHELL_CLASSNAME "yandere_bullet"
#define JETPLANE_ROCKET_CLASSNAME "yandere_rocket"
#define JETPLANE_MG_CLASSNAME "yandere_mg"
#define JETPLANE_LAW_CLASSNAME "yandere_law"



#define JETPLANE_MODEL "models/shmod/yandere/jetplane/fuselage/airattack_plane.mdl"
#define JETPLANE_CAMERA_MODEL "models/camera.mdl"
#define ROCKET_MODEL "models/shmod/yandere/jetplane/projectiles/GradRocket.mdl"



// GLOBAL VARIABLES
#define JET_COOLDOWN_TASKID 17261782
#define JET_LOAD_TASKID 1722112

#define JET_CHARGE_TASKID 21267438
#define JET_HUD_TASKID 2141213
#define JET_SOUND_TASKID 6212398
#define JET_DEPLOY_TASKID 22227438
//#define JET_SPEED_TASKID 22647438
#define JET_CHARGE_PERIOD 0.15
#define JET_HUD_PERIOD 0.15
#define JET_SOUND_PERIOD 0.15
#define JET_THINK_PERIOD 0.1
#define JET_MINIMUM_SPEED 50.0
#define JET_RESTITUTION_COEFF 0.40
#define JET_TRAIL_LIFE_PERIOD 1.0
#define JET_TRAIL_LIFE_INPUT_VALUE (floatround(JET_TRAIL_LIFE_PERIOD*10.0)+1)

#define JET_AVG_SPEED_CALC_PERIOD 0.1
#define JET_CHARGE_RATE 1000.0

#define CAMERA_DIST 300.0
stock Float:jetplane_min_dims[3]={-33.0,-33.0,-33.0}
stock Float:jetplane_max_dims[3]={33.0,33.0,33.0}
stock const jetplane_color[4]={100,100,100,50}

stock const Float:jetplane_origin_mg_offsets[3]={0.0,0.0,10.0}
stock const Float:jetplane_origin_law_offsets[3]={0.0,0.0,30.0}
native clear_jets()

native reset_jet_user(id)
native jet_get_user_jet_cooldown(id)
native jet_loaded(id)
native jet_destroy(id)
native jet_deployed(id)
native jet_uncharge_user(id)
native jet_charge_user(id)
native Float:jet_get_think_period()
native jet_get_user_jet(id)
native jet_hurt_user_jet(id,attacker,damage_entity,Float:damage_to_do)
