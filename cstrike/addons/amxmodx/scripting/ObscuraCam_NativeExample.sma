#include <amxmodx>
#include <camera>

#define PLUGIN_VERSION "0.1"

public plugin_init() 
{
	register_plugin("Obscura Cam (Native Example)", PLUGIN_VERSION, "Nani (SkumTomteN@Alliedmodders)")
	
	register_clcmd("say /toggle", "CMD_Toggle")
}

public CMD_Toggle(iPlayer)
{
	if(!get_user_camera(iPlayer))
		set_user_camera(iPlayer, 1)
	else 
		set_user_camera(iPlayer, 0)
}