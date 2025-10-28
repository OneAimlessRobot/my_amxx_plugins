//Deagle Sniper!

/*
Cvars:
//Deagle sniper
dsniper_level 10
dsniper_health 175
dsniper_armor 175
dsniper_gravity 0.3
dsniper_mult 4
*/

#include "../my_include/superheromod.inc"

new gHeroID
new gHeroName[] = "Deagle Assassin"
new bool:gHasDeaglePower[SH_MAXSLOTS+1]
new bool:gHasZoom[SH_MAXSLOTS+1]
new gLastWeapon[SH_MAXSLOTS+1]
new gmsgSetFOV
new const gModelDgl[] = "models/shmod/deagle.mdl"

public plugin_init()
{
	//plugin info
	register_plugin("SUPERHERO Deagle Sniper", "1.0", "Jelle / Fr33m@n")

	//cvars
	new pcvarLevel = register_cvar("dassassin_level", "7")
	new pcvarHealth = register_cvar("dassassin_health", "175")
	new pcvarArmor = register_cvar("dassassin_armor", "175")
	new pcvarGravity = register_cvar("dassassin_gravity", "0.3")
	new pcvarDglmult = register_cvar("dassassin_mult", "3")

	//create hero
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Sniper Deagle", "Get a nice new deagle with scope")

	//set hero power
	sh_set_hero_hpap(gHeroID, pcvarHealth, pcvarArmor)
	sh_set_hero_grav(gHeroID, pcvarGravity)
	sh_set_hero_dmgmult(gHeroID, pcvarDglmult, CSW_DEAGLE)

	//events
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	register_forward(FM_CmdStart, "fakemeta_CmdStart")

	gmsgSetFOV = get_user_msgid("SetFOV")
}

public plugin_precache()
{
	precache_model(gModelDgl)
}

public sh_hero_init(id, HeroID, mode)
{
	//if no power return
	if (gHeroID != HeroID) return

	//check if they get or lose power
	switch(mode)
	{
		//if they get power
		case SH_HERO_ADD:
		{
			gHasDeaglePower[id] = true
			deagle_weapon(id)
			switch_model(id)
		}

		//if they lose power
		case SH_HERO_DROP:
		{
			gHasDeaglePower[id] = false
			if (is_user_alive(id))
			{
				sh_drop_weapon(id, CSW_DEAGLE, true)
			}
		}
	}
}

public sh_client_spawn(id)
{
	//if client has power give weapon
	if (gHasDeaglePower[id])
	{
		deagle_weapon(id)
	}
}

public fakemeta_CmdStart(id, uc_handle, seed)
{
	// if sh is not active or user don't have the power or user is dead do nothing
	if ( !sh_is_active() || !gHasDeaglePower[id] || !is_user_alive(id) ) return FMRES_IGNORED

	// if user use secondary attack
	if ( (get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2) )
	{
		// if user's weapon is deagle
		if ( get_user_weapon(id) == CSW_DEAGLE )
		{
			// if user don't have the zoom, set the zoom
			if ( !gHasZoom[id] ) dsniper_zoom(id)
			// else if user have zoom, reset the zoom
			else dsniper_zoomout(id)
		}
	}
	return FMRES_IGNORED
}

public dsniper_zoom(id)
{
	gHasZoom[id] = true
	emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
	message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
	write_byte(60)	//Zooming AUG/SIG style
	message_end()
}

dsniper_zoomout(id)
{
	gHasZoom[id] = false
	message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
	write_byte(90)	//not Zooming
	message_end()
}

switch_model(id)
{
	//if client does not have hero, is dead, or sh is off do nothing
	if ( !sh_is_active() || !is_user_alive(id) || !gHasDeaglePower[id] ) return

	//if client has deagle set model
	if ( get_user_weapon(id) == CSW_DEAGLE )
	{
		set_pev(id, pev_viewmodel2, gModelDgl)
	}
}

deagle_weapon(id)
{
	//if client is alive and has power give deagle
	if ( sh_is_active() && is_user_alive(id) && gHasDeaglePower[id] )
	{
		sh_give_weapon(id, CSW_DEAGLE)
	}
}

public weapon_change(id)
{
	//do nothing if client does not have hero or sh is off
	if ( !sh_is_active() || !gHasDeaglePower[id] ) return

	new weaponID = read_data(2)
	if ( weaponID != gLastWeapon[id] )
	{
		// if user switch weapon
		dsniper_zoomout(id)
		gLastWeapon[id] = weaponID
	}
	if ( weaponID != CSW_DEAGLE ) return

	//go to set model
	switch_model(id)

	//unlimited ammo!
	//read if clip is 0
	if ( read_data(3) == 0 )
	{
		//then reload ammo
		sh_reload_ammo(id, 1)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
