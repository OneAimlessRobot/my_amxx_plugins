/* 3rd person mode
Timmi the savage

*/

#include <amxmodx>
#include <engine>
#include <amxmisc>

public thirdpersonangle(id)
{
	set_view(id, CAMERA_3RDPERSON)
	return PLUGIN_HANDLED
}

public normalangle(id)
{
	set_view(id, CAMERA_NONE)
	return PLUGIN_HANDLED
}

public topdownanangle(id)
{
	set_view(id, CAMERA_TOPDOWN)
	return PLUGIN_HANDLED
}

public upleftangle(id)
{
	set_view(id, CAMERA_UPLEFT)
	return PLUGIN_HANDLED
}



public plugin_init()
{
	register_concmd("thirdview", "thirdpersonangle")
	register_concmd("upview", "upleftangle")
	register_concmd("topview", "topdownanangle")
	register_concmd("normalview", "normalangle")
	register_plugin("Camera Changer", "1.0", "Timmi")
}