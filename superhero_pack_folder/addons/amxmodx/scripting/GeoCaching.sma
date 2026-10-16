/*
Web: http://geo.edza.lv (full game description and contact information)
Official game server: geo.edza.lv

Additional information about the plugin is available on AlliedMods.net

If you like you can modify this plugin, take functions or parts of code, but do please credit me if you do so, thanks.

(c) 2009. - 2010. Eduards V.
*/

#include <amxmodx>
#include <amxmisc> 
#include <engine>
#include <fun>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN "Geo!Caching"
#define VERSION "Final 1.2"
#define AUTHOR "Eduards V."

/*
Increase this below if server crashes, however it is extremely unlikely.
It's the maximum number of entities created of whos id's can be stored in an array per round.

Do not overkill the number either because then you might run out of operational memory or this won't compile.
*/
#define MAX_BOX_CREATIONS_BEFORE_SERVER_CRASH 1000

#define mBoxSizeKeys (1<<0)|(1<<1)|(1<<2)

#define TASK_OFFSET 6087 //Random number

#define TASK_RELAY_START_SEARCHING TASK_OFFSET + 0
#define TASK_SHOW_STATS TASK_OFFSET + 1
#define TASK_RELAY_END_GAME TASK_OFFSET + 2
#define TASK_ENSURE_SPAWN TASK_OFFSET + 3
#define TASK_RELAY_RAMPAGE_SURVIVED TASK_OFFSET + 4
#define TASK_SHOW_IDLE_MESSAGE TASK_OFFSET + 5
#define TASK_SHOW_FREEZE_MESSAGE TASK_OFFSET + 6
#define TASK_RADAR TASK_OFFSET + 7
#define TASK_SET_TEAMS TASK_OFFSET + 8
#define TASK_RESTRICT_RECURRING_GEO TASK_OFFSET + 9
#define TASK_COUNTDOWN_PICKUP_TIMES TASK_OFFSET + 10

//This below is for multilangual messages
#define CT "CT"
#define T "T"

//Constants used to hide the hud
#define HUD_HIDE_CAL (1<<0)
#define HUD_HIDE_FLASH (1<<1)
#define HUD_HIDE_RHA (1<<3)
#define HUD_HIDE_TIMER (1<<4)
#define HUD_HIDE_MONEY (1<<5)

//Constant's below can be changed as needed, as different game enviorments need to be differnetly balanced.
//---------------------------------------------------------------------------------------------------------
const boxFindDistance = 85
const radarFindDistance = 272

const Float:boxSetBaseTime = 20.0
const Float:boxSetDiffBaseTime = 4.8
const Float:boxSetDiffPlayerAddTime = 0.4

const Float:gameTime = 130.0
const Float:gameDiffBaseTime = 1.5
const Float:gameDiffPlayerAddTime = 0.1875

const Float:rampageTime = 29.0

const pickupBoxTime = 45
const pickupBoxBaseAddTime = 25

const roundsInRowMustSetBoxes = 2
//---------------------------------------------------------------------------------------------------------

new leftBoxes[2][32]
new foundBoxes[2][32]
new setBoxes[2][32]
new takenBoxes[2][32]

new roundsNoBoxesSetTemp[2][32]
new roundsNoBoxesSet[2][32]
new timeLeftToPickupBox[2][32]

new registredRadarTime[2][32]
new registredGeoKeyTime[2][32]

new leftBoxesId
new foundBoxesId
new setBoxesId
new takenBoxesId

new roundsNoBoxesSetTempId
new roundsNoBoxesSetId
new timeLeftToPickupBoxId

new registredRadarTimeId
new registredGeoKeyTimeId

new globalRank[5][32]
new globalRankTemp[6][32]

new globalRankId
new globalRankTempId

new registredSpawns[32]
new topPlayers[32]
new nolagToggled[32]

new registredSpawnsId
new topPlayersId
new nolagToggledId

new boxesSetCount
new boxesTotalCount
new boxesTakenCount
new huntedInRampageCount
new survivedRampageCount

new boxEntity[MAX_BOX_CREATIONS_BEFORE_SERVER_CRASH] 
new boxEntityId

new boxModelBig[33]
new boxModelMedium[33]
new boxModelSmall[33]

new msgObjMain
new msgObjRTop
new msgObjLBottom
new msgObjRBottom

new Float:timePassed

new CsTeams:rampageTeam

new hudHideMsg

new hideFlags

new bool:rampageTeamSet
new bool:canSetBoxes

new bool:rampageStarted
new bool:roundStarted
new bool:gameStarted
new bool:freezeStarted
new bool:standbyStarted

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_menucmd(register_menuid("mBoxSize"), mBoxSizeKeys, "event_mBoxSize_pressed")
	
	register_clcmd("geo", "event_geo")
	
	register_clcmd("say /geo", "event_show_help", 0, "- displays Geo!Caching help")
	register_clcmd("say \geo", "event_show_help", 0, "- displays Geo!Caching help")
	register_clcmd("say geo", "event_show_help", 0, "- displays Geo!Caching help")
	
	register_clcmd("say /nolag", "event_no_lag", 0, "- disables some flashing messages")
	register_clcmd("say \nolag", "event_no_lag", 0, "- disables some flashing messages")
	register_clcmd("say nolag", "event_no_lag", 0, "- disables some flashing messages")
	
	register_logevent("event_start_round", 2, "1=Round_Start")
	register_logevent("event_end_round",2,"0=World triggered","1=Round_End")
	
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")  
	register_event("CurWeapon", "event_give_weapon", "be")
	register_event("DeathMsg", "event_death", "a")
	register_event("ResetHUD", "event_hud_reset", "b")
	
	register_dictionary("GeoCaching.txt")
	
	hudHideMsg = get_user_msgid("HideWeapon")
	register_message(hudHideMsg, "message_hud_hide")
	
	RegisterHam(Ham_Spawn, "player", "event_new_spawn", 1)  
	
	server_cmd("mp_freezetime 7")
	server_cmd("mp_limitteams 0")
	server_cmd("mp_autoteambalance 0")
	server_cmd("mp_friendlyfire 0")
	server_cmd("mp_flashlight 1")
	
	msgObjMain = CreateHudSyncObj();
	msgObjRTop = CreateHudSyncObj();
	msgObjLBottom = CreateHudSyncObj();
	msgObjRBottom = CreateHudSyncObj();
}

public plugin_precache() {
	precache_model("models/geo/box_big.mdl")
	copy(boxModelBig,32,"models/geo/box_big.mdl")
	
	precache_model("models/geo/box_medium.mdl")
	copy(boxModelMedium,32,"models/geo/box_medium.mdl")
	
	precache_model("models/geo/box_small.mdl")
	copy(boxModelSmall,32,"models/geo/box_small.mdl")
}

public cleanup() {
	new i;
	
	for (i = 0; i < boxEntityId; i++) {
		if(boxEntity[i] != -1 && is_valid_ent(boxEntity[i])) {
			remove_entity(boxEntity[i]);
		}
	}
	
	leftBoxesId = 0
	foundBoxesId = 0
	setBoxesId = 0
	takenBoxesId = 0
	timeLeftToPickupBoxId = 0
	boxEntityId = 0
	registredSpawnsId = 0
	registredRadarTimeId = 0
	registredGeoKeyTimeId = 0
	
	boxesSetCount = 0
	boxesTotalCount = 0
	boxesTakenCount = 0
	
	canSetBoxes = false
	rampageStarted = false
	freezeStarted = false
	roundStarted = false
	gameStarted = false
	
	new Players[32], numPlayers
	get_players(Players, numPlayers, "c")
	
	if(numPlayers > 1) {
		standbyStarted = false
	}
	
	
	if(task_exists(TASK_RELAY_START_SEARCHING)) {
		remove_task(TASK_RELAY_START_SEARCHING)
	}
	
	if(task_exists(TASK_SHOW_STATS)) {
		remove_task(TASK_SHOW_STATS)
	}
	
	if(task_exists(TASK_RELAY_END_GAME)) {
		remove_task(TASK_RELAY_END_GAME)
	}
	
	if(task_exists(TASK_ENSURE_SPAWN)) {
		remove_task(TASK_ENSURE_SPAWN)
	}
	
	if(task_exists(TASK_RELAY_RAMPAGE_SURVIVED)) {
		remove_task(TASK_RELAY_RAMPAGE_SURVIVED)
	}
	
	if(task_exists(TASK_SHOW_FREEZE_MESSAGE)) {
		remove_task(TASK_SHOW_FREEZE_MESSAGE)
	}
	
	if(task_exists(TASK_RADAR)) {
		remove_task(TASK_RADAR)
	}

	if(task_exists(TASK_SET_TEAMS)) {
		remove_task(TASK_SET_TEAMS)
	}
	
	if(task_exists(TASK_RESTRICT_RECURRING_GEO)) {
		remove_task(TASK_RESTRICT_RECURRING_GEO)
	}
	
	if(task_exists(TASK_COUNTDOWN_PICKUP_TIMES)) {
		remove_task(TASK_COUNTDOWN_PICKUP_TIMES)
	}
}

public event_new_round() {
	cleanup()
	
	freezeStarted = true;
	
	set_task(1.0,"task_ensure_spawn", TASK_ENSURE_SPAWN,"",0,"a",5);
	set_task(1.0,"task_show_freeze_message", TASK_SHOW_FREEZE_MESSAGE,"",0,"b");
	set_task(6.0,"task_set_teams", TASK_SET_TEAMS)
}

public event_new_spawn(id) {
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	
	new n
	new bool:foundPlayer = false;
	
	for(n = 0; n < registredSpawnsId; n++) {
		if(registredSpawns[n] == id) {
			foundPlayer = true;
		}
	}
	
	if(!foundPlayer) {
		set_user_on_spawn(id);
	}
	
	return PLUGIN_HANDLED
}

public task_ensure_spawn() {
	new id, i, n, Players[32], numPlayers
	new bool:foundPlayer
	
	get_players(Players, numPlayers, "ac")
	
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		foundPlayer = false;
		
		for(n = 0; n < registredSpawnsId; n++) {
			if(registredSpawns[n] == id) {
				foundPlayer = true;
			}
		}
		
		if(!foundPlayer) {
			set_user_on_spawn(id);
		}
	}
}

public event_hud_reset(id) {
	hideFlags = 0
	
	if(is_user_connected(id) && is_user_alive(id)) {
		if(!rampageStarted && cs_get_user_team(id) != rampageTeam) {
			hideFlags |= HUD_HIDE_CAL
		}
	
		hideFlags |= HUD_HIDE_RHA
		hideFlags |= HUD_HIDE_TIMER
		hideFlags |= HUD_HIDE_MONEY
		
		
		if(hideFlags)
		{
			message_begin(MSG_ONE, hudHideMsg, _, id)
			write_byte(hideFlags)
			message_end()
		}
	}
}

public message_hud_hide() {
	if(hideFlags)
		set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | hideFlags)
}

public set_user_on_spawn(id) {
	if(!is_user_alive(id)) return
		
	if(roundStarted) {
		user_silentkill(id)
		
		return
	}
		
	if(!continue_game(id)) return
	
	if(standbyStarted) return
	
	set_user_maxspeed(id, 0.1)
	set_user_rendering(id, kRenderNormal, 0, 0, 0, kRenderNormal)
	set_user_godmode(id, 1)
	
	entity_set_int(id, EV_INT_solid, 0)
	menu_cancel(id)
	
	new i
	new bool:foundPlayer = false
	
	for(i = 0; i < globalRankId; i++) {
		if(globalRank[0][i] == id) {
			new playerRank, n
			
			foundPlayer = true
			
			for(n = 0; n < topPlayersId; n++) {
				if(topPlayers[n] == id) {
					playerRank = n + 1
				}
			}
			
			set_user_frags(id, globalRankTemp[1][i] + globalRankTemp[2][i])
			cs_set_user_deaths(id, globalRankTemp[3][i] + globalRankTemp[4][i])
			
			client_print(id, print_chat, "[GEO] %L %L", id, "RANK_UPDATED", id, "RANKED_OUT_OF", playerRank, topPlayersId)
		}
	}
	
	if(!foundPlayer) {
		set_user_frags(id, 0)
		cs_set_user_deaths(id, 0)
			
		client_print(id, print_chat, "[GEO] %L", id, "INFO")
		client_print(id, print_chat, "[GEO] %L", id, "INFO_HELP")
	}
	
	registredSpawns[registredSpawnsId] = id;
	registredSpawnsId++;
	
	return
}

public task_show_idle_message(idleMessage[]) {
	if(gameStarted) return
	
	set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0);
	ShowSyncHudMsg(0, msgObjMain, idleMessage);
	
	return
}

public task_show_freeze_message() {
	if(!freezeStarted) return
	
	if(task_exists(TASK_SHOW_IDLE_MESSAGE)) {
		remove_task(TASK_SHOW_IDLE_MESSAGE)
	}
	
	new id, i, n, t, Players[32], numPlayers
	new bool:foundPlayer
	
	get_players(Players, numPlayers, "ac")
	
	set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0);
	
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		foundPlayer = false;
		
		for(t = 0; t < globalRankId; t++) {
			if(globalRank[0][t] == id) {
				foundPlayer = true
				
				new playerRank
				
				for(n = 0; n < topPlayersId; n++) {
					if(topPlayers[n] == id) {
						playerRank = n + 1
					}
				}
				
				set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjMain, "%L", id, "RANKED_OUT_OF", playerRank, topPlayersId);
				
				set_hudmessage(107, 142, 35, 0.05, 0.6, 0, 0.0, 1.0, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjLBottom, "%L^n%L", id, "RANKED_OUT_OF", playerRank, topPlayersId, id, "RANK_SCORE", globalRank[1][t], globalRank[4][t], globalRank[2][t], globalRank[3][t]);

				set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 1.0, 0.0, 0.0); 
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "INFO_HUD");

			}
		}
	
		if(!foundPlayer) {
			set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0);
			ShowSyncHudMsg(id, msgObjMain, "%L", id, "INFO");
			
			set_hudmessage(107, 142, 35, 0.05, 0.67, 0, 0.0, 1.0, 0.0, 0.0);
			ShowSyncHudMsg(id, msgObjLBottom, "%L", id, "INFO_HUD");
		}	
	}
	
	return
}

public event_show_help(id) {
	new szMotdName[128]
	formatex(szMotdName, 127, "%L", id, "MOTD_HEADER")
	show_motd(id, "addons/amxmodx/configs/geo.txt", szMotdName)
	
	return PLUGIN_HANDLED;
}

public event_no_lag(id) {
	new i, nolagToggledTempId, nolagToggledTemp[32]
	
	if(nolagToggledId != 0) {
		for(i = 0; i < nolagToggledId; i++) {
			if(nolagToggled[i] != -1 && is_user_connected(nolagToggled[i])) {
				nolagToggledTemp[nolagToggledTempId] = nolagToggled[i];
				nolagToggledTempId++
			}
		}
		
		nolagToggledId = 0
		
		for(i = 0; i < nolagToggledTempId; i++) {
			nolagToggled[nolagToggledId] = nolagToggledTemp[i]
			nolagToggledId++
		}
		
		new foundPlayer;
		
		for(i = 0; i < nolagToggledId; i++) {
			if(nolagToggled[i] == id) {
				nolagToggled[i] = -1;
				
				client_print(id, print_chat, "[GEO] %L", id, "NO_LAG_OFF")
				
				foundPlayer = true;
			}
		}
		
		if(!foundPlayer) {
			nolagToggled[nolagToggledId] = id;
			nolagToggledId++
			
			client_print(id, print_chat, "[GEO] %L", id, "NO_LAG_ON")
		}
	}
	else {
		nolagToggled[nolagToggledId] = id;
		nolagToggledId++
		
		client_print(id, print_chat, "[GEO] %L", id, "NO_LAG_ON")
	}
	
	return PLUGIN_HANDLED;
}

public continue_game(id) {
	new Players[32], numPlayers
	
	get_players(Players, numPlayers, "c")
	
	if(numPlayers <= 1) {
		standby_game()
		
		return 0;
	}
	else {
		if(standbyStarted) {
			server_cmd("sv_restartround 3")
		}
	}

	return 1;
}

public standby_game() {
	cleanup()
	
	standbyStarted = true
	
	if(task_exists(TASK_SHOW_IDLE_MESSAGE)) {
		remove_task(TASK_SHOW_IDLE_MESSAGE)
	}
	
	client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "NOT_ENOUGH_PLAYERS")
	
	new idleMsgToShow[128]
	formatex(idleMsgToShow, 127, "%L", LANG_PLAYER, "GET_MORE_PPL")
	set_task(1.0, "task_show_idle_message", TASK_SHOW_IDLE_MESSAGE, idleMsgToShow, strlen(idleMsgToShow), "b")

}

public task_set_teams() {
	new i, n, Players[32], PlayersT[32], PlayersCT[32], numPlayers, numPlayersT, numPlayersCT, nPT, nPCT
	
	get_players(Players, numPlayers, "ac")
	
	for(i = 0; i < numPlayers; i++) {
		new CsTeams:UserTeam = cs_get_user_team(Players[i])
		
		if(UserTeam == CS_TEAM_T) {
			nPT++
			PlayersT[numPlayersT] =  Players[i]
			numPlayersT++
		}
		else if(UserTeam == CS_TEAM_CT) {
			nPCT++
			PlayersCT[numPlayersCT] =  Players[i]
			numPlayersCT++
		}
	}
	
	if(numPlayers % 2 == 0) {
		if(nPT == nPCT) return
		
		while(nPT != nPCT) {
			n++
			
			if(nPT > nPCT) {
				cs_set_user_team(PlayersT[numPlayersT - n], CS_TEAM_CT)
				nPCT++
				nPT--
				client_print(PlayersT[numPlayersT - n], print_chat, "[GEO] %L", PlayersT[numPlayersT - n], "TRANSFERRED", CT)
			}
			else {
				cs_set_user_team(PlayersCT[numPlayersCT - n], CS_TEAM_T)
				nPT++
				nPCT--
				client_print(PlayersCT[numPlayersCT - n], print_chat, "[GEO] %L", PlayersCT[numPlayersCT - n], "TRANSFERRED", T)
			}
		}
	}
	else {
		if((nPT + 1 == nPCT) || (nPT - 1 == nPCT)) return
		
		while((nPT + 1 != nPCT) || (nPT - 1 != nPCT)) {
			n++
			
			if(nPT > nPCT) {
				cs_set_user_team(PlayersT[numPlayersT - n], CS_TEAM_CT)
				nPCT++
				nPT--
				client_print(PlayersT[numPlayersT - n], print_chat, "[GEO] %L", PlayersT[numPlayersT - n], "TRANSFERRED", CT)
			}
			else {
				cs_set_user_team(PlayersCT[numPlayersCT - n], CS_TEAM_T)
				nPT++
				nPCT--
				client_print(PlayersCT[numPlayersCT - n], print_chat, "[GEO] %L", PlayersCT[numPlayersCT - n], "TRANSFERRED", T)
			}
		}
	}
	
	return
}

public event_give_weapon(id) {
	new CsTeams:UserTeam = cs_get_user_team(id)
	
	server_cmd("sv_maxspeed 800")
	client_cmd(id, "cl_forwardspeed 800")
	client_cmd(id, "cl_backspeed 800")
	client_cmd(id, "cl_sidespeed 800")
	
	if(canSetBoxes) {
		if(UserTeam == CS_TEAM_T) {
			set_user_maxspeed(id, 800.0)
			} else if(UserTeam == CS_TEAM_CT) {
			set_user_maxspeed(id, 0.1)
		}
	}
	
	if(rampageStarted) {
		if(UserTeam == rampageTeam) {
			set_user_maxspeed(id, 800.0)
		}
	}
	
	return PLUGIN_HANDLED
}

public event_start_round() {
	freezeStarted = false;
	
	new id, i, Players[32], numPlayers, nPT, nPCT
	get_players(Players, numPlayers, "ac")
	
	for(i = 0; i < numPlayers; i++) {
		new CsTeams:UserTeam = cs_get_user_team(Players[i])
		
		if(UserTeam == CS_TEAM_T) nPT++
		if(UserTeam == CS_TEAM_CT) nPCT++
	}
	
	if(standbyStarted) return PLUGIN_HANDLED
	
	if(nPT == 0 || nPCT == 0) {
		standby_game()
		
		return PLUGIN_HANDLED
	}
	
	set_hudmessage(107, 142, 35, 0.05, 0.67, 0, 0.0, 60.0, 0.0, 0.0);
	ShowSyncHudMsg(0, msgObjLBottom, "%L", LANG_PLAYER, "INFO_HUD");
	
	roundStarted = true
	gameStarted = true
	
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		
		new CsTeams:UserTeam = cs_get_user_team(id)
		
		strip_user_weapons(id)
		give_item(id,"weapon_knife")
		
		set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 20.0, 0.0, 0.0); 
		
		if(UserTeam == CS_TEAM_T) {
			ShowSyncHudMsg(id, msgObjRTop, "%L", id, "YOUR_TASK");
			
			client_print(id, print_chat, "[GEO] %L", id, "YOUR_TASK")
			
			leftBoxes[0][leftBoxesId] = id
			leftBoxes[1][leftBoxesId] = 3
			leftBoxesId++
			boxesTotalCount = boxesTotalCount + 3
			
			setBoxes[0][setBoxesId] = id
			setBoxes[1][setBoxesId] = 0
			setBoxesId++
			
			timeLeftToPickupBox[0][timeLeftToPickupBoxId] = id
			timeLeftToPickupBox[1][timeLeftToPickupBoxId] = pickupBoxTime
			
			timeLeftToPickupBoxId++
			
			set_user_rendering(id, kRenderFxPulseSlowWide, 0, 0, 0, kRenderTransAlpha, 0)
			set_user_footsteps(id, 1);
		}
		else if(UserTeam == CS_TEAM_CT) {
			ShowSyncHudMsg(id, msgObjRTop, "%L", id, "PLEASE_WAIT");
			
			client_print(id, print_chat, "[GEO] %L", id, "PLEASE_WAIT")
		}
	}
	
	
	canSetBoxes = true
	set_task(1.0, "task_show_stats", TASK_SHOW_STATS, "", 0, "b")
	
	timePassed = 0.0;
	set_task(1.0, "task_relay_start_searching", TASK_RELAY_START_SEARCHING, "", 0, "b")
	
	return PLUGIN_HANDLED
}

public event_death() {
	new attacker, victim
	attacker = read_data(1)
	victim = read_data(2)
	
	if(attacker == victim) return
	
	if(rampageStarted || !gameStarted || cs_get_user_team(victim) == CS_TEAM_CT) {
		return
	}
	
	new i, t
	
	for(i = 0; i < takenBoxesId; i++) {
		if(takenBoxes[0][i] == victim) {
			if(takenBoxes[1][i] == 0) {
				return
			}
			
			takenBoxes[1][i]--
			boxesTakenCount--
		}
	}
	
	for(t = 0; t < setBoxesId; t++) {
		if(setBoxes[0][t] == victim && setBoxes[1][t] > 0) {
			setBoxes[1][t]--
		}
	}
	
	for(i = 0; i < foundBoxesId; i++) {
		if(foundBoxes[0][i] == attacker) {
			foundBoxes[1][i]++			
		}
	}
	
	boxesSetCount--
	
	new  Players[32], numPlayers, nPT
	get_players(Players, numPlayers, "ac")
	
	for(i = 0; i < numPlayers; i++) {
		new CsTeams:UserTeam = cs_get_user_team(Players[i])
		
		if(UserTeam == CS_TEAM_T) nPT++
	}
		
	set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 10.0, 0.0, 0.0);
	ShowSyncHudMsg(victim, msgObjMain, "%L", victim, "FAILED")	
	
	set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0); 
	ShowSyncHudMsg(attacker, msgObjRTop, "%L", attacker, "KILLED_CARRIER")			
	
	client_print(victim, print_chat, "[GEO] %L", victim, "FAILED")
	client_print(attacker, print_chat, "[GEO] %L", attacker, "KILLED_CARRIER")
	
	if(boxesSetCount == 0 || nPT == 0) {
		end_game()
	}
	
	return
}

public task_relay_start_searching() {
	/*
	This whole thing below is awfully coded, originally it was not meant to contain even half of the features implemented,
	so the basic algorithm for other similar relay's doesn't work here well at all. I'm way too tired with this plugin to fix this,
	if someone has the time	please do send me a better version, if you can make one or have the time. :)
	
	Right now it works, and that's all that matters. ;)
	*/
	
	timePassed = timePassed + 1.0;
	
	new id, i, Players[32], numPlayers
	new Float:penalty;
	
	get_players(Players, numPlayers, "ac")
	
	if(huntedInRampageCount != 0 && survivedRampageCount != 0) {
		penalty = (boxSetDiffBaseTime + (boxSetDiffPlayerAddTime * float(huntedInRampageCount))) * (float(survivedRampageCount) / float(huntedInRampageCount));
	}
	else if (huntedInRampageCount != 0 && survivedRampageCount == 0 && rampageTeamSet == true && (rampageTeam == CS_TEAM_CT || rampageTeam == CS_TEAM_T)) {
		penalty = boxSetDiffBaseTime;
	}
	else {
		penalty = 0.0;
	}
		
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 1.0, 0.0, 0.0); 
			
		new CsTeams:UserTeam = cs_get_user_team(id)
		if(UserTeam == CS_TEAM_T) {
			new n
			new bool:foundPlayer;
			
			foundPlayer = false;
			
			for (n = 0; n < nolagToggledId; n++) {
				if(nolagToggled[n] == id && nolagToggled[n] != -1) {
					foundPlayer = true;
				}
			}
			
			if(foundPlayer && timePassed == 1.0) {
				if((rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
					set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, boxSetBaseTime - penalty - 1.0, 0.0, 0.0); 
					ShowSyncHudMsg(id, msgObjRTop, "[NOLAG]%L (-%.2f %L)", id, "YOUR_TASK_NOW", (boxSetBaseTime - penalty) - timePassed, penalty, id, "SEC");
				} else if((rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
					set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, boxSetBaseTime + penalty - 1.0, 0.0, 0.0); 
					ShowSyncHudMsg(id, msgObjRTop, "[NOLAG]%L (+%.2f %L)", id, "YOUR_TASK_NOW", (boxSetBaseTime + penalty) - timePassed, penalty, id, "SEC");
				} else {
					set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, boxSetBaseTime - 1.0, 0.0, 0.0); 
					ShowSyncHudMsg(id, msgObjRTop, "[NOLAG]%L (+-0.00 %L)", id, "YOUR_TASK_NOW", boxSetBaseTime - timePassed, id, "SEC");
				}
			}
			else if (foundPlayer == false) {
				if((rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
					ShowSyncHudMsg(id, msgObjRTop, "%L (-%.2f %L)", id, "YOUR_TASK_NOW", (boxSetBaseTime - penalty) - timePassed, penalty, id, "SEC");
				} else if((rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
					ShowSyncHudMsg(id, msgObjRTop, "%L (+%.2f %L)", id, "YOUR_TASK_NOW", (boxSetBaseTime + penalty) - timePassed, penalty, id, "SEC");
				} else {
					ShowSyncHudMsg(id, msgObjRTop, "%L (+-0.00 %L)", id, "YOUR_TASK_NOW", boxSetBaseTime - timePassed, id, "SEC");
				}
			}
		} else if(UserTeam == CS_TEAM_CT) {
			if((rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
				ShowSyncHudMsg(id, msgObjRTop, "%L (-%.2f %L)", id, "PLEASE_WAIT_WHILE", (boxSetBaseTime - penalty) - timePassed, penalty, id, "SEC");
			} else if((rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
				ShowSyncHudMsg(id, msgObjRTop, "%L (+%.2f %L)", id, "PLEASE_WAIT_WHILE", (boxSetBaseTime + penalty) - timePassed, penalty, id, "SEC");
			} else {
				ShowSyncHudMsg(id, msgObjRTop, "%L (+-0.00 %L)", id, "PLEASE_WAIT_WHILE", boxSetBaseTime - timePassed, id, "SEC");
			}
		}
	}

	if((rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
		if(timePassed >= boxSetBaseTime - penalty) {
			huntedInRampageCount = 0
			survivedRampageCount = 0
			rampageTeamSet = false
			start_searching();
		}
	}  else if((rampageTeam == CS_TEAM_CT && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount != 0) || (rampageTeam == CS_TEAM_T && penalty != 0.0 && huntedInRampageCount != 0 && survivedRampageCount == 0)) {
		if(timePassed >= boxSetBaseTime + penalty) {
			huntedInRampageCount = 0
			survivedRampageCount = 0
			rampageTeamSet = false
			start_searching();
		}
	} else {
		if(timePassed >= boxSetBaseTime) {
			huntedInRampageCount = 0
			survivedRampageCount = 0
			rampageTeamSet = false
			start_searching();
		}
	}
}

public start_searching() {
	if(task_exists(TASK_RELAY_START_SEARCHING)) {
		remove_task(TASK_RELAY_START_SEARCHING)
	}
	
	new id, i, Players[32], numPlayers

	get_players(Players, numPlayers, "c")
	
	boxesTotalCount = boxesSetCount
	
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		
		if(is_user_alive(id)) {
			new CsTeams:UserTeam = cs_get_user_team(id)
			
			set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 60.0, 0.0, 0.0); 
			
			if(UserTeam == CS_TEAM_T) {
				set_user_maxspeed(id, 0.1)
				
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "TIME_FASTER")
				
				client_print(id, print_chat, "[GEO] %L", id, "TIME_FASTER")
				
				set_user_maxspeed(id, 320.0)
				set_user_rendering(id, kRenderNormal, 0, 0, 0, kRenderNormal)
				set_user_footsteps(id, 0)
				
				menu_cancel(id)

				
				takenBoxes[0][takenBoxesId] = id
				takenBoxes[1][takenBoxesId] = 0
				takenBoxesId++
			}
			else if(UserTeam == CS_TEAM_CT) {
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "GO_AND_FIND")
				
				client_print(id, print_chat, "[GEO] %L %L", id, "GO_AND_FIND", id, "RADAR_WILL")
				
				set_user_maxspeed(id, 320.0)
				
				foundBoxes[0][foundBoxesId] = id
				foundBoxes[1][foundBoxesId] = 0
				foundBoxesId++			
			}
		}
	}
	
	if(boxesSetCount == 0) {
		end_game()
		
		return
	}
	
	roundsNoBoxesSetTempId = 0;
	
	new n, t
	new bool:foundPlayer
						 
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
				
		new CsTeams:UserTeam = cs_get_user_team(id)
		
		if(is_user_alive(id) && UserTeam == CS_TEAM_T) {
			for(n = 0; n < setBoxesId; n++) {
				if(setBoxes[0][n] == id && setBoxes[1][n] == 0) {
					for(t = 0; t < roundsNoBoxesSetId; t++) {					
						if(roundsNoBoxesSet[0][t] == id) {
							roundsNoBoxesSetTemp[0][roundsNoBoxesSetTempId] = id;
							roundsNoBoxesSetTemp[1][roundsNoBoxesSetTempId] = roundsNoBoxesSet[1][t] + 1;
										
							foundPlayer = true;
																					
							roundsNoBoxesSetTempId++
						}										
					}
					if(!foundPlayer) {								
						roundsNoBoxesSetTemp[0][roundsNoBoxesSetTempId] = id
						roundsNoBoxesSetTemp[1][roundsNoBoxesSetTempId] = 1
											
						roundsNoBoxesSetTempId++
					}

				}
			}
		}
	}

	
	roundsNoBoxesSetId = 0;
	
	for(i = 0; i < roundsNoBoxesSetTempId; i++) {
		roundsNoBoxesSet[0][roundsNoBoxesSetId] = roundsNoBoxesSetTemp[0][i]
		roundsNoBoxesSet[1][roundsNoBoxesSetId] = roundsNoBoxesSetTemp[1][i]
		 
		 
		id = roundsNoBoxesSet[0][roundsNoBoxesSetId]
		
		if(roundsNoBoxesSetTemp[1][i] >= roundsInRowMustSetBoxes) {
			if(is_user_alive(id)) {
				user_silentkill(id)
			}
			
			set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 60.0, 0.0, 0.0);
			ShowSyncHudMsg(id, msgObjMain, "%L %L^n%L", id, "NOT_SET_BOXES_IN_ROW", roundsNoBoxesSetTemp[1][i], id, "READ_HELP", id, "INFO_HELP")		
		}
		
		client_print(id, print_chat, "[GEO] %L %L %L", id, "NOT_SET_BOXES_IN_ROW", roundsNoBoxesSetTemp[1][i], id, "READ_HELP", id, "INFO_HELP")
		 
		roundsNoBoxesSetId++
	}
	
	new rPlayers[32], numrPlayers
	
	get_players(rPlayers, numrPlayers, "c")
	
	if(numrPlayers <= 1) {
		server_cmd("sv_restartround 3")
		return
	}
	
	canSetBoxes = false
	
	timePassed = 0.0;
	set_task(1.0, "task_radar", TASK_RADAR, "", 0, "b")
	
	set_task(1.0, "task_relay_end_game", TASK_RELAY_END_GAME, "", 0, "b")
	
	set_task(1.0, "task_restrict_recurring_geo", TASK_RESTRICT_RECURRING_GEO, "", 0, "b")
	
	set_task(1.0, "task_countdown_pickup_times", TASK_COUNTDOWN_PICKUP_TIMES, "", 0, "b")
}

public task_show_stats() {
	if(!gameStarted) return
	
	new id, i, Players[32], numPlayers
	
	get_players(Players, numPlayers, "ac")
	
	set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0);
	
	if(canSetBoxes) {
		for(i = 0; i < numPlayers; i++) {
			id = Players[i]
			
			new CsTeams:UserTeam = cs_get_user_team(id)
			
			if(UserTeam == CS_TEAM_T) {
				new n
				
				for(n = 0; n < leftBoxesId; n++) {
					if(leftBoxes[0][n] == id) {
						ShowSyncHudMsg(id, msgObjMain, "%L", id, "X_REMAINING", leftBoxes[1][n]);
					}
				}			
			}
			else if(UserTeam == CS_TEAM_CT) {
				ShowSyncHudMsg(id, msgObjMain, "%L", id, "X_OF_X_REMAINING", boxesSetCount, boxesTotalCount);
			}
		}
	}
	else {
		for(i = 0; i < numPlayers; i++) {
			id = Players[i]
			
			new CsTeams:UserTeam = cs_get_user_team(id)
			
			if(UserTeam == CS_TEAM_T) {
				new n
				
				for(n = 0; n < setBoxesId; n++) {
					if(setBoxes[0][n] == id) {
						new t
						
						for(t = 0; t < takenBoxesId; t++) {
							if(takenBoxes[0][t] == id && takenBoxes[1][t] == 0) {
								new rPlayers[32], numrPlayers, g, nT
								
								get_players(rPlayers, numrPlayers, "c")
								
								for(g = 0; g < numrPlayers; g++) {
									if(cs_get_user_team(rPlayers[g]) == CS_TEAM_T) nT++;
								}
								
								if(nT == 1) {
									ShowSyncHudMsg(id, msgObjMain, "%L^n%L", id, "BOX_INFO_HUD", setBoxes[1][n], boxesSetCount, boxesTotalCount, id, "LAST_ONE");
								}
								else {
									new e
									
									for(e = 0; e < timeLeftToPickupBoxId; e++) {
										if(timeLeftToPickupBox[0][e] == id) {
											ShowSyncHudMsg(id, msgObjMain, "%L^n%L %L", id, "BOX_INFO_HUD", setBoxes[1][n], boxesSetCount, boxesTotalCount, id, "NOT_CARRYING", timeLeftToPickupBox[1][e], id, "SEC");
										}
									}
								}
							}
							else if(takenBoxes[0][t] == id && takenBoxes[1][t] != 0){
								ShowSyncHudMsg(id, msgObjMain, "%L^n%L", id, "BOX_INFO_HUD", setBoxes[1][n], boxesSetCount, boxesTotalCount, id, "CARRYING");
							}
						}
					}
				}
			}
			else if(UserTeam == CS_TEAM_CT) {
				new n
				
				for(n = 0; n < foundBoxesId; n++) {
					if(foundBoxes[0][n] == id) {
						ShowSyncHudMsg(id, msgObjMain, "%L", id, "MAIN_HUD", foundBoxes[1][n], boxesSetCount, boxesTotalCount, boxesTakenCount);
					}
				}				
			}
		}
	}
}

public event_geo(id) {
	if(!is_user_alive(id) || !gameStarted) return PLUGIN_HANDLED
	
	new i
	new CsTeams:UserTeam = cs_get_user_team(id)
	
	if(UserTeam == CS_TEAM_T && leftBoxesId > 0 && canSetBoxes) {
		for(i = 0; i < leftBoxesId; i++) {
			if(leftBoxes[0][i] == id && leftBoxes[1][i] != 0) {
				new szMenuName[128]
				formatex(szMenuName, 127, "%L^n", id, "MENU_HEADER")
				show_menu(id, mBoxSizeKeys, szMenuName, -1, "mBoxSize")
								
				return PLUGIN_HANDLED
			}
			else {
				set_hudmessage(107, 142, 35, 0.7, 0.55, 0, 0.0, 2.0, 0.0, 0.0); 
				ShowSyncHudMsg(id, msgObjRBottom, "%L", id, "NO_BOXES");
				
				client_print(id, print_chat, "[GEO] %L", id, "NO_BOXES")	
			}
		}
	}
	else if(UserTeam == CS_TEAM_T && !canSetBoxes) {
		for(i = 0; i < takenBoxesId; i++) {
			if(takenBoxes[0][i] == id) {
				if(takenBoxes[1][i] == 0) {
					remove_box(id)
					
					return PLUGIN_HANDLED
				}
				else if(takenBoxes[1][i] == 1){
					new szMenuName[128]
					formatex(szMenuName, 127, "%L^n", id, "MENU_HEADER")
					show_menu(id, mBoxSizeKeys, szMenuName, -1, "mBoxSize")
										
					return PLUGIN_HANDLED
				}
				else {
					set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0); 
					ShowSyncHudMsg(id, msgObjRTop, "%L", id, "ALREADY_BOX")
					
					client_print(id, print_chat, "[GEO] %L", id, "ALREADY_BOX")
				}
			}
		}
	}
	else if(UserTeam == CS_TEAM_CT && !canSetBoxes) {
		for(i = 0; i < foundBoxesId; i++) {
			if(foundBoxes[0][i] == id) {
				new n
				new bool:foundPlayer
				
				for(n = 0; n < registredGeoKeyTimeId; n++) {
					if(registredGeoKeyTime[0][n] == id) {
						foundPlayer = true;
						
						if(registredGeoKeyTime[1][n] == 0) {
							remove_box(id)
							registredGeoKeyTime[1][n] = 2;
						}
						else {
							set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0);
							ShowSyncHudMsg(id, msgObjRTop, "%L", id, "TOO_OFTEN")
					
							client_print(id, print_chat, "[GEO] %L", id, "TOO_OFTEN")
						}
					}
				}
				
				if(!foundPlayer) {
					registredGeoKeyTime[0][registredGeoKeyTimeId] = id
					remove_box(id)
					registredGeoKeyTime[1][registredGeoKeyTimeId] = 2
					registredGeoKeyTimeId++
				}
				
				return PLUGIN_HANDLED
			}
		}	
	}
	
	return PLUGIN_HANDLED
}

public task_countdown_pickup_times() {
	if(canSetBoxes || !gameStarted) return
	
	new i, id
	
	for(i = 0; i < timeLeftToPickupBoxId; i++) {
		if(timeLeftToPickupBox[1][i] > 0) {
			timeLeftToPickupBox[1][i]--
		}
		else if(timeLeftToPickupBox[1][i] == 0){
			id = timeLeftToPickupBox[0][i]
			
			new rPlayers[32], numrPlayers, g, nT
								
			get_players(rPlayers, numrPlayers, "c")
								
			for(g = 0; g < numrPlayers; g++) {
					if(cs_get_user_team(rPlayers[g]) == CS_TEAM_T) nT++;
			}
			
			if(nT > 1) {
				if(is_user_alive(id)) {
					user_silentkill(id)
				}
				
				set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjRTop, "%L %L^n%L", id, "DID_NOT_PICK_UP", id, "READ_HELP", id, "INFO_HELP")
						
				client_print(id, print_chat, "[GEO] %L %L %L", id, "DID_NOT_PICK_UP", id, "READ_HELP", id, "INFO_HELP")
			}
		}
	}
}

public task_restrict_recurring_geo() {
	if(canSetBoxes || !gameStarted) return
	
	new i
	
	for(i = 0; i < registredGeoKeyTimeId; i++) {
		if(registredGeoKeyTime[1][i] != 0) {
			registredGeoKeyTime[1][i]--
		}
	}
}

public event_mBoxSize_pressed(id, key) {
	switch (key) {
		case 0: {
			create_box(id, 2)
		}
		case 1: {
			create_box(id, 1)
		}
		case 2: {
			create_box(id, 0)
		}
	}
}

public create_box(id, boxSize) {
	if(!gameStarted || !is_user_alive(id)) return
	
	new i
	
	if(canSetBoxes) {
		for(i = 0; i < setBoxesId; i++) {
			if(setBoxes[0][i] == id) {
				setBoxes[1][i]++
			}
		}

		for(i = 0; i < leftBoxesId; i++) {
			if(leftBoxes[0][i] == id) {
				leftBoxes[1][i]--
				boxesSetCount++
				
				if(boxesSetCount == boxesTotalCount) {
					remove_task(TASK_RELAY_START_SEARCHING)
					
					set_task(1.5, "start_searching", TASK_RELAY_START_SEARCHING)
				}
			}
		}
	}
	else {
		for(i = 0; i < takenBoxesId; i++) {
			if(takenBoxes[0][i] == id) {
				if(takenBoxes[1][i] == 1) {
					set_user_rendering(id, kRenderFxGlowShell,0,0,0,kRenderNormal,25) 
					set_user_godmode(id, 1)
					
					entity_set_int(id, EV_INT_solid, 0)
					
					takenBoxes[1][i]--
					boxesTakenCount--
					
					for(i = 0; i < timeLeftToPickupBoxId; i++) {
						if(timeLeftToPickupBox[0][i] == id) {
							timeLeftToPickupBox[1][i] = pickupBoxTime + pickupBoxBaseAddTime;
						}
					}
				}
				else {
					return
				}
			}
		}
	}
	
	
	boxEntity[boxEntityId] = create_entity("info_target")
	
	if (boxEntity[boxEntityId] == 0) return
	
	new boxName[] = "Box_"
	new playerId[3]
	new Float:renderAmount
	new Float:PlayerOrigin[3]
	new Float:Color[3] = {0.0, 0.0, 0.0}
	
	num_to_str(id, playerId, 3)
	strcat(boxName, playerId, 8)
	
	entity_set_string(boxEntity[boxEntityId], EV_SZ_classname, boxName)
	
	if(canSetBoxes) {
		set_hudmessage(107, 142, 35, 0.7, 0.55, 0, 0.0, 2.0, 0.0, 0.0);
	}
	else {
		set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0);
	}
	
	switch (boxSize) {
		case 2: {
			entity_set_model(boxEntity[boxEntityId], boxModelBig)
			
			renderAmount = 80.0
			
			if(canSetBoxes) {
				ShowSyncHudMsg(id, msgObjRBottom, "%L", id, "BIG_BOX")
			}
			else {
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "BIG_BOX")
			}
			
			client_print(id, print_chat, "[GEO] %L", id, "BIG_BOX")
		}
		case 1: {
			entity_set_model(boxEntity[boxEntityId], boxModelMedium)
			
			renderAmount = 120.0
			
			if(canSetBoxes) {
				ShowSyncHudMsg(id, msgObjRBottom, "%L", id, "MEDIUM_BOX")
			}
			else {
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "MEDIUM_BOX")
			}
			
			client_print(id, print_chat, "[GEO] %L", id, "MEDIUM_BOX")
		}
		case 0: {
			entity_set_model(boxEntity[boxEntityId], boxModelSmall)
			
			renderAmount = 255.0
			
			if(canSetBoxes) {
				ShowSyncHudMsg(id, msgObjRBottom, "%L", id, "SMALL_BOX")
			}
			else {
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "SMALL_BOX")
			}
			
			client_print(id, print_chat, "[GEO] %L", id, "SMALL_BOX")
		}
	}
	
	entity_set_int(boxEntity[boxEntityId], EV_INT_solid, 0)
	entity_set_int(boxEntity[boxEntityId], EV_INT_movetype, 6)
	entity_set_int(boxEntity[boxEntityId], EV_INT_rendermode, kRenderTransAlpha)
	
	entity_get_vector(id, EV_VEC_origin, PlayerOrigin)
	entity_set_vector(id,EV_VEC_rendercolor, Color)
	
	entity_set_origin(boxEntity[boxEntityId], PlayerOrigin)
	
	entity_set_edict(boxEntity[boxEntityId], EV_ENT_owner, id)
	
	entity_set_float(boxEntity[boxEntityId], EV_FL_renderamt, renderAmount)
	
	boxEntityId++
	
	return
}

public remove_box(id) {
	new n, foundBoxN, foundBox
	
	foundBox  = -1
	
	for (n = 0; n < boxEntityId; n++) {
		if(boxEntity[n] != -1 && is_valid_ent(boxEntity[n]) && get_entity_distance(id, boxEntity[n]) < boxFindDistance) {
			foundBox = boxEntity[n];
			foundBoxN = n;
		}
	}
	
	set_hudmessage(107, 142, 35, 0.7, -1.0, 0, 0.0, 2.0, 0.0, 0.0); 
	
	if(foundBox != -1) {
		new i
		if(cs_get_user_team(id) == CS_TEAM_CT) {
			new t, boxOwnerId
			
			boxOwnerId = entity_get_edict(foundBox, EV_ENT_owner)
			
			ShowSyncHudMsg(id, msgObjRTop, "%L", id, "BOX_FOUND")
			
			client_print(id, print_chat, "[GEO] %L", id, "BOX_FOUND")
			
			for(t = 0; t < setBoxesId; t++) {
				if(setBoxes[0][t] == boxOwnerId && setBoxes[1][t] > 0) {
					setBoxes[1][t]--
				}
			}
			
			remove_entity(foundBox)
			
			boxEntity[foundBoxN] = -1
			
			for(i = 0; i < foundBoxesId; i++) {
				if(foundBoxes[0][i] == id) {
					foundBoxes[1][i]++
				}
			}
			
			new userFrags;
			
			userFrags = get_user_frags(id);
			
			set_user_frags(id, userFrags + 1);
			
			message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
			write_byte(id);
			write_short(get_user_frags(id));
			write_short(cs_get_user_deaths(id));
			write_short(0);
			write_short(1);
			message_end();
			
			boxesSetCount--
			
			if(boxesSetCount == 0) {
				end_game()
			}
		}
		else if(cs_get_user_team(id) == CS_TEAM_T) {
			if(entity_get_edict(foundBox, EV_ENT_owner) == id) {
				set_user_rendering(id, kRenderFxGlowShell,255,0,0,kRenderNormal,25)
				set_user_godmode(id)
				
				entity_set_int(id, EV_INT_solid, SOLID_BBOX)
				
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "BOX_PICKED_UP")
				
				client_print(id, print_chat, "[GEO] %L", id, "BOX_PICKED_UP")
				
				remove_entity(foundBox)
				
				boxEntity[foundBoxN] = -1
				
				for(i = 0; i < takenBoxesId; i++) {
					if(takenBoxes[0][i] == id) {
						takenBoxes[1][i]++
						boxesTakenCount++
					}
				}
				
				for(i = 0; i < timeLeftToPickupBoxId; i++) {
					if(timeLeftToPickupBox[0][i] == id) {
						timeLeftToPickupBox[1][i] = -1;
					}
				}
			}
			else {
				ShowSyncHudMsg(id, msgObjRTop, "%L", id, "NOT_YOURS");
				
				client_print(id, print_chat, "[GEO] %L", id, "NOT_YOURS")
			}
		}
	}
	else {
		ShowSyncHudMsg(id, msgObjRTop, "%L", id, "NO_BOX_FOUND");
		
		client_print(id, print_chat, "[GEO] %L", id, "NO_BOX_FOUND")
	}
}

public task_relay_end_game() {
	new id, i, Players[32], numPlayers, nPT, nPCT
	
	get_players(Players, numPlayers, "ac")
	
	for(i = 0; i < numPlayers; i++) {
		new CsTeams:UserTeam = cs_get_user_team(Players[i])
		if(UserTeam == CS_TEAM_T) nPT++
		if(UserTeam == CS_TEAM_CT) nPCT++
	}
	
	new Float:addTime;
	
	addTime = ((gameDiffBaseTime + (float(nPT) * gameDiffPlayerAddTime)) * float(boxesTakenCount))  / float(nPT);
	
	timePassed = timePassed + 1.0 + addTime;
	
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		
		new CsTeams:UserTeam = cs_get_user_team(id)
		
		set_hudmessage(107, 142, 35, 0.05, 0.7, 0, 0.0, 1.0, 0.0, 0.0);
		
		new n
		new bool:foundPlayer;
			
		foundPlayer = false;
			
		for (n = 0; n < nolagToggledId; n++) {
			if(nolagToggled[n] == id && nolagToggled[n] != -1) {
				foundPlayer = true;
			}
		}
		
		if(UserTeam == CS_TEAM_T) {
			if(!foundPlayer) {
				ShowSyncHudMsg(id, msgObjLBottom, "%L", id, "TIME_REMAINING_VICTORY", gameTime - timePassed, addTime, boxesTakenCount, nPT);
			}
			else if(foundPlayer == true && timePassed == 1.0 + addTime) {
				set_hudmessage(107, 142, 35, 0.05, 0.7, 0, 0.0, gameTime - 1.0, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjLBottom, "[NOLAG] %L", id, "TIME_REMAINING_VICTORY_LIMITED", gameTime - timePassed);
			}
		}
		else if(UserTeam == CS_TEAM_CT) {
			if(!foundPlayer) {
				ShowSyncHudMsg(id, msgObjLBottom, "%L", id, "TIME_REMAINING_VICTORY", gameTime - timePassed, addTime, boxesTakenCount, nPT);
			}
			else if(foundPlayer == true && timePassed == 1.0 + addTime) {
				set_hudmessage(107, 142, 35, 0.05, 0.7, 0, 0.0, gameTime - 1.0, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjLBottom, "[NOLAG] %L", id, "TIME_REMAINING_VICTORY_LIMITED", gameTime - timePassed);
			}
		}
	}
	
	if(timePassed >= gameTime) {
		end_game();
	}
}

public task_radar() {
	if(!gameStarted) return
	
	new id, i, n, t, e, g, Players[32], numPlayers, foundBox, foundPlayerT, foundPlayerE
	new bool:foundPlayer 
	new bool:foundPlayerNoLag;
	
	get_players(Players, numPlayers, "ac")
			
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
				
		foundPlayerNoLag = false;
		
		for (g = 0; g < nolagToggledId; g++) {
			if(nolagToggled[g] == id && nolagToggled[g] != -1) {
				foundPlayerNoLag = true;
			}
		}
		
		set_hudmessage(107, 142, 35, 0.7, 0.55, 0, 0.0, 1.0, 0.0, 0.0);
		
		new CsTeams:UserTeam = cs_get_user_team(id)
				
		if(UserTeam == CS_TEAM_CT) {
			if(foundPlayerNoLag == true && timePassed == 0.0) {
				set_hudmessage(107, 142, 35, 0.7, 0.55, 0, 0.0, gameTime, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjRBottom, "[NOLAG] %L %L", id, "RADAR", id, "RADAR_BLINK");
			}
			
			foundPlayer = false;
			
			for(e = 0; e < registredRadarTimeId; e++) {
				if(registredRadarTime[0][e] == id) {
					foundPlayer = true;
					foundPlayerE = e;
				}
			}
			
			if(foundPlayer) {
				if(registredRadarTime[1][foundPlayerE] != 0) {
					registredRadarTime[1][foundPlayerE]--;
				}
			}
			
			foundBox = -1;
			
			for (n = 0; n < boxEntityId; n++) {
				if(boxEntity[n] != -1 && is_valid_ent(boxEntity[n]) && get_entity_distance(id, boxEntity[n]) < radarFindDistance) {
					foundBox = boxEntity[n];
				}
			}
			
			if(foundBox == -1) {
					if(foundPlayer) {
						if(registredRadarTime[1][foundPlayerE] != 0) {
							if(!foundPlayerNoLag) {
								ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR", id, "ALREADY_BLINKED");
							}
						}
						else {
							if(!foundPlayerNoLag) {
								ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR", id, "BLINK_ONCE");
							}
						}
					}
					else {
						if(!foundPlayerNoLag) {
							ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR", id, "BLINK_ONCE");
						}
					}
			}
			else {
				foundPlayer = false;
				
				for(t = 0; t < registredRadarTimeId; t++) {
					if(registredRadarTime[0][t] == id) {
						foundPlayer = true;
						foundPlayerT = t;
					}
				}
				
				if(!foundPlayer) {
					set_hudmessage(255, 0, 0, 0.7, 0.55, 1, 0.0, 0.4, 0.0, 0.0);
					ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR_DETECTS", id, "BOXES_NEAR");
					
					registredRadarTime[0][registredRadarTimeId] = id;
					registredRadarTime[1][registredRadarTimeId] = 10;
					registredRadarTimeId++
				}
				else {
					if(registredRadarTime[1][foundPlayerT] == 0) {
						set_hudmessage(255, 0, 0, 0.7, 0.55, 1, 0.0, 0.4, 0.0, 0.0);
						ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR_DETECTS", id, "BOXES_NEAR");
						
						registredRadarTime[1][foundPlayerT] = 10;
					}
					else {
						if(!foundPlayerNoLag) {
							ShowSyncHudMsg(id, msgObjRBottom, "%L %L", id, "RADAR", id, "ALREADY_BLINKED");
						}
					}
				}
			}
		}
	}
}

public end_game() {
	if(task_exists(TASK_RELAY_END_GAME)) {
		remove_task(TASK_RELAY_END_GAME)
	}
	
	if(task_exists(TASK_RESTRICT_RECURRING_GEO)) {
		remove_task(TASK_RESTRICT_RECURRING_GEO)
	}
	
	if(task_exists(TASK_COUNTDOWN_PICKUP_TIMES)) {
		remove_task(TASK_COUNTDOWN_PICKUP_TIMES)
	}
	
	gameStarted = false;
	
	new rPlayers[32], numrPlayers
	
	get_players(rPlayers, numrPlayers, "c")
	
	if(numrPlayers <= 1) {
		server_cmd("sv_restartround 3")
		return
	}
	
	globalRankTempId = 0
	
	new i, n, id, Players[32], numPlayers
	
	get_players(Players, numPlayers, "c")
	
	if(globalRankId == 0) {
		for(i = 0; i < numPlayers; i++) {
			id = Players[i]
			
			new CsTeams:UserTeam = cs_get_user_team(id)
			
			globalRankTemp[0][globalRankTempId] = id
			
			globalRankTemp[1][globalRankTempId] = 0
			globalRankTemp[2][globalRankTempId] = 0
			globalRankTemp[5][globalRankTempId] = 0
			
			if(UserTeam == CS_TEAM_T) {
				globalRankTemp[3][globalRankTempId] = 1
				globalRankTemp[4][globalRankTempId] = 0
			}
			else if(UserTeam == CS_TEAM_CT) {
				globalRankTemp[3][globalRankTempId] = 0
				globalRankTemp[4][globalRankTempId] = 1
			}
			
			globalRankTempId++
		}
	}
	else {
		for(i = 0; i < globalRankId; i++) {
			id = globalRank[0][i]	
			
			if(is_user_connected(id)) {
				new CsTeams:UserTeam = cs_get_user_team(id)
				
				globalRankTemp[0][globalRankTempId] = id
				globalRankTemp[1][globalRankTempId] = globalRank[1][i]
				globalRankTemp[2][globalRankTempId] = globalRank[2][i]
				globalRankTemp[5][globalRankTempId] = 0
				
				if(UserTeam == CS_TEAM_T) {
					globalRankTemp[3][globalRankTempId] = globalRank[3][i] + 1
					globalRankTemp[4][globalRankTempId] = globalRank[4][i]
				}
				else if(UserTeam == CS_TEAM_CT) {
					
					globalRankTemp[3][globalRankTempId] = globalRank[3][i]
					globalRankTemp[4][globalRankTempId] = globalRank[4][i] + 1
				}
				
				globalRankTempId++
			}
		}
				
		for(i = 0; i < numPlayers; i++) {
			new playerRanked
			
			id = Players[i]	
			
			playerRanked = id
			
			for(n = 0; n < globalRankTempId; n++) {
				if(globalRankTemp[0][n] == id) {
					playerRanked = -1
				}
			}
			
			if(playerRanked != -1) {
				new CsTeams:UserTeam = cs_get_user_team(playerRanked)
				
				globalRankTemp[0][globalRankTempId] = id
				globalRankTemp[1][globalRankTempId] = 0
				globalRankTemp[2][globalRankTempId] = 0
				globalRankTemp[5][globalRankTempId] = 0
				
				if(UserTeam == CS_TEAM_T) {
					globalRankTemp[3][globalRankTempId] = 1
					globalRankTemp[4][globalRankTempId] = 0
				}
				else if(UserTeam == CS_TEAM_CT) {
					globalRankTemp[3][globalRankTempId] = 0
					globalRankTemp[4][globalRankTempId] = 1
				}
				
				globalRankTempId++
			}
		}
	}
	
	for(i = 0; i < globalRankTempId; i++) {
		for(n = 0; n < foundBoxesId; n++) {
			if(globalRankTemp[0][i] == foundBoxes[0][n]) {
				globalRankTemp[1][i] = globalRankTemp[1][i] + foundBoxes[1][n]
			}
		}
		
		for(n = 0; n < setBoxesId; n++) {
			if(globalRankTemp[0][i] == setBoxes[0][n]) {
				globalRankTemp[2][i] = globalRankTemp[2][i] + setBoxes[1][n]
			}
		}
	}
	
	topPlayersId = 0
	
	new topPlayer, topPlayerId
	new Float:topValue
	
	do {
		topPlayer = -1
		topValue = 0.0
		i = 0
		
		for(i = 0; i < globalRankTempId; i++) {
			new Float:eQ
			
			eQ = float(globalRankTemp[1][i] + globalRankTemp[2][i]) / float(globalRankTemp[3][i] + globalRankTemp[4][i])
			
			if(topValue < eQ || topValue == 0.0) {
				if(globalRankTemp[5][i] == 0) {
					topPlayer = globalRankTemp[0][i]
					topPlayerId = i
					topValue = eQ
				}
			}
		}
		
		if(topPlayer != -1) {
			topPlayers[topPlayersId] = topPlayer
			globalRankTemp[5][topPlayerId] = -1
			topPlayersId++
		}
	} while(topPlayer != -1)
	
	globalRankId = 0
	
	for(i = 0; i < globalRankTempId; i++) {
		globalRank[0][globalRankId] = globalRankTemp[0][i]
		globalRank[1][globalRankId] = globalRankTemp[1][i]
		globalRank[2][globalRankId] = globalRankTemp[2][i]
		globalRank[3][globalRankId] = globalRankTemp[3][i]
		globalRank[4][globalRankId] = globalRankTemp[4][i]
		
		globalRankId++
	}
	
	new r, nrPT
	get_players(rPlayers, numrPlayers, "ac")
	
	for(r = 0; r < numrPlayers; r++) {
		new CsTeams:rUserTeam = cs_get_user_team(rPlayers[r])
		
		if(rUserTeam == CS_TEAM_T) nrPT++
	}
	
	if(boxesSetCount == 0 && nrPT == 0) {
		set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, rampageTime, 0.0, 0.0);
		ShowSyncHudMsg(0, msgObjMain, "%L", LANG_PLAYER, "LAST_PLAYER_KILLED")
		
		client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LAST_PLAYER_KILLED");
		
		rampageStarted = false
		
		rampageTeamSet = false
		
		huntedInRampageCount = 0
	}
	else {
		set_task(0.1, "task_rampage")
	}
}

public task_rampage() {
	rampageStarted = true;
	
	new r, rPlayers[32], numRPlayers, nrPT, nrPCT
	
	get_players(rPlayers, numRPlayers, "ac")
	
	for(r = 0; r < numRPlayers; r++) {
		new CsTeams:rUserTeam = cs_get_user_team(rPlayers[r])
		
		if(rUserTeam == CS_TEAM_T) nrPT++
		if(rUserTeam == CS_TEAM_CT) nrPCT++
	}
	
	set_hudmessage(107, 142, 35, -1.0, 0.3, 0, 0.0, rampageTime, 0.0, 0.0);
	
	if(boxesSetCount == 0 && !canSetBoxes && nrPT != 0) {
		ShowSyncHudMsg(0, msgObjMain, "%L", LANG_PLAYER, "ALL_BOXES_FOUND")
		
		client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "ALL_BOXES_FOUND");
		
		rampageTeam = CS_TEAM_CT
	}
	else if(boxesSetCount == 0 && nrPT == 0) {
		ShowSyncHudMsg(0, msgObjMain, "%L", LANG_PLAYER, "LAST_PLAYER_KILLED")
		
		client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LAST_PLAYER_KILLED");
		
		rampageStarted = false
		
		rampageTeamSet = false
	}
	else if(boxesSetCount == 0 && canSetBoxes) {
		ShowSyncHudMsg(0, msgObjMain, "%L", LANG_PLAYER, "NO_BOXES_SET")
		
		client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "NO_BOXES_SET");
		
		rampageTeam = CS_TEAM_CT
	}
	else { 
		ShowSyncHudMsg(0, msgObjMain, "%L", LANG_PLAYER, "GAME_ENDED")
		
		client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "GAME_ENDED");
		
		rampageTeam = CS_TEAM_T
	}
	
	huntedInRampageCount = 0

	if(rampageStarted) {
		new t, Players[32], numPlayers
		
		get_players(Players, numPlayers, "ac")

		for(t = 0; t < numPlayers; t++) {
			new CsTeams:userTeam = cs_get_user_team(Players[t])
			
			set_user_rendering(Players[t], kRenderFxGlowShell,0,0,0,kRenderNormal,25)
			
			new n
			new bool:foundPlayer;
			
			foundPlayer = false;
			
			for (n = 0; n < nolagToggledId; n++) {
				if(nolagToggled[n] == Players[t] && nolagToggled[n] != -1) {
					foundPlayer = true;
				}
			}
			
			if(!foundPlayer) {
				set_hudmessage(255, 0, 0, 0.7, -1.0, 1, 0.0, rampageTime, 0.0, 0.0); 
			}
			else {
				set_hudmessage(255, 0, 0, 0.7, -1.0, 0, 0.0, rampageTime, 0.0, 0.0); 
			}
			
			if(userTeam == rampageTeam) {
				give_item(Players[t],"weapon_m249")
				give_item(Players[t], "ammo_556natobox")
				give_item(Players[t], "ammo_556natobox")
				give_item(Players[t], "ammo_556natobox")
				give_item(Players[t], "ammo_556natobox")
				give_item(Players[t], "ammo_556natobox")
				
				set_user_godmode(Players[t], 1)				
				
				ShowSyncHudMsg(Players[t], msgObjRTop, "%L", Players[t], "KILL_ALL");
				
				client_print(Players[t], print_chat, "[GEO] %L", Players[t], "KILL_ALL");
				
				set_hudmessage(255, 0, 0, 0.05, 0.7, 1, 0.0, 1.0, 0.0, 0.0);
				ShowSyncHudMsg(Players[t], msgObjLBottom, "%L", Players[t], "KILL_IN_SECS", rampageTime);
				
				client_print(Players[t], print_chat, "[GEO] %L", Players[t], "KILL_IN_SECS", rampageTime)
				
			}
			else {
				strip_user_weapons(Players[t])
				
				set_user_godmode(Players[t])
				set_user_maxspeed(Players[t], 320.0)
				
				entity_set_int(Players[t], EV_INT_solid, SOLID_BBOX)
				
				ShowSyncHudMsg(Players[t], msgObjRTop, "%L", Players[t], "ESC_OR_DIE");
				
				client_print(Players[t], print_chat, "[GEO] %L", Players[t], "ESC_OR_DIE")
				
				set_hudmessage(255, 0, 0, 0.05, 0.7, 1, 0.0, 1.0, 0.0, 0.0);
				ShowSyncHudMsg(Players[t], msgObjLBottom, "%L", Players[t], "SURVIVE", rampageTime);
				
				client_print(Players[t], print_chat, "[GEO] %L", Players[t], "SURVIVE", rampageTime)
				
				huntedInRampageCount++
			}
		}
		
		timePassed = 0.0;
		set_task(1.0, "task_relay_rampage_survived", TASK_RELAY_RAMPAGE_SURVIVED, "", 0, "b")
	}
}

public task_relay_rampage_survived() {
	timePassed = timePassed + 1.0;
	
	new id, i, Players[32], numPlayers
	
	get_players(Players, numPlayers, "ac")
		
	for(i = 0; i < numPlayers; i++) {
		id = Players[i]
		
		set_hudmessage(255, 0, 0, 0.05, 0.7, 1, 0.0, 1.0, 0.0, 0.0, 2);
			
		new CsTeams:UserTeam = cs_get_user_team(id)
		
		new n
		new bool:foundPlayer;
			
		foundPlayer = false;
			
		for (n = 0; n < nolagToggledId; n++) {
			if(nolagToggled[n] == id && nolagToggled[n] != -1) {
				foundPlayer = true;
			}
		}
		
		if(UserTeam == rampageTeam) {
			if(!foundPlayer) {
				ShowSyncHudMsg(id, msgObjLBottom, "%L", id, "KILL_IN_SECS", rampageTime - timePassed);
			}
			else if(foundPlayer == true && timePassed == 1.0) {
				set_hudmessage(255, 0, 0, 0.05, 0.7, 0, 0.0, rampageTime, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjLBottom, "[NOLAG] %L", id, "KILL_IN_SECS", rampageTime - timePassed);
			}
		}
		else if(UserTeam != rampageTeam) {
			if(!foundPlayer) {
				ShowSyncHudMsg(id, msgObjLBottom, "%L", id, "SURVIVE", rampageTime - timePassed);
			}
			else if(foundPlayer == true && timePassed == 1.0) {
				set_hudmessage(255, 0, 0, 0.05, 0.7, 0, 0.0, rampageTime, 0.0, 0.0);
				ShowSyncHudMsg(id, msgObjLBottom, "[NOLAG] %L", id, "SURVIVE", rampageTime - timePassed);
			}
		}
	}
	
	if(timePassed >= rampageTime) {
		rampage_survived();
	}
}

public rampage_survived() {
	if(task_exists(TASK_RELAY_RAMPAGE_SURVIVED)) {
		remove_task(TASK_RELAY_RAMPAGE_SURVIVED)
	}
	
	if(task_exists(TASK_SHOW_IDLE_MESSAGE)) {
		remove_task(TASK_SHOW_IDLE_MESSAGE)
	}

	rampageStarted = false;
	
	if(rampageTeam == CS_TEAM_CT) {
			client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LOST_BY", CT, T)
			
			new idleMsgToShow[128]
			formatex(idleMsgToShow, 127, "%L", LANG_PLAYER, "CT_LOST")
			set_task(1.0, "task_show_idle_message", TASK_SHOW_IDLE_MESSAGE, idleMsgToShow, strlen(idleMsgToShow), "b")
	}
	else if (rampageTeam == CS_TEAM_T) {
			client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LOST_BY", T, CT)
			
			new idleMsgToShow[128]
			formatex(idleMsgToShow, 127, "%L", LANG_PLAYER, "T_LOST")
			set_task(1.0, "task_show_idle_message", TASK_SHOW_IDLE_MESSAGE, idleMsgToShow, strlen(idleMsgToShow), "b")
	}
	
	new i, Players[32], numPlayers
	
	get_players(Players, numPlayers, "ac")
	
	survivedRampageCount = 0

	for(i = 0; i < numPlayers; i++) {
		new CsTeams:UserTeam = cs_get_user_team(Players[i])
		
		if(UserTeam == rampageTeam) {
			user_kill(Players[i]);
		}
		else {
			survivedRampageCount++
		}
	}
}

public event_end_round() {
	roundStarted = false;
	
	if(rampageStarted == true) {
		if(task_exists(TASK_RELAY_RAMPAGE_SURVIVED)) {
			remove_task(TASK_RELAY_RAMPAGE_SURVIVED)
		}
		
		if(task_exists(TASK_SHOW_IDLE_MESSAGE)) {
			remove_task(TASK_SHOW_IDLE_MESSAGE)
		}
		
		if(rampageTeam == CS_TEAM_T) {
			client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LOST_BY", CT, T)
			
			new idleMsgToShow[128]
			formatex(idleMsgToShow, 127, "%L", LANG_PLAYER, "T_WON")
			set_task(0.1, "task_show_idle_message", TASK_SHOW_IDLE_MESSAGE, idleMsgToShow, strlen(idleMsgToShow), "b")
		}
		else if (rampageTeam == CS_TEAM_CT) {
			client_print(0, print_chat, "[GEO] %L", LANG_PLAYER, "LOST_BY", T, CT)
			
			new idleMsgToShow[128]
			formatex(idleMsgToShow, 127, "%L", LANG_PLAYER, "CT_WON")
			set_task(0.1, "task_show_idle_message", TASK_SHOW_IDLE_MESSAGE, idleMsgToShow, strlen(idleMsgToShow), "b")
		}
		
		rampageTeamSet = true
	}
	
	cleanup()
	
	return PLUGIN_HANDLED;
}
