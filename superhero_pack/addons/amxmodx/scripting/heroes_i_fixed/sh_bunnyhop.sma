//Bunny hop
/*
Credits to Cheap suit for the Bunny hop plugin bit
*/

/* CVARS - copy and paste to shconfig.cfg

//Bunny Hop
Bunny_level 5

*/

#include "my_plugins/my_include/superheromod.inc"

new gHeroName[]="Bunny hop"
new bool:gHasBunnyHop[SH_MAXSLOTS+1]
//-------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Bunny hop", "1.0", "newbie1233")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("Bunny_level", "5")
	register_cvar("Bunny Hop", "Auto jumping", 800)

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Bunny hop", "Start jumping like a bunnu hold jump button.", false, "bunny_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("bunny_init", "bunny_init")
	shRegHeroInit(gHeroName, "bunny_init")

}
//------------------------------------------------------------------------------------
public bunny_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	gHasBunnyHop[id] = (hasPowers != 0)
}
//-----------------------------------------------------------------------------------
public client_PreThink(id)
{
	if(gHasBunnyHop[id] && is_user_alive(id))
         { 
	entity_set_float(id, EV_FL_fuser2, 0.0)
         }
	if((get_user_button(id) & IN_JUMP)&&gHasBunnyHop[id] )
         {
		new Flags = entity_get_int(id, EV_INT_flags)
		if(Flags | FL_WATERJUMP && entity_get_int(id, EV_INT_waterlevel) < 2 && Flags & FL_ONGROUND)
		{
			new Float:fVelocity[3]
			entity_get_vector(id, EV_VEC_velocity, fVelocity)
			fVelocity[2] += 250.0
			entity_set_vector(id, EV_VEC_velocity, fVelocity)
			entity_set_int(id, EV_INT_gaitsequence, 6)
		}
	}
	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------------