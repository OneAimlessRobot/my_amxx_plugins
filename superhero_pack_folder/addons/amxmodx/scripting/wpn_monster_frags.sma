/* Copyright (C) 2008 Space Headed Productions
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
#include <weaponmod_stocks>
#include <fakemeta>

// Plugin informations
new const PLUGIN[] = "WPN Custom Monster Frags"
new const VERSION[] = "0.2"
new const AUTHOR[] = "DevconeS"

#define MAX_MONSTERS			16	// Maximum amount of monsters to be registered
#define MAX_MONSTER_MDL_LENGTH	32	// Max length a mostername can have

// Contains list of monster names
new g_MonsterModelList[MAX_MONSTERS][MAX_MONSTER_MDL_LENGTH]
new Float:g_MonsterFragList[MAX_MONSTERS]
new g_MonsterMoneyList[MAX_MONSTERS]
new g_MonsterCount

// CVARs
new g_MonsterFrags
new g_MonsterMoney

// Initializes the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
	
	g_MonsterFrags = get_cvar_pointer("wpn_monster_frags")
	g_MonsterMoney = register_cvar("wpn_monsterkill_money", "0")	// Register since not all gameinfo plugins support this
	
	load_monster_list()
}

// Loads the monster list
load_monster_list()
{
	// Reset monster count :)
	g_MonsterCount = 0
	
	// Get the configuration file
	new wpnmoddir[64], dirExists, file[64], fp, data[64], frags[4], money[8]
	dirExists = get_weaponmoddir(wpnmoddir, 63)
	formatex(file, 63, "%s/custom_monster_frags.ini", wpnmoddir)
	
	if(file_exists(file))
	{
		// File exists, read it :)
		fp = fopen(file, "r")
		if(fp)
		{
			// Read until file end or to the maximum of registered monsters
			while(!feof(fp) && g_MonsterCount < MAX_MONSTERS)
			{
				fgets(fp, data, 63)
				if(data[0] == ';')
				{
					// Current line is a comment, ignore it
					continue
				}
				
				// Get data and increase monster amount
				parse(data, g_MonsterModelList[g_MonsterCount], MAX_MONSTER_MDL_LENGTH-1, frags, 3, money, 7)
				g_MonsterFragList[g_MonsterCount] = str_to_float(frags)
				g_MonsterMoneyList[g_MonsterCount] = str_to_num(money)
				g_MonsterCount++
			}
			
			// Close the file handle
			fclose(fp)
		}
	} else {
		// Make sure directory exists
		if(!dirExists)
		{
			// Directory doesn't exist and couldn't be created, exit
			return PLUGIN_CONTINUE
		}
		
		// File doesn't exist, create it
		fp = fopen(file, "w")
		if(fp)
		{
			// Put some information in it :)
			fputs(fp, "; Add here the list of monsters with the specified frag amount^n")
			fputs(fp, "; Format:^n")
			fputs(fp, ";   <modelfile>^t<fragamount>^t<money>^n^n")
			fputs(fp, "; Examples:^n")
			fputs(fp, ";   models/zombie.mdl^t2^t300^n")
			fputs(fp, ";   models/apache.mdl^t10^t6000^n")
			fputs(fp, ";   models/scientist.mdl^t-1^t-300^n^n")
			
			// Close the file handle
			fclose(fp)
		}
	}
	
	return PLUGIN_CONTINUE
}

// A player or a monster was killed by a special weapon
public wpn_gi_player_killed(id, killer, hitplace, wpnid, weapon[], bool:monster)
{
	if(!monster)
	{
		// No monster was killed, ignore it
		return PLUGIN_CONTINUE
	}
	
	new model[32]
	pev(id, pev_model, model, 31)
	for(new i = 0; i < g_MonsterCount; i++)
	{
		if(equal(model, g_MonsterModelList[i]))
		{
			// We found the monster to handle, do the modifications and were done :)
			new Float:frags
			new money = wpn_gi_get_offset_int(killer, offset_money)
			pev(killer, pev_frags, frags)
			
			// Remove the frags/money set by WeaponMod and add monster specifiec frag/money amount
			frags = frags+g_MonsterFragList[i]-get_pcvar_float(g_MonsterFrags)
			money = money+g_MonsterMoneyList[i]-get_pcvar_num(g_MonsterMoney)
			
			// Update user frags/money
			set_pev(killer, pev_frags, frags);
			wpn_gi_set_offset_int(killer, offset_money, money)
			
			// No more monsters to check :)
			break
		}
	}
	
	return PLUGIN_CONTINUE
}

