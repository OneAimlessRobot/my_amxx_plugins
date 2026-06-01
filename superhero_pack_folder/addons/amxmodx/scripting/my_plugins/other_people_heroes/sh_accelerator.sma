#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_inc.inc"

new gHeroName[] = "Accelerator"
new gHeroID
new pcvar_accel_rate
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Accelerator", "1.1", "SRGrty")

	create_cvar("acc_level", "0")
	pcvar_accel_rate = create_cvar("acc_rate", "20")

	gHeroID=shCreateHero(gHeroName, "Accelerate", "Get Faster Every Second", false, "acc_level")



	set_task(1.0, "acc_loop", 0, "", 0, "b")
}
//----------------------------------------------------------------------------------------------
public acc_loop()
{
	if ( !sh_is_active() || !hasRoundStarted() ) return

	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]
		if ( sh_get_user_has_hero(id,gHeroID) && is_user_alive(id) )
		{
			set_user_maxspeed(id, get_user_maxspeed(id)+cvar_val(float,pcvar_accel_rate))
		}
	}
}
//----------------------------------------------------------------------------------------------