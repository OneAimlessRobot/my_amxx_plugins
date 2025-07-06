#if defined sh_ester_flight_funcs
  #endinput
#endif
#define sh_ester_flight_funcs

#define FLIGHT_POWER "shmod/ester/flight/flight_power.wav"
#define FLIGHT_IGNITION "shmod/ester/flight/flight_ignition.wav"
#define FLIGHT_HUM "shmod/ester/flight/flight_hum.wav"
#define FLIGHT_WEAK "shmod/ester/flight/flight_weak.wav"

#define COLOR_STRONG WHITE
#define COLOR_WEAK GREEN

#define ESTER_NUM_BLOWUPSOUNDS 7
stock const ester_blowup_sounds[ESTER_NUM_BLOWUPSOUNDS][128]={

	"shmod/ester/flight/flight_blowup1.wav",
	"shmod/ester/flight/flight_blowup2.wav",
	"shmod/ester/flight/flight_blowup3.wav",
	"shmod/ester/flight/flight_blowup4.wav",
	"shmod/ester/flight/flight_blowup5.wav",
	"shmod/ester/flight/flight_blowup6.wav",
	"shmod/ester/flight/amurican_malez.wav"
}

#define ESTER_RESPAWN_FAIL_SOUND "shmod/ester/flight/flight_blowup_fail.wav"

#define ESTER_RESPAWN_FAIL_MSG "You're done. You get no more chances."

#define ESTER_SUICIDE_FAIL_MSG "You failed to transcend self-worth, for you have bailed the ultimate honour. You're done. Now, rest easy."

#define ESTER_SUICIDE_SCOURN_MSG "Wow, they really do not make gods like they used to. Forgiven for taking your own life? Alright, enjoy the rest of the round."

#define FLIGHT_GODMODE_THINK_TIME 0.3

#define FlameAndSoundRate 10

#define ESTER_WALL_STUCK_MSG "You were eliminated completely. Dont get stuck on walls, numbskull."
#define ESTER_REBORN_TEAM_CHANGE_MSG "You changed teams and were reborn as ester, now you shall die"




const fPainShock=108
#define PRE_RESPAWN_MESSAGE_RELAY 0.0
#define ESTER_REBORN_EXPLOSION_DELAY_TIME 10.0

#define ESTER_REBORN_CALCULATION_LOOP_TASKID 12912923
#define ESTER_REBORN_TASKID 666333000
#define ESTER_REBORN_POSITION_CHECK_TASKID   176423923
#define ESTER_REBORN_GLOW_TASKID 42912923
#define ESTER_REBORN_TEAM_CHECK_TASKID   676423923
#define ESTER_REBORN_EXPLOSION_DELAY_TASKID   8271237

#define ESTER_NUM_SENTENCES 3
stock const ester_sentences[ESTER_NUM_SENTENCES][128]={
	"You were made to do more than survive the day. Go avenge yourself",
	"This one must count, now. I wont disappoint myself or them any longer",
	"Its show time."}
	
native ester_get_reborn_mode(id)
native ester_get_respawn_attempts_remaining(id)
native ester_set_reborn_mode(id,value)
native reset_ester_reborn_mode(id,enable)