#include <amxmodx>
#include <engine>
#include <fun>

new maxplayers

public plugin_init() {
	maxplayers = get_maxplayers()
	register_cvar("amx_nobombhos","1")
	register_plugin("No bomb/hostages","1.00","NL)Ramon(NL")
	register_event("RoundTime", "nohos", "bc")
	removeit()
	nohos()
}

public removeit() {
	new fhosr = find_ent_by_class(-1, "func_hostage_rescue")
	while(fhosr > maxplayers)
		{
		entity_set_int(fhosr, EV_INT_flags, FL_KILLME)
		fhosr = find_ent_by_class(fhosr, "func_hostage_rescue") 
	} 
	new doneonce = 0
	new fbombt = find_ent_by_class(-1, "func_bomb_target")
	while(fbombt > maxplayers)
		{
		entity_set_int(fbombt, EV_INT_flags, FL_KILLME)
		doneonce = 1
		fbombt = find_ent_by_class(fbombt, "func_bomb_target")
	}
	if(doneonce == 1)server_cmd("sv_restartround 1")
	new ibombt = find_ent_by_class(-1, "info_bomb_target")
	while(ibombt > maxplayers)
		{
		entity_set_int(ibombt, EV_INT_flags, FL_KILLME)
		ibombt = find_ent_by_class(ibombt, "info_bomb_target")
	}	
	new fescape = find_ent_by_class(-1, "func_escapezone")
	while(fescape > maxplayers)
		{
		entity_set_int(fescape, EV_INT_flags, FL_KILLME)
		fescape = find_ent_by_class(fescape, "func_escapezone")
	}	
	new fvips = find_ent_by_class(-1, "func_vip_safteyzone")
	while(fvips > maxplayers)
		{
		entity_set_int(fvips, EV_INT_flags, FL_KILLME)
		fvips = find_ent_by_class(fvips, "func_vip_safteyzone")
	}	
	new fvipst = find_ent_by_class(-1, "func_vip_start")
	while(fvipst > maxplayers)
		{
		entity_set_int(fvipst, EV_INT_flags, FL_KILLME)
		fvipst = find_ent_by_class(fvipst, "func_vip_start")
	}	
	return PLUGIN_CONTINUE
}

public nohos() {
	if(get_cvar_num("amx_nobombhos") == 1)
		{
		new iHos = find_ent_by_class(-1, "hostage_entity")
		while(iHos > maxplayers)
			{
			entity_set_int(iHos, EV_INT_flags, FL_KILLME)
			iHos = find_ent_by_class(iHos, "hostage_entity") 
		} 
		new jHos = find_ent_by_class(-1, "monster_scientist")
		while(iHos > maxplayers) 
			{
			entity_set_int(jHos, EV_INT_flags, FL_KILLME)
			iHos = find_ent_by_class(jHos, "monster_scientist") 
		} 
	}
}
