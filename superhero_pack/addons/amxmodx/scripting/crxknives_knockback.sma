#include <amxmodx>
#include <crxknives>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#if !defined MAX_PLAYERS
const MAX_PLAYERS = 32
#endif

new const PLUGIN_VERSION[] = "1.1"

const NOT_SET = -1
const Float:NOT_SET_F = -1.0
new const ATTRIBUTE_KNOCKBACK[] = "KNOCKBACK"

new g_pFriendlyFire
new g_iPower[MAX_PLAYERS + 1]
new Float:g_fVelocity[MAX_PLAYERS + 1]

public plugin_init()
{
	register_plugin("CRXKnives: Knockback", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXKnivesKnockback", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage", 1)
	g_pFriendlyFire = get_cvar_pointer("mp_friendlyfire")
}

public crxknives_knife_updated(id, iKnife, bool:bOnConnect)
{
	if(bOnConnect)
	{
		g_iPower[id] = NOT_SET
		g_fVelocity[id] = NOT_SET_F
	}

	new szValue[12]

	if(crxknives_get_attribute_str(id, ATTRIBUTE_KNOCKBACK, szValue, charsmax(szValue)))
	{
		new szKnockback[2][8]
		parse(szValue, szKnockback[0], charsmax(szKnockback[]), szKnockback[1], charsmax(szKnockback[]))

		g_iPower[id] = str_to_num(szKnockback[0])
		g_fVelocity[id] = str_to_float(szKnockback[1])
	}
	else if(g_iPower[id] != NOT_SET)
	{
		g_iPower[id] = NOT_SET
		g_fVelocity[id] = NOT_SET_F
	}
}

public OnTakeDamage(iVictim, iInflictor, iAttacker)
{
	if(!is_user_connected(iAttacker) || g_iPower[iAttacker] == NOT_SET || iVictim == iAttacker || iInflictor != iAttacker || get_user_weapon(iAttacker) != CSW_KNIFE)
	{
		return
	}

	if(cs_get_user_team(iAttacker) == cs_get_user_team(iVictim))
	{
		return
	}

	new Float:fVelocity[3]
	velocity_by_aim(iAttacker, g_iPower[iAttacker], fVelocity)
	fVelocity[2] = g_fVelocity[iAttacker]
	set_pev(iVictim, pev_velocity, fVelocity)
}
