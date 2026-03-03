/*
	*EDITED BY : yas17sin for alien vs predator mod.
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <aliens_vs_predator>
#include <xs>

new g_norecoil[33]
new Float: cl_pushangle[33][3]
new g_maxplayers

const WEAPONS_BITSUM = (1<<CSW_KNIFE|1<<CSW_HEGRENADE|1<<CSW_FLASHBANG|1<<CSW_SMOKEGRENADE|1<<CSW_C4)

public plugin_init()
{
	register_plugin("[AVP] Extra Item: No Recoil", "0.1.0", "CarsonMotion")
	
	avp_register_extra_item("No Recoil", 8, "func_mrn_item_handler", AVP_TEAM_MARINE);

	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Pre")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Post", 1)
		}
	}

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

	g_maxplayers = get_maxplayers()
}
public client_connect(id)
{
	g_norecoil[id] = false
}
public func_mrn_item_handler(index)
{
	g_norecoil[index] = true
}
public event_round_start()
{
	for (new id = 1; id <= g_maxplayers; id++)
		g_norecoil[id] = false
}

public fw_Weapon_PrimaryAttack_Pre(entity)
{
	new id = pev(entity, pev_owner)

	if (g_norecoil[id])
	{
		pev(id, pev_punchangle, cl_pushangle[id])
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Post(entity)
{
	new id = pev(entity, pev_owner)

	if (g_norecoil[id])
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.0, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
