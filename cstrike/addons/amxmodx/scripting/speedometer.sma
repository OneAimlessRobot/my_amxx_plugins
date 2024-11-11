#include <amxmodx>
#include <fakemeta>

#define PLUGIN "Speedometer"
#define VERSION "1.2"
#define AUTHOR "AciD"

#define FREQ 0.1

new bool:plrSpeed[33]

new TaskEnt,SyncHud,showspeed,color, maxplayers, r, g, b

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("AcidoX", "Speedometer 1.1", FCVAR_SERVER)
	register_forward(FM_Think, "Think")
	
	TaskEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))	
	set_pev(TaskEnt, pev_classname, "speedometer_think")
	set_pev(TaskEnt, pev_nextthink, get_gametime() + 1.01)
	
	register_clcmd("say /speed", "toogleSpeed")
	
	showspeed = register_cvar("showspeed", "1")
	color = register_cvar("speed_colors", "255 255 255")
	
	SyncHud = CreateHudSyncObj()
	
	maxplayers = get_maxplayers()
	
	new colors[16], red[4], green[4], blue[4]
	get_pcvar_string(color, colors, sizeof colors - 1)
	parse(colors, red, 3, green, 3, blue, 3)
	r = str_to_num(red)
	g = str_to_num(green)
	b = str_to_num(blue)
}

public Think(ent)
{
	if(ent == TaskEnt) 
	{
		SpeedTask()
		set_pev(ent, pev_nextthink,  get_gametime() + FREQ)
	}
}

public client_putinserver(id)
{
	plrSpeed[id] = showspeed > 0 ? true : false
}

public toogleSpeed(id)
{
	plrSpeed[id] = plrSpeed[id] ? false : true
	return PLUGIN_HANDLED
}

SpeedTask()
{
	static i, target
	static Float:velocity[3]
	static Float:speed, Float:speedh
	
	for(i=1; i<=maxplayers; i++)
	{
		if(!is_user_connected(i)) continue
		if(!plrSpeed[i]) continue
		
		target = pev(i, pev_iuser1) == 4 ? pev(i, pev_iuser2) : i
		pev(target, pev_velocity, velocity)

		speed = vector_length(velocity)
		speedh = floatsqroot(floatpower(velocity[0], 2.0) + floatpower(velocity[1], 2.0))
		
		set_hudmessage(r, g, b, -1.0, 0.7, 0, 0.0, FREQ, 0.01, 0.0)
		ShowSyncHudMsg(i, SyncHud, "%3.2f units/second^n%3.2f velocity", speed, speedh)
	}
}
