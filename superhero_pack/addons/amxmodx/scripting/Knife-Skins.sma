#include <amxmodx> 
#include <amxmisc> 
#include <engine>  
#include <vault> 
#include <hamsandwich> 
#include <fvault> 

#pragma tabsize 0

#define is_valid_player(%1) (1 <= %1 <= 32)

new knife_model[33];

new const g_VAULTNAME[] = "Knife-Skins";
new const VERSION[] = "2.2" 
new const AUTHOR[] = "Asafmazon." 


new iLevel[33];
new iXp[33];

new knife_on;

new MaxLevel;
new StartedLevel;

new cvar_KillXp;
new cvar_HsXp;
new cvar_KnifeXp;

new Forward_spawn;
new Forward_levelup;
new ForwardReturn;

new const g_KnifeNames[][32] =
{
	"Normal Knife",
	"Alien Knife",
	"Ellium Dagger",
	"Dark Dagger",
	"Transparent Knife",
	"Genuine Dagger",
	"Hunt Blade",
	"Shadow Blade",
	"Slaughterer Axe",
	"Golden Katana",
	"Assasin's Blade",
	"Lightsaber",
	"Bloody Wolverine Claws",
	"Proton Axe"
};

new const g_KnifevModels[][256] =
{
	"models/v_knife.mdl",
	"models/Knifes/v_knife_alien.mdl",
	"models/Knifes/v_knife_ellium.mdl",
	"models/Knifes/v_knife_dark.mdl",
	"models/Knifes/v_knife_transparent.mdl",
	"models/Knifes/v_knife_genuine.mdl",
	"models/Knifes/v_knife_hunt.mdl",
	"models/Knifes/v_knife_shadow.mdl",
	"models/Knifes/v_knife_slaughterer.mdl",
	"models/Knifes/v_knife_katana.mdl",
	"models/Knifes/v_knife_assasins.mdl",
	"models/Knifes/v_knife_lightsaber.mdl",
	"models/Knifes/v_knife_wolverine.mdl",
	"models/Knifes/v_knife_proton.mdl"
}

native register_maxlevels( maxlevel = 99, started_xp_level = 100 );
native get_user_level( index );
native get_user_xp( index );

public plugin_init() {  
	
	register_plugin(g_VAULTNAME, VERSION, AUTHOR);
	register_cvar("knife_skins", VERSION, FCVAR_SERVER); // Find Servers on Game-Monitor
	set_cvar_string("knife_skins", VERSION); // Find Servers on Game-Monitor
	
	// register max levels 13 is the top level, 100 is the started level xp.
	register_maxlevels( 13, 100 );
	
	//Admin commands
	
	register_concmd("knife_givexp" ,"givexp",ADMIN_RCON,"Add xp to a player")
	register_concmd("knife_takexp", "takexp",ADMIN_RCON,"Remove xp from a player")
	
	//Clcmd's
	
	knife_on = register_cvar( "knife_skins", "1" );
	
	register_clcmd("say","HandleSay"); 
	register_clcmd("say_team","HandleSay")
	register_clcmd("say /knife", "KnifeSkinsMenu");
	register_clcmd("say /level", "PlayerLevelsMenu");
	
	//Event's
	
	register_event("CurWeapon","CurWeapon","be","1=1");
	register_event( "DeathMsg", "EventDeathMsg", "a" );
	
	//Cvar's
	
	cvar_KillXp = register_cvar( "kill_xp", "5" );
	cvar_HsXp = register_cvar( "hs_xp", "2" );
	cvar_KnifeXp = register_cvar( "knife_xp", "3" );
	
	//Ham's
	
	RegisterHam( Ham_Spawn, "player", "FwdPlayerSpawn", 1 );
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	//Forward's
	
	Forward_levelup = CreateMultiForward( "forward_client_levelup", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL );
	Forward_spawn = CreateMultiForward( "forward_client_spawn", ET_IGNORE, FP_CELL , FP_CELL, FP_CELL );
	
	set_task(15.0, "Knifemessage", 0, _, _, "b")
	set_task(35.0, "Levelmessage", 0, _, _, "b")
} 

public plugin_precache() {  
	
	precache_model("models/Knifes/v_knife_alien.mdl")  
	precache_model("models/Knifes/v_knife_ellium.mdl")  
	precache_model("models/Knifes/v_knife_dark.mdl") 
	precache_model("models/Knifes/v_knife_transparent.mdl") 
	precache_model("models/Knifes/v_knife_genuine.mdl") 
	precache_model("models/Knifes/v_knife_hunt.mdl") 
	precache_model("models/Knifes/v_knife_shadow.mdl") 
	precache_model("models/Knifes/v_knife_slaughterer.mdl") 
	precache_model("models/Knifes/v_knife_katana.mdl") 
	precache_model("models/Knifes/v_knife_assasins.mdl") 
	precache_model("models/Knifes/v_knife_lightsaber.mdl") 
	precache_model("models/Knifes/v_knife_wolverine.mdl") 
	precache_model("models/Knifes/v_knife_proton.mdl") 
	
}

public plugin_natives( )
{
	//Native's
	
	register_library( "Knife-Skins" );
	
	register_native( "register_maxlevels", "_register_maxlevels" );
	register_native( "get_user_level", "_get_user_level" );
	register_native( "set_user_level", "_set_user_level" );
	register_native( "get_user_xp", "_get_user_xp" );
	register_native( "set_user_xp", "_set_user_xp" );
}

public _register_maxlevels( plugin, params )
{
	if( MaxLevel != 0 && StartedLevel != 0 )
	{
		return;
	}
	else
	{
		MaxLevel = get_param( 1 );
		StartedLevel = get_param( 2 );
	}
}

public _get_user_level( plugin, params )
{
	return iLevel[ get_param( 1 ) ];
}

public _set_user_level( plugin, params )
{
	iLevel[ get_param( 1 ) ] = max( get_param( 2 ), MaxLevel );
	
	FlsahLevelUp( get_param( 1 ) );
	
	SaveData( get_param( 1 ) );
	
	LoadData( get_param( 1 ) );
}

public _get_user_xp( plugin, params )
{
	return iXp[ get_param( 1 ) ];
}

public _set_user_xp( plugin, params )
{
	iXp[ get_param( 1 ) ] = get_param( 2 );
	
	CheckLevel( get_param( 1 ) );
	
	SaveData( get_param( 1 ) );
	
	LoadData( get_param( 1 ) );
}

public CheckLevel( id )
{
	if( iLevel[id] == MaxLevel )
	{
		return;
	}
	else
	{
		new level = iLevel[id] > 0 ? iLevel[id] : 1;
		
		new xp = level * StartedLevel;
		
		if( iLevel[id] > 0 )
		{
			xp +=  ( xp * 4 / 2 );
		}
		
		while( iXp[id] >= xp )
		{
			iLevel[id]++;
			
			ColorChat(id,"^4Congratulations!^1 You'r have level up! You'r new^4 LEVEL^1 is: ^3%i^1.", iLevel[id]); 
			ColorChat(0,"^3%s^1 has level up to^4 LEVEL^3 %i^1!",get_player_name(id), iLevel[id]); 
			
			FlsahLevelUp(id);
			
			ExecuteForward( Forward_levelup, ForwardReturn, id, iLevel[id], iXp[id] );
			
			SaveData( id );
			
			CheckLevel( id );
			
			break;
		}
	}
}

public FlsahLevelUp( id )
{
	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), { 0, 0, 0}, id );
	write_short( 1 << 10 );
	write_short( 1 << 10 );
	write_short( 0 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 215 );
	write_byte( 100 );
	message_end( );
}


public HandleSay(id){
	
	if (get_pcvar_num(knife_on) == 0)
	{
		ColorChat(id, "The mod has been disabale.");
		return PLUGIN_HANDLED;
	}
	
	new iMsg[200], iArgs[4][60]; 
	new level = iLevel[id] > 0 ? iLevel[id] : 1;
	
	new xp = level * StartedLevel;
	
	if( iLevel[id] > 0 )
	{
		xp +=  ( xp * 4 / 2 );
	}
	
	read_argv(1,iMsg ,sizeof iMsg - 1); 
	parse(iMsg,iArgs[0],charsmax(iArgs[]),iArgs[1],charsmax(iArgs[]),iArgs[2],charsmax(iArgs[]),iArgs[3],charsmax(iArgs[])); 
	
	if (equali(iArgs[0],"/level") || equali(iArgs[0],"/lvl") || equali(iArgs[0],"/xp")) 
	{     
		new player = cmd_target(id,iArgs[1],CMDTARGET_NO_BOTS); 
		
		if (!player) 
		{ 
			ColorChat( id, "Your^4 LEVEL^1 is:^3 %i^4 |^1 Your^4 XP^1 is:^3 %i^1/^3%i^1.", iLevel[id], iXp[id], xp );
		} 
	} 
	
	return 0; 
} 

public EventDeathMsg(id)
{
	if (get_pcvar_num(knife_on) == 0)
	return PLUGIN_HANDLED;
	
	new killer = read_data( 1 );
	new victim = read_data( 2 );
	
	if( killer == victim || ! is_user_connected( killer ) || ! is_user_connected( victim ) )
	{
		return PLUGIN_HANDLED;
		//return;
	}
	
	new XpAmount = get_pcvar_num( cvar_KillXp );
	
	if( read_data( 3 ) )
	{
		XpAmount += get_pcvar_num( cvar_HsXp );
	}
	
	static sWeapon[ 26 ];
	
	read_data( 4, sWeapon, sizeof( sWeapon ) - 1 );
	
	
	if( equal( sWeapon, "knife" ) )   
	{
		XpAmount += get_pcvar_num( cvar_KnifeXp );
	}
	
	iXp[ killer ] += XpAmount;
	
	CheckLevel( killer );
	
	SaveData( killer );
	
	ColorChat( killer, "You have gained^3 %i^1 XP.", XpAmount );
	
	return PLUGIN_HANDLED;
}

public FwdPlayerSpawn( id )
{
	ExecuteForward( Forward_spawn, ForwardReturn, id, iLevel[id], iXp[id] );
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if( get_pcvar_num( knife_on ) == 0 )
	return HAM_IGNORED;
	
	if( is_valid_player( attacker ) && get_user_weapon(attacker) == CSW_KNIFE )
	{
		SetHamParamFloat(4, damage + knife_model[attacker]);
		
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public KnifeSkinsMenu(id) { 
	
	if (get_pcvar_num(knife_on) == 0)
	{
		ColorChat(id, "The mod has been disabale.");
		return PLUGIN_HANDLED;
	}
	
	new szItem[256], szAlien[50], szEllium[50], szDark[50], szTransparent[50], szGenuine[50], szHunt[50], szShadow[50], szSlaughterer[50], szKatana[50], szAssasins[50],
	szLightsaber[50], szWolverine[50], szProton[50];
	
	new level = iLevel[id] > 0 ? iLevel[id] : 1;
	
	new xp = level * StartedLevel;
	
	if( iLevel[id] > 0 )
	{
		xp +=  ( xp * 4 / 2 );
	}
	
	formatex(szItem, charsmax(szItem), "\w[ \r%s \w] \yKnife Skins Menu \rv%s^n\yYour Level: \r%d \w- \yYour XP: \r%d\w/\r%d\w.^n\yPage:\r", g_VAULTNAME, VERSION,iLevel[id],iXp[id], xp);
	formatex(szAlien, charsmax(szAlien),"%s", iLevel[id] >= 1 ? "\wAlien Knife [\yUNLOCKED\w]" : "\d???? ????? [\rLEVEL 1 REQUIRE\d]");
	formatex(szEllium, charsmax(szEllium),"%s", iLevel[id] >= 2 ? "\wEllium Knife [\yUNLOCKED\w]" : "\d?????? ?????? [\rLEVEL 2 REQUIRE\d]");
	formatex(szDark, charsmax(szDark),"%s", iLevel[id] >= 3 ? "\wDark Dagger [\yUNLOCKED\w]" : "\d???? ?????? [\rLEVEL 3 REQUIRE\d]");
	formatex(szTransparent, charsmax(szTransparent),"%s", iLevel[id] >= 4 ? "\wTransparent Knife [\yUNLOCKED\w]" : "\d??????????? ????? [\rLEVEL 4 REQUIRE\d]");
	formatex(szGenuine, charsmax(szGenuine),"%s", iLevel[id] >= 5 ? "\wGenuine Dagger [\yUNLOCKED\w]" : "\d??????? ?????? [\rLEVEL 5 REQUIRE\d]");
	formatex(szHunt, charsmax(szHunt),"%s", iLevel[id] >= 6 ? "\wHunt Blade [\yUNLOCKED\w]" : "\d???? ????? [\rLEVEL 6 REQUIRE\d]");
	formatex(szShadow, charsmax(szShadow),"%s", iLevel[id] >= 7 ? "\wShadow Blade [\yUNLOCKED\w]" : "\d?????? ????? [\rLEVEL 7 REQUIRE\d]");
	formatex(szSlaughterer, charsmax(szSlaughterer),"%s", iLevel[id] >= 8 ? "\wSlaughterer Axe [\yUNLOCKED\w]" : "\d??????????? ??? [\rLEVEL 8 REQUIRE\d]");
	formatex(szKatana, charsmax(szKatana),"%s", iLevel[id] >= 9 ? "\wGolden Katana [\yUNLOCKED\w]" : "\d?????? ?????? [\rLEVEL 9 REQUIRE\d]");
	formatex(szAssasins, charsmax(szAssasins),"%s", iLevel[id] >= 10 ? "\wAssasin's Blade [\yUNLOCKED\w]" : "\d???????? ????? [\rLEVEL 10 REQUIRE\d]");
	formatex(szLightsaber, charsmax(szLightsaber),"%s", iLevel[id] >= 11 ? "\wLightsaber [\yUNLOCKED\w]" : "\d?????????? [\rLEVEL 11 REQUIRE\d]");
	formatex(szWolverine, charsmax(szWolverine),"%s", iLevel[id] >= 12 ? "\wBloody Wolverine Claws [\yUNLOCKED\w]" : "\d?????? ????????? ????? [\rLEVEL 12 REQUIRE\d]");
	formatex(szProton, charsmax(szProton),"%s", iLevel[id] >= 13 ? "\wProton Axe [\yUNLOCKED\w]" : "\d?????? ??? [\rLEVEL 13 REQUIRE\d]");
	
	new menu = menu_create( szItem, "KnifeSkinsMenu_Handler" ); 
	menu_additem(menu, "\wNormal Knife [\yUNLOCKED\w]", "", 0 );
	menu_additem(menu, szAlien, "", iLevel[id] >= 1 ? 0 : 1);
	menu_additem(menu, szEllium, "", iLevel[id] >= 2 ? 0 : 1);
	menu_additem(menu, szDark, "", iLevel[id] >= 3 ? 0 : 1);
	menu_additem(menu, szTransparent, "", iLevel[id] >= 4 ? 0 : 1);
	menu_additem(menu, szGenuine, "", iLevel[id] >= 5 ? 0 : 1);
	menu_additem(menu, szHunt, "", iLevel[id] >= 6 ? 0 : 1);
	menu_additem(menu, szShadow, "", iLevel[id] >= 7 ? 0 : 1);
	menu_additem(menu, szSlaughterer, "", iLevel[id] >= 8 ? 0 : 1);
	menu_additem(menu, szKatana, "", iLevel[id] >= 9 ? 0 : 1);
	menu_additem(menu, szAssasins, "", iLevel[id] >= 10 ? 0 : 1);
	menu_additem(menu, szLightsaber, "", iLevel[id] >= 11 ? 0 : 1);
	menu_additem(menu, szWolverine, "", iLevel[id] >= 12 ? 0 : 1);
	menu_additem(menu, szProton, "", iLevel[id] >= 13 ? 0 : 1);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu, 0 );
	
	return PLUGIN_HANDLED;
} 

public KnifeSkinsMenu_Handler(id, menu, item) 
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	SetKnife(id, item);
	ColorChat(id, "The knife you chose is: ^4%s^1.", g_KnifeNames[item]);
	
	SaveData(id);
	return PLUGIN_HANDLED;
}

public SetKnife(id, item) { 
	
	knife_model[id] = item
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo)  
	if ( Weapon != CSW_KNIFE ) 
	return PLUGIN_HANDLED 
	
	new vModel[56],pModel[56] 
	
	if (get_pcvar_num(knife_on) == 0)
	{
		format(vModel,55,"models/v_knife.mdl") 
		return PLUGIN_HANDLED;
	}
	
	format(vModel,55, g_KnifevModels[item]) 
	format(pModel,55,"models/p_knife.mdl")
	entity_set_string(id, EV_SZ_viewmodel, vModel) 
	entity_set_string(id, EV_SZ_weaponmodel, pModel) 
	
	return PLUGIN_HANDLED;   
}

public PlayerLevelsMenu(id)
{	
	if (get_pcvar_num(knife_on) == 0)
	{
		ColorChat(id, "The mod has been disabale.");
		return PLUGIN_HANDLED;
	}
	
	new some[256], menu;
	
	static players[32],szTemp[10],pnum;	
	get_players(players,pnum,"ch");
	
	formatex(some,255,"\w[ \r%s \w] \yPlayer's Level:\r", g_VAULTNAME);
	
	menu = menu_create(some,"PlayerLevelsMenu_Handler");
	
	for (new i; i < pnum; i++)
	{
		new level = iLevel[players[i]] > 0 ? iLevel[players[i]] : 1;
		
		new xp = level * StartedLevel;
		
		if( iLevel[players[i]] > 0 )
		{
			xp +=  ( xp * 4 / 2 );
		}
		
		formatex(some,256,"%s \y(Level: \r%i\y) \w- \y(XP: \r%i\w/\r%i\y)",get_player_name(players[i]), iLevel[players[i]], iXp[players[i]], xp);
		num_to_str(players[i],szTemp,charsmax(szTemp));
		menu_additem(menu, some, szTemp);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public PlayerLevelsMenu_Handler(id,menu, item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[6] ,szName[64],access,callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new player = str_to_num(data);
	
	new level = iLevel[player] > 0 ? iLevel[player] : 1;
	
	new xp = level * StartedLevel;
	
	if( iLevel[player] > 0 )
	{
		xp +=  ( xp * 4 / 2 );
	}
	
	ColorChat(id,"^3%s's ^4LEVEL ^1is: ^3%i ^1with ^3%i^1/^3%i ^4XP^1.",get_player_name(player), iLevel[player], iXp[player], xp);
	PlayerLevelsMenu(id);
}

public CurWeapon(id) 
{
	// Set Knife Model
	SetKnife(id, knife_model[id])
} 

public givexp(id) {
	if (get_pcvar_num(knife_on) == 0)
	{
		ColorChat(id, "The mod has been disabale.");
		return PLUGIN_HANDLED;
	}
	
	if( get_user_flags( id ) & ADMIN_RCON ) {
		
		new PlayerToGive[32], XP[32]
		read_argv(1,PlayerToGive,31)
		read_argv(2,XP, 31)
		new Player = cmd_target(id,PlayerToGive,9)
		
		if(!Player) {
			
			return PLUGIN_HANDLED
			
		}
		
		new XPtoGive = str_to_num(XP)
		new name[32],owner[32]
		get_user_name(id,owner,31)
		get_user_name(Player,name,31)
		ColorChat(0,"^4ADMIN^3 %s^1 give to^4 %s^3 %s^1 XP.", owner,name,XP );
		iXp[Player]+= XPtoGive
		CheckLevel(Player);
		SaveData(id)
		
	}
	
	else {
		
		client_print(id,print_console,"You have no acces to that command")
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED;
}

public takexp(id) {
	if (get_pcvar_num(knife_on) == 0)
	{
		ColorChat(id, "The mod has been disabale.");
		return PLUGIN_HANDLED;
	}
	
	if(get_user_flags(id) & ADMIN_RCON ) {
		
		
		new PlayerToTake[32], XP[32]
		read_argv(1,PlayerToTake,31 )
		read_argv(2,XP,31 )
		new Player = cmd_target(id,PlayerToTake,9)
		
		if(!Player) {
			
			return PLUGIN_HANDLED
			
		}
		
		new XPtoTake = str_to_num(XP)
		new name[32],owner[32]
		get_user_name(id,owner,31)
		get_user_name(Player,name,31)
		ColorChat(0,"^4ADMIN^3 %s^1 take to^4 %s^3 %s^1 XP.", owner,name,XP );
		iXp[ Player ]-=XPtoTake
		CheckLevel(Player);
		SaveData(id)
		
	}
	
	else {
		
		client_print(id,print_console,"You have no acces to that command.")
		
		return PLUGIN_HANDLED
		
	}
	
	return PLUGIN_HANDLED;
}

public client_disconnected(id) {   
	
	if(task_exists(id)){
		remove_task(id) 
	}
	SaveData(id);
}   


public Knifemessage(id) { 
	
	if (get_pcvar_num(knife_on) == 0)
	return PLUGIN_HANDLED;
	
	ColorChat(0, "Type ^3/knife ^1in chat to open the ^4Knife Skins Menu^1."); 
	ColorChat(0, "This server is running ^4%s ^3v%s^1 by ^4%s^1.",g_VAULTNAME, VERSION, AUTHOR)
	return PLUGIN_HANDLED;
}   

public Levelmessage(id) { 
	
	if (get_pcvar_num(knife_on) == 0)
	return PLUGIN_HANDLED;
	
	ColorChat(0,"To see other ^4Players Level ^1type ^3/level ^1in chat."); 
	return PLUGIN_HANDLED;
}

public client_putinserver(id) LoadData(id);

public SaveData(id){ 
	
	new authid[32] 
	get_user_authid(id, authid, 31) 
	
	new vaultkey[64] 
	new vaultdata[64] 
	
	format(vaultkey, 63, "KNIFEMOD_%s", authid) 
	format(vaultdata, 63, "%d", knife_model[id]) 
	set_vaultdata(vaultkey, vaultdata)
	
	new data[ 16 ];
	
	get_user_authid( id, authid, sizeof( authid ) - 1 );
	
	formatex( data, sizeof( data ) - 1, "%d %d", iLevel[id], iXp[id] );
	
	fvault_set_data(g_VAULTNAME, authid, data );
	
	return;
	
	
} 

public LoadData(id){ 
	
	new authid[32]  
	get_user_authid(id,authid,31) 
	
	new vaultkey[64], vaultdata[64] 
	
	format(vaultkey, 63, "KNIFEMOD_%s", authid) 
	get_vaultdata(vaultkey, vaultdata, 63) 
	knife_model[id] = str_to_num(vaultdata)
	
	new data[ 16 ], szLevel[ 8 ], szXp[ 8 ];
	
	get_user_authid( id, authid, sizeof( authid ) - 1 );
	
	if( fvault_get_data(g_VAULTNAME, authid, data, sizeof( data ) - 1 ) )
	{
		argbreak( data, szLevel, sizeof( szLevel ) - 1, szXp, sizeof( szXp ) - 1 );
		
		iLevel[id] = str_to_num( szLevel );
		iXp[id] = str_to_num( szXp );
		
		return;
	}
	else
	{
		iLevel[id] = 0;
		iXp[id] = 0;
		
		return;
	}
}

stock get_player_name(id){
	static szName[32];
	get_user_name(id,szName,31);
	return szName;
}

stock ColorChat( const id, const string[ ], { Float, Sql, Resul, _ } : ... )
{
	new msg[ 191 ], players[ 32 ], count = 1;
	
	static len;
	len = formatex( msg, charsmax( msg ), "^x04[^x01 Knife-Skins^x04 ]^x01 " );
	vformat( msg[ len ], charsmax( msg ) - len, string, 3 );
	
	if( id )
	players[ 0 ] = id;
	else
	get_players( players,count,"ch" );
	
	for( new i = 0; i < count; i++ )
	{
		if( is_user_connected( players[i] ) )
		{
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _ , players[ i ] );
			write_byte( players[ i ] );
			write_string( msg );
			message_end( );
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
