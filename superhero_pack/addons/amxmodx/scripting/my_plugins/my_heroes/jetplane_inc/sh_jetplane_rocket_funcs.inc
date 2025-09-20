#if defined sh_yandere_jet_rocket_funcs
  #endinput
#endif
#define sh_yandere_jet_rocket_funcs



#define JETPLANE_ROCKET_CLASSNAME "yandere_rocket"
#define JETPLANE_LAW_CLASSNAME "yandere_law"



#define P_ROCKET_LAUNCHER_MODEL "models/shmod/yandere/jetplane/gunz/law/w_law.mdl"
#define ROCKET_MODEL "models/shmod/yandere/jetplane/projectiles/GradRocket.mdl"



#define JETPLANE_LAW_FIRE_SOUND "shmod/yandere/jetsounds/weapons/law/rocketfire1.wav"
#define JETPLANE_LAW_ROCKET_SOUND "shmod/yandere/jetsounds/weapons/law/rocket1.wav"

#define ROCKET_EXPLODE_SOUND "weapons/explode3.wav"

#define JETROCKET_FALLOFF_DIST 1.0

#define ROCKET_SHOOT_PERIOD 1.0

#define ROCKET_RELOAD_TASKID 7668

#define ROCKET_RADIUS 500.0


#define LAW_THINK_PERIOD 0.1

#define ROCKET_SPEED 2000.0

stock Float:jetplane_law_min_dims[3]={-20.0,-5.0,-5.0}
stock Float:jetplane_law_max_dims[3]={20.0,5.0,5.0}

native get_jet_rockets(jet_id)
native set_jet_rockets(jet_id,num_rockets)
native reset_jet_rockets(jet_id)
native get_user_jet_rockets(id)
native set_user_jet_rockets(id,num_rockets)
native reset_user_jet_rockets(id)
native clear_rockets()
native clear_laws()
native law_destroy(id)
native spawn_jetplane_law(id)
native get_user_law(id)
native Float:get_law_think_period()

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
