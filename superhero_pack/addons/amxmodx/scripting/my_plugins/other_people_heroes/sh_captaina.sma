// CAPTAIN AMERICA!

/* CVARS - copy and paste to shconfig.cfg

//Captain America
captaina_level 0
captaina_pctperlev 0.02		//Percentage that factors into godmode randomness (Default 0.02)
captaina_godsecs 1.0		//# of seconds of god mode

*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Captain America"
new bool:gHasCaptainAmerica[SH_MAXSLOTS+1]
new Float:gMaxLevelFactor
new gPcvarPctPerLev, gPcvarGodSecs
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Captain America", SH_VERSION_STR, "{HOJ} Batman/JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("captaina_level", "0")
	gPcvarPctPerLev = register_cvar("captaina_pctperlev", "0.02")
	gPcvarGodSecs = register_cvar("captaina_godsecs", "1.0")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Super Shield", "Random Invincibility, better chance the higher your level")

	// OK Random Generator
	set_task(1.0, "captaina_loop", _, _, _, "b")
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	// Check here so sh_get_num_lvls has time to set itself
	gMaxLevelFactor = (10.0 / sh_get_num_lvls()) * 100.0
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	gHasCaptainAmerica[id] = mode ? true : false

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public captaina_loop()
{
	if ( !sh_is_active() ) return

	static Float:pctperlev
	static Float:godsecs
	pctperlev = get_pcvar_float(gPcvarPctPerLev)
	godsecs = get_pcvar_float(gPcvarGodSecs)
	static heroLevel

	static players[SH_MAXSLOTS], playerCount, id, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		id = players[i]

		if ( gHasCaptainAmerica[id] && !get_user_godmode(id) ) {

			heroLevel = floatround(sh_get_user_lvl(id) * pctperlev * gMaxLevelFactor)

			if ( heroLevel >= random_num(0, 100) ) {

				sh_set_godmode(id, godsecs)

				//Quick Blue Screen Flash Letting You know about god mode
				sh_screen_fade(id, godsecs, godsecs/2, 0, 0, 255, 50, SH_FFADE_MODULATE)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	gHasCaptainAmerica[id] = false
}
//----------------------------------------------------------------------------------------------
