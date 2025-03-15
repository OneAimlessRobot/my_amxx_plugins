/*
	*EDITED BY : yas17sin for alien vs predator mod
*/
#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <aliens_vs_predator>

new bool:g_WallClimb[33]
new Float:g_wallorigin[32][3]

public plugin_init() 
{
	register_plugin("[AVP] Extra Item: Wall climb ", "1.0", "Python1320 & Accelerator")
	avp_register_extra_item("Wall Climb", 5, "func_aln_item_handler", AVP_TEAM_ALIEN);
	
	register_forward(FM_Touch, "fwd_touch")
	register_forward(FM_PlayerPreThink, "fwd_playerprethink")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	
}
public func_aln_item_handler(index)
{
	g_WallClimb[index] = true
	
	client_print(index, print_chat, "[AvP] You've got Wall Clim Item press E to use it ");
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	g_WallClimb[victim] = false
}
public client_connect(id)
{
	g_WallClimb[id] = false
}
public fwd_touch(id, world)
{
	if(!is_user_alive(id) || !g_WallClimb[id])
		return FMRES_IGNORED
	if(!avp_get_user_alien(id))
		return FMRES_IGNORED
	
	pev(id, pev_origin, g_wallorigin[id])
	
	return FMRES_IGNORED
}

public wallclimb(id, button)
{
	static Float:origin[3]
	pev(id, pev_origin, origin)
	
	if(get_distance_f(origin, g_wallorigin[id]) > 25.0)
		return FMRES_IGNORED  // if not near wall
	
	if(fm_get_entity_flags(id) & FL_ONGROUND)
		return FMRES_IGNORED
	
	if(button & IN_FORWARD)
	{
		static Float:velocity[3]
		velocity_by_aim(id, 120, velocity)
		fm_set_user_velocity(id, velocity)
	}
	else if(button & IN_BACK)
	{
		static Float:velocity[3]
		velocity_by_aim(id, -120, velocity)
		fm_set_user_velocity(id, velocity)
	}
	return FMRES_IGNORED
}    

public fwd_playerprethink(id) 
{
	if(!g_WallClimb[id]) 
		return FMRES_IGNORED
	if(!avp_get_user_alien(id))
		return FMRES_IGNORED
	
	new button = fm_get_user_button(id)
	
	if(button & IN_USE) //Use button = climb
		wallclimb(id, button)
	
	return FMRES_IGNORED
}