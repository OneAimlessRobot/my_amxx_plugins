// WONDER WOMAN!

/* CVARS - copy and paste to shconfig.cfg

//Wonder Woman
wonderwoman_level 0
wonderwoman_cooldown 45		//# of seconds for cooldown between use (Default 45)
wonderwoman_searchtime 45	//# of seconds to search for a victim when key is pressed (Default 45)
wonderwoman_entangletime 10	//# of seconds the victim is stunned (Default 10)

*/

/*
* v1.3 - Fr33m@n - 1/12/11
*      - Small optimization
*
* v1.2 - Fr33m@n - 12/31/10
*      - Added a define to block or not key powers if you are stunned
*
* v1.1 - Fr33m@n - 12/30/10
*      - Updated to be SH 1.2.0 compliant, removed amx compatibility.
*      - Cleaned up and recoded using wc3ft entangle roots and Electro as a base.
*      - Now this hero also block the use of key powers
*      - Added wonderwoman_entangletime cvar
*      - Added compatibility for sh_ffa cvar
*
*   Based on wc3ft Elf Entangle Roots.
*/

//---------- User Changeable Defines --------//

// Note: If you change anything here from default setting you must recompile the plugin

// Comment out to not block victim's key powers when she is stunned
#define BLOCK_KEY_POWERS

//------- Do not edit below this point ------//

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new bool:gHasWonderWoman[SH_MAXSLOTS+1]
new bool:gIsSearching[SH_MAXSLOTS+1]
new bool:gIsStunned[SH_MAXSLOTS+1]
new const gSoundSearch[] = "turret/tu_ping.wav"
new const gSoundLassoHit[] = "weapons/cbar_hitbod3.wav"
new const gSoundLassoExpand[] = "weapons/electro5.wav"
new gSpriteLasso, gSpriteTrail
new gPcvarCooldown, gPcvarSearchTime, gPcvarStunTime
new sh_ffa
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Wonder Woman", "1.3", "AssKicR")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("wonderwoman_level", "0")
	gPcvarCooldown = register_cvar("wonderwoman_cooldown", "45")
	gPcvarSearchTime = register_cvar("wonderwoman_searchtime", "45")
	gPcvarStunTime = register_cvar("wonderwoman_entangletime", "10")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero("Wonder Woman", pcvarLevel)
	sh_set_hero_info(gHeroID, "Lasso", "Catch enemies with your lasso")
	sh_set_hero_bind(gHeroID)

	register_forward(FM_TraceLine, "FM_TraceLine_Pre", false)

#if !defined BLOCK_KEY_POWERS
	register_event("CurWeapon", "weapon_change", "be", "1=1")
#endif

	sh_ffa = get_cvar_pointer("sh_ffa")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound(gSoundSearch)
	precache_sound(gSoundLassoHit)
	precache_sound(gSoundLassoExpand)
	gSpriteLasso = precache_model("sprites/zbeam4.spr")
	gSpriteTrail = precache_model("sprites/smoke.spr")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	gHasWonderWoman[id] = mode ? true : false
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	gPlayerInCooldown[id] = false
	gIsSearching[id] = false
	gIsStunned[id] = false

	remove_task(id)
}
//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || sh_is_freezetime() ) return
	if ( !is_user_alive(id) || !gHasWonderWoman[id] ) return

	if ( gIsSearching[id] ) return

	if ( key == SH_KEYDOWN )
	{
		// Let them know they already used their ultimate if they have
		if ( gPlayerInCooldown[id] )
		{
			sh_sound_deny(id)
			return
		}

		gIsSearching[id] = true

		new parm[2]
		parm[0] = id
		parm[1] = get_pcvar_num(gPcvarSearchTime)
		WonderWoman_Search(parm)
	}
}
//----------------------------------------------------------------------------------------------
public WonderWoman_Search(parm[2])
{
	new id = parm[0]
	new timeLeft = parm[1]

	// Decrement our timer
	parm[1]--

	// User died or diconnected or no target was found
	if ( !is_user_alive(id) || !gHasWonderWoman[id] || timeLeft == 0 )
	{
		gIsSearching[id] = false
	}
	else if ( gIsSearching[id] )
	{
		// Play the ping sound
		emit_sound(id, CHAN_STATIC, gSoundSearch, 1.0, ATTN_NORM, 0, PITCH_NORM)

		set_task(1.0, "WonderWoman_Search", id, parm, 2)
	}
}
//----------------------------------------------------------------------------------------------
public FM_TraceLine_Pre(Float:v1[3], Float:v2[3], const noMonsters, const pentToSkip)
{
	if ( !sh_is_active() ) return FMRES_IGNORED

	new victim = get_tr(TR_pHit)
	if ( !is_user_alive(victim)  || gIsStunned[victim] ) return FMRES_IGNORED

	//new attacker = pentToSkip
	if ( !is_user_alive(pentToSkip) || !gHasWonderWoman[pentToSkip] || !gIsSearching[pentToSkip] ) return FMRES_IGNORED
	if ( !get_pcvar_num(sh_ffa) && cs_get_user_team(pentToSkip) == cs_get_user_team(victim) ) return FMRES_IGNORED

	WonderWoman_Entangle(pentToSkip, victim)

	new Float:seconds = get_pcvar_float(gPcvarCooldown)
	if ( seconds > 0.0 ) sh_set_cooldown(pentToSkip, seconds)

	gIsSearching[pentToSkip] = false

	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
WonderWoman_Entangle(attacker, victim)
{
	// Follow the user until they stop moving...
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)	// 22
	write_short(victim)
	write_short(gSpriteTrail)
	write_byte(10)		// life
	write_byte(5)		// width
	write_byte(230)		// r, g, b
	write_byte(125)		// r, g, b
	write_byte(0)		// r, g, b
	write_byte(255)		// brightness
	message_end()

	emit_sound(attacker, CHAN_ITEM, gSoundLassoHit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	// User is now stunned so we can't do any other stun abilities
	gIsStunned[victim] = true

	// Set the speed of the enemy (this will auto-stun them)
#if defined BLOCK_KEY_POWERS
	sh_set_stun(victim, get_pcvar_float(gPcvarStunTime))
#else
	set_user_maxspeed(victim, 1.0)
#endif

	// Start waiting for the user to stop...
	new parm[4]
	parm[0] = victim
	WonderWoman_EntangleWait(parm)
}
//----------------------------------------------------------------------------------------------
// Wait for the user to stop moving
public WonderWoman_EntangleWait(parm[4])
{
	new id = parm[0]

	if ( !is_user_alive(id) ) return

	new origin[3]
	get_user_origin(id, origin)

	// Checking to see if the user has actually stopped yet?
	if ( origin[0] == parm[1] && origin[1] == parm[2] && origin[2] == parm[3] )
	{
		new Float:iStunTime = get_pcvar_float(gPcvarStunTime)

#if defined BLOCK_KEY_POWERS
		// Override the previous Stun time to match with the effect
		sh_set_stun(id, iStunTime)
#else
		set_user_maxspeed(id, 1.0)
#endif

		set_task(iStunTime, "UnStun_Task", id)

		WonderWoman_EntangleEffect(id, origin, iStunTime)
	}
	// If not lets run another check in 0.1 seconds
	else
	{
		parm[1] = origin[0]
		parm[2] = origin[1]
		parm[3] = origin[2]

		set_task(0.1, "WonderWoman_EntangleWait", id, parm, 4)
	}
}
//----------------------------------------------------------------------------------------------
public UnStun_Task(id)
{
	gIsStunned[id] = false

#if !defined BLOCK_KEY_POWERS
	sh_reset_max_speed(id)
#endif
}
//----------------------------------------------------------------------------------------------
WonderWoman_EntangleEffect(id, origin[3], Float:iStunTime)
{
	// Play the entangle sound
	emit_sound(id, CHAN_STATIC, gSoundLassoExpand, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new iHeight
	new iRadius	= 20, iCounter = 0
	new x1, y1, x2, y2

	// Some sweet crap that I don't understand courtesy of SpaceDude - draws the "cylinder" around the player
	while ( iCounter <= 7 )
	{
		switch(iCounter)
		{
			case 0, 8: x1 = -iRadius
			case 1, 7: x1 = -iRadius * 100 / 141
			case 2, 6: x1 = 0
			case 3, 5: x1 = iRadius * 100 / 141
			case 4: x1 = iRadius
		}

		if ( iCounter <= 4 )
			y1 = sqroot( iRadius * iRadius - x1 * x1 )
		else
			y1 = -sqroot( iRadius * iRadius - x1 * x1 )

		++iCounter

		switch(iCounter)
		{
			case 0, 8: x2 = -iRadius
			case 1, 7: x2 = -iRadius * 100 / 141
			case 2, 6: x2 = 0
			case 3, 5: x2 = iRadius * 100 / 141
			case 4: x2 = iRadius
		}

		if ( iCounter <= 4 )
			y2 = sqroot( iRadius * iRadius - x2 * x2 )
		else
			y2 = -sqroot( iRadius * iRadius - x2 * x2 )

		iHeight = 16 + 2 * iCounter

		while ( iHeight > -40 )
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMPOINTS)	// 0
			write_coord(origin[0] + x1)
			write_coord(origin[1] + y1)
			write_coord(origin[2] + iHeight)
			write_coord(origin[0] + x2)
			write_coord(origin[1] + y2)
			write_coord(origin[2] + iHeight + 2)
			write_short(gSpriteLasso)
			write_byte(0)			// framestart
			write_byte(0)			// framerate
			write_byte(floatround(iStunTime * 10))	// life
			write_byte(10)			// width
			write_byte(5)			// noise
			write_byte(320)			// r, g, b
			write_byte(125)			// r, g, b
			write_byte(0)			// r, g, b
			write_byte(225)			// brightness
			write_byte(0)			// speed
			message_end()

			iHeight -= 16
		}
	}
}
//----------------------------------------------------------------------------------------------
#if !defined BLOCK_KEY_POWERS
public weapon_change(id)
{
	if ( !sh_is_active() ) return

	if ( gIsStunned[id] )
	{
		set_user_maxspeed(id, 1.0)
	}
}
#endif
//----------------------------------------------------------------------------------------------