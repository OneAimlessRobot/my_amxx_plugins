/* WeaponMod ChickenMod Support
* 
* (c) Copyright 2008, DevconeS 
* This file is provided as is (no warranties). 
* 
*/ 

#include <amxmodx>
#include <fakemeta>
#include <weaponmod>

// Plugin informations
new const PLUGIN[] = "WPN ChickenMod Support"
new const VERSION[] = "0.2"
new const AUTHOR[] = "DevconeS"

// ChickenMod data
new const CHICKEN_PLAYER_MODEL[] = "models/player/chicken/chicken.mdl"
new const CHICKEN_VIEW_MODEL[] = ""
new const CHICKEN_WEAPON_MODEL[] = ""

// Others
new g_ChickenModelIndex

// Initializes the plugin
public plugin_init()
{
	// Register the addon
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
	
	// Get the player model index
	g_ChickenModelIndex = engfunc(EngFunc_ModelIndex, CHICKEN_PLAYER_MODEL)
}

// Executed each time before an event happened
public wpn_event_pre(id, wpnid, wpn_event:event, params[])
{
	if(event == event_draw)
	{
		// Player drawed weapon, if the player is a chicken,
		// move to the knife weapon
		if(is_chicken(id))
		{
			take_knife(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

// Checks if the given player is a chicken
bool:is_chicken(id)
{
	return (g_ChickenModelIndex == pev(id, pev_modelindex))
}

// Makes the player taking the knife and removes the models,
// since the chicken has no knife model
take_knife(id)
{
	// Change to knife
	wpn_change_user_weapon(id, -1, false)
	
	// Hide model
	set_pev(id, pev_viewmodel2, CHICKEN_VIEW_MODEL)
	set_pev(id, pev_weaponmodel2, CHICKEN_WEAPON_MODEL)
}
