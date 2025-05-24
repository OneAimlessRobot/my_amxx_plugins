#if defined sh_kzam_particle_funcs
  #endinput
#endif
#define sh_kzam_particle_funcs


#define KZAM_SPORE_MDL "models/shmod/predgun/preddisc.mdl"
#define SPORE_WOUND_SFX  "hornet/ag_hornethit1.wav"
#define SPORE_HEAL_SFX "shmod/ration.wav"
#define SPORE_TRAVEL_SFX "roach/rch_smash.wav"



#define SPORE_CLASSNAME "kzam_spore"

#define SPORE_SIZE 5.0


#define FIRE_LOOP_TASKID 65231239
#define UNFIRE_LOOP_TASKID 12344323
#define FIRE_DELAY 0.2

#define FOLLOW_LOOP_TASKID 2329129
#define UNFOLLOW_LOOP_TASKID 1223332
#define FOLLOW_LOOP_PERIOD 0.2
#define FOLLOW_LOOP_TIMES floatround(floatdiv(kzam_follow_time,FOLLOW_LOOP_PERIOD))


#define SPORE_DEAD_HP 1000.0