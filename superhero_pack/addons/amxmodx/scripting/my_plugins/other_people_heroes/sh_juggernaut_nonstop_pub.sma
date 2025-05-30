// JUGGERNAUT (Non-Stop Version)

/* CVARS - copy and paste to shconfig.cfg

//Juggernaut
juggernaut_level 2

*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Juggernaut"
new bool:gHasJuggernaut[SH_MAXSLOTS+1]
new bool:gRestoreVel
new Float:vecVel[3]
new fm_PreThink
new fm_PreThink_Post

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Juggernaut (Non-Stop)", "1.0", "1sh0t2killz AKA Subtlety")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("juggernaut_level", "2")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Unstoppable!", "You do not feel the knockback from bullets.")

	// PRE-THINK AND POST-THINK
	fm_PreThink = register_forward(FM_PlayerPreThink, "Player_PreThink")
	fm_PreThink_Post = register_forward(FM_PlayerPreThink, "Player_PreThink_Post", 1)
}

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	gHasJuggernaut[id] = mode ? true : false

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public plugin_end()
{
	if(fm_PreThink)
	{
		unregister_forward(FM_PlayerPreThink, fm_PreThink)
	}
	if(fm_PreThink_Post)
	{
		unregister_forward(FM_PlayerPreThink, fm_PreThink_Post, 1)
	}
}

public Player_PreThink(id)
{
	if(gHasJuggernaut[id])
	{
		if(pev_valid(id) && is_user_alive(id) && (FL_ONGROUND & pev(id, pev_flags)))
		{
			pev(id, pev_velocity, vecVel)
			gRestoreVel = true
		}
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public Player_PreThink_Post(id)
{
	if(gRestoreVel && gHasJuggernaut[id])
	{
		gRestoreVel = false

		if(!(FL_ONTRAIN & pev(id, pev_flags)))
		{
			static iGEnt
			
			iGEnt = pev(id, pev_groundentity)
			if(pev_valid(iGEnt) && (FL_CONVEYOR & pev(iGEnt, pev_flags)))
			{
				static Float:vecTemp[3]
				
				pev(id, pev_basevelocity, vecTemp)
				
				vecVel[0] += vecTemp[0]
				vecVel[1] += vecTemp[1]
				vecVel[2] += vecTemp[2]
			}				

			set_pev(id, pev_velocity, vecVel)
			
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
