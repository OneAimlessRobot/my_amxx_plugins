
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



	set_task(1.0, "acc_loop", 0, "", 0, "b")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if  (heroID!=gHeroID) return
	
	if ( !sh_user_has_hero(id,gHeroID)   && is_user_connected(id) )
	{
		shRemSpeedPower(id)
	}
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	shRemSpeedPower(id)
}
//----------------------------------------------------------------------------------------------
public acc_loop()
{
	if ( !sh_is_active() || !hasRoundStarted() ) return

	for ( new id = 1; id < sh_maxplayers()+1; id++ )
	{
		if ( sh_user_has_hero(id,gHeroID) && is_user_alive(id) )
		{
			set_user_maxspeed(id, get_user_maxspeed(id)+get_cvar_num("acc_rate"))
		}
	}
}
//----------------------------------------------------------------------------------------------