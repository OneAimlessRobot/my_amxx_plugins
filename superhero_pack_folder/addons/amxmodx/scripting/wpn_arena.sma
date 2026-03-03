/* Copyright (C) 2006-2008 Space Headed Productions
* 
* WeaponMod is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation.
*
* WeaponMod is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with WeaponMod; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/ 

#include <amxmodx>
#include <weaponmod>

new const PLUGIN[] = "Weapon Arena"
new const VERSION[] = "2.31"
new const AUTHOR[] = "DevconeS"

// CVAR Pointers
new g_Enabled

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
	
	register_cvar("wpn_arena_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	g_Enabled = get_cvar_pointer("wpn_enabled")
	
	register_logevent("logEventRoundStart", 2, "1=Round_Start")  
}

// Round started
public logEventRoundStart()
{
	new wpnid = random_num(0, wpn_weapon_count()-1)
	giveWeapons(wpnid, wpn_get_integer(wpnid, wpn_ammo1), wpn_get_integer(wpnid, wpn_ammo2))
}

// Gives every player a given weapon
giveWeapons(wpnid, ammo1, ammo2)
{
	if(get_pcvar_num(g_Enabled) == 0) return PLUGIN_CONTINUE
	
	for(new id = 1; id < 33; id++)
	{
		if(!is_user_alive(id)) continue
		
		if(wpn_has_weapon(id, wpnid) == -1)
		{
			// This player is alive, but doesn't own a Jetpack, give him one :)
			wpn_give_weapon(wpnid, id, ammo1, ammo2)
		}
	}
	
	new name[32]
	wpn_get_string(wpnid, wpn_name, name, 31)
	client_print(0, print_chat, "[WeaponMod] A %s has been given to every player", name)
	
	return PLUGIN_CONTINUE
}
