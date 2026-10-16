#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN					"Land Reality"
#define AUTHOR					"OT"
#define VERSION					"1.3"

// You can modify
#define MAX_PLAYERS				32

#define MIN_DAMAGE_VELOCITY		150.0
#define UNIT_MAKE_MORE_DAMAGE	50

// Do not modify
#define OFFSET_PL_FALLVEL		251
#define EXTRA_PL_OFFSET			5

new Float:old_fall_vel[MAX_PLAYERS + 1]
new Float:fall_vel[MAX_PLAYERS + 1]
new bool:was_on_ladder[MAX_PLAYERS + 1]
new g_maxplayers

new pcv_ff
new pcv_da

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("land_real_version", VERSION, FCVAR_SPONLY | FCVAR_SERVER)
	
	pcv_ff = get_cvar_pointer("mp_friendlyfire")
	pcv_da = register_cvar("mp_lr_damage", "1") // 0 - do not damage teammates, 1 - follow FF
	
	g_maxplayers = get_maxplayers()
}

public client_PreThink(id)
{
	if ( !is_user_alive(id) )
		return PLUGIN_CONTINUE
	
	fall_vel[id] = get_pdata_float(id, OFFSET_PL_FALLVEL, EXTRA_PL_OFFSET)
	static	ground_ent
	ground_ent = entity_get_edict(id, EV_ENT_groundentity)
	
	if (fall_vel[id] == 0.0 && old_fall_vel[id] > MIN_DAMAGE_VELOCITY && !was_on_ladder[id])
	{
		if (is_breakable(ground_ent))
		{
			if ( 1 <= ground_ent <= g_maxplayers)
			{
				if (cs_get_user_team(id) != cs_get_user_team(ground_ent))
				{
					ExecuteHamB(Ham_TakeDamage, ground_ent, 0, id, (10.0 + (float(  floatround(old_fall_vel[id] - MIN_DAMAGE_VELOCITY) / UNIT_MAKE_MORE_DAMAGE ) * 5.0)), DMG_FALL)
				}
				else
				{
					if (get_pcvar_num(pcv_ff) != 0 && get_pcvar_num(pcv_da) == 1)
					{
						ExecuteHamB(Ham_TakeDamage, ground_ent, 0, id, (5.0 + (float(  floatround(old_fall_vel[id] - MIN_DAMAGE_VELOCITY) / UNIT_MAKE_MORE_DAMAGE ) * 2.5)), DMG_FALL)
					}
				}
			}
			else
			{
				ExecuteHamB(Ham_TakeDamage, ground_ent, 0, id, (10.0 + (float(  floatround(old_fall_vel[id] - MIN_DAMAGE_VELOCITY) / UNIT_MAKE_MORE_DAMAGE ) * 5.0)), DMG_FALL)
			}
			
			if ((!is_valid_ent(ground_ent)) || (( 1 <= ground_ent <= g_maxplayers) && !is_user_alive(ground_ent)))
			{
				// IF entity was destroyed fall velocity continues!
				fall_vel[id] = old_fall_vel[id] - MIN_DAMAGE_VELOCITY
				set_pdata_float(id, OFFSET_PL_FALLVEL, fall_vel[id], EXTRA_PL_OFFSET)
				return PLUGIN_CONTINUE
			}
			
		}
	}
	
	was_on_ladder[id] = (entity_get_int(id, EV_INT_movetype) == MOVETYPE_FLY)
	old_fall_vel[id] = fall_vel[id]
	
	return PLUGIN_CONTINUE
}


stock is_breakable(ent)
{
	if (ent == 0)
		return 0
	
	if ((entity_get_float(ent, EV_FL_health) > 0.0) && (entity_get_float(ent, EV_FL_takedamage) > 0.0) && !(entity_get_int(ent, EV_INT_spawnflags) & SF_BREAK_TRIGGER_ONLY))
		return 1
	
	return 0
}