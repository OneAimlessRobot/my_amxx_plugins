//--------------------------------------------------------------------------------------------------
// ORIGINAL HERO DISCRIPTIONS & UPDATES
//--------------------------------------------------------------------------------------------------
/*
NO DESCRIPTIONS AVAILABLE

VERSION 1.4
- MODIFIED AND ENHANCED CODES FOR MRHYDROGEN_VICTIM_FLOAT(ID) AND MRHYDROGEN_POWERS(ID) - CREDITS: G-DOG

VERSION 1.3
- REMOVED VEXD_UTILITIES INCLUDES AS IT IS NOT NEEDED
- ADDED ENGINE INCLUDES
- CVAR CHANGES - MR_HYDROGEN TO MRHYDROGEN
- MINOR CODE CLEANUP

VERSION 1.2
- REMOVED AMXMOD INCLUDES AS REQUESTED BY VITTU

VERSION 1.1
- ADDED SOUND EFFECTS - WHEN POWER IS USED ON ENEMY, VICTIM MAKES BREATHING SOUNDS UNTIL HYDROGEN GAS IS GONE
- ADDED HUD MESSAGE - WHEN POWER IS USED ON ENEMY, HUD MESSAGE WILL ONLY SHOW TO VICTIM
- MAJOR CODE CLEANUP

VERSION 1.0
- RELEASE OF HERO
*/
//--------------------------------------------------------------------------------------------------
// CVARS
//--------------------------------------------------------------------------------------------------
/*

//Mr. Hydrogen
mrhydrogen_level 0		// Level Acquired To Use Hero
mrhydrogen_knifemult 1.10	// Multiply Knife Damage
mrhydrogen_floattime 8.0	// Time Before Victim Drops

*/
//--------------------------------------------------------------------------------------------------
// INCLUDED HEADERS
//--------------------------------------------------------------------------------------------------
	#include <amxmodx>
	#include <superheromod>
	#include <engine>
//--------------------------------------------------------------------------------------------------
// GLOBAL VARIABLES
//--------------------------------------------------------------------------------------------------
	new gHeroName[]="Mr. Hydrogen"
	new bool:gHasMrHydrogenPowers[SH_MAXSLOTS+1]
	new Float:HydroVelocity[SH_MAXSLOTS+1][3]
	new gIsHitByMrHydrogen[SH_MAXSLOTS+1]
//--------------------------------------------------------------------------------------------------
// PLUGIN EVENTS
//--------------------------------------------------------------------------------------------------
	public plugin_init()
	{
	register_plugin("SUPERHERO Mr. Hydrogen", "1.4", "Zul Rivers")
	register_cvar("mrhydrogen_level", "0")
	register_cvar("mrhydrogen_knifemult", "1.10" )
	register_cvar("mrhydrogen_floattime", "8.0" )
	shCreateHero(gHeroName, "Fill Enemy With Hydrogen Gas", "Boost Knife Damage & Victim Floats When Being Hit By Your Knife", false, "mrhydrogen_level")
	register_srvcmd("mrhydrogen_init", "mrhydrogen_init")
	shRegHeroInit(gHeroName, "mrhydrogen_init")
	register_event("ResetHUD", "mrhydrogen_newspawn", "b")
	register_event("DeathMsg", "mrhydrogen_death", "a")
	register_event("Damage", "mrhydrogen_powers", "b", "2!0")
	}
//--------------------------------------------------------------------------------------------------
// HERO EVENTS
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_init()
	{
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)
	read_argv(2, temp, 5)
	new hasPowers=str_to_num(temp)
	gHasMrHydrogenPowers[id] = (hasPowers != 0)
	}
//--------------------------------------------------------------------------------------------------
// PLUGIN PRECACHES
//--------------------------------------------------------------------------------------------------
	public plugin_precache()
	{
	precache_sound("player/breathe2.wav")
	}
//--------------------------------------------------------------------------------------------------
// EVENTS ON NEW SPAWN
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_newspawn(id)
	{
	if (is_user_alive(id))
	mrhydrogen_stop_powers(id)
	}
//--------------------------------------------------------------------------------------------------
// EVENTS ON DEATH
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_death()
	{
	new id = read_data(2)
	mrhydrogen_stop_powers(id)
	}
//--------------------------------------------------------------------------------------------------
// HERO POWERS
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_powers(id)
	{
	if (!shModActive() && !is_user_alive(id))
	return PLUGIN_CONTINUE
	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if (attacker <= 0 && attacker > SH_MAXSLOTS && id != attacker)
	return PLUGIN_CONTINUE
	if (gHasMrHydrogenPowers[attacker] && weapon == CSW_KNIFE && is_user_alive(id))
	{
	new extraDamage = floatround(damage * get_cvar_float("mrhydrogen_knifemult") - damage)
	if (extraDamage > 0)
	shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	if (!gIsHitByMrHydrogen[id])
	{
	gIsHitByMrHydrogen[id] = true
	set_task(0.1,"mrhydrogen_victim_float", id, "", 0, "b")
	set_task(get_cvar_float("mrhydrogen_floattime"),"mrhydrogen_stop_powers", id)
	set_hudmessage(255, 0, 0, -1.0, 0.35, 0, 5.0, 5.0, 0.1, 0.2)
	show_hudmessage(id, "Someone Filled You With Hydrogen Gas! - It Will Run Out In Sometime", gHeroName)
	emit_sound(id, CHAN_STATIC, "player/breathe2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	}
	return PLUGIN_CONTINUE
	}
//--------------------------------------------------------------------------------------------------
// VICTIM EFFECTS WHEN BEING HIT BY KNIFE
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_victim_float(id)
	{
	if (is_user_alive(id) && gIsHitByMrHydrogen[id])
	HydroVelocity[id][0] = 0.0
	HydroVelocity[id][1] = 0.0
	HydroVelocity[id][2] = 1000.0
	entity_set_vector(id, EV_VEC_velocity, HydroVelocity[id])
	}
//--------------------------------------------------------------------------------------------------
// STOP ALL RUNNING TASK
//--------------------------------------------------------------------------------------------------
	public mrhydrogen_stop_powers(id)
	{
	remove_task(id)
	gIsHitByMrHydrogen[id] = false
	new sndStop=(1<<5)
	emit_sound(id, CHAN_STATIC, "player/breathe2.wav", 1.0, ATTN_NORM, sndStop, PITCH_NORM)
	}
//--------------------------------------------------------------------------------------------------
