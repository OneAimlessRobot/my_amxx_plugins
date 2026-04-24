
#include "../my_include/superheromod.inc"

new gHeroName[] = "Accelerator"
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Accelerator", "1.1", "SRGrty")

	register_cvar("acc_level", "0")
	register_cvar("acc_rate", "20")

	gHeroID=shCreateHero(gHeroName, "Accelerate", "Get Faster Every Second", false, "acc_level")

	register_srvcmd("acc_init", "acc_init")
	shRegHeroInit(gHeroName, "acc_init")

	register_event("ResetHUD", "new_spawn", "b")

	set_task(1.0, "acc_loop", 0, "", 0, "b")
}
//----------------------------------------------------------------------------------------------
public acc_init()
{
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)

	read_argv(2, temp, 5)
	new hasPowers = str_to_num(temp)

	if ( !hasPowers  && is_user_connected(id) )
	{
		shRemSpeedPower(id)
	}
}
//----------------------------------------------------------------------------------------------
public new_spawn(id)
{
	shRemSpeedPower(id)
}
//----------------------------------------------------------------------------------------------
public acc_loop()
{
	if ( !sh_is_active() || !hasRoundStarted() ) return

	for ( new id = 1; id <= SH_MAXSLOTS; id++ )
	{
		if ( sh_user_has_hero(id,gHeroID) && is_user_alive(id) )
		{
			set_user_maxspeed(id, get_user_maxspeed(id)+get_cvar_num("acc_rate"))
		}
	}
}
//----------------------------------------------------------------------------------------------