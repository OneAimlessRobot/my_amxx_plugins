#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Bad spawn preventer"
#define AUTHOR "beast"
#define VERSION "1.3"

#define TASKID_FIXIT 256

new g_freezetime
new Float:g_time1
new Float:g_flSpawned[33]
new Float:g_spawndelay = 6.0 // Should not be set lower. Higher values may reduce rare 'second spawn kills'.

public plugin_init()
{         
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SPONLY | FCVAR_SERVER)

	RegisterHam(Ham_Spawn,  "player", "FwdHamPlayerSpawn", 1, true)
	RegisterHam(Ham_Killed, "player", "FwdHamPlayerKilled", _, true)
	
	g_freezetime = get_cvar_pointer("mp_freezetime")
	g_time1 = get_pcvar_num(g_freezetime) + g_spawndelay
}

public FwdHamPlayerSpawn(id)
{
	if (is_user_alive(id))
		g_flSpawned[id] = get_gametime()
		
	if(is_user_stuck(id))
		set_task(g_time1, "task_fixit", id + TASKID_FIXIT)
}

public FwdHamPlayerKilled(id, iAttacker, iShouldGib)
{
	// we don't want deathmatch
	if((get_gametime() - g_flSpawned[id]) < 0.01)
		set_task(g_time1, "task_fixit", id + TASKID_FIXIT)
		
	return HAM_IGNORED
}

public task_fixit(id)
{
	new map[32]
	get_mapname(map, 31)
	
	ExecuteHam(Ham_CS_RoundRespawn, id - TASKID_FIXIT)
	
	// we don't want to flood the log with the same msg
	if(CheckForString("logs", "bsp_log_file.log", map))
		return 1
	else
	{
		log_to_file("bsp_log_file.log", "[BSP] Check %s map, it may contain some bad spawn points.", map)
		return 0
	}
}

// thx Alka
stock CheckForString(const szDir[32], const szFile[32], const szString[32])
{
	new szLocalDir[32]
	get_localinfo("amx_basedir", szLocalDir, charsmax(szLocalDir))
	new szPath[64]
	formatex(szPath, charsmax(szPath), "%s/%s/%s", szLocalDir, szDir, szFile)
	
	new iFile = fopen(szPath, "rt")
	if(!iFile)
		return 0
		
	new szBuffer[128]
	while(!feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer))
		if(!szBuffer[0])
			continue
        
		if(containi(szBuffer, szString) != -1)
		{
			fclose(iFile)
			return 1
		}
	}
	fclose(iFile)
	return 0
}

stock bool:is_user_stuck(Id)
{
	static Float:Origin[3]
	pev(Id, pev_origin, Origin)
	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0)
	if (get_tr2(0, TR_StartSolid))
		return true
        
	return false
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1063\\ f0\\ fs16 \n\\ par }
*/
