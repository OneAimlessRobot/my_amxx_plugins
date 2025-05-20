#include <amxmodx>
#include <hamsandwich>
#include <csstats>
//#include <dhudmessage>
#include <Commas>
#include <nvault>
#include <time>

new bool: FirstJoin[33]

new SteamID[33][32]
new LastPlayedTime[33]

new HostName

new nVault

public plugin_init()
{
	register_plugin("[CS16] Connect Info", "1.0", "CS16 Team")

	RegisterHam(Ham_Spawn, "player", "Fwd_PlayerSpawn", 1)

	HostName = get_cvar_pointer("hostname")

	register_dictionary("time.txt")

	nVault = nvault_open("PlayedTime")
}

public plugin_end()
{
	nvault_close(nVault)
}

public client_authorized(id) 
{
	FirstJoin[id] = true

	get_user_authid(id, SteamID[id], charsmax(SteamID[]))

	new Time[32]
	nvault_get(nVault, SteamID[id], Time, charsmax(Time))
	LastPlayedTime[id] = str_to_num(Time)
}

public Fwd_PlayerSpawn(id)
{
	if (!is_user_alive(id))
		return

	if (FirstJoin[id])
	{
		set_task(15.0, "Show_Info", id)
		set_task(18.0, "Fav", id)

		FirstJoin[id] =  false
	}
}

public client_disconnect(id)
{
	new Time[32]

	formatex(Time, charsmax(Time), "%d", Get_User_Total_PlayTime(id))
	nvault_set(nVault, SteamID[id], Time)
}

public Show_Info(id)
{
	new szHostName[64]
	get_pcvar_string(HostName, szHostName, charsmax(szHostName))

	static Name[32]
	get_user_name(id, Name, charsmax (Name))

	static Stats[8], Body[8]

	new RankPos = get_user_stats(id, Stats, Body)
	new MaxRank = get_statsnum()

	static RankPosString[16], MaxRankString[16]
	AddCommas(RankPos, RankPosString, 15)
	AddCommas(MaxRank, MaxRankString, 15)

	static KillString[16], DeathString[16];
	AddCommas(Stats[0], KillString, 15);
	AddCommas(Stats[1], DeathString, 15);

	new Time[128]
	get_time_length(id, Get_User_Total_PlayTime(id), timeunit_seconds, Time, charsmax(Time))

	set_dhudmessage(14, 204, 14, 0.10, 0.24, 2, 6.0, 8.0)
	show_dhudmessage(id, "Welcome, %s^nRank %s of %s^nKills: %s Deaths: %s ^nTime Played: %s^nEnjoy! www.PoCaralho.pt", Name, RankPosString, MaxRankString, KillString, DeathString, Time)
}

public Fav(id)
{
	new szHostName[64]
	get_pcvar_string(HostName, szHostName, charsmax(szHostName))

	set_dhudmessage(14, 204, 14, 0.10, 0.50, 2, 6.0, 8.0)
	show_dhudmessage(id, "%s^nDon't forget to add us to your favorites.", szHostName)
}

Get_User_Total_PlayTime(id) 
{
	return LastPlayedTime[id] + get_user_time(id)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
