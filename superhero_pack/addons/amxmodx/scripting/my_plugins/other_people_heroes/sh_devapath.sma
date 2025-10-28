    // The Six Paths of Pain, The Deva Path - Made by Exploited & Fr33m@n.

/* CVARS - COPY AND PASTE INTO SHCONFIG.CFG

// Deva Path - WARNING - THE SLAPS SENDS YOU PRETTY HIGH FLYING, MAY EASILY DIE CAUSE OF SLAPS
deva_level 10 // What level should he be available at? default = 10
deva_cooldown 8 // How long between each use in seconds? default = 8
deva_percentage 3 // How big chance each shot? default = 3
deva_damage 0 // How much damage should the slaps do? default = 0 (Damage is applied one time; setting this to 5 will deal 5 damage regardless if you are using four slaps or not)

*/


// IF YOU EDIT BELOW HERE YOU WILL HAVE TO RECOMPILE THE PLUGIN
//-----------------------------------------------------
// Uncomment this means that the targeted victim will receive four slaps instead of two. /* (WARNING - THIS MEANS YOUR TARGET WILL FLY MUCH HIGHER AND MIGHT DIE OF FALLDAMAGE) */
//#define USE_FOUR_SLAPS
//-----------------------------------------------------

#include "../my_include/superheromod.inc"

new gHeroID
new gHeroName[] = "Deva Path"
new bool:gHasDeva[SH_MAXSLOTS+1]
new gPcvarCooldown, gPcvarPercentage, gPcvarDamage
//----------------------------------------------------------------
public plugin_init()
{
	// PLUGIN INFORMATION
	register_plugin("SUPERHERO Deva Path", "1.0", "Exploited/Fr33m@n")
	
	// DON'T USE THIS FILE TO CHANGE THE CVARS. USE THE SHCONFIG.CFG!
	new pcvarLevel = register_cvar("deva_level", "10")
	gPcvarCooldown = register_cvar("deva_cooldown", "8")
	gPcvarPercentage = register_cvar("deva_percentage", "3")
	gPcvarDamage = register_cvar("deva_damage", "0")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Manipulate Gravity", "Six Paths of Pain, The Deva Path - Manipulate the Gravity of your attackers/victims.")
}
//----------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
	if ( gHeroID == heroID )
		gHasDeva[id] = mode ? true : false
	//----------------------------------------------------------------
public sh_client_spawn(id)
{
	gPlayerInCooldown[id] = false
}
//----------------------------------------------------------------
public client_damage ( attacker, victim, damage, wpnindex, hitplace, TA )
{
	// if sh is not active, return rest of the code in this function is not called
	if ( !sh_is_active() ) return
	new Float:cooldown = get_pcvar_float(gPcvarCooldown)
	new Float:percentage = get_pcvar_float(gPcvarPercentage)
	new damage = get_pcvar_num(gPcvarDamage)

	
	// if  attacker have Deva and is not in cooldown
	if ( gHasDeva[attacker] && !gPlayerInCooldown[attacker] && random_num(0, 100) <= percentage )
	{
		user_slap(victim, damage)
		user_slap(victim, 0)
		#if defined USE_FOUR_SLAPS             
		user_slap(victim, 0)
		user_slap(victim, 0)
		#endif
		if ( cooldown > 0.0 ) sh_set_cooldown(attacker, cooldown)
		sh_chat_message(victim, gHeroID, "You repelled an enemy!")
		
	}
	// if victim have Deva and is not in coldown
	if ( gHasDeva[victim] && !gPlayerInCooldown[victim] && random_num(0, 100) <= percentage )
	{
		user_slap(attacker, damage)
		user_slap(attacker, 0)
		#if defined USE_FOUR_SLAPS
		user_slap(attacker, 0)
		user_slap(attacker, 0)
		#endif
		if ( cooldown > 0.0 ) sh_set_cooldown(victim, cooldown)
		sh_chat_message(attacker, gHeroID, "You repelled an enemy!")
	}
}
