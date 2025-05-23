

#define SEARCH_MSG "loading targets!"


#define SEARCH_LOOP_TASKID 218128
#define SPORE_TRAIL_LOOP_TASKID 2329129



#define SPORE_PREPARE_SFX "shmod/kzam/launcher/eject_prepare.wav"
#define SPORE_SEND_SFX "shmod/kzam/launcher/eject_send.wav"

//emit_sound(id, CHAN_WEAPON, SPORE_PREPARE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
//emit_sound(id, CHAN_WEAPON, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)


#define SHOOT_LOOP_TASKID 46523423
#define UNSHOOT_LOOP_TASKID 6433243
#define SHOOT_LOOP_PERIOD 0.2

#define UNITS_ABOVE = 80



native spores_launch(id)
native spores_gather_targets(id)
native spores_reset_user(id)
native spores_clear()
native bool:spores_used(id)
native bool:spores_ready(id)
native bool:spores_busy(id)
native spores_max_victims()