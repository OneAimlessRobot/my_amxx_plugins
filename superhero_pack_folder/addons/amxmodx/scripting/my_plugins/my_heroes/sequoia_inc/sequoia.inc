#if defined sh_sequoia_inc
  #endinput
#endif
#define sh_sequoia_inc

#define SEQUOIA_START_ANGLE ((45.0))
#define SEQUOIA_BEAM_THINK_PERIOD 0.05
#define SEQUOIA_ACTIVE_TASK_TIME_PERIOD 0.3
#define SEQUOIA_PASSIVE_TASK_TIME_PERIOD 1.0
#define SEQUOIA_SWEEP_TIME 6.0
#define SPAM_TIME 2.0
#define SPAM_PERIOD 0.1
#define SPAM_NUM_TIMES (SPAM_TIME/SPAM_PERIOD)
#define SPAM_SUBLOOP_TIMES 9
#define SPAM_LINGER 1.0

#define SEQUOIA_ANGLE_LINEAR_INC ((SEQUOIA_START_ANGLE/SEQUOIA_SWEEP_TIME)*SEQUOIA_BEAM_THINK_PERIOD)

#define SEQUOIA_BEAM_TERMINAL_ENT_CLASS "sequoia_terminal"

#define HYDROCVTTR_CHARGING_SOUND "shmod/flora/fields/field_charging.wav"

#define HYDROCVTTR_IMPACT_SOUND  "shmod/sequoia/beam/beam_water_torrent_sound.wav"
#define HYDROCVTTR_TORRENT_PULSE_SOUND "shmod/sequoia/beam/beam_water_torrent_sound_micro_pulse.wav"
#define HYDROCVTTR_WINDUP_SOUND "shmod/sequoia/beam/beam_water_torrent_sound_windup.wav"

#define SEQUOIA_HEALTHCAP 30.0
#define SEQUOIA_HEALTHCAP_INT_VERSION 30

enum attack_phase{

    none,
    select,
    aim,
    COAGULATION,
    ANNIHILATION

}

native sequoia_get_hero_id()