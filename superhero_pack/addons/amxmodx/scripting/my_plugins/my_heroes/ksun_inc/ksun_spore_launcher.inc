

#if defined sh_ksun_launcher_funcs
  #endinput
#endif
#define sh_ksun_launcher_funcs

#define SEARCH_MSG "loading targets!"
#define BUSY_MSG "Some launched spores still busy!"


#define SEARCH_LOOP_TASKID 218128
#define SPORE_TRAIL_LOOP_TASKID 2329129

#define LAUNCHER_CLASSNAME "ksun_launcher"


#define SPORE_PREPARE_SFX "shmod/ksun/launcher/eject_prepare.wav"
#define SPORE_SEND_SFX "shmod/ksun/launcher/eject_send.wav"
#define SPORE_READY_SFX "shmod/ksun/launcher/spore_notification.wav"


#define SHOOT_LOOP_TASKID 46523423
#define UNSHOOT_LOOP_TASKID 6433243
#define SHOOT_LOOP_PERIOD 0.2




#define DEPLOY_LOOP_TASKID 7261272
#define UNDEPLOY_LOOP_TASKID 3434004
#define DEPLOY_LOOP_PERIOD 0.2

#define SPORE_THINK_PERIOD 0.05

#define UNITS_ABOVE 80

#define PHASE_IDLE 0
#define PHASE_DEPLOY 1
#define PHASE_HOLD 2
#define PHASE_SEND 3
#define PHASE_DONE 4

#define LAUNCHER_DEAD_HP 1000.0

#define LAUNCHER_SIZE 15.0

#define LAUNCHER_THINK_PERIOD 0.25



native delete_hud_tasks(id)
native init_hud_tasks(id)
native init_cooldown_update_tasks(id)
native delete_cooldown_update_tasks(id)
native get_player_launcher_phase(id)
native get_player_launcher(id)
native launcher_deploy(id)
native spores_launch(id)
native spores_reset_user(id)
native launchers_clear()
native Float:get_follow_time()
native bool:spores_busy(id)
native spores_max_victims()