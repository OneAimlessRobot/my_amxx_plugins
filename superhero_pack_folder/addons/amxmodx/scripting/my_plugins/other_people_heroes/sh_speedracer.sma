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

#include <amxmodx>
#include "../my_include/superheromod.inc"
#include <fakemeta>

new gHeroName[] = "Speed Racer";
new bool:gHasSpeedPower[SH_MAXSLOTS+1];
new bool:gCanJump[SH_MAXSLOTS+1];

public plugin_init() {
	register_plugin("SUPERHERO Speed Racer", "1.0", "Rolnaaba");
	
	register_cvar("speed_level", "1");
	register_cvar("speed_speed", "300");
	register_cvar("speed_height", "60.0");

	shCreateHero(gHeroName, "Go Speed Racer", "Upgraded Speed and Super Jump!", false, "speed_level");

	register_srvcmd("speed_init", "speed_init");
	shRegHeroInit(gHeroName, "speed_init");
	
	register_srvcmd("speed_kd", "speed_kd");
	shRegKeyDown(gHeroName, "speed_kd");

	register_event("ResetHUD", "speed_NewRound", "b");

	shSetMaxSpeed(gHeroName, "speed_speed", "[0]");
}

public speed_init() {
	new temp[5];
	read_argv(1, temp, 4);
	new id = str_to_num(temp);

	read_argv(2, temp, 4);
	new haspower = str_to_num(temp);

	gHasSpeedPower[id] = (haspower != 0);
}

public speed_kd() {
	new temp[5];
	read_argv(1, temp, 4);
	new id = str_to_num(temp);

	if(!is_user_alive(id) || !gHasSpeedPower[id]) return;
	if(!gCanJump[id]) { playSoundDenySelect(id); client_print(id, print_chat, "[SH](Speed Racer) You can only Super-Jump once per round!"); return; }

	new Float:velocity[3]
	pev(id, pev_velocity, velocity);

	velocity[2] += get_cvar_float("speed_height");
	set_pev(id, pev_velocity, velocity);

	gCanJump[id] = false
}

public speed_NewRound(id) {
	if(!is_user_alive(id) || !gHasSpeedPower[id] || !hasRoundStarted()) return;

	gCanJump[id] = true
}
