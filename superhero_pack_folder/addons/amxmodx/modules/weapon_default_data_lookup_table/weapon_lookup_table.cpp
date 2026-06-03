/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/weapon_lookup_table.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"


/*
 * 
 * 
 * 
 * for all of these,
 * the only arg is the wpnid.
 * 
 * it will give you an error if wpnid is invalid!
 * 
 *  

*/

static cell AMX_NATIVE_CALL wlt_get_def_clip(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return weapon_data_structs_array[params[1]].wpn_struct_max_clip;
}
static cell AMX_NATIVE_CALL wlt_get_def_pos(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return weapon_data_structs_array[params[1]].wpn_struct_wpn_position;
}
static cell AMX_NATIVE_CALL wlt_get_def_slot(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return weapon_data_structs_array[params[1]].wpn_slot;
}

static cell AMX_NATIVE_CALL wlt_get_def_bp_ammo(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return weapon_data_structs_array[params[1]].wpn_struct_max_bp_ammo;
}
static cell AMX_NATIVE_CALL wlt_get_def_ammo_id(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return weapon_data_structs_array[params[1]].wpn_struct_ammo_id;
}

static cell AMX_NATIVE_CALL wlt_get_def_prim_atk_delay(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return amx_ftoc(weapon_data_structs_array[params[1]].wpn_struct_primary_attack_delay );
}

static cell AMX_NATIVE_CALL wlt_get_def_scnd_atk_delay(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return amx_ftoc(weapon_data_structs_array[params[1]].wpn_struct_secondary_attack_delay );
}

static cell AMX_NATIVE_CALL wlt_get_def_rld_delay(AMX *amx,cell *params)
{
	if(!is_valid_cs_weapon(params[1])) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Invalid wpnid Specified!");
		return -1;
	}
	return amx_ftoc(weapon_data_structs_array[params[1]].wpn_struct_reload_delay );
}

AMX_NATIVE_INFO weapon_lookup_table_exports[] = 
{
	{ "wlt_get_def_clip", wlt_get_def_clip },
	{ "wlt_get_def_bp_ammo", wlt_get_def_bp_ammo },
	{ "wlt_get_def_prim_atk_delay", wlt_get_def_prim_atk_delay },
	{ "wlt_get_def_scnd_atk_delay", wlt_get_def_scnd_atk_delay },
	{ "wlt_get_def_rld_delay", wlt_get_def_rld_delay },
	{ "wlt_get_def_ammo_id", wlt_get_def_ammo_id },
	{ "wlt_get_def_pos", wlt_get_def_pos },
	{ "wlt_get_def_slot", wlt_get_def_slot },
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	MF_AddNatives(weapon_lookup_table_exports);
}