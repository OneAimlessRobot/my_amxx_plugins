
#define YANDERE_MORPH_TASKID 8562
#define YANDERE_STATS_TASKID 29626
#define YANDERE_ANGER_TASKID 29333
#define YANDERE_CRY_TASKID 30333
#define YANDERE_HEAL_TASKID 30911
#define YANDERE_HEAL_PERIOD 0.1
#define YANDERE_REMOVE_GLOW_TASKID 30112

#define YANDERE_WARCRY "shmod/yandere/Yanderu_war_cry.wav"
#define YANDERE_CYCLE "shmod/yandere/yandere_cycle3.wav"
#define YANDERE_THELAST "shmod/yandere/Yandere_thelast.wav"
#define YANDERE_THELAST2 "shmod/yandere/Yandere_thelast2.wav"
#define YANDERE_THELAST3 "shmod/yandere/Yandere_thelast3.wav"
#define YANDERE_PAIN "shmod/yandere/Yandere_pain.wav"

#define YANDERE_SHOTGUN_V_MODEL "models/shmod/yandere/shotgun/v_yanderu_shotgun.mdl"
#define YANDERE_SHOTGUN_W_MODEL "models/shmod/yandere/shotgun/w_xm1014.mdl"

#define YANDERE_KNIFE_V_MODEL "models/shmod/yandere/knife/v_knife.mdl"
#define YANDERE_KNIFE_P_MODEL "models/shmod/yandere/knife/p_knife.mdl"

#define YANDERE_PSYCHO_KNIFE_V_MODEL "models/shmod/yandere/knife/v_psycho_knife.mdl"

#define YANDERE_PSYCHOSIS_TASKID 3026
#define UNPSYCHOSIS_TASKID 1122
#define PSYCHOSIS_PERIOD 1.0
#define PSYCHOSIS_TIMES floatround(floatdiv(psychosis_time,PSYCHOSIS_PERIOD))

#define TOUCHING_GROUND (1<<9)
const FL_INGROUND2=TOUCHING_GROUND

const fPainShock = 108 
// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Yandere Mk.II"
new bool:gHasYandere[SH_MAXSLOTS+1]
new bool:gSuperAngry[SH_MAXSLOTS+1]
new bool:gIdleAngry[SH_MAXSLOTS+1]
new bool:gToPlaySound[SH_MAXSLOTS+1]
new bool:gPlayedSound[SH_MAXSLOTS+1]
new gmorphed[SH_MAXSLOTS+1]
new bool:g_is_cursed[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new Float:gNormalDmgMult[SH_MAXSLOTS+1]
new Float:gNormalHeal[SH_MAXSLOTS+1]
new Float:gNormalHealRadius[SH_MAXSLOTS+1]
new Float:gNormalSpeed[SH_MAXSLOTS+1]
new Float:gPrevSpeed[SH_MAXSLOTS+1]
new Float:gNormalGravity[SH_MAXSLOTS+1]
new Float:gBaseSpeed[SH_MAXSLOTS+1]
new Float:gBaseGravity[SH_MAXSLOTS+1]
new bool:gIsPsychosis[SH_MAXSLOTS+1]
new gPsychosisTime[SH_MAXSLOTS+1]
new bool:g_yandere_leaped[SH_MAXSLOTS+1];
enum{
NO_HEALING=0,
RADIAL_HEALING,
GAZE_HEALING


}
new g_spriteSmoke, g_spriteRing, g_spriteExplosion
new const sounds[3][]={YANDERE_THELAST,YANDERE_THELAST2,YANDERE_THELAST3}

new MsgSetFOV
new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]

new m_spriteTexture
new Float:base_dmg_mult,
Float:dmg_pct_per_inc,
Float:base_heal,
Float:heal_pct_per_inc,
Float:base_heal_radius,
Float:heal_radius_inc_per_inc,
Float:base_extra_speed,
Float:speed_inc_per_inc

new Float:angry_heal,
Float:angry_speed,
Float:angry_dmg_mult,
Float:angry_gravity,
Float:angry_degen,
Float:angry_hitheal_pct,
Float:heal_base,
Float:explode_radius,
Float:explode_maxdamage,
Float:curse_pct;
new hud_sync
new Float:psychosis_time
new psychosis_cooldown
new gHeroLevel
new heal_mode
new min_players
new teamglow_on
new zoom
new psychosis_add_ap
new Float:psychosis_degen_mult
new Float:psychosis_dmg_cushion
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
