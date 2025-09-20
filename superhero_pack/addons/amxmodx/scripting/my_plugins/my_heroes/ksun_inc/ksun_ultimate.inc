#if defined sh_ksun_ultimate_funcs
  #endinput
#endif
#define sh_ksun_ultimate_funcs


#define KSUN_ULTIMATE_TASKID 23712316
#define UNKSUN_ULTIMATE_TASKID 9723512
#define KSUN_ULTIMATE_LOOP_PERIOD 0.4
#define KSUN_ULTIMATE_LOOP_DEC 30
#define KSUN_ULTIMATE_LOOP_TIMES floatround(floatdiv(float(ksun_supply_capacity),float(KSUN_ULTIMATE_LOOP_DEC)))

#define KSUN_ULTIMATE_SOUND "shmod/ksun/ultimate/ksun_ultimate_deploy_sound.wav"

#define FAST_RELOAD_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

// weapons offsets
const m_pPlayer            = 41
const m_iId                = 43
const m_flNextPrimaryAttack    = 46
const m_flNextSecondaryAttack    = 47
const m_flTimeWeaponIdle        = 48
const m_fInReload            = 54

const m_flNextAttack = 83

stock const Float:g_fReloadDelay[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
	2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
	0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

native ksun_player_is_in_ultimate(id)

native ksun_player_is_ultimate_ready(id)

native ksun_unultimate_user(id)

native ksun_player_engage_ultimate(id)


native ksun_get_player_supply_points(id)


native ksun_set_player_supply_points(id, value)

native ksun_inc_player_supply_points(id, value)

native ksun_dec_player_supply_points(id, value)
