// ALIEN! - from the Alien movie series.

/* CVARS - copy and paste to shconfig.cfg

//Alien
alien_level 5
alien_health 125	//Default 125
alien_armor 125		//Default 125
alien_knifemult 0.0	//Damage multiplyer for his Knife
alien_vision 160	//How far vision is zoomed out (must be 100 or higer because normal vision is 90)
alien_tint 50		//How dark the green screen tint is (255-no sight, 0-perfect sight)
alien_alpha 50		//Alpha level when invisible (0-invisible, 255-full visibility)
alien_knifemode 0	//1-knife only can't change weapons, 0-Alien Vision on only when knifing (def 0)

*/

/*
* v1.5 - vittu - 6/27/06
*      - Updated to amxmodx only, requires amxx 1.70 or higher.
*      - Plus other minor code changes.
*
* v1.4 - vittu - 7/3/05
*      - Fixed crash to AMX caused by the previous update, since
*          AMX can't register a MSG_ONE_UNRELIABLE message.
*
* v1.3 - vittu - 6/14/05
*      - Minor code clean up.
*
* v1.2 - vittu - 3/18/05
*      - Updated and cleaned code a bit. Still functions the same.
*      - Added new cvar alien_knifemode to allow weapon change or not,
*         old version was knife only.
*
*/

#include <amxmodx>
#include <superheromod>

// GLOBAL VARIABLES
new HeroName[] = "Alien"
new HasAlien[SH_MAXSLOTS+1]
new AlienModeOn[SH_MAXSLOTS+1]
new MsgSetFOV
new CvarKnifeMult, CvarZoomVision, CvarTint, CvarAlphaValue, CvarMode
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Alien", "1.5", "Freecode/AssKicR")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("alien_level", "5")
	register_cvar("alien_health", "125")
	register_cvar("alien_armor", "125")
	CvarKnifeMult = register_cvar("alien_knifemult", "0.0")
	CvarZoomVision = register_cvar("alien_vision", "160")
	CvarTint = register_cvar("alien_tint", "50")
	CvarAlphaValue = register_cvar("alien_alpha", "50")
	CvarMode = register_cvar("alien_knifemode", "0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(HeroName, "Alien Vision", "Get Alien Vision and Invisibility when using Knife (but you can only use your knife)", false, "alien_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("alien_init", "alien_init")
	shRegHeroInit(HeroName, "alien_init")

	// EVENTS
	register_event("ResetHUD", "new_spawn", "b")
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	register_event("DeathMsg", "alien_death", "a")
	register_event("Damage", "alien_damage", "b", "2!0")

	// Let Server know about Alien's Variables
	shSetMaxHealth(HeroName, "alien_health")
	shSetMaxArmor(HeroName, "alien_armor")

	MsgSetFOV = get_user_msgid("SetFOV")
}
//----------------------------------------------------------------------------------------------
public alien_init()
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
			HasAlien[id] = true
			weapon_change(id)
		}

		case false:
		{
			//This gets run if they had the power but don't anymore
			if ( is_user_connected(id) && HasAlien[id] )
			{
				alien_vision_off(id)
				shRemHealthPower(id)
				shRemArmorPower(id)
			}

			HasAlien[id] = false
		}
	}
}
//----------------------------------------------------------------------------------------------
public new_spawn(id)
{
	if ( shModActive() && is_user_alive(id) && HasAlien[id] )
		weapon_change(id)
}
//----------------------------------------------------------------------------------------------
public weapon_change(id)
{
	if ( !shModActive() || !is_user_alive(id) || !HasAlien[id] )
		return

	//new wpnid = read_data(2)
	// Do it this way since this might be called on alien_init or reset hud
	new clipNull, ammoNull, wpnid = get_user_weapon(id, clipNull, ammoNull)

	switch(wpnid)
	{
		case CSW_KNIFE:
			alien_vision_on(id)

		default:
		{
			// Force knife only or not?
			switch(get_pcvar_num(CvarMode))
			{
				case 1:
					client_cmd(id, "weapon_knife")
				case 0:
					alien_vision_off(id)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
alien_vision_on(id)
{
	if ( shModActive() && is_user_alive(id) && HasAlien[id] )
	{
		AlienModeOn[id] = true

		// Prevent cvar from being set too low
		new Zoom = get_pcvar_num(CvarZoomVision)

		if ( Zoom < 100 )
		{
			debugMessage("(Alien) Alien Vision must be set higher than 100, defaulting to 100", 0, 0)
			Zoom = 100
			set_cvar_num("alien_vision", Zoom)
		}

		// Set Zoom
		message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
		write_byte(Zoom)
		message_end()

		// Set once before loop task
		setScreenFlash(id, 0, 200, 0, 13, get_pcvar_num(CvarTint))
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarAlphaValue))

		// Loop to make sure their screen stays green and they stay invisible
		set_task(1.0, "alien_loop", id, "", 0, "b")
	}
}
//----------------------------------------------------------------------------------------------
public alien_loop(id)
{
	// Prevents loop from running on disconnected clients
	if ( !shModActive() || !is_user_connected(id) )
	{
		remove_task(id)
		return
	}

	if ( HasAlien[id] && is_user_alive(id) )
	{
		setScreenFlash(id, 0, 200, 0, 13, get_pcvar_num(CvarTint))
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarAlphaValue))
	}
}
//----------------------------------------------------------------------------------------------
alien_vision_off(id)
{
	if ( !is_user_connected(id) || !AlienModeOn[id] )
		return

	remove_task(id)

	// Quickly removes screenflash
	setScreenFlash(id, 0, 200, 0, 1, get_pcvar_num(CvarTint))

	// Reset Zoom
	message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
	write_byte(90)	//Normal, not Zooming
	message_end()

	// Resets alpha
	set_user_rendering(id)

	// Makes sure this function is only called once, if alien mode was on
	AlienModeOn[id] = false
}
//----------------------------------------------------------------------------------------------
public alien_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) )
		return

	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS )
		return

	if ( HasAlien[attacker] && weapon == CSW_KNIFE && is_user_alive(id) )
	{
		new damage = read_data(2)
		new headshot = bodypart == 1 ? 1 : 0

		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(CvarKnifeMult) - damage)
		if ( extraDamage > 0 )
			shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	}
}
//----------------------------------------------------------------------------------------------
public alien_death()
{
	new id = read_data(2)

	if ( !HasAlien[id] )
		return

	alien_vision_off(id)
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	HasAlien[id] = false
	AlienModeOn[id] = false

	// Yeah don't want any left over residuals
	remove_task(id)
}
//----------------------------------------------------------------------------------------------
