#if defined sh_yandere_jet_mg_funcs
  #endinput
#endif
#define sh_yandere_jet_mg_funcs

#define JETPLANE_SHELL_CLASSNAME "yandere_bullet"
#define JETPLANE_MG_CLASSNAME "yandere_mg"


#define P_MACHINEGUN_MODEL "models/shmod/yandere/jetplane/gunz/mountgun/mountgun.mdl"
#define GUN_SHELL "models/shmod/yandere/jetplane/projectiles/rshell.mdl"
#define MACHINE_GUN_SOUND "shmod/yandere/jetsounds/weapons/mg/m60-1.wav"




#define MG_SHELL_PERIOD 0.1


#define MG_SHELL_RELOAD_TASKID 51212631
#define MG_SHELL_REM_TASKID 9467437

#define MG_SHELL_REM_TIME 0.001

new Float:jetplane_mg_min_dims[3]={-30.0,-30.0,-30.0}
new Float:jetplane_mg_max_dims[3]={30.0,30.0,30.0}


native get_jet_shells(jet_id)
native set_jet_shells(jet_id,num_shells)
native reset_jet_shells(jet_id)
native get_user_jet_shells(id)
native set_user_jet_shells(id,num_shells)
native reset_user_jet_shells(id)
native clear_shells()
native clear_mgs()
native mg_destroy(id)
native spawn_jetplane_mg(id)
native get_user_mg(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
