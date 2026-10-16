/* AMX Mod X
*   Decals/Models Lister
*
* (c) Copyright 2006 by VEN
*
* This file is provided as is (no warranties)
*
*     DESCRIPTION
*       This plugin is for developers: outputs decals/models index/name list
*       Note: should be compiled locally
*
*     MODS
*       Currently supported mods:
*         Counter-Strike (cs) - by default
*         Half-Life (hl)
*       To switch from one mod to another change #include decals/cs below
*         Example: #include decals/hl
*       Note: if you want support for other mod, provide me $moddir/decals.wad file
*
*     MODULES
*       fakemeta
*
*     COMMANDS
*       dml_decals [name] [index]
*         dml_decals - outputs full decal index/name list
*         dml_decals "{ammo" - outputs decal index of the given decal name
*           Note: only part of name can be specified (case insensitive)
*         dml_decals _ 137 - outputs decal name of the given decal index
*         Note: mod-specific decals list required for that command
*       dml_models [name] [index]
*         dml_models - outputs full model index/name list
*         dml_models "models/w_hegrenade.mdl" - outputs model index of the given model name
*           Note: only part of name can be specified (case insensitive)
*         dml_models _ 92 - outputs model name of the given model index
*         Note: mod-specific decals/models list not required for that command
*       Note: commands access level can be changed below (default: ADMIN_ALL)
*
*     CVARS
*       dml_log_on <0|1>
*         dml_log_on 1 - output will be directed to the server console and log file
*         dml_log_on 0 - output will be directed to the server console only
*         Notes:
*           CVAR default value can be changed below (default: "0")
*           log filenames can be changed below (default: "decals.log", "models.log")
*
*     VERSIONS
*       0.2   expanded commands functionality
*             "dml_models" command is safe now
*             few other improvements
*       0.1   first release
*/

// change to different mod-specific filename from scripting/decals folder if necessary
#include <decals/cs>	// include file which contain mod-specific decals list

#include <amxmodx>	// AMX Mod X required, check your addons/metamod/plugins.ini
#include <fakemeta>	// fakemeta module required, check your configs/modules.ini
#include <amxmisc>	// this is not a module!

// plugin's main information
#define PLUGIN_NAME "Decals/Models Lister"
#define PLUGIN_VERSION "0.2"
#define PLUGIN_AUTHOR "VEN"

// OPTIONS BELOW

// commands names
new CMD_NAME_DECALS[] = "dml_decals"
new CMD_NAME_MODELS[] = "dml_models"

// commands access level
#define CMD_ACCESS_LEVEL ADMIN_ALL

// CVAR name
new CVAR_NAME_LOG[] = "dml_log_on"

// CVAR default value
#define CVAR_DEFAULT_LOG "0"

// log filenames
new LOG_FILE_DECALS[] = "decals.log"
new LOG_FILE_MODELS[] = "models.log"

// OPTIONS ABOVE

// initial AMXX version number supported CVAR pointers in get/set_pcvar_* natives
#define CVAR_POINTERS_AMXX_INIT_VER_NUM 170

// determine if get/set_pcvar_* natives can be used
#if defined AMXX_VERSION_NUM && AMXX_VERSION_NUM >= CVAR_POINTERS_AMXX_INIT_VER_NUM
	#define CVAR_POINTERS
	new g_pcvar_log_on
#endif

// macros
#define decal_index(%1) engfunc(EngFunc_DecalIndex, %1)
#define model_index(%1) engfunc(EngFunc_ModelIndex, %1)

new bool:g_log_on
new bool:g_cmd_type

#define PRECACHED_MODEL_LIMIT 512
new PRECACHED_MODEL_NAME[PRECACHED_MODEL_LIMIT][128]

public plugin_precache() {
	//register_forward(FM_PrecacheModel, "forward_precache_model", 1)
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_concmd(CMD_NAME_DECALS, "cmd_decals_models", CMD_ACCESS_LEVEL, "[name] [index]")
	register_concmd(CMD_NAME_MODELS, "cmd_decals_models", CMD_ACCESS_LEVEL, "[name] [index]")

#if defined CVAR_POINTERS
	g_pcvar_log_on = register_cvar(CVAR_NAME_LOG, CVAR_DEFAULT_LOG)
#else
	register_cvar(CVAR_NAME_LOG, CVAR_DEFAULT_LOG)
#endif
}

public forward_precache_model(name[]) {
	copy(PRECACHED_MODEL_NAME[model_index(name)], 127, name)
}

public cmd_decals_models(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

#if defined CVAR_POINTERS
	g_log_on = bool:get_pcvar_num(g_pcvar_log_on)
#else
	g_log_on = bool:get_cvar_num(CVAR_NAME_LOG)
#endif

	new command[32]
	read_argv(0, command, 31)
	g_cmd_type = bool:equali(command, CMD_NAME_DECALS)

	new name[128], idx[4]
	read_argv(1, name, 127)
	read_argv(2, idx, 3)
	new index = str_to_num(idx)

	if (g_cmd_type) {
		if (idx[0]) {
			for (new i = 0; i < DECALS_NUMBER; ++i) {
				if (decal_index(DECAL_NAME[i]) == index) {
					output(index, DECAL_NAME[i])
					break
				}
			}
		}
		else if (name[0]) {
			for (new i = 0; i < DECALS_NUMBER; ++i) {
				if (containi(DECAL_NAME[i], name) != -1)
					output(decal_index(DECAL_NAME[i]), DECAL_NAME[i])
			}
			
		}
		else {
			for (new i = 0; i < DECALS_NUMBER; ++i) {
				for (new j = 0; j < DECALS_NUMBER; ++j) {
					if (decal_index(DECAL_NAME[j]) == i) {
						output(i, DECAL_NAME[j])
						break
					}

				}
			}
		}
	}
	else {
		if (idx[0]) {
			if (index >= 0 && index < PRECACHED_MODEL_LIMIT && PRECACHED_MODEL_NAME[index][0])
				output(index, PRECACHED_MODEL_NAME[index])
		}
		else if (name[0]) {
			for (new i = 0; i < PRECACHED_MODEL_LIMIT; ++i) {
				if (containi(PRECACHED_MODEL_NAME[i], name) != -1)
					output(i, PRECACHED_MODEL_NAME[i])
			}
		}
		else {
			for (new i = 0; i < PRECACHED_MODEL_LIMIT; ++i) {
				if (PRECACHED_MODEL_NAME[i][0])
					output(i, PRECACHED_MODEL_NAME[i])
			}
		}
	}

	return PLUGIN_HANDLED	
}

output(index, name[]) {
		if (g_log_on)
			log_to_file(g_cmd_type ? LOG_FILE_DECALS : LOG_FILE_MODELS, "%3d   %s", index, name)
		else
			server_print("%3d   %s", index, name)
}
