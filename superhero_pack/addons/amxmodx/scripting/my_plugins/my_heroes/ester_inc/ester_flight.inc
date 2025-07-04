#if defined sh_ester_flight_funcs
  #endinput
#endif
#define sh_ester_flight_funcs

#define FLIGHT_POWER "shmod/ester/flight/flight_power.wav"
#define FLIGHT_HUM "shmod/ester/flight/flight_hum.wav"
#define FLIGHT_WEAK "shmod/ester/flight/flight_weak.wav"
#define FLIGHT_BLOWUPSOUND "shmod/ester/flight/flight_blowup.wav"

#define FLIGHT_GODMODE_THINK_TIME 0.3

#define FlameAndSoundRate 10

const fPainShock=108
#define PRE_RESPAWN_MESSAGE_RELAY 0.0
#define ESTER_REBORN_EXPLOSION_DELAY_TIME 10.0

#define ESTER_REBORN_CALCULATION_LOOP_TASKID 12912923
#define ESTER_REBORN_TASKID 666333000
#define ESTER_REBORN_POSITION_CHECK_TASKID   176423923
#define ESTER_REBORN_GLOW_TASKID 42912923
#define ESTER_REBORN_TEAM_CHECK_TASKID   676423923
#define ESTER_REBORN_EXPLOSION_DELAY_TASKID   8271237

native ester_get_reborn_mode(id)
native ester_set_reborn_mode(id,value)
native reset_ester_reborn_mode(id,enable)