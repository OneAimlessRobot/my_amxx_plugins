// GHOSTFACE! - Woodsboro Killer from the Scream movies.

/* CVARS - copy and paste to shconfig.cfg

//Ghostface (Scream)
ghostface_level 0
ghostface_health 100		//Default 100 (no extra health)
ghostface_armor 100		//Default 100
ghostface_gravity 1.0		//Default 1.0 = no extra gravity (0.50 is 50% of normal gravity, ect.)
ghostface_knifespeed 290	//Speed when holding knife, Default 290 (for faster then normal speed set to 261 or higher)
ghostface_knifemult 1.5		//Damage multiplyer for his knife, Default 1.5
ghostface_healpoints 5		//The # of HP healed per second, Default 5
// Below only used if USE_PLAYER_MODEL is uncommented
ghostface_teamglow 0		//Glow Team Color when player skin in use, Default 0 (0=no 1=yes)

*/


/*
* v1.0 - vittu - 7/3/08
*      - Complete rework of entire code, started from scratch.
*      - Renamed Hero to Ghostface, as it is the true character name and Scream is just the movie.
*
*    Recreated due to demand and newly available CS model, as old had HL model (which is not allowed).
*    Hero orginally named Scream created by some jerk-off who shall not be named.
*    Hero was ripped from Masterchief + Wolverine.
*    There was also another version that was Chucky + Wolverine. That is not this one.
*
*    Knife model by Dennispls.
*    Player model by Hoffa(origninal HLDM model), converted to CS by xVox-Bloodstonex(Re-skin/Highres/Hack/Rigg), & Luca (Hands).
*    (Note: Models differ from Scream, because these better represent the character.)
*/


//---------- User Changeable Defines --------//


// Comment out to not use the player model
#define USE_PLAYER_MODEL

// Comment out to not use the Knife model
#define USE_WPN_MODEL


//------- Do not edit below this point ------//


#include <amxmodx>
#include <fakemeta>
#include <superheromod>

// GLOBAL VARIABLES
new HeroName[] = "Ghostface (Scream)"
new bool:HasGhostface[SH_MAXSLOTS+1]
new PlayerMaxHealth[SH_MAXSLOTS+1]
new HealPoints
new CvarKnifeDmgMult, CvarHealPoints

#if defined USE_PLAYER_MODEL
	new bool:ModelPlayerSet[SH_MAXSLOTS+1]
	new bool:ModelPlayerLoaded
	new const Model_Player[] = "models/player/ghostface/ghostface.mdl"
	new const Model_Player_Name[] = "ghostface"
	new CvarTeamGlow
#endif

#if defined USE_WPN_MODEL
	new const Model_V_Knife[] = "models/shmod/ghostface_v_knife.mdl"
	new const Model_P_Knife[] = "models/shmod/ghostface_p_knife.mdl"
	new bool:ModelWeaponLoaded
#endif
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Ghostface", "1.0", "vittu")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("ghostface_level", "0")
	register_cvar("ghostface_health", "100")
	register_cvar("ghostface_armor", "100")
	register_cvar("ghostface_gravity", "1.0")
	register_cvar("ghostface_knifespeed", "290")
	CvarKnifeDmgMult = register_cvar("ghostface_knifemult", "1.5")
	CvarHealPoints = register_cvar("ghostface_healpoints", "5")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(HeroName, "Knife Dmg & HP Regen", "Become the Woodsboro Serial Killer - get a Bowie Knife that deals Extra Damage, also Regen Health.", false, "ghostface_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("ghostface_init", "ghostface_init")
	shRegHeroInit(HeroName, "ghostface_init")

	// EVENTS
	register_event("Damage", "ghostface_damage", "b", "2!0")

	#if defined USE_PLAYER_MODEL
		CvarTeamGlow = register_cvar("ghostface_teamglow", "0")
		register_event("ResetHUD", "new_spawn", "b")
		register_event("DeathMsg", "ghostface_death", "a")
	#endif

	#if defined USE_WPN_MODEL
		register_event("CurWeapon", "weapon_change", "be", "1=1")
	#endif

	// Let Server know about the hero's variables
	shSetMaxHealth(HeroName, "ghostface_health")
	shSetMaxArmor(HeroName, "ghostface_armor")
	shSetMinGravity(HeroName, "ghostface_gravity")
	shSetMaxSpeed(HeroName, "ghostface_knifespeed", "[29]")

	register_srvcmd("ghostface_maxhealth", "ghostface_maxhealth")
	shRegMaxHealth(HeroName, "ghostface_maxhealth")

	// HEAL LOOP
	set_task(1.0, "heal_loop", _, _, _, "b")
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	HealPoints = get_pcvar_num(CvarHealPoints)	
}
//----------------------------------------------------------------------------------------------
#if defined USE_PLAYER_MODEL || defined USE_WPN_MODEL
public plugin_precache()
{
	#if defined USE_PLAYER_MODEL
		ModelPlayerLoaded = true

		if ( file_exists(Model_Player) ) {
			precache_model(Model_Player)
		}
		else {
			log_amx("[SH](%s)Aborted loading ^"%s^", file does not exist on server", HeroName, Model_Player)
			ModelPlayerLoaded = false
		}
	#endif

	#if defined USE_WPN_MODEL
		ModelWeaponLoaded = true
		if ( file_exists(Model_V_Knife) ) {
			precache_model(Model_V_Knife)
		}
		else {
			log_amx("[SH](%s)Aborted loading ^"%s^", file does not exist on server", HeroName, Model_V_Knife)
			ModelWeaponLoaded = false
		}

		if ( file_exists(Model_P_Knife) ) {
			precache_model(Model_P_Knife)
		}
		else {
			log_amx("[SH](%s)Aborted loading ^"%s^", file does not exist on server", HeroName, Model_P_Knife)
			ModelWeaponLoaded = false
		}
	#endif
}
#endif
//----------------------------------------------------------------------------------------------
public ghostface_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2, temp, 5)
	new hasPowers = str_to_num(temp)

	switch(hasPowers)
	{
		case true:
		{
			HasGhostface[id] = true

			if ( is_user_alive(id) )
			{
				#if defined USE_WPN_MODEL
					if ( ModelWeaponLoaded )
						switch_model(id)
				#endif

				#if defined USE_PLAYER_MODEL
					if ( ModelPlayerLoaded )
						ghostface_tasks(id)
				#endif
			}
		}

		case false:
		{
			// Check is needed since this gets run on clearpowers even if user didn't have this hero
			if ( is_user_alive(id) && HasGhostface[id] )
			{
				#if defined USE_PLAYER_MODEL
					if ( ModelPlayerLoaded )
						ghostface_unmorph(id)
				#endif

				shRemHealthPower(id)
				shRemArmorPower(id)
				shRemGravityPower(id)
				shRemSpeedPower(id)
			}

			HasGhostface[id] = false
		}
	}
}
//----------------------------------------------------------------------------------------------
#if defined USE_WPN_MODEL
switch_model(id)
{
	if ( !shModActive() || !is_user_alive(id) || !HasGhostface[id] )
		return

	new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)

	if ( wpnid == CSW_KNIFE )
	{
		set_pev(id, pev_viewmodel2, Model_V_Knife)
		set_pev(id, pev_weaponmodel2, Model_P_Knife)
	}
}
//----------------------------------------------------------------------------------------------
public weapon_change(id)
{
	if ( !shModActive() || !HasGhostface[id] )
		return

	//weaponID = read_data(2)
	if ( read_data(2) != CSW_KNIFE )
		return

	if ( ModelWeaponLoaded )
		switch_model(id)
}
#endif
//----------------------------------------------------------------------------------------------
public ghostface_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) )
		return

	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS )
		return

	if ( HasGhostface[attacker] && weapon == CSW_KNIFE )
	{
		new damage = read_data(2)
		new headshot = bodypart == 1 ? 1 : 0

		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(CvarKnifeDmgMult) - damage)
		if ( extraDamage > 0 )
			shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	}
}
//----------------------------------------------------------------------------------------------
#if defined USE_PLAYER_MODEL
public new_spawn(id)
{
	if ( shModActive() && is_user_alive(id) && HasGhostface[id] )
	{
		if ( ModelPlayerLoaded )
			ghostface_tasks(id)
	}
}
//----------------------------------------------------------------------------------------------
ghostface_tasks(id)
{
	set_task(1.0, "ghostface_morph", id)

	if ( get_pcvar_num(CvarTeamGlow) )
		set_task(1.0, "ghostface_glow", id+100, _, _, "b")
}
//----------------------------------------------------------------------------------------------
public ghostface_morph(id)
{
	if ( ModelPlayerSet[id] || !is_user_alive(id) || !HasGhostface[id] )
		return

	cs_set_user_model(id, Model_Player_Name)

	ModelPlayerSet[id] = true
}
//----------------------------------------------------------------------------------------------
ghostface_unmorph(id)
{
	if ( ModelPlayerSet[id] && is_user_connected(id) )
	{
		cs_reset_user_model(id)

		ModelPlayerSet[id] = false

		if ( get_pcvar_num(CvarTeamGlow) )
		{
			remove_task(id+100)
			set_user_rendering(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public ghostface_glow(id)
{
	id -= 100

	if ( !shModActive() || !is_user_connected(id) )
	{
		//Don't want any left over residuals
		remove_task(id+100)
		return
	}

	if ( HasGhostface[id] && is_user_alive(id) )
	{
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_T: shGlow(id, 100, 0, 0)
			case CS_TEAM_CT: shGlow(id, 0, 0, 100)
		}
	}
}
//----------------------------------------------------------------------------------------------
public ghostface_death()
{
	new id = read_data(2)

	if ( !HasGhostface[id] )
		return

	if ( ModelPlayerLoaded )
		ghostface_unmorph(id)
}
#endif
//----------------------------------------------------------------------------------------------
public ghostface_maxhealth()
{
	new id[6]
	new health[9]

	read_argv(1,id,5)
	read_argv(2,health,8)

	PlayerMaxHealth[str_to_num(id)] = str_to_num(health)
}
//----------------------------------------------------------------------------------------------
public heal_loop()
{
	if ( !shModActive() ) return

	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( HasGhostface[id] && is_user_alive(id) ) {
			// Let the server add the hps back since the # of max hps is controlled by it
			// I.E. Superman has more than 100 hps etc.
			shAddHPs(id, HealPoints, PlayerMaxHealth[id])
		}
	}
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	HasGhostface[id] = false

	#if defined USE_PLAYER_MODEL
		ModelPlayerSet[id] = false
	#endif
}
//----------------------------------------------------------------------------------------------