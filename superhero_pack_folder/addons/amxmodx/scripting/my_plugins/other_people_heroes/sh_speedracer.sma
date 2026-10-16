/********************************************\
|*Speed Racer - Go Speed Raser, GO!         *|
|*Created By: Rolnaaba                      *|
|*                                          *|
|* Have Fun,                                *|
|*           Rolnaaba                       *|
\********************************************/

/*shconfig.cfg Cvars:

//Speed Racer
speed_level 1
speed_speed 300		//how fast can he run?!
speed_hight 60.0	//how high can he jump?!

*/
#include "../my_include/superheromod.inc"

new gHeroName[] = "Speed Racer";
new gHeroID
new bool:gCanJump[SH_MAXSLOTS+1];

public plugin_init() {
	register_plugin("SUPERHERO Speed Racer", "1.0", "Rolnaaba");
	
	create_cvar("speed_level", "1");
	create_cvar("speed_speed", "300");
	create_cvar("speed_height", "60.0");

	gHeroID=shCreateHero(gHeroName, "Go Speed Racer", "Upgraded Speed and Super Jump!", false, "speed_level");

	shSetMaxSpeed(gHeroName, "speed_speed", "[0]");
}


//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		speed_kd(id)
	}
}
}
public speed_kd(id) {
	
	if(!is_user_alive(id) || !sh_get_user_has_hero(id,gHeroID)) return;
	if(!gCanJump[id]) { sh_sound_deny(id); client_print(id, print_chat, "[SH](Speed Racer) You can only Super-Jump once per round!"); return; }

	new Float:velocity[3]
	pev(id, pev_velocity, velocity);

	velocity[2] += get_cvar_float("speed_height");
	set_pev(id, pev_velocity, velocity);

	gCanJump[id] = false
}

public sh_client_spawn(id) {
	if(!is_user_alive(id) || !sh_get_user_has_hero(id,gHeroID) || !hasRoundStarted()) return;

	gCanJump[id] = true
}
