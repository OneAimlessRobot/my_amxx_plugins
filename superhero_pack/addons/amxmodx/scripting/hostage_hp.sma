#include <amxmodx>
#include <amxmisc>
#include <engine>

public SetHostageHp(id)
{
	new health=get_cvar_num("mp_hostagehp")
	if (health==100) return PLUGIN_HANDLED
	if (health>9999) set_cvar_num("mp_hostagehp",100)
	if (health<=0) set_cvar_num("mp_hostagehp",100)

	new iHos = find_ent_by_class(-1, "hostage_entity")
	while(iHos != 0)
	{
			entity_set_float(iHos, EV_FL_health, get_cvar_float("mp_hostagehp"))
//			client_print(id, 3,"[DEBUG] Hostage with id %d now has %.0f HP", iHos, Entvars_Get_Float(iHos, EV_FL_health))
			iHos = find_ent_by_class(iHos, "hostage_entity")
	}
	new jHos = find_ent_by_class(-1, " monster_scientist")
	while(jHos != 0)
	{
			entity_set_float(jHos, EV_FL_health, get_cvar_float("mp_hostagehp"))
//			client_print(id, 3,"[DEBUG] Hostage with id %d now has %.0f HP", iHos, Entvars_Get_Float(iHos, EV_FL_health))
			iHos = find_ent_by_class(jHos, " monster_scientist")
	}
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Hostage HP", "1.1", "AssKicR")
	register_cvar("mp_hostagehp","100") //Max is 9999
	register_event("RoundTime", "SetHostageHp", "bc") 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
