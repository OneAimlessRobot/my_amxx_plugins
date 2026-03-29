
#define YANDERE_MORPH_TASKID 8562
#define YANDERE_STATS_TASKID 29626
#define YANDERE_ANGER_TASKID 29333
#define YANDERE_CRY_TASKID 30333
#define YANDERE_REMOVE_GLOW_TASKID 30112

#define YANDERE_WEAPON_CLASSID CSW_XM1014
#define YANDERE_WEAPON_NAME "weapon_xm1014"
#define YANDERE_WARCRY "shmod/yandere/Yanderu_war_cry.wav"
#define YANDERE_CYCLE "shmod/yandere/yandere_cycle3.wav"
#define YANDERE_THELAST "shmod/yandere/Yandere_thelast.wav"
#define YANDERE_THELAST2 "shmod/yandere/Yandere_thelast2.wav"
#define YANDERE_THELAST3 "shmod/yandere/Yandere_thelast3.wav"
#define YANDERE_PAIN "shmod/yandere/Yandere_pain.wav"

#define YANDERE_SHOTGUN_V_MODEL "models/shmod/yandere/shotgun/v_yanderu_shotgun.mdl"
#define YANDERE_SHOTGUN_P_MODEL "models/shmod/yandere/shotgun/w_xm1014.mdl"

#define YANDERE_KNIFE_V_MODEL "models/shmod/yandere/knife/v_knife.mdl"
#define YANDERE_KNIFE_P_MODEL "models/shmod/yandere/knife/p_knife.mdl"

#define YANDERE_PSYCHO_KNIFE_V_MODEL "models/shmod/yandere/knife/v_psycho_knife.mdl"
#define YANDERE_PSYCHO_KNIFE_P_MODEL "models/shmod/yandere/knife/p_psycho_knife.mdl"



#define YANDERE_CYCLE_PERIOD 0.4
#define TOUCHING_GROUND (1<<9)
const FL_INGROUND2=TOUCHING_GROUND

const fPainShock = 108 
// GLOBAL VARIABLES
stock gHeroID
stock const gHeroName[] = "Yandere Mk.II"
stock bool:gHasYandere[SH_MAXSLOTS+1]
stock bool:gSuperAngry[SH_MAXSLOTS+1]
stock bool:gIdleAngry[SH_MAXSLOTS+1]
stock bool:gToPlaySound[SH_MAXSLOTS+1]
stock bool:gPlayedSound[SH_MAXSLOTS+1]
stock gmorphed[SH_MAXSLOTS+1]
stock bool:g_is_cursed[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
stock Float:gNormalDmgMult[SH_MAXSLOTS+1]
stock Float:gNormalSpeed[SH_MAXSLOTS+1]
stock Float:gBaseSpeed[SH_MAXSLOTS+1]
stock g_prevWeapon[SH_MAXSLOTS+1]
stock g_mates_alive[SH_MAXSLOTS+1]
stock g_mates_dead[SH_MAXSLOTS+1]

stock const sounds[3][]={YANDERE_THELAST,YANDERE_THELAST2,YANDERE_THELAST3}

stock gLastWeapon[SH_MAXSLOTS+1]
stock gLastClipCount[SH_MAXSLOTS+1]

stock Float:base_dmg_mult,
Float:dmg_pct_per_inc,
Float:base_extra_speed,
Float:speed_inc_per_inc

stock Float:angry_speed,
Float:angry_dmg_mult,
Float:angry_gravity,
Float:angry_degen_pct,
Float:angry_hitheal_pct,
Float:explode_radius,
Float:explode_maxdamage,
Float:curse_pct;
stock hud_sync
stock gHeroLevel
stock min_players
stock teamglow_on
stock degen_health_extra_threshold
stock overheal_hp_max


stock Float:gTransTimer[SH_MAXSLOTS+1]
stock bool:gTransTimerStarted[SH_MAXSLOTS+1]
stock Float:trans_time


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
