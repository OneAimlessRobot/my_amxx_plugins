/*********************************************************************************************
*						FFAC server side plugin v2.6
**********************************************************************************************
FFAChmp V2.6
hackziner : hackziner@gmail.com
FFAC Website : http://82.232.102.55/FFAC


Licence : CeCILL FREE SOFTWARE LICENSE AGREEMENT

Use :
 Only run the plugin on your server. After the first player connection the server will be added to the server list
 No subscription require !

 	Features, ... :

	Global players stats  ( based on skill ) !
	FFA Team rank ( create a team with ffa player )
	Global CStats like rank ( based on Kill - Death ... )
	Servers stats ( graphs with connections by hours/day, total frag, ... )
	Show current skill,rank on a server
	Global Banlist
	Sentence log
	Map download from FFAC server 
	Package Manager 
	Package choice menu 
	Autoupdate
	No subscription require !

More informations, support, improvements, .... :
http://ufb.free.fr or http://82.232.102.55/FFAC/forum

	Cvar:
	ffac_showinfo ( default 1 ) : Show information ingame, like player skill ... ( commands are skill,ffac,score,allskill,ffac version )
	ffac_showpub ( default 1 ) : Show a little pub message for ffac every 180 secs
	ffac_ffacban ( default 1 ) : Use the FFAC banned steamid database
	ffac_ban ( default 30 ) : Duration of a FFACBan in Min
	ffac_plog ( default 1 ) : Log sentence function ( when you say something with "log" inside, the sentence is logged and you can read it on the ffac website )
	ffac_msn_contact ( default "" ) : Set the msn adress for the ffac msn bot !
	ffac_aim_contact ( default "" ) : Set the aim contact for the ffac aim bot !
	ffac_ip_bind ( default "" ) : Set your public ip ( if you server is behind someting ... )
	ffac_autoupdate ( default 1 ) : enable autoupdate
	ffac_hpt ( default 1 ) : enable the packet manager
	
	Network Cvar :
	ffac_packetsize ( default 1024 ) :  Size of packets
	ffac_master_server ( default "82.232.102.55" ) : FFAC master server address
	
	admin commands :
	
	amx_ffac_ban <user id or steam id> : ban a player for amx_ffac_ffacban minuts, and repport the ban to the ffac server
	amx_ffac_map_download <map> : download a map from the ffac server on your server ! 
	amx_ffac_map_list : show the list of downloable maps
	amx_ffac_hpt_install <package> : Install a package on your server !
	amx_ffac_hpt_remove <package> : Remove a package 
	amx_ffac_hpt_menu : Show a menu with all packages available
	
	Players commands : ffac version,ffac changelog,skill,!log <sentence>,set nickname

	ffac version : display the ffac version
	ffac changelog : display ffac changelog
	serverconnections : show server connections stats in motd ( day & month )
	skill : show your skill
	rank : show your rank by skill and csstats ( global and server rank )
	!log <sentence> : Log a sentence ( you can view all your logged sentences on the ffac website )
	
	
	FFACBan :
	Ban player banned in the FFAC Database for 30 minute ! Not unlimited ban !

	
	Changelog:
	
	2.5
	-dbsys
	-Change autoupdate system, now it update only if the version is older 
	-bmann_420 reported bug corrected
	-change tfc mod detection : tfc -> tf%
	-new package instruction : DeleleFile
	-new cvar ffac_pub_time to change the pub time
	-new forward ffac_client_auth(id)
	-some other little fix
	
	2.4
	-force update on some client to avoid DoS attack
	
	2.3
	-Optimisation : ->static
	-Optimisation : ->formatex
	-Optimisation : ->Global
	-New package manager instruction : [ServerExec]
	-Remove unused multilang support
	-Remove hud skill messages
	-Command list/ads -> One line 
	-Some "say text" commands are registered now
	-"Auto ban" report and better ban support
	-New stats support ...
		-Log all games of last 7 days
		-Support stats of specifics mods
	-Version before 0.8 are unsupported now
	
	
	2.2
	-fix the aim bot bug
	-add icq support
	-new stats record ...
	-several little fixs ...
	
	2.1
	-aim bot support ...
	-cvar version bug
	
	2.0
	-Totaly new version :)
	-all fix of 1.4 and 1.5
	-Some security fix with the package manager
	-new natives
	-split the plugin in some sub plugin
	-auto switch between fast & slow mode for the socket packet check
	

*********************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <sockets>

#define PLUGIN "FFAChmp!Tools"
#define VERSION "2.6"
#define AUTHOR "hackziner"

#define SOCKET_TASK 23233
#define SOCKET_PORT 19863

#define PUB_TASK 23234

#define TASK_SLOW 0.20
#define TASK_FAST 0.05

#define HSPOINT 9

#define PUBLINE "FFAC commands : ffac version,ffac changelog,skill,rank,!log <sentence>"

//Stats
new skill[33] 
new CDeath[33] //Death count
new CKill[33] //Kill count
new CHSG[33] //HS Giv
new CHST[33] //HS Tak
new CTSpawn[33] //Spawn ct 
new TSpawn[33] // Spawn Terro
new SpawnCount[33]

//info
new latitude[32][8]
new longitude[32][8]
new city[32][16]
new country[32][16]

//TP Stats
new TPAction[33][6]
new LastIdMainAction

//Stats display
new	RankSkill[33] //global rank by skill
new RankCSStats[33] //global rank by csstats
new	RankCSServer[33] //server rank by skill
new RankSkillServer[33] //server rank by csstats

//V
new FFAReady[33]
new Server_ID

//Server
new port[16]
new thehostname[256]
new mapname[64]
new maxplayers
new modname[32]

//Cvar
new ffac_showinfo
new ffac_showpub
new ffac_pub_time
new ffac_ffacban
new ffac_ffacban_duration
new ffac_plog
new ffac_autoupdate
new ffac_msn_contact[256]
new ffac_aim_contact[256]
new ffac_icq_contact[256]
new ffac_ip_bind[64]
new ffac_master_server[64]
new ffac_dbsys

//Packet Manager
new Amxmodx_version[8]
new PacketDataSize
new ActiveHpt
new HPTStatus
new HTPCurrentPacket[128]
new Item_Menu
new Item_MenuVal[32][32]

//Chaussette :)
new sckRemoteServer

//Packet manager
new MapDownSize // 0 = No download
new MapCurrentPacket
new MapCurrentPacketTO
new MapCurrentPacketTOF
new map[64]
new hpt_menu
new id_menu

//dbsys
new registered_gvar[128]
new gvar_values[4][33][32]
new gvar_count

//intern stats vars
new cstrike_stats
new tfc_stats
new dod_stats


//Multip stock Var -> Global
	new szName[128]
	new szAuthID[33]

public plugin_init() 
{
	new error, err[40]
	new cmd[256]
 
	register_plugin(PLUGIN, VERSION, AUTHOR)

 	register_event("DeathMsg","death","a")
	register_event("ResetHUD", "client_spawn", "be")

	register_clcmd("fullupdate", "clcmd_fullupdate")
	register_clcmd("say", "handle_say")

	//HL1 mods support
	get_modname(modname,32)
	if (containi(modname,"cstrike")!=-1)cstrike_stats=1
	if (containi(modname,"dod")!=-1)dod_stats=1
	if (containi(modname,"tf")!=-1)tfc_stats=1
	
	//clients commands
	register_clcmd("say /setnickname", "set_nickname", 0, "- Set your steam id for your ffac forum account")
	
	//commands
	register_concmd("amx_ffac_ban","ffacban",ADMIN_LEVEL_B,"<authid, nick or #userid>")
	register_concmd("amx_ban","ffacban",ADMIN_LEVEL_B,"<authid, nick or #userid>")
	register_concmd("amx_ffac_map_download","MapDownload",ADMIN_LEVEL_B,"<mapname>")
	register_concmd("amx_ffac_map_list","MapList",ADMIN_LEVEL_B," List ffac donwloable maps")
	register_concmd("amx_ffac_hpt_install","hpt_install",ADMIN_LEVEL_B," <package name>")
	register_concmd("amx_ffac_hpt_remove","hpt_remove",ADMIN_LEVEL_B," <package name>")
	register_concmd("amx_ffac_hpt_menu","hpt_menur",ADMIN_LEVEL_B,"")
	
	//functions cvar
	register_cvar("ffac_showinfo","1") 
	register_cvar("ffac_showpub","1") 
	register_cvar("ffac_pub_time","240") 
	
	register_cvar("ffac_ffacban","1",FCVAR_SERVER) 
	register_cvar("ffac_ffacban_duration","30",FCVAR_SERVER) 
	register_cvar("ffac_plog","1",FCVAR_SERVER)
	register_cvar("ffac_msn_contact","msn_adress")
	register_cvar("ffac_aim_contact","aim_contact")
	register_cvar("ffac_icq_contact","icq_contact")
	register_cvar("ffac_version",VERSION,FCVAR_SERVER)
	register_cvar("ffac_ip_bind","",FCVAR_SERVER)
	register_cvar("ffac_autoupdate","1",FCVAR_SERVER)	
	register_cvar("ffac_hpt","1",FCVAR_SERVER)
	register_cvar("ffac_dbsys","0",FCVAR_SERVER)
	
	
	
	//Mods specifics stats
		//CS Stats
	if (cstrike_stats==1)
	{
		// Bomb dropped (including disconnect/death) event
		register_logevent("cs_drop_the_bomb", 3, "2=Dropped_The_Bomb")
		
		//Bomb collected (except spawn) event
		register_logevent("cs_got_the_bomb", 3, "2=Got_The_Bomb")
		
		// Bomb planted event
		register_logevent("cs_bomb_planted", 3, "2=Planted_The_Bomb")
		
		// Bomb defused event
	    register_logevent("cs_bomb_defused", 3, "2=Defused_The_Bomb")
		
		// Target bombed (right before round end) event
	    register_logevent("cs_target_bombed", 6, "3=Target_Bombed")	
	}
		//TFC Stats
	if (tfc_stats==1)
	{
		//Player take the Blue Flag
		register_logevent("tfc_blue_flag", 3, "2=Blue Flag")
		
		//Player take the Red Flag
		register_logevent("tfc_red_flag", 3, "2=Red Flag")
		
		//Player red capture the blue flag
		register_logevent("tfc_red_capture", 3, "2=Red Capture Point")
		
		//Player blue capture the red flag
		register_logevent("tfc_blue_capture", 3, "2=Blue Capture Point")		
		
	}
		//DOD stats
	if (dod_stats==1)
	{
	}
	//tech Cvar
	register_cvar("ffac_packetsize","1024",FCVAR_SERVER)	
	register_cvar("ffac_master_server","82.232.102.55",FCVAR_SERVER)
	
	
	ffac_showinfo = get_cvar_num("ffac_showinfo")
	ffac_showpub= get_cvar_num("ffac_showpub")
	ffac_pub_time = get_cvar_float("ffac_pub_time")
	ffac_ffacban= get_cvar_num("ffac_ffacban")
	ActiveHpt= get_cvar_num("ffac_hpt")
	ffac_ffacban_duration= get_cvar_num("ffac_ffacban_duration")
	ffac_plog= get_cvar_num("ffac_plog")
	ffac_autoupdate = get_cvar_num("ffac_autoupdate")
	PacketDataSize=get_cvar_num("ffac_packetsize")
	ffac_dbsys=get_cvar_num("ffac_dbsys")
	
	get_cvar_string("hostname",thehostname,256) 
	get_cvar_string("port",port,15) 
	get_cvar_string("ffac_msn_contact",ffac_msn_contact,255) 
	get_cvar_string("ffac_aim_contact",ffac_aim_contact,255) 
	get_cvar_string("ffac_icq_contact",ffac_icq_contact,255) 
	get_cvar_string("amxmodx_version",Amxmodx_version,7)
	get_cvar_string("ffac_master_server",ffac_master_server,64) 
	get_cvar_string("ffac_ip_bind",ffac_ip_bind,64) 	
	
	get_mapname (mapname,64)
	
	maxplayers = get_maxplayers()
	MapDownSize=0 
	HPTStatus=0
	gvar_count=0
		
	sckRemoteServer = socket_open(ffac_master_server,SOCKET_PORT, SOCKET_UDP,error)
	if(sckRemoteServer <= 0 || error)
			server_print("Couldn't connect to ffac/tools master server, error: %s",err)
			
	formatex(cmd, 256, "%s^"level!^"%s^"%s^"%s^"%d^"%s^"%s^"%d^"%s^"",VERSION,port,thehostname,mapname,maxplayers,ffac_msn_contact,ffac_ip_bind,ffac_autoupdate,modname) 
	socket_send2(sckRemoteServer, cmd,255)
	set_task(TASK_SLOW, "receive_info", SOCKET_TASK, "",0, "b")
	
	if (ffac_showpub)
		set_task(ffac_pub_time, "website_pub", PUB_TASK, "",0, "b")
		

	if (ActiveHpt)
		AddMenuItem("FFAC package manager", "amx_ffac_hpt_menu", ADMIN_MENU, PLUGIN)
		
	server_cmd("amx_cvar ffac_version %s",VERSION)
	
}

public plugin_end () 
{
	socket_close(sckRemoteServer)
	remove_task(SOCKET_TASK)
}



/******************************************************
Native-Native-Native-Native-Native-Native-Native-Native
******************************************************/

public plugin_natives()
{
	register_library("ffac_sys")
    
	register_native("ffac_register_plugin","_ffac_register_plugin")
	register_native("ffac_get_server_id","_ffac_get_server_id")
	register_native("ffac_get_skill","_ffac_get_skill")
	register_native("ffac_is_player_auth","_ffac_is_player_auth")
	
	register_native("ffac_msn_message2admin","_ffac_msn_message2admin")
	register_native("ffac_msn_message2admin2","_ffac_msn_message2admin2")
	register_native("ffac_msn_message","_ffac_msn_message")
	
	register_native("ffac_aim_message2admin","_ffac_aim_message2admin")
	register_native("ffac_aim_message2admin2","_ffac_aim_message2admin2")
	register_native("ffac_aim_message","_ffac_aim_message")
	
	register_native("ffac_icq_message2admin","_ffac_icq_message2admin")
	register_native("ffac_icq_message2admin2","_ffac_icq_message2admin2")
	register_native("ffac_icq_message","_ffac_icq_message")
	
	register_native("ffac_download_map","_ffac_download_map")
	register_native("ffac_install_package","_ffac_install_package")
	register_native("ffac_remove_package","_ffac_remove_package")
	register_native("ffac_log_sentence","_ffac_log_sentence")

	
	register_native("ffac_register_gvar","_ffac_register_gvar")
	register_native("ffac_get_gvar_int","_ffac_get_gvar_int")
	register_native("ffac_set_gvar_int","_ffac_set_gvar_int")
	
	register_native("ffac_get_player_city","_ffac_get_player_city")
	register_native("ffac_get_player_country","_ffac_get_player_country")
	register_native("ffac_get_player_latitude","_ffac_get_player_latitude")
	register_native("ffac_get_player_longitude","_ffac_get_player_longitude")
}
public _ffac_get_player_latitude(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	set_string(2,latitude[id],8)
	return PLUGIN_CONTINUE
}
public _ffac_get_player_longitude(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	set_string(2,longitude[id],8)
	return PLUGIN_CONTINUE
}
public _ffac_get_player_city(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	set_string(2,city[id],16)
	return PLUGIN_CONTINUE
}
public _ffac_get_player_country(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	set_string(2,country[id],16)
	return PLUGIN_CONTINUE
}

public _ffac_register_gvar(iPlugin,iParams)
{
	new msg[17]
	get_string(1,msg,16)
	strcat(registered_gvar,msg,128)
	strcat(registered_gvar,";",128)
	gvar_count=gvar_count+1;
	return gvar_count	
}
public _ffac_get_gvar_int(iPlugin,iParams)
{
	new gvarid = get_param(1)
	new plrid = get_param(2)
	return str_to_num(gvar_values[gvarid][plrid])
}

public _ffac_set_gvar_int(iPlugin,iParams)
{
	new gvarid = get_param(1)
	new plrid = get_param(2)
	new val = get_param(3)
	format(gvar_values[gvarid][plrid],32,"%d",val)
	return PLUGIN_CONTINUE	
}

public _ffac_register_plugin(iPlugin,iParams)
{
	return PLUGIN_CONTINUE	
}
public _ffac_get_server_id(iPlugin,iParams)
{
	return Server_ID	
}
public _ffac_is_player_auth(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	return FFAReady[id]
}
public _ffac_get_skill(iPlugin,iParams)
{
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	return skill[id]
}
public _ffac_msn_message(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[64]
	get_string(1,msg,128)
	get_string(2,msncontact,128)
	formatex(cmd, 349, "%s^"MSNADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_msn_message2admin(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[256]
	get_string(1,msg,128)
	get_cvar_string("ffac_msn_contact",msncontact,255)
	formatex(cmd, 349, "%s^"MSNADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_msn_message2admin2(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new ident[32]
	new nickname[32]
	new msncontact[256]
	get_string(1,msg,128)
	get_string(2,ident,128)
	get_string(3,nickname,128)
	get_cvar_string("ffac_msn_contact",msncontact,255)
	formatex(cmd, 349, "%s^"MSNADM!^"%s^"%s^"%s^"%s^"",VERSION,ident,nickname, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}


public _ffac_aim_message(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[64]
	get_string(1,msg,128)
	get_string(2,msncontact,64)
	formatex(cmd, 349, "%s^"AIMADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_aim_message2admin(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[256]
	get_string(1,msg,128)
	get_cvar_string("ffac_aim_contact",msncontact,255)
	formatex(cmd, 349, "%s^"AIMADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_aim_message2admin2(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new ident[32]
	new nickname[32]
	new msncontact[256]
	get_string(1,msg,128)
	get_string(2,ident,128)
	get_string(3,nickname,128)
	get_cvar_string("ffac_aim_contact",msncontact,255)
	formatex(cmd, 349, "%s^"AIMADM!^"%s^"%s^"%s^"%s^"",VERSION,ident,nickname, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}

public _ffac_icq_message(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[64]
	get_string(1,msg,128)
	get_string(2,msncontact,64)
	formatex(cmd, 349, "%s^"ICQADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_icq_message2admin(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new msncontact[256]
	get_string(1,msg,128)
	get_cvar_string("ffac_icq_contact",msncontact,255)
	formatex(cmd, 349, "%s^"ICQADM!^"**^"MESS_ONLY^"%s^"%s^"",VERSION, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}
public _ffac_icq_message2admin2(iPlugin,iParams)
{
	new cmd[350]
	new msg[128]
	new ident[32]
	new nickname[32]
	new msncontact[256]
	get_string(1,msg,128)
	get_string(2,ident,128)
	get_string(3,nickname,128)
	get_cvar_string("ffac_icq_contact",msncontact,255)
	formatex(cmd, 349, "%s^"ICQADM!^"%s^"%s^"%s^"%s^"",VERSION,ident,nickname, msncontact,msg) 
	socket_send2(sckRemoteServer, cmd,349)
	return PLUGIN_CONTINUE	
}

public _ffac_download_map(iPlugin,iParams)
{
	new mapname[128]
	get_string(1,mapname,128)
	server_cmd("amx_ffac_map_download %s",mapname) // I'm ashamed
	return PLUGIN_CONTINUE	
}
public _ffac_install_package(iPlugin,iParams)
{
	new package[128]
	get_string(1,package,128)
	server_cmd("amx_ffac_hpt_install %s",package) // I'm ashamed
	return PLUGIN_CONTINUE	
}
public _ffac_remove_package(iPlugin,iParams)
{
	new package[128]
	get_string(1,package,128)
	server_cmd("amx_ffac_hpt_remove %s",package) // I'm ashamed
	return PLUGIN_CONTINUE	
}
public _ffac_log_sentence(iPlugin,iParams)
{
	new sentence[96]
	new cmd[128]
	new id = get_param(1)
	if(!id)
		return PLUGIN_CONTINUE	
	get_string(2,sentence,128)
	get_user_authid(id,szAuthID,32)
	formatex(cmd, 128, "%s^"Log!^"%s^"%s^"",VERSION, szAuthID,sentence) 
	socket_send2(sckRemoteServer, cmd,127)
	return PLUGIN_CONTINUE	
}

/******************************************************
Native-Native-Native-Native-Native-Native-Native-Native
******************************************************/

public clcmd_fullupdate() {
    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	static cmd[256]
	static szIP[64]
	
	get_user_authid(id,szAuthID,32)
	get_user_ip(id,szIP,64)
	get_user_name(id,szName,128)
 
	formatex(cmd, 256, "%s^"Score?^"%s^"%d^"%s^"%s^"%s^"%s^"",VERSION, szAuthID,id,szIP,port,szName,registered_gvar) 
	socket_send2(sckRemoteServer, cmd,255)
	FFAReady[id]=0

}

public client_disconnect(id)
{
	static cmd[256]
	static szIP[33]
	static TeamName[16]
	get_user_ip(id,szIP,64)
	new ConnectTime
	ConnectTime = get_user_time(id)
	get_user_team(id,TeamName,16)
	if(FFAReady[id])
	{
		get_user_authid(id,szAuthID,32)
		formatex(cmd, 256, "%s^"Score!^"%s^"%d^"%d^"%d^"%d^"%d^"%d^"%d^"%d^"%s^"%d^"%d^"%s^"%d^"%d^"%d^"%d^"%d^"%d^"",VERSION, szAuthID,skill[id],CDeath[id],CKill[id],ConnectTime,id,CHSG[id],CHST[id],SpawnCount[id],szIP,TSpawn[id],CTSpawn[id],TeamName,TPAction[id][0],TPAction[id][1],TPAction[id][2],TPAction[id][3],TPAction[id][4],TPAction[id][5]) 
		socket_send2(sckRemoteServer, cmd,255)
		if(ffac_dbsys)
		{
			formatex(cmd, 256, "%s^"Score!^"%s^"%s^"%s;%s;%s;%s^"",VERSION, szAuthID,registered_gvar,gvar_values[0][id],gvar_values[1][id],gvar_values[0][id],gvar_values[2][id],gvar_values[3][id])
			socket_send2(sckRemoteServer, cmd,255)
		}
	}
	FFAReady[id]=0
	skill[id]=0
	CKill[id]=0
	CDeath[id]=0
	CHSG[id]=0
	CHST[id]=0
	RankSkill[id]=0
	RankCSStats[id]=0
	RankCSServer[id]=0
	RankSkillServer[id]=0
	SpawnCount[id]=0
	TSpawn[id]=0
	CTSpawn[id]=0
	TPAction[id][0]=0
	TPAction[id][1]=0
	TPAction[id][2]=0
	TPAction[id][3]=0
	TPAction[id][4]=0
	TPAction[id][5]=0

}

public death ()
{
  /*
  Skill calculation
  There are some server side skill checks. A server can give skill. If a player win 9 points an other MUST lost 9 points !
  You "can" change the calculation, but if you do a "bad calculation" you'll banned from ffac.
  */

	new killer
	new victim
	killer = read_data(1)
	victim = read_data(2)
	if(FFAReady[killer] && FFAReady[victim])
	{
		new scoredif
		new Float:scoreratio
		new Float:scorefinal  
		new score_num

		scoredif = skill[victim]-skill[killer] 
		if (scoredif>0)
		{
			scoredif=scoredif+1000
			scoreratio = floatlog(float(scoredif)) 
			scoreratio = floatpower(scoreratio, 2.5)
			scorefinal = floatmul(scoreratio, 4.5)
		}
		else
		{
			scorefinal = 60.0
		}
		score_num=floatround(scorefinal)
		skill[killer] = skill[killer]+score_num
		skill[victim] = skill[victim]-score_num
		CDeath[victim]=CDeath[victim]+1
		CKill[killer]=CKill[killer]+1
		if (ffac_showinfo)
		{	
			client_print(killer,print_chat,"FFAC : %d Points won",score_num)
			client_print(victim,print_chat,"FFAC : %d Points lost",score_num)		
		}
	}
	return PLUGIN_CONTINUE 
}
 
public  client_damage ( attacker, victim, damage, wpnindex, hitplace, TA )
{
	if (hitplace == 1 && FFAReady[attacker] && FFAReady[victim] ) //Headshot
	{
		skill[attacker] = skill[attacker]+HSPOINT
		skill[victim] = skill[victim]-HSPOINT
		CHSG[attacker]=CHSG[attacker]+1
		CHST[victim]=CHSG[victim]+1
		if (ffac_showinfo)
		{	

			client_print(attacker,print_chat,"FFAC : HeadShot, 9 points Won !")
			client_print(victim,print_chat,"FFAC : HeadShot, 9 points Lost !")
		}
	} 
	return PLUGIN_CONTINUE 	
}

public	client_spawn ( id )
{
	if(FFAReady[id])
	{
		SpawnCount[id]=SpawnCount[id]+1
		if (cstrike_stats==1)
		{
			if (get_user_team(id)==1)
				TSpawn[id]=TSpawn[id]+1
			if (get_user_team(id)==2)
				CTSpawn[id]=CTSpawn[id]+1
		}
	}
} 

public MapDownload(id,level,cid) {
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 
	new arg[32]
	read_argv(1, arg, 31)
	new cmd[256]
	new basedir[128]
	new mapdir[128]
	
	get_basedir(basedir,127)
	
	if(containi(arg,".bsp") == -1) 
		{
		formatex(mapdir, 127, "%s/../../maps/%s.bsp",basedir,arg) 
		formatex(cmd, 256, "%s*GetFile!*../../maps/%s.bsp*",VERSION, arg) 
		socket_send2(sckRemoteServer, cmd,255)
		client_print(0,print_chat,"Server download : %s",arg)

		}
	else
		{
		formatex(mapdir, 127, "%s/../../maps/%s",basedir,arg) 
		formatex(cmd, 256, "%s*GetFile!*../../maps/%s*",VERSION, arg) 
		socket_send2(sckRemoteServer, cmd,255)
		client_print(0,print_chat,"Server download : %s",arg)
		}
	return PLUGIN_HANDLED 	
	
} 

public hpt_menur(id,level,cid){
	new cmd[256]
	id_menu = id
	formatex(cmd, 256, "%s*GetPackageList!*Morgoth Catin :)*",VERSION) 
	socket_send2(sckRemoteServer, cmd,255)
	client_print(id,print_chat,"Server'll get the packages list !")
	hpt_menu = menu_create("\rFFAC Package Manager : Install Mode", "menu_handler")
	Item_Menu=0
	return PLUGIN_CONTINUE
}

public menu_handler(id, menu, item)
{
	new cmd[256]
	
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)	
	formatex(cmd, 256, "amx_ffac_hpt_install %s",Item_MenuVal[str_to_num(data)]) 
	client_print(id_menu,print_chat,"Command from menu %s",cmd)
	server_cmd(cmd)
	menu_destroy(menu)
	return PLUGIN_CONTINUE
}

public hpt_show_menu()
{
	if (id_menu>0)
	menu_display(id_menu, hpt_menu, 0)
	return PLUGIN_HANDLED
}

public hpt_install(id,level,cid){
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 
	if (ActiveHpt==1)
	{
	new arg[32]
	read_argv(1, arg, 31)
	new cmd[256]
	new basedir[128]
	new ddir[128]
	get_basedir(basedir,127)
	formatex(ddir, 127, "%s/configs/hpt/",basedir) 
	

	if(dir_exists ( ddir ) ==0)
		mkdir (ddir)
	
	HPTStatus=1
	formatex(cmd, 256, "%s*GetFile!*configs/hpt/%s.hpt*",VERSION, arg) 
	socket_send2(sckRemoteServer, cmd,255)
	client_print(0,print_chat,"Install Package: %s",arg)

	
	formatex(HTPCurrentPacket, 127, "%s/configs/hpt/%s.hpt",basedir,arg)
	}
	else
	{
		client_print(0,print_chat,"Package manager is disabled, set cvar ffac_apt 1 to enable it")
	}
	
	return PLUGIN_HANDLED

}

public hpt_remove(id,level,cid){
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 
	new arg[32]
	read_argv(1, arg, 31)
	new basedir[128]
	
	get_basedir(basedir,127)
	
	HPTStatus=3
	formatex(HTPCurrentPacket, 127, "%s/configs/hpt/remove_%s.hpt",basedir,arg)
	client_print(0,print_chat,"Remove Package: %s",arg)
	packet_manager()
	return PLUGIN_HANDLED

}

public MapList(id) {
	new cmd[128]
	formatex(cmd, 127,"http://82.232.102.55/public/maps.txt")
	show_motd(id, cmd, "FFAC http://82.232.102.55/FFAC")
}

public ffacban(id,level,cid) 
{ 
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED

	new target[32], minutes[8], reason[64]
	
	read_argv(1, target, 31)
	read_argv(2, minutes, 7)
	read_argv(3, reason, 63)
	
	new cmd[128]

	if (ffac_ffacban)
	{
		get_user_authid(id,szAuthID,32)
		server_cmd("amx_ban %c%s%c %d FFACBan",'"',cid,'"',ffac_ffacban_duration)
		formatex(cmd, 128, "%s^"FFACBAN!^"%d^"%s^"%d^"%d^"%s^"",VERSION, cid,szAuthID,ffac_ffacban_duration,minutes,reason) 
		socket_send2(sckRemoteServer, cmd,128)
	}
	return PLUGIN_CONTINUE
}

public website_pub() 
{
	new i
	for(i=1;i<33;i++)
		{
		if (FFAReady[i]==1)
			{
			client_print(i,print_chat,"This server takes part in the FFAC Championship : http://82.232.102.55/FFAC")
			client_print(i,print_chat,PUBLINE)
			}
		}
}	

public receive_info() 
{
 	new len

	static cmdb[196]
	len=0
	
	if(MapDownSize>0)
		MapCurrentPacketTO=MapCurrentPacketTO+1
	if(MapCurrentPacketTO>5)
	{
		formatex(cmdb, 196, "%s*GetFileData!*%s*%d*%d*",VERSION, map,MapCurrentPacket,PacketDataSize ) 
		socket_send2(sckRemoteServer, cmdb,196 )
		MapCurrentPacketTO=0
		MapCurrentPacketTOF=MapCurrentPacketTOF+1
		if(MapCurrentPacketTOF>25)
			MapDownSize=0
	}
	
	if (socket_change(sckRemoteServer,1))
	{
		static recv[1536]
		len=socket_recv(sckRemoteServer, recv,1536)
		if (len > 8 ) 
		{
			static string_id[64]
			static string_type[64]
			static string_score[64]
			static string_sid[512]
			static string_a[128]
			static string_b[1300]
			strtok(recv,string_a,127,string_b,1299,'+')
			strtok(string_a,string_id,63,string_type,63,'*')
			strtok(string_b,string_score,63,string_sid,511,'*')

			if(  containi(string_score, "BANNED") != -1 )
			{
				client_print(str_to_num(string_id),print_chat,"FFAC : Your are BANNED from FFAC server, more info : http://82.232.102.55/FFAC")
				if (ffac_ffacban)
					server_cmd("amx_ban %c%s%c %d FFAC",'"',string_sid,'"',ffac_ffacban_duration)
			}
			if(  containi(string_type, "ID_SERV") != -1 )
			{
				Server_ID = str_to_num(string_id)	
				if (ffac_autoupdate ==1)
				{
					if (str_to_num(string_score)>str_to_num(VERSION))
					{
						server_cmd("amx_ffac_hpt_install ffachmp2") //autoupdate
					}
				}
			}
			
			if(  containi(string_type, "RANKPLAYERA") != -1 )
			{
				RankSkill[str_to_num(string_id)]=str_to_num(string_score)
				RankCSStats[str_to_num(string_id)]=str_to_num(string_sid)
				client_print(str_to_num(string_id),print_chat,"Rank on FFAC : %d by Skill, %d by Score",RankSkill[str_to_num(string_id)],RankCSStats[str_to_num(string_id)])		
			}
			
			if(  containi(string_type, "RANKPLAYERS") != -1 )
			{
				RankCSServer[str_to_num(string_id)]=str_to_num(string_sid)
				RankSkillServer[str_to_num(string_id)]=str_to_num(string_score)
				client_print(str_to_num(string_id),print_chat,"Server Rank : %d by Skill, %d by Score",RankSkillServer[str_to_num(string_id)],RankCSServer[str_to_num(string_id)])
			}
			
			if(  containi(string_type, "SAYPLAYER") != -1 )
			{
				client_print(str_to_num(string_id),print_chat,"%s",string_a)
			}		
			
			if(  containi(string_type, "SEND") != -1 )
			{
				skill[str_to_num(string_id)]=str_to_num(string_score)
				FFAReady[str_to_num(string_id)]=1
				new split[32]
				new split2[32]
				strtok(string_sid,split,32,split2,32,'!')
				strtok(split,country[str_to_num(string_id)],16,city[str_to_num(string_id)],16,'_')
				strtok(split2,latitude[str_to_num(string_id)],8,longitude[str_to_num(string_id)],8,'_')
				if (ffac_showinfo)
				{
					client_print(str_to_num(string_id),print_chat,"FFAC : Score loaded : %d ",str_to_num(string_score))	
				}	
				//forward
				new iForward = CreateMultiForward("ffac_client_auth",ET_IGNORE,FP_CELL),iReturn
				if(iForward >= 0)
				{
				    ExecuteForward(iForward,iReturn,str_to_num(string_id))
				    DestroyForward(iForward)
				}
			}
			
			if(  containi(string_type, "GVAR") != -1 )
			{
				format(gvar_values[str_to_num(string_score)][str_to_num(string_id)],32,"%s",string_sid)
			}			
			
			if(  containi(string_type, "PACKAGELIST") != -1 )		
			{
				new val[4]
				formatex(val,4,"%d",Item_Menu);
				menu_additem(hpt_menu,string_score ,val , ADMIN_BAN)
				copy(Item_MenuVal[Item_Menu],32,string_id)
				Item_Menu=Item_Menu+1
			}
			if(  containi(string_type, "PACKAGEENDLIST") != -1 )
			{
				if (ActiveHpt)
					hpt_show_menu()
			}
			
			if(  containi(string_type, "MAPINFO") != -1 )
			{
				new cmd[256]
				new basedir[128]
				new dire[128]
				get_basedir(basedir,127)
				MapCurrentPacketTOF=0
				formatex(dire, 127, "%s/%s",basedir,string_id) 
				MapDownSize=str_to_num(string_score) //Get size in o
				
				
				if (file_exists(dire)==1)
				{
					if (filesize(dire)==MapDownSize)
					{
						server_print ( "%s is already up to date ! ",string_id )
						client_print(0,print_chat," %s is already up to date",string_id)
						MapDownSize=0
						if (HPTStatus==1)
							HPTStatus=2
						if (HPTStatus==4)
						{
							HPTStatus=3
							packet_manager()
						}
					}
					else
					{
						delete_file(dire)
						server_print ( "Server start the upgrade of %s : size : %do",string_id,MapDownSize )
						client_print(0,print_chat,"Server start the upgrade of %s : size : %do",string_id,MapDownSize)
						MapCurrentPacket=0
						formatex(cmd, 256, "%s*GetFileData!*%s*0*%d*",VERSION, string_id,PacketDataSize)
						socket_send2(sckRemoteServer, cmd,255)
						change_task(SOCKET_TASK,TASK_FAST)
						if (HPTStatus==1)
							HPTStatus=2
					}
				}
				else
				{
					server_print ( "Server start the download of %s : size : %do",string_id,MapDownSize )
					client_print(0,print_chat,"Server start the download of %s : size : %do",string_id,MapDownSize)
					MapCurrentPacket=0
					formatex(cmd, 256, "%s*GetFileData!*%s*0*%d*",VERSION, string_id,PacketDataSize)
					socket_send2(sckRemoteServer, cmd,255)
					change_task(SOCKET_TASK,TASK_FAST)
					if (HPTStatus==1)
						HPTStatus=2
				}
			}
			
			if(  containi(string_type, "MAPDATA") != -1 )
			{
				new cmd[256]
				new basedir[128]
				new mapdir[128]
				new headerl[64]
				new Cursor
				new i
				MapCurrentPacketTOF=0
				strtok(string_id,headerl,63,map,63,'!')
				get_basedir(basedir,127)
				formatex(mapdir, 127, "%s/%s",basedir,map) 			 
				
				Cursor = str_to_num(string_score)
				server_print ( "Server Get data from %d to %d of %s ( header %d bytes) ",Cursor,Cursor+PacketDataSize,map,str_to_num(headerl) )

				if (Cursor == MapCurrentPacket )
				{
					new mapfile = fopen(mapdir,"ab+")
					fseek ( mapfile,SEEK_END  , 0)
					if ((MapDownSize-Cursor)<PacketDataSize )
					{	
						for(i = 0 ; i < MapDownSize-Cursor ; i++)
							fputc(mapfile, recv[str_to_num(headerl)+i])
						server_print ( "File Downloaded ! : %s",map )
						client_print(0,print_chat,"File Downloaded ! : %s",map  )
						set_hudmessage(255, 0, 0, 0.46, 0.17, 0, 6.0, 6.0)
						show_hudmessage(0, "%s Downloading^n Completed !",map)	
						change_task(SOCKET_TASK,TASK_SLOW)
						MapDownSize=0
						if (HPTStatus==2 || HPTStatus==4 )
						{	
							HPTStatus=3
							server_print ( "Run packet installer !" )
							client_print(0,print_chat,"Run packet installer !"  )
							fclose(mapfile)
							packet_manager()
						
						}	
					}
					else
					{
						for(i = 0 ; i < PacketDataSize ; i++)
							fputc(mapfile, recv[str_to_num(headerl)+i])
						formatex(cmd, 256, "%s*GetFileData!*%s*%d*%d*",VERSION, map,Cursor+PacketDataSize,PacketDataSize ) //Ask the first block of 512 o of the map 
						MapCurrentPacket=Cursor+PacketDataSize
						socket_send2(sckRemoteServer, cmd,256 )
						MapCurrentPacketTO=0
						if (random(3)==2)
							{
							set_hudmessage(255, 0, 0, 0.46, 0.17, 0, 6.0, 2.0)
							show_hudmessage(0, "%s Downloading^n %dKo/%dKo Done",map,Cursor/1024,MapDownSize/1024)
							}
						fclose(mapfile)
					}
				}
				
			}
		}
	}
	return PLUGIN_CONTINUE
}

public packet_manager(){

	if (ActiveHpt==1 && HPTStatus==3)
	{
		new line;
		new rien;
		new readline[128];
		new cmd[128];
		new extr[128];
		line=0
		new basedir[128]
		get_basedir(basedir,127)
		
		line= read_file(HTPCurrentPacket,line,readline,127,rien)
		while ( line>0 )
		{
			if (containi(readline,"[Done]")==-1)
			{
				
				if (containi(readline,"[Download]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					HPTStatus=4
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					formatex(cmd, 256, "%s*GetFile!*%s*",VERSION,extr) 
					socket_send2(sckRemoteServer, cmd,255)
					client_print(0,print_chat,"Packet manager get : %s",extr)
					return PLUGIN_HANDLED 
				}
				if (containi(readline,"[Version]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					if (containi(Amxmodx_version,extr)==-1)
					{
						client_print(0,print_chat,"Wrong Amxmodx version, please check last version on http://www.amxmodx.org")
						HPTStatus=0
						client_print(0,print_chat,"Installation stopped")
						return PLUGIN_HANDLED 
					}
					client_print(0,print_chat,"Packet manager get : %s",extr)
					
				}
				if (containi(readline,"[MkDir]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					if(dir_exists ( extr ) ==0)
						mkdir(extr)
					client_print(0,print_chat,"Packet manager create dir : %s",extr)
 
					
				}
				if (containi(readline,"[DeleteFile]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					if(dir_exists ( extr ) ==0)
						delete_file(extr)
					client_print(0,print_chat,"Packet manager delete file : %s",extr)
 
					
				}
				if (containi(readline,"[ServerExec]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					server_cmd("%s",extr) 
					client_print(0,print_chat,"Packet manager execute : '%s' ",extr)
				}
				if (containi(readline,"[Install]")!=-1)
				{
					write_file(HTPCurrentPacket,"[Done]",line-1)
					HPTStatus=4
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					formatex(cmd, 256, "%s*GetFile!*%s*",VERSION,extr) 
					socket_send2(sckRemoteServer, cmd,255)
					client_print(0,print_chat,"Packet manager get : %s",extr)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					client_print(0,print_chat,"Packet manager write plugin into config : %s",extr)
					formatex(cmd, 127, "%s/configs/plugins.ini",basedir)
					write_file(cmd,"",-1)
					write_file(cmd,extr,-1)
					return PLUGIN_HANDLED 
				}
				if (containi(readline,"[UnInstall]")!=-1)
				{
					new tpline
					new oline
					new rline[128]
					tpline=0
					write_file(HTPCurrentPacket,"[Done]",line-1)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					formatex(cmd, 127, "%s/%s",basedir,extr)
					delete_file(cmd)
					client_print(0,print_chat,"Packet manager remove : %s",extr)
					line= read_file(HTPCurrentPacket,line,extr,128,rien)
					write_file(HTPCurrentPacket,"[Done]",line-1)
					client_print(0,print_chat,"Packet manager remove plugin of config : %s",extr)
					formatex(cmd, 127, "%s/configs/plugins.ini",basedir)
					oline=tpline
					while (tpline= read_file(cmd,tpline,rline,127,rien))
					{
						if (containi(rline,extr)!=-1)
						{
							write_file(cmd,"",oline)
						}
						oline=tpline
					}
					
				}
			}
			line= read_file(HTPCurrentPacket,line,readline,127,rien)
		}
		HPTStatus=0
		server_print ( "Packet installed ! : %s", HTPCurrentPacket )
		client_print(0,print_chat,"Packet installed! : %s",HTPCurrentPacket  )		
		delete_file(HTPCurrentPacket)
		

	}
	return PLUGIN_HANDLED 
}
public handle_say(id) 
{
	static said[192]
	static cmd[512]
	read_args(said,192)

	if (ffac_showinfo)
	{
     	if (contain(said, "skill") != -1 )
    	{
			if(FFAReady[id])
			{
				client_print(id,print_chat,"Skill %d points ",skill[id])
			}
			else
			{
				client_print(id,print_chat,"Sorry, server can't obtain your skill !")
				client_putinserver(id)
				client_print(id,print_chat,"Server will try to get your skill again ...")
			}
		}
		if ((containi(said, "ffac")!=-1 && containi(said, "version")!=-1))
		{
			client_print(id,print_chat,"FFAC by http://82.232.102.55")
			client_print(id,print_chat,"Version ( revision 0.1 ) : ")
			client_print(id,print_chat,VERSION)
		}		
	/*	if (containi(said, "ffac") != -1 && containi(said, "changelog") != -1   )
		{
			formatex(cmd, 131,"http://82.232.102.55/FFAC/changelog.txt")
			show_motd(id, cmd, "FFAC http://82.232.102.55/FFAC")
		}*/
		if (containi(said, "ffac") != -1 && containi(said, "debug") != -1   )
		{
			client_print(id, print_chat,"Stats support Cstrike=%d, TFC=%d, DOD=%d",cstrike_stats,tfc_stats,dod_stats)
		}
		if (containi(said, "rank") != -1 )
		{
		
			if (RankSkill[id]==0)
			{
				get_user_authid(id,szAuthID,32)
				formatex(cmd, 128, "%s^"Rank?^"%s^"%d^"",VERSION, szAuthID,id) 
				socket_send2(sckRemoteServer, cmd,128)
				client_print(id,print_chat,"Server ask your Rank, please wait !")
			}
			else
			{
				client_print(id,print_chat,"Rank on FFAC : %d by Skill, %d by Score",RankSkill[id],RankCSStats[id])
				client_print(id,print_chat,"Server Rank : %d by Skill, %d by Score",RankSkillServer[id],RankCSServer[id])
			}
		}		
	}
	if(  containi(said, "!log") != -1  )
	{
		if(ffac_plog)
		{
			get_user_authid(id,szAuthID,32)
			formatex(cmd, 128, "%s^"Log!^"%s^"%s^"",VERSION, szAuthID,said) 
			socket_send2(sckRemoteServer, cmd,127)
		}
	}
		
	return PLUGIN_CONTINUE
}

public set_nickname(id)
{
	new cmd[128]
	get_user_name(id,szName,127)
	get_user_authid(id,szAuthID,32)
	formatex(cmd, 128, "%s^"Name!^"%s^"%s^"",VERSION, szAuthID,szName) 
	socket_send2(sckRemoteServer, cmd,127)
}

//Specific stats treatment !
//************************************** CS
public cs_drop_the_bomb() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][0]=TPAction[id][0]+1
	}

}  
public cs_got_the_bomb() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][1]=TPAction[id][1]+1
	}
} 
public cs_bomb_planted() 
{
    new id = get_loguser_index()
	LastIdMainAction = id
	if(FFAReady[id])
	{
		TPAction[id][2]=TPAction[id][2]+1
	}
} 
public cs_bomb_defused() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][3]=TPAction[id][3]+1
	}
} 
public cs_target_bombed() 
{
	new id = LastIdMainAction
	if(FFAReady[id])
	{
		TPAction[id][4]=TPAction[id][4]+1
	}
} 
//************************************** TFC	
public tfc_blue_flag() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][0]=TPAction[id][0]+1
	}
} 
public tfc_red_flag() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][1]=TPAction[id][1]+1
	}
} 
public tfc_red_capture() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][2]=TPAction[id][2]+1
	}
} 
public tfc_blue_capture() 
{
	new id = get_loguser_index()
	if(FFAReady[id])
	{
		TPAction[id][3]=TPAction[id][3]+1
	}
} 
	

		
//from Ven bomb scripting tutorial

stock get_loguser_index() {
    new loguser[80], name[32]
    read_logargv(0, loguser, 79)
    parse_loguser(loguser, name, 31)
 
    return get_user_index(name)
}  