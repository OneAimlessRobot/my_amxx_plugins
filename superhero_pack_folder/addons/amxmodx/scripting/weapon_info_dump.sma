/* AMX Mod X
*   Weapon Info Dump
*
* (c) Copyright 2006 by VEN
*
* This file is provided as is (no warranties)
*
*     DESCRIPTION
*       This plugin is for developers, allow to dump weapon info.
*       ID NAME SPEED CLIP AMMO AID ANAME COST ACOST BUYNAME BUYNAME2 =
*       Index, Name, PlayerSpeed, MaxClipAmmo, MaxBackpackAmmo,
*       AmmoIndex, AmmoName, Cost, AmmoCost, BuyName, BuyName2
*       Use client command "wi_dump" (default access is ADMIN_CFG)
*       By default dump file is "weaponinfo.log" (in logs dir).
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>

#define PLUGIN_NAME "Weapon Info Dump"
#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "VEN"

#define ACCESS_LEVEL ADMIN_CFG

new const g_dump_file[] = "weaponinfo.log"

// do not edit
#define DUMP_INTERVAL 0.1
#define START_MONEY 10000
#define WNUM 31
#define START_WID 1

new _name[WNUM][32]
new _clip[WNUM]
new _cost[WNUM]
new _aname[WNUM][32]
new _aid[WNUM]
new _acost[WNUM]
new _ammo[WNUM]
new _speed[WNUM]
new _buyname[WNUM][32]
new _buyname2[WNUM][32]

new g_name[32]
new g_ent
new g_id
new g_aid
new g_ammo

new g_ipsz_player_weaponstrip

new bool:g_processing = false

new const g_buy[][32] = {
	"galil",
	"ak47",
	"scout",
	"sg552",
	"awp",
	"g3sg1",
	"famas",
	"m4a1",
	"aug",
	"sg550",
	"glock",
	"usp",
	"p228",
	"deagle",
	"elites",
	"fn57",
	"m3",
	"xm1014",
	"mac10",
	"tmp",
	"mp5",
	"ump45",
	"p90",
	"m249",
	"flash",
	"hegren",
	"sgren"
}

new const g_buy2[][32] = {
	"defender",
	"cv47",
	"",
	"krieg552",
	"magnum",
	"d3au1",
	"clarion",
	"",
	"bullpup",
	"krieg550",
	"9x19mm",
	"km45",
	"228compact",
	"nighthawk",
	"",
	"fiveseven",
	"12gauge",
	"autoshotgun",
	"",
	"mp",
	"smg",
	"",
	"c90",
	"",
	"",
	"",
	""
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_clcmd("wi_dump", "clcmdDump", ACCESS_LEVEL, "- dumps weapon info")

	register_forward(FM_CreateNamedEntity, "fwCreateNamedEntity", 1)

	register_event("WeapPickup", "evWeapPickup", "b")
	register_event("AmmoPickup", "evAmmoPickup", "b")

	g_ipsz_player_weaponstrip = engfunc(EngFunc_AllocString, "player_weaponstrip")
}

public clcmdDump(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	if (g_processing) {
		console_print(id, "[WI] Already in progress!")
		return PLUGIN_HANDLED
	}

	if (!is_user_alive(id) || !(cs_get_user_buyzone(id) & (1<<0) /* backward compatibility */)) {
		console_print(id, "[WI] You must be in buyzone!")
		return PLUGIN_HANDLED
	}

	g_processing = true
	client_print(id, print_chat, "[WI] Dump started. Do NOT move!")

	new params[2]
	params[0] = id
	params[1] = 0
	set_task(DUMP_INTERVAL, "tskWeaponInfo", _, params, sizeof params)

	return PLUGIN_HANDLED
}

public tskWeaponInfo(params[2]) {
	new id = params[0]
	new i = params[1]
	WeaponInfo(id, i)

	if (++i == sizeof g_buy) {
		fm_strip_user_weapons(id)

		//                       ID NAME SPEED CLIP AMMO AID ANAME COST ACOST BUYNAME BUYNAME2
		log_to_file(g_dump_file, "%-2s %-19s %-5s %-4s %-4s %-3s %-15s %-4s %-5s %-7s %-11s", "ID", "NAME", "SPEED", "CLIP", "AMMO", "AID", "ANAME", "COST", "ACOST", "BUYNAME", "BUYNAME2")
		for (new x = START_WID; x < WNUM; ++x)
			log_to_file(g_dump_file, "%2d %-19s %5d %4d %4d %3d %-15s %4d %5d %-7s %-11s", x, _name[x], _speed[x], _clip[x], _ammo[x], _aid[x], _aname[x], _cost[x], _acost[x], _buyname[x], _buyname2[x])

		log_to_file(g_dump_file, "[WI] Note that there are also ^"especial^" weapons: ^"weapon_c4^" (ID=6, SPEED=250, AID=14), ^"weapon_knife^" (ID=29, SPEED=250), ^"weapon_shield^" (COST=2200)")

		client_print(id, print_chat, "[WI] End of dump. Look into ^"%s^"", g_dump_file)
		client_print(id, print_center, "[WI] Dump completed!")
		g_processing = false

		return
	}

	static newparams[2]
	newparams[0] = id
	newparams[1] = i
	set_task(DUMP_INTERVAL, "tskWeaponInfo", _, newparams, sizeof newparams)
}

public fwCreateNamedEntity(iclass) {
	engfunc(EngFunc_SzFromIndex, iclass, g_name, sizeof g_name - 1)
	g_ent = get_orig_retval()
}

public evWeapPickup(id) {
	g_id = read_data(1)
}

public evAmmoPickup(id) {
	g_aid = read_data(1)
	g_ammo += read_data(2)
}

WeaponInfo(id, i) {
	g_name[0] = 0
	g_ent = 0
	g_id = 0
	g_aid = 0
	g_ammo = 0

	fm_strip_user_weapons(id)
	cs_set_user_money(id, START_MONEY, 0)
	engclient_cmd(id, g_buy[i])

	if (!(START_MONEY - cs_get_user_money(id))) {
		cs_set_user_team(id, CS_TEAM_SPECTATOR - cs_get_user_team(id))
		engclient_cmd(id, g_buy[i])
		cs_set_user_team(id, CS_TEAM_SPECTATOR - cs_get_user_team(id))
	}

	_buyname[g_id] = g_buy[i]
	_buyname2[g_id] = g_buy2[i]

	_name[g_id] = g_name
	if (pev_valid(g_ent))
		_clip[g_id] = cs_get_weapon_ammo(g_ent)
	_cost[g_id] = START_MONEY - cs_get_user_money(id)

	g_name[0] = 0
	cs_set_user_money(id, START_MONEY, 0)
	engclient_cmd(id, "buyammo1")
	engclient_cmd(id, "buyammo2")

	_aname[g_id] = g_name
	_aid[g_id] = g_aid
	_acost[g_id] = START_MONEY - cs_get_user_money(id)

	engclient_cmd(id, "primammo")
	engclient_cmd(id, "secammo")
	_ammo[g_id] = g_ammo

	static Float:speed
	pev(id, pev_maxspeed, speed)
	_speed[g_id] = floatround(speed)

	if (g_id)
		cs_set_user_bpammo(id, g_id, 0)
}

stock fm_strip_user_weapons(index) {
	new ent = engfunc(EngFunc_CreateNamedEntity, g_ipsz_player_weaponstrip)
	if (pev_valid(ent)) {
		dllfunc(DLLFunc_Spawn, ent)
		dllfunc(DLLFunc_Use, ent, index)
		engfunc(EngFunc_RemoveEntity, ent)
	}
}
