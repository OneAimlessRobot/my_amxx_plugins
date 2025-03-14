
// Haloune Tsurgi - A Stealthy Ninja from Hell! - Elite Johnson aka John Smallberries

// v1.0 - Elite Johnson - 8/14/07

// Special Thanks To: Vittu and Haloune Tsurgi himself

// Models: Tony, Ankalar, Stoke, bullet_head, Creeping_Jesus, Jennifer!!, Vunsunta, SureShot

//----------------------------------------------------------------------------------------------
// CVARS - copy and paste to shconfig.cfg

/*
//Haloune
Haloune_level 0                 //Change to level of choice
Haloune_health 200		//Default 200 
Haloune_armor 300		//Default 300
Haloune_gravity 1.5		//Default 1.5 = 1.5 = 150% 1 = 100% etc
Haloune_speed 500		//Default 500 = Super Speed
Haloune_M4A1mult 2		//Damage multiplyer for his M4A1 Default 2x
Haloune_teamglow 0		//Teams Glows so you can tell your friends and foes ( 1=On 0=Off )
sv_maxspeed 500
*/
#include <amxmodx>
#include <fakemeta>
#include <superheromod>


// GLOBAL VARIABLES
new HeroName[] = "Haloune Tsurgi"
new bool:HasHaloune[SH_MAXSLOTS+1]
new bool:HalouneModelSet[SH_MAXSLOTS+1]
new HalouneSound[] = "shmod/frostnova.wav"
new CvarTeamGlow, CvarM4A1DmgMult
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Haloune", "1.0", "Haloune/David Parker")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("Haloune_level", "10")
	register_cvar("Haloune_health", "200")
	register_cvar("Haloune_armor", "300")
	register_cvar("Haloune_gravity", "1.5")
	register_cvar("Haloune_speed", "500")
	CvarM4A1DmgMult = register_cvar("Haloune_M4A1mult", "2")
        CvarTeamGlow = register_cvar("Haloune_teamglow", "0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(HeroName, "Stealth Ninja", "Haloune - A Stealthy Ninja With Gravity/HP/AP a Super M4A1+Damage and a custom player model.", false, "Haloune_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("Haloune_init", "Haloune_init")
	shRegHeroInit(HeroName, "Haloune_init")

	// EVENTS
	register_event("ResetHUD", "new_spawn", "b")
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	register_event("Damage", "Haloune_damage", "b", "2!0")
	register_event("DeathMsg", "Haloune_death", "a")

	// Let Server know about the hero's variables
	shSetShieldRestrict(HeroName)
	shSetMaxHealth(HeroName, "Haloune_health")
	shSetMaxArmor(HeroName, "Haloune_armor")
	shSetMinGravity(HeroName, "Haloune_gravity")
	shSetMaxSpeed(HeroName, "Haloune_speed", "[0]")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model("models/player/Haloune/Haloune.mdl")
	precache_model("models/shmod/v_halounem4a1.mdl")
	precache_model("models/shmod/p_halounem4a1.mdl")
	precache_sound(HalouneSound)
}
//----------------------------------------------------------------------------------------------
public Haloune_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2, temp, 5)
	new hasPowers = str_to_num(temp)

	// Reset thier shield restrict status
	// Shield restrict MUST be before weapons are given out
	shResetShield(id)

	switch(hasPowers)
	{
		case true:
		{
			HasHaloune[id] = true

			if ( is_user_alive(id) )
			{
				Haloune_weapons(id)
				switch_model(id)
				Haloune_tasks(id)
			}
		}

		case false:
		{
			// Check is needed since this gets run on clearpowers even if user didn't have this hero
			if ( is_user_alive(id) && HasHaloune[id] )
			{
				// This gets run if they had the power but don't anymore
				engclient_cmd(id, "drop", "weapon_M4A1")
				Haloune_unmorph(id)
				shRemHealthPower(id)
				shRemArmorPower(id)
				shRemGravityPower(id)
				shRemSpeedPower(id)
			}

			HasHaloune[id] = false
		}
	}
}
//----------------------------------------------------------------------------------------------
public new_spawn(id)
{
	if ( shModActive() && is_user_alive(id) && HasHaloune[id] )
	{
		set_task(0.1, "Haloune_weapons", id)

		Haloune_tasks(id)
	}
}
//----------------------------------------------------------------------------------------------
Haloune_tasks(id)
{
	set_task(1.0, "Haloune_morph", id)

	if ( get_pcvar_num(CvarTeamGlow) )
		set_task(1.0, "Haloune_glow", id+100, "", 0, "b")

}
//----------------------------------------------------------------------------------------------
public Haloune_weapons(id)
{
	if ( !shModActive() || !is_user_alive(id) || !HasHaloune[id] )
		return

	shGiveWeapon(id, "weapon_m4a1")
}
//----------------------------------------------------------------------------------------------
switch_model(id)
{
	if ( !shModActive() || !is_user_alive(id) || !HasHaloune[id] )
		return

	new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)

	if ( wpnid == CSW_M4A1 )
	{
		set_pev(id, pev_viewmodel2, "models/shmod/v_halounem4a1.mdl")
		set_pev(id, pev_weaponmodel2, "models/shmod/p_halounem4a1.mdl")
	}
}
//----------------------------------------------------------------------------------------------
public weapon_change(id)
{
	if ( !shModActive() || !HasHaloune[id] )
		return

	new wpnid = read_data(2)

	if ( wpnid != CSW_M4A1 )
		return

	switch_model(id)

	new clip = read_data(3)

	// Never Run Out of Ammo!
	if ( clip == 0 )
		shReloadAmmo(id)
}
//----------------------------------------------------------------------------------------------
public Haloune_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) )
		return

	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS )
		return

	if ( HasHaloune[attacker] && weapon == CSW_M4A1 && is_user_alive(id) )
	{
		new damage = read_data(2)
		new headshot = bodypart == 1 ? 1 : 0

		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(CvarM4A1DmgMult) - damage)
		if ( extraDamage > 0 )
			shExtraDamage(id, attacker, extraDamage, "M4A1", headshot)
	}
}
//----------------------------------------------------------------------------------------------
Haloune_sound(id)
{
	emit_sound(id, CHAN_AUTO, HalouneSound, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_AUTO, HalouneSound, 0.2, ATTN_NORM, 0, PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
public Haloune_morph(id)
{
	if ( HalouneModelSet[id] || !is_user_alive(id) || !HasHaloune[id] )
		return

	cs_set_user_model(id, "Haloune")

	Haloune_sound(id)

	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, -1)
	show_hudmessage(id, "%s - Haloune Stealth Suit Online", HeroName)

	HalouneModelSet[id] = true
}
//----------------------------------------------------------------------------------------------
Haloune_unmorph(id)
{
	if ( HalouneModelSet[id] && is_user_connected(id) )
	{
		if ( is_user_alive(id) )
		{
			// Message only shows if alive and dropping hero
			set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, -1)
			show_hudmessage(id, "%s - MODE OFF, you returned to normal self", HeroName)
		}

		cs_reset_user_model(id)

		Haloune_sound(id)

		HalouneModelSet[id] = false

		if ( get_pcvar_num(CvarTeamGlow) )
		{
			remove_task(id+100)
			set_user_rendering(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public Haloune_glow(id)
{
	id -= 100

	if ( !shModActive() || !is_user_connected(id) )
	{
		//Don't want any left over residuals
		remove_task(id+100)
		return
	}

	if ( HasHaloune[id] && is_user_alive(id) )
	{
		new teamId = get_user_team(id)
		switch(teamId)
		{
			case 1:
				shGlow(id, 100, 0, 0)
			case 2:
				shGlow(id, 0, 0, 100)
		}
	}
}
//----------------------------------------------------------------------------------------------
public Haloune_death()
{
	new id = read_data(2)

	if ( !HasHaloune[id] )
		return

	Haloune_unmorph(id)
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	HasHaloune[id] = false
	HalouneModelSet[id] = false
}
//----------------------------------------------------------------------------------------------