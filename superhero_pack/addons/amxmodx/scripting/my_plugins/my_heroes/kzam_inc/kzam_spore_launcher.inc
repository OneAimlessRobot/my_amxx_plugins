

#define SEARCH_MSG "loading targets!"
#define BUSY_MSG "Some launched spores still busy!"


#define SEARCH_LOOP_TASKID 218128
#define SPORE_TRAIL_LOOP_TASKID 2329129



#define LAUNCHER_CLASSNAME "kzam_launcher"


#define SPORE_PREPARE_SFX "shmod/kzam/launcher/eject_prepare.wav"
#define SPORE_SEND_SFX "shmod/kzam/launcher/eject_send.wav"

//emit_sound(id, CHAN_WEAPON, SPORE_PREPARE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
//emit_sound(id, CHAN_WEAPON, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)


#define SHOOT_LOOP_TASKID 46523423
#define UNSHOOT_LOOP_TASKID 6433243
#define SHOOT_LOOP_PERIOD 0.2

#define SPORE_THINK_PERIOD 0.05

#define UNITS_ABOVE = 80

#define COOLDOWN_UPDATE_TASKID 1233222
#define COOLDOWN_UPDATE_PERIOD 0.5

#define STATUS_UPDATE_TASKID 7812713
#define STATUS_UPDATE_PERIOD 0.5



native delete_hud_tasks(id)
native init_hud_tasks(id)
native init_cooldown_update_tasks(id)
native delete_cooldown_update_tasks(id)
native spores_launch(id)
native spores_gather_targets(id)
native spores_reset_user(id)
native spores_clear()
native bool:spores_busy(id)
native spores_max_victims()