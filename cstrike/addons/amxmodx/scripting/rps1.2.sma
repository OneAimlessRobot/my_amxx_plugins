#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#define PLUGIN "Rock Paper Scissors"
#define VERSION "1.2"
#define AUTHOR "Smilex_Gamer/Exertency/fysiks"

enum _:Options
{
	NONE,
	ROCK,
	PAPER,
	SCISSORS
}

new OptionStrings[Options][] =
{
	"None",
	"Rock",
	"Paper",
	"Scissors"
}

enum _:Vars_Game
{
	game,
	gamepc,
	played,
	player,
	option,
	optionpc,
	challenge,
	block_challenge
}

new g_vars[33][Vars_Game];
new cvar_time_accept;

enum (+= 100)
{
	TASK_ACCEPT = 2000,
	TASK_GAME,
	TASK_WAIT,
	TASK_RESULT
}

#define ID_ACCEPT (taskid - TASK_ACCEPT)
#define ID_GAME (taskid - TASK_GAME)
#define ID_WAIT (taskid - TASK_WAIT)
#define ID_RESULT (taskid - TASK_RESULT)

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say /rps", "clcmd_rps")
	
	cvar_time_accept = register_cvar("challenge_time_accept", "15")
}

public client_putinserver(id)
{
	reset_vars(id)
	
	g_vars[id][block_challenge] = 0
	g_vars[id][game] = 0
	g_vars[id][gamepc] = 0
}

public client_disconnect(id)
{
	if(g_vars[id][game])
	{
		reset_vars(g_vars[id][player])
		remove_all_tasks(g_vars[id][player])
		g_vars[g_vars[id][player]][game] = 0
		show_menu(g_vars[id][player], 0, "^n", 1)
		
		client_print(g_vars[id][player], print_chat, "The opponent has disconnected from the server.")
	}
	else if(g_vars[id][gamepc])
	{
		g_vars[id][gamepc] = 0
	}
	
	reset_vars(id)
	remove_all_tasks(id)
	remove_TASK_ACCEPT(id)
}

public clcmd_rps(id)
{
	if(g_vars[id][game] || g_vars[id][gamepc])
	{
		client_print(id, print_chat, "You're already playing a game!")
		return PLUGIN_HANDLED;
	}
	
	show_menu_choose(id)

	return PLUGIN_HANDLED;
}

public show_menu_choose(id)
{
	new msg1[64]
	
	new menu = menu_create("\yRock Paper Scissors Game", "menu_choose")
	
	formatex(msg1, 63, "\wBlock Challenges: \r%s", g_vars[id][block_challenge] ? "Yes" : "No")
	
	menu_additem(menu, "Challenge the PC", "0", 0)
	menu_additem(menu, "Challenge a Player", "1", 0)
	menu_additem(menu, msg1, "2", 0)
	menu_additem(menu, "Rules", "3", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "Close")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, menu); 
	return PLUGIN_HANDLED;
}

public menu_choose(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return;
	}
	
	new data[6], iName[64]; 
	new access, callback; 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	switch(item)
	{
		case 0:
		{
			reset_vars(id)
			g_vars[id][gamepc] = 1
			show_menu_gamepc(id+TASK_GAME)
			set_task(1.0, "show_menu_gamepc", id+TASK_GAME, _, _, "b")
		}
		case 1:
		{
			show_menu_challenge(id)
		}
		case 2:
		{
			g_vars[id][block_challenge] = g_vars[id][block_challenge] ? 0 : 1
			show_menu_choose(id)
		}
		case 3:
		{
			client_print(id, print_chat, "Rules: Rock crushes Scissors, Paper covers Rock and Scissors cuts Paper.")
			show_menu_choose(id)
		}
	}
}

public show_menu_challenge(id)
{	
	new menu = menu_create("\yChallenge a Player:", "menu_challenge")
	
	new players[32], pnum, tempid; 
	new szName[32], szTempid[10]; 
    
	get_players(players, pnum, "a"); 
    
	for( new i; i<pnum; i++ ) 
	{ 
		tempid = players[i]; 
		
		if (id == tempid || !challenge_available(tempid)) 
		{ 
			continue; 
		} 
        
		get_user_name(tempid, szName, 31); 
		num_to_str(tempid, szTempid, 9); 
		menu_additem(menu, szName, szTempid, 0); 
	} 
	
	menu_setprop(menu, MPROP_BACKNAME, "Back")
	menu_setprop(menu, MPROP_NEXTNAME, "Next")
	menu_setprop(menu, MPROP_EXITNAME, "Close")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, menu); 
	return PLUGIN_HANDLED;
}

public menu_challenge(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return;
	}
	
	new data[6], iName[64]; 
	new access, callback; 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	g_vars[id][player] = str_to_num(data);
	g_vars[g_vars[id][player]][player] = id
	
	if(!is_user_connected(g_vars[id][player]))
	{
		client_print(id, print_chat, "That player isn't online!")
		return;
	}
	else if(g_vars[g_vars[id][player]][game])
	{
		client_print(id, print_chat, "That player is playing against other player!")
		return;
	}
	else if(g_vars[g_vars[id][player]][gamepc])
	{
		client_print(id, print_chat, "That player is playing against the PC!")
		return;
	}
	else if(g_vars[g_vars[id][player]][block_challenge])
	{
		client_print(id, print_chat, "That player has blocked game challenges!")
		return;
	}
	else if(cs_get_user_team(g_vars[id][player]) == CS_TEAM_SPECTATOR || cs_get_user_team(g_vars[id][player]) == CS_TEAM_UNASSIGNED)
	{
		client_print(id, print_chat, "That player is spectator!")
		return;
	}
	else if(g_vars[g_vars[id][player]][challenge])
	{
		client_print(id, print_chat, "That player has a pending challenge!")
		return;
	}
	
	new name[32]
	get_user_name(g_vars[id][player], name, 31)
	
	client_print(id, print_chat, "Challenge sent to %s!", name)
	show_menu_invite(g_vars[id][player])
}

public show_menu_invite(id)
{
	new msg1[64], name[32], menu
	
	get_user_name(g_vars[id][player], name, 31)
	
	formatex(msg1, 63, "\y%s challenged you to a Rock Paper Scissors Game", name)
	
	menu = menu_create(msg1, "menu_invite")
	
	menu_additem(menu, "Accept", "0", 0)
	menu_additem(menu, "Decline", "1", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(id, menu);
	
	set_task(get_pcvar_float(cvar_time_accept), "Time_Accept", id+TASK_ACCEPT)
	return PLUGIN_HANDLED;
}

public menu_invite(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return;
	}
	
	new data[6], iName[64]; 
	new access, callback; 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new name[32], name2[32]
	
	get_user_name(id, name, 31)
	get_user_name(g_vars[id][player], name2, 31)
	
	switch(item)
	{
		case 0:
		{
			if(!g_vars[g_vars[id][player]][game] || !g_vars[g_vars[id][player]][gamepc])
			{
				reset_vars(g_vars[id][player])
				reset_vars(id)
				
				g_vars[id][game] = 1
				g_vars[g_vars[id][player]][game] = 1
				g_vars[g_vars[id][player]][player] = id
				
				show_menu_game(id+TASK_GAME)
				set_task(1.0, "show_menu_game", id+TASK_GAME, _, _, "b")
				show_menu_game(g_vars[id][player]+TASK_GAME)
				set_task(1.0, "show_menu_game", g_vars[id][game]+TASK_GAME, _, _, "b")
				
				client_print(g_vars[id][player], print_chat, "%s accepted your challenge", name)
			}
			else if(!is_user_connected(g_vars[id][player]))
			{
				client_print(id, print_chat, "That player isn't online")
			}
			else
			{
				client_print(id, print_chat, "%s is playing against other player", name2)
			}
			
			g_vars[id][challenge] = 0
		}
		case 1:
		{
			client_print(g_vars[id][player], print_chat, "%s declined your challenge", name)
			
			g_vars[id][challenge] = 0
		}
	}
	
	remove_TASK_ACCEPT(id)
	
	menu_destroy(menu)
}

public Time_Accept(taskid)
{
	static id; id = ID_ACCEPT;
	
	if(!is_user_connected(id))
		id = taskid;
	
	if(!g_vars[id][game])
	{
		client_print(g_vars[id][game], print_chat, "%s declined your challenge")
		show_menu(id, 0, "^n", 1)
		g_vars[id][challenge] = 0
	}
	
	remove_TASK_ACCEPT(id)
}

public show_menu_game(taskid)
{
	static id; id = ID_GAME;
	
	if(!is_user_connected(id))
		id = taskid;
	
	new menu = menu_create("\yChoose what you're going to play:", "menu_game")
	
	menu_additem(menu, "Rock", "1", 0)
	menu_additem(menu, "Paper", "2", 0)
	menu_additem(menu, "Scissors", "3", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(id, menu); 
	return PLUGIN_HANDLED;
}

public menu_game(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	new data[6], iName[64]; 
	new access, callback; 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	g_vars[id][option] = _Option:(item+1)
	g_vars[id][played] = 1
	
	if(task_exists(id+TASK_GAME))
		remove_task(id+TASK_GAME);
		
	show_menu_wait(id+TASK_WAIT)
	set_task(1.0, "show_menu_wait", id+TASK_WAIT, _, _, "b")
}

public show_menu_wait(taskid)
{
	static id; id = ID_WAIT
	
	if(!is_user_connected(id))
		id = taskid;
	
	new menu
	new msg1[64], msg2[64], nameplayer[32]
	
	if(g_vars[id][played] && g_vars[g_vars[id][player]][played])
	{
		menu = menu_create("\yResults in 5 seconds!", "menu_wait")
		
		if(!task_exists(id+TASK_RESULT))
			set_task(5.0, "show_menu_result", id+TASK_RESULT)
	}
	else
	{
		menu = menu_create("\yWaiting Opponent to play...", "menu_wait")
	}
	
	get_user_name(g_vars[id][player], nameplayer, 31)
	
	formatex(msg1, 63, "You played %s", OptionStrings[g_vars[id][option]])
	formatex(msg2, 63, "%s %s", nameplayer, g_vars[g_vars[id][player]][played] ? "played" : "didn't play yet")
	
	menu_additem(menu, msg1, "0", 0)
	menu_additem(menu, msg2, "1", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public menu_wait(id, menu, item)
{	
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	show_menu_wait(id)
}

public show_menu_result(taskid)
{
	static id; id = ID_RESULT;
	
	if(!is_user_connected(id))
		id = taskid;
	
	new menu
	new msg1[64], msg2[64]
	
	new nameplayer[32]
	
	switch(check_winner(g_vars[id][option], g_vars[g_vars[id][player]][option]))
	{
		case 0:
		{
			menu = menu_create("\yDraw!", "menu_result")
		}
		case 1:
		{
			menu = menu_create("\yYou Won!", "menu_result")
		}
		case 2:
		{
			menu = menu_create("\yYou Lost!", "menu_result")
		}
	}

	get_user_name(g_vars[id][player], nameplayer, 31)
	
	formatex(msg1, 63, "You played %s", OptionStrings[g_vars[id][option]])
	formatex(msg2, 63, "%s played %s", nameplayer, OptionStrings[g_vars[g_vars[id][player]][option]])
	
	menu_additem(menu, msg1, "0", 0)
	menu_additem(menu, msg2, "1", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "Close")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, menu); 
	
	g_vars[id][game] = 0
	
	if(task_exists(id+TASK_WAIT))
		remove_task(id+TASK_WAIT);
	
	if(task_exists(id+TASK_RESULT))
		remove_task(id+TASK_RESULT);
		
	return PLUGIN_HANDLED
}

public menu_result(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	show_menu_result(id)
}

public show_menu_gamepc(taskid)
{
	static id; id = ID_GAME;
	
	if(!is_user_connected(id))
		id = taskid;
	
	new menu = menu_create("\yChoose what you're going to play:", "menu_gamepc")
	
	menu_additem(menu, "Rock", "1", 0)
	menu_additem(menu, "Paper", "2", 0)
	menu_additem(menu, "Scissors", "3", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(id, menu); 
	return PLUGIN_HANDLED;
}

public menu_gamepc(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	new data[6], iName[64]; 
	new access, callback; 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	g_vars[id][option] = _Option:(item+1)
	g_vars[id][optionpc] = random_num(1, 3)

	if(task_exists(id+TASK_GAME))
		remove_task(id+TASK_GAME);
	
	show_menu_waitpc(id+TASK_WAIT)
	set_task(1.0, "show_menu_waitpc", id+TASK_WAIT, _, _, "b")
	set_task(5.0, "show_menu_resultpc", id+TASK_RESULT)
}

public show_menu_waitpc(taskid)
{
	static id; id = ID_WAIT;
	
	if(!is_user_connected(id))
		id = taskid;
	
	new msg1[64], msg2[64]
	
	new menu = menu_create("\yResults in 5 seconds!", "menu_waitpc")
	
	formatex(msg1, 63, "You played %s", OptionStrings[g_vars[id][option]])
	formatex(msg2, 63, "The PC played")
	
	menu_additem(menu, msg1, "0", 0)
	menu_additem(menu, msg2, "1", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)

	menu_display(id, menu); 
	return PLUGIN_HANDLED;
}

public menu_waitpc(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	show_menu_waitpc(id)
}

public show_menu_resultpc(taskid)
{
	static id; id = ID_RESULT;
	
	if(!is_user_connected(id))
		id = taskid;
	
	new menu
	new msg1[64], msg2[64]
	
	switch(check_winner(g_vars[id][option], g_vars[id][optionpc]))
	{
		case 0:
		{
			menu = menu_create("\yDraw!", "menu_resultpc")
		}
		case 1:
		{
			menu = menu_create("\yYou Won!", "menu_resultpc")
		}
		case 2:
		{
			menu = menu_create("\yYou Lost!", "menu_resultpc")
		}
	}
	
	formatex(msg1, 63, "You played %s", OptionStrings[g_vars[id][option]])
	formatex(msg2, 63, "The PC played %s", OptionStrings[g_vars[id][optionpc]])
	
	menu_additem(menu, msg1, "0", 0)
	menu_additem(menu, msg2, "1", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "Close")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, menu); 
	
	g_vars[id][gamepc] = 0
	
	if(task_exists(id+TASK_WAIT))
		remove_task(id+TASK_WAIT);
	
	if(task_exists(id+TASK_RESULT))
		remove_task(id+TASK_RESULT);
		
	return PLUGIN_HANDLED
}

public menu_resultpc(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	show_menu_resultpc(id)
}

public reset_vars(id)
{
	g_vars[id][played] = 0
	g_vars[id][option] = 0
	g_vars[id][optionpc] = 0
	g_vars[id][challenge] = 0
}

stock remove_TASK_ACCEPT(id)
{
	if(task_exists(id+TASK_ACCEPT))
		remove_task(id+TASK_ACCEPT)
}

stock remove_all_tasks(id)
{
	if(task_exists(id+TASK_GAME))
		remove_task(id+TASK_GAME);
		
	if(task_exists(id+TASK_WAIT))
		remove_task(id+TASK_WAIT);
			
	if(task_exists(id+TASK_RESULT))
		remove_task(id+TASK_RESULT);
}

stock challenge_available(id)
{
	if(!is_user_connected(id) || g_vars[id][game] || g_vars[id][gamepc] || g_vars[id][block_challenge] || cs_get_user_team(id) == CS_TEAM_SPECTATOR || cs_get_user_team(id) == CS_TEAM_UNASSIGNED)
		return false;
		
	return true;
}

stock check_winner(player1_option, player2_option)
{
	if(player1_option == player2_option)
	{
		return 0
	}
	else if(player1_option > player2_option || (player1_option == ROCK && player2_option == SCISSORS))
	{
		return 1
	}
	else
	{
		return 2
	}

	return 3
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
