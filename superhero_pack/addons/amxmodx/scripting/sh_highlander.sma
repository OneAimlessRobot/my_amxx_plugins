/*
CVARS:
highlander_level 0
*/

#include <superheromod>

new gHeroID
new const gHeroName[] = "Highlander"
new gHasHighlanderPower[SH_MAXSLOTS+1]
//-------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Highlander", "1.4", "blue")
	
	new pcvarLevel = register_cvar("highlander_level", "0")
	
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "You can killable only with headshots.", "You will respawn until you get a headshot.")
	
}
//--------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	gHasHighlanderPower[id] = mode ? true : false
}
//---------------------------------------------------------------------------
public sh_client_death(victim, attacker, headshot)
{	
	new id = read_data(2)
	if ( gHasHighlanderPower[victim] && !headshot )
	{
	
	if ( !is_user_alive(id))
	{
		new parm[1]
		parm[0] = id
		
		set_task(0.5, "highlander_respawn", 0, parm, 1)
	}
	}
}

//------------------------------------------------------------------------------
public highlander_respawn(parm[])
{
	new id = parm[0]
	if ( !shModActive() || !is_user_connected(id) || is_user_alive(id) ) return
	emit_sound(id, CHAN_STATIC, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	client_print(id, print_chat, "[SH](Highlander) That wasn't headshot!")

	spawn(id)
	spawn(id)
}