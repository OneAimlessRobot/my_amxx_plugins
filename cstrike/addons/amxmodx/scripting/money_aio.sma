/********************************************************************************

			Plugin name: Money All-in-One
			
			Version: 3.02
			
			Author: tomcash@263.net

*********************************************************************************

Cvars & default value 
------------------------------
Amx_startmoney 800 //Fully instead of mp_startmoney.

Amx_maxmoney 30000 // Max money player can have.

Amx_bonus_planter 500 // Bonus for C4 planter. Set 0 to disable.

Amx_bonus_explode 500 // Bonus for the planter when C4 was exploded. Set 0 to disable.

Amx_bonus_defuser 1000 // Bonus for who defused C4 bomb. Set 0 to disable.

Amx_bonus_headshot 200 // Bonus for player who headshot someone. Set 0 to disable.

Amx_bonus_o4killer 200 // Bonus for player who killed someone by grenade. Set 0 to disable.

Amx_bonus_9fkiller 5000 // Bonus for player who killed someone by knife. Set 0 to disable.

Amx_bonus_1stkiller 1000 // Bonus for the first killer in a round. Set 0 to disable as well as tow cvars followed.

Amx_bonus_2ndkiller 500 // Bonus for the second killer in a round. Set 0 to disable.

Amx_bonus_3rdkiller 300 // Bonus for the third killer in a round. Set 0 to disable.

Amx_servertag "" // A tag displayed at the head of color message, Need restart to enable change.

Amx_setgmnum 500 1000 2000 5000 10000 // See command explaination


Commands
-------------------------------
Amx_moneymenu 

// Display Give Money to Player Menu.

Amx_setgmnum <amount1> [amount2] [amount3] ...

// Set the menu¡¯s option amount. 

Amx_givemoney <target> <amount> 

//Give player money Command, <target> should be player name, or put a ¡®@¡¯ as prefix to group player. 

********************************************************************************************/




// Modules...
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>


//Constants..

#define MAX_CLIENTS 	32 + 1



// Globle variables...
new g_client_connected[MAX_CLIENTS]
new g_client_money[MAX_CLIENTS]
new g_rankcounter		
new g_restartround		
new Array:g_moneysettings
new g_tag[32]

// Cvars........
new amx_servertag
new amx_startmoney
new amx_maxmoney
new amx_bonus_planter
new amx_bonus_explode
new amx_bonus_defuser
new amx_bonus_1stkiller
new amx_bonus_2ndkiller
new amx_bonus_3rdkiller
new amx_bonus_headshot
new amx_bonus_9fkiller
new amx_bonus_o4killer



public plugin_init() {
	register_plugin("Money All-in-One", "3.02", "tomcash@263.net")
	register_dictionary("money_aio.txt")
	
	register_logevent("fn_restartround",2,"0=World triggered","1&Restart_Round_","1&Game_Commencing")
	register_logevent("fn_roundstart",2,"0=World triggered","1&Round_Start")
	register_logevent("fn_joinfromspec",3,"1=joined team")
	register_event("RoundTime","fn_newround","bde")
	register_event("Money","fn_event_money","b")
	
	register_srvcmd("amx_setgmnum", "fn_setgmnum")	
	register_concmd("amx_givemoney", "fn_cmd_givemoney", ADMIN_KICK, "<target> <amount>")
	register_concmd("amx_moneymenu", "fn_cmdGM2PMenu", ADMIN_KICK, "- displays Give Money to Player Menu")
	register_menucmd(register_menuid("Give Money to Player Menu"), 1023, "fn_actionGM2PMenu")
	
	amx_servertag		= register_cvar("amx_bonus_servertag","")
	amx_startmoney		= register_cvar("amx_startmoney", "800")
	amx_maxmoney		= register_cvar("amx_maxmoney", "30000")
	amx_bonus_planter	= register_cvar("amx_bonus_planter", "500")
	amx_bonus_explode	= register_cvar("amx_bonus_explode", "500")
	amx_bonus_defuser	= register_cvar("amx_bonus_defuser", "1000")
	amx_bonus_1stkiller	= register_cvar("amx_bonus_1stkiller", "1000")
	amx_bonus_2ndkiller	= register_cvar("amx_bonus_2ndkiller", "500")
	amx_bonus_3rdkiller	= register_cvar("amx_bonus_3rdkiller", "300")
	amx_bonus_headshot	= register_cvar("amx_bonus_headshot", "200")
	amx_bonus_9fkiller	= register_cvar("amx_bonus_9fkiller", "5000")
	amx_bonus_o4killer	= register_cvar("amx_bonus_o4killer", "200")
	
	
	g_moneysettings = ArrayCreate();	
	ArrayPushCell(g_moneysettings, 500); 
	ArrayPushCell(g_moneysettings, 1000); 
	ArrayPushCell(g_moneysettings, 2000);
	ArrayPushCell(g_moneysettings, 5000);
	ArrayPushCell(g_moneysettings, 10000);
	
}

public plugin_cfg(){
	
	get_pcvar_string(amx_servertag,g_tag,31)
}

public client_connect(id){// Set flag for reset money when player connect...
	
	g_client_connected[id]	= 1    	

}

public fn_restartround(){//Set flag for sv_restart/sv_restartround commands ...
	
	g_restartround	= 1
	
}

public fn_newround(id){//I'v tried HLTV event msg, but it cause wrong result...
					//Because HLTV event happened too earlier...
	if(g_restartround)
		fn_resetmoney(id)

}

public fn_roundstart(){
	
	g_restartround	= 0		//The flag MUST put here to turn off!!!
	g_rankcounter 	= 0
	
}


public fn_joinfromspec(){//If someone join game from spectator, his money must be reset...
	
	new text[64],name[32],previous_team[8]
	
	read_logargv(0,text,63)
	
	parse_loguser(text,name,31,_,_,_,previous_team,7)
	
	if(previous_team[0]=='S')
		fn_resetmoney(get_user_index(name))		
}



public fn_resetmoney(id){//Reset player's money to amx_startmoney when connecting, restartround,... etc.
	
	g_client_money[id] = get_pcvar_num(amx_startmoney)
	
	fn_breakmoney(id,g_client_money[id]) 	// fn_breakmoney(id,flash_offset), flash_offset:the value flashing on HUD...

}

public fn_event_money(id){//I guess this event was fired by HL only.....
	
	if(g_client_connected[id]){		//I hate put it here! But where it shoud be...?
		
		fn_resetmoney(id)
		g_client_connected[id] = 0
		
		return PLUGIN_HANDLED
	}
	
	
	new current_money = read_data(1)
	
	new money_offset = 0
	
	if(g_client_money[id]>=10000){			//Calculate the veriation of player's money...
		money_offset = current_money - 10000
	}
	else{
		money_offset = current_money - g_client_money[id]
	}
	
	fn_add_player_money(id,money_offset)		//fn_add_player_money(id,addtion), addtion:the value to add.
	
	return PLUGIN_CONTINUE	
}

public fn_add_player_money(id,addtion){//Short BUT usefull func to calculate player's money....
		
	g_client_money[id]+= addtion
	
	fn_breakmoney(id,addtion)
	
}

public fn_breakmoney(id,flash_offset){//Engine of money break out 16000......
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	new maxmoney = get_pcvar_num(amx_maxmoney)
	
	g_client_money[id] = (g_client_money[id]>maxmoney)?maxmoney:g_client_money[id]
	
	g_client_money[id] = (g_client_money[id]<0)?0:g_client_money[id]	
	
	if(g_client_money[id]>=10000){// When I clear my brain, I found it is very simple....

		cs_set_user_money(id,10000,0)
		
	}
	else{			

		cs_set_user_money(id, g_client_money[id], 0)
		
	}
	
	message_begin( MSG_ONE,get_user_msgid("Money"),{0,0,0},id)  // Code from Ramono, very cute method :)
	write_long(g_client_money[id]-flash_offset)
	write_byte(0)
	message_end()
	
	message_begin( MSG_ONE,get_user_msgid("Money"),{0,0,0},id) 
	write_long(g_client_money[id])
	write_byte(1)
	message_end()
	
	return PLUGIN_CONTINUE
}



//----------------------------Bonus----------------------------------------------

public bomb_planted(planter){             //CSX native function...
	
	new bonus=get_pcvar_num(amx_bonus_planter)
	
	if(!bonus)
		return PLUGIN_HANDLED
	
	fn_add_player_money(planter,bonus)
	
	new name[32+2], s_bonus[8], msg[256]
	get_user_name(planter,name,31)
	format(name,33,"^x03%s^x01",name)
	format(s_bonus,7,"^x04%d^x01",bonus)
	
	new i,players[32],player_num
	get_players(players,player_num)
	
	for(i=0;i<player_num;i++){
		format(msg,255,"^x01%s :: %L",g_tag,players[i],"BOMB_PLANTED",name,s_bonus)
		fn_colorprint(players[i],planter,msg)
	}
	return PLUGIN_CONTINUE	
} 

public bomb_defused(defuser){            //CSX native function...
	
	new bonus=get_pcvar_num(amx_bonus_defuser)
	
	if(!bonus)
		return PLUGIN_HANDLED
	
	fn_add_player_money(defuser,bonus)
	
	new name[32+2], s_bonus[8], msg[256]
	get_user_name(defuser,name,31)
	format(name,33,"^x03%s^x01",name)
	format(s_bonus,7,"^x04%d^x01",bonus)
	
	new i,players[32],player_num
	get_players(players,player_num)
	
	for(i=0;i<player_num;i++){
		format(msg,255,"^x01%s :: %L",g_tag,players[i],"BOMB_DEFUSED",name,s_bonus)
		fn_colorprint(players[i],defuser,msg)
	}
	return PLUGIN_CONTINUE		
} 

public bomb_explode(planter){    //CSX native function...
	
	new bonus=get_pcvar_num(amx_bonus_explode)
	
	if(!bonus)
		return PLUGIN_HANDLED
	
	fn_add_player_money(planter,bonus)
	
	new name[32+2], s_bonus[8], msg[256]
	get_user_name(planter,name,31)
	format(name,33,"^x03%s^x01",name)
	format(s_bonus,7,"^x04%d^x01",bonus)
	
	new i,players[32],player_num
	get_players(players,player_num)
	for(i=0;i<player_num;i++){
		format(msg,255,"^x01%s :: %L",g_tag,players[i],"BOMB_EXPLODE",name,s_bonus)
		fn_colorprint(players[i],planter,msg)
	}
	return PLUGIN_CONTINUE
}

public client_death(killer,victim,wpnindex,hitplace,TK){ //CSX native function...
	
	if(TK || killer == victim)
		return PLUGIN_HANDLED
	
	new i,players[32],player_num
	get_players(players,player_num)
	
	new name[32+2], s_bonus[8], msg[256]
	
	new bonus=0
	
	get_user_name(killer,name,31)
	
	format(name,33,"^x03%s^x01",name)
	
	if(get_pcvar_num(amx_bonus_headshot) && hitplace==HIT_HEAD){			
		bonus+=get_pcvar_num(amx_bonus_headshot)
		format(s_bonus,7,"^x04%d^x01",get_pcvar_num(amx_bonus_headshot))
		for(i=0;i<player_num;i++){
			format(msg,255,"^x01%s :: %L",g_tag,players[i],"HEAD_SHOT",name,s_bonus)
			fn_colorprint(players[i],killer,msg)
		}
	}
	
	if(get_pcvar_num(amx_bonus_o4killer) && wpnindex==CSW_HEGRENADE){
		bonus+=get_pcvar_num(amx_bonus_o4killer)
		format(s_bonus,7,"^x04%d^x01",get_pcvar_num(amx_bonus_o4killer))
		for(i=0;i<player_num;i++){
			format(msg,255,"^x01%s :: %L",g_tag,players[i],"GRENADE_KILL",name,s_bonus)
			fn_colorprint(players[i],killer,msg)
		}
	}
	
	if(get_pcvar_num(amx_bonus_9fkiller) && wpnindex==CSW_KNIFE){
		bonus+=get_pcvar_num(amx_bonus_9fkiller)
		format(s_bonus,7,"^x04%d^x01",get_pcvar_num(amx_bonus_9fkiller))
		for(i=0;i<player_num;i++){
			format(msg,255,"^x01%s :: %L",g_tag,players[i],"KNIFE_KILL",name,s_bonus)
			fn_colorprint(players[i],killer,msg)
		}
	}
	
	new rk_bonus
	
	if(get_pcvar_num(amx_bonus_1stkiller)&& g_rankcounter<3){
		
		switch(g_rankcounter){
			case 0:rk_bonus=get_pcvar_num(amx_bonus_1stkiller)
			case 1:rk_bonus=get_pcvar_num(amx_bonus_2ndkiller)
			case 2:rk_bonus=get_pcvar_num(amx_bonus_3rdkiller)
		}
		
		bonus += rk_bonus
		format(s_bonus,7,"^x04%d^x01",rk_bonus)
		for(i=0;i<player_num;i++){				
			format(msg,255,"^x01%s :: %L",g_tag,players[i],"RUSH_KILL",name,g_rankcounter+1,s_bonus)
			fn_colorprint(players[i],killer,msg)
		}
	}
	
	fn_add_player_money(killer,bonus)
	
	g_rankcounter++
	
	return PLUGIN_CONTINUE
}

public fn_colorprint(playerid, colorid, msg[]){		//the code from google...Thanks the origin author.
	
	message_begin(playerid?MSG_ONE:MSG_ALL,get_user_msgid("SayText"),_,playerid) 
	write_byte(colorid)
	write_string(msg)
	message_end()
} 

public client_disconnect(id){
	g_client_money[id] = 0
}

//---------------------------Commands--------------------------------------------------

public fn_cmd_givemoney(id, level, cid){		//I refered the code in AMX Mod X Documentation wrote by BAILOPAN. 
						//BAILOPAN, YOU ARE A GREATER CODER !!!!!:D
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new Arg1[32]
	new Arg2[8]
	
	read_argv(1, Arg1, 31)
	read_argv(2, Arg2, 7)
	
	new amount = str_to_num(Arg2)
	
	
	if (Arg1[0] == '@')
	{
		new Team = 0
		
		if(equali(Arg1[1], "CT")){
			Team = 2
		} 
		else if(equali(Arg1[1], "T")) {
			Team = 1
		}
		
		new players[32], num
		
		get_players(players, num)
		
		for (new i=0; i<num; i++){
			
			if(!Team){
				fn_add_player_money(players[i],amount)
			} 
			else {
				
				if(get_user_team(players[i]) == Team)					
					fn_add_player_money(players[i],amount)
				
			}
		}
	} 
	else {
		new player = cmd_target(id, Arg1, 2)
		if (!player){
			console_print(id, "%L",LANG_PLAYER,"CMD_NO_TARGET", Arg1)
			return PLUGIN_HANDLED
		} 
		else {
			fn_add_player_money(player,amount)
		}
	}
	
	return PLUGIN_CONTINUE
}

//------------------------------------MENU-------------------------------------------------------
/*
	The idea from plmenu.sma, but modify the code was not a easy task.
	
*/


new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_menuOption[33]
new g_menuSettings[33]

public fn_cmdGM2PMenu(id, level, cid){
	
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	g_menuOption[id] = 0
	if (ArraySize(g_moneysettings) > 0){
		
		g_menuSettings[id] = ArrayGetCell(g_moneysettings, g_menuOption[id]);
	}
	else{
		g_menuSettings[id] = 0
	}
	
	fn_displayGM2PMenu(id, g_menuPosition[id] = 0)
	
	return PLUGIN_CONTINUE
}

fn_displayGM2PMenu(id, pos){
	
	if (pos < 0)
		return
	
	get_players(g_menuPlayers[id], g_menuPlayersNum[id])
	
	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 7
	
	if (start >= g_menuPlayersNum[id]+3)
		start = pos = g_menuPosition[id] = 0
	
	new end = start + 7
	
	if (end > g_menuPlayersNum[id]+3)
		end = g_menuPlayersNum[id]+3
	
	new keys = MENU_KEY_0|MENU_KEY_8
	new len = format(menuBody, 511,"\y%L\R%d/%d^n\w^n",id,"MENU_NAME", pos + 1, ((g_menuPlayersNum[id]+3) / 7 + (((g_menuPlayersNum[id]+3) % 7) ? 1 : 0)))
	
	for (new a = start; a < end; ++a)
	{
		keys |= (1<<b)
		if(a < g_menuPlayersNum[id]){
			i = g_menuPlayers[id][a]
			get_user_name(i, name, 31)
			
			if (is_user_admin(i)){
				len += format(menuBody[len], 511-len, "%d. %s \r*\y\R%d$^n\w" , ++b, name,g_client_money[i])
			}
			else{
				len += format(menuBody[len], 511-len, "%d. %s\y\R%d$^n\w" , ++b, name,g_client_money[i])
			}
		}
		
		if(a==g_menuPlayersNum[id])
			len += format(menuBody[len], 512-len, "^n%d. \y%L ^n\w" , ++b, id,"ALL_CTS")
		
		if(a==g_menuPlayersNum[id]+1)
			len += format(menuBody[len], 512-len,  "%d. \y%L ^n\w" , ++b, id, "ALL_TS")
		
		if(a==g_menuPlayersNum[id]+2)
			len += format(menuBody[len], 512-len,  "%d. \y%L ^n\w" , ++b, id,"ALL_PLAYERS")
		
		
		
		
	}
	
	
	len += format(menuBody[len], 511-len, "^n8. %L: %d^n", id,"MENU_AMOUNT", g_menuSettings[id])
	
	if (end != g_menuPlayersNum[id]+3){
		keys |= MENU_KEY_9
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MENU_MORE",id,  pos ? "MENU_BACK" : "MENU_EXIT")
	}
	else{
		format(menuBody[len], 511-len, "^n0. %L",id, pos ? "MENU_BACK" : "MENU_EXIT")
	}
	
	show_menu(id, keys, menuBody, -1, "Give Money to Player Menu")
	
}




public fn_actionGM2PMenu(id, key){
	
	switch (key)
	{
		case 7:{
			++g_menuOption[id]
			
			g_menuOption[id] %= ArraySize(g_moneysettings)
			
			g_menuSettings[id] = ArrayGetCell(g_moneysettings, g_menuOption[id])
			
			fn_displayGM2PMenu(id, g_menuPosition[id])
		}
		
		case 8: fn_displayGM2PMenu(id, ++g_menuPosition[id])
			
		case 9: fn_displayGM2PMenu(id, --g_menuPosition[id])
			
		default:{
			if(g_menuPosition[id] * 7 + key < g_menuPlayersNum[id]){			
				new player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

				fn_add_player_money(player,g_menuSettings[id])
				
				fn_displayGM2PMenu(id, g_menuPosition[id])

			}
			
			if(g_menuPosition[id] * 7 + key ==g_menuPlayersNum[id]){
				
				for(new i=0;i<g_menuPlayersNum[id];i++){
					if(get_user_team(g_menuPlayers[id][i])==2)
						fn_add_player_money(g_menuPlayers[id][i],g_menuSettings[id])
				}				
				fn_displayGM2PMenu(id, g_menuPosition[id])
				//add all CTs money
			}
			
			if(g_menuPosition[id] * 7 + key ==g_menuPlayersNum[id]+1){
				
				for(new i=0;i<g_menuPlayersNum[id];i++){
					if(get_user_team(g_menuPlayers[id][i])==1)
						fn_add_player_money(g_menuPlayers[id][i],g_menuSettings[id])
				}
				fn_displayGM2PMenu(id, g_menuPosition[id])
				//add all Ts money
			}
			
			if(g_menuPosition[id] * 7 + key ==g_menuPlayersNum[id]+2){
				
				for(new i=0;i<g_menuPlayersNum[id];i++){
					fn_add_player_money(g_menuPlayers[id][i],g_menuSettings[id])					
				}
				fn_displayGM2PMenu(id, g_menuPosition[id])
				//add all Players money
			}
			
		}
	}
	return PLUGIN_CONTINUE
}

public fn_setgmnum(){
	
	new buff[32]
	new args = read_argc()
	
	if (args <= 1){
		server_print("usage: amx_setgmnum <num1> [num2] [num3] ...")	
		return PLUGIN_HANDLED
	}
	
	ArrayClear(g_moneysettings)
	
	for (new i = 1; i < args; i++)	{
		read_argv(i, buff, charsmax(buff))
		ArrayPushCell(g_moneysettings, str_to_num(buff))
	}
	return PLUGIN_CONTINUE
}

