/*
*   _______     _      _  __          __
*  | _____/    | |    | | \ \   __   / /
*  | |         | |    | |  | | /  \ | |
*  | |         | |____| |  | |/ __ \| |
*  | |   ___   | ______ |  |   /  \   |
*  | |  |_  |  | |    | |  |  /    \  |
*  | |    | |  | |    | |  | |      | |
*  | |____| |  | |    | |  | |      | |
*  |_______/   |_|    |_|  \_/      \_/
*
*
*
*  Last Edited: 06-21-08
*
*  ============
*   Changelog:
*  ============
*
*  v2.1
*    -Bug Fix
*    -Changed String lengths from 128 - 256
*
*  v2.0
*    -Remake
*
*  v1.0
*    -Initial Release
*
*/

#define VERSION	"2.1"

#include <amxmodx>
#include <amxmisc>

#define NUM_MESSAGES	20
#define STRING_LEN	256

static const configfile[] = "addons/amxmodx/configs/messages.ini"
new text_messages[NUM_MESSAGES][STRING_LEN]
new hud_messages[NUM_MESSAGES][4][STRING_LEN]
new hud_message_colors[NUM_MESSAGES][4][3]
new saytext_msgid

new num_hudmessages, num_textmessages, cur_hudmessage, cur_textmessage

public plugin_init()
{
	register_plugin("GHW Auto Message Displayer",VERSION,"GHW_Chronic")

	register_cvar("advertise_hud_len","120.0")
	register_cvar("advertise_text_len","200.0")
	register_cvar("advertise_hud_loc","1")

	saytext_msgid = get_user_msgid("SayText")

	read_configfile()

	if(num_hudmessages) set_task(get_cvar_float("advertise_hud_len"),"display_hudmessage",0,"",0,"b")
	if(num_textmessages) set_task(get_cvar_float("advertise_text_len"),"display_textmessage",0,"",0,"b")
}

public read_configfile()
{
	new Fsize = file_size(configfile,1)
	new read[STRING_LEN], trash
	for(new i=0;i<Fsize;i++)
	{
		read_file(configfile,i,read,STRING_LEN - 1,trash)
		if(containi(read,"Text")==0)
		{
			read_file(configfile,i+1,read,STRING_LEN - 1,trash)
			replace_all(read,STRING_LEN - 1,"[blue]","^x03")
			replace_all(read,STRING_LEN - 1,"[/blue]","^x01")
			replace_all(read,STRING_LEN - 1,"[red]","^x03")
			replace_all(read,STRING_LEN - 1,"[/red]","^x01")
			replace_all(read,STRING_LEN - 1,"[green]","^x04")
			replace_all(read,STRING_LEN - 1,"[/green]","^x01")
			replace_all(read,STRING_LEN - 1,"[Blue]","^x03")
			replace_all(read,STRING_LEN - 1,"[/Blue]","^x01")
			replace_all(read,STRING_LEN - 1,"[Red]","^x03")
			replace_all(read,STRING_LEN - 1,"[/Red]","^x01")
			replace_all(read,STRING_LEN - 1,"[Green]","^x04")
			replace_all(read,STRING_LEN - 1,"[/Green]","^x01")
			format(text_messages[num_textmessages],STRING_LEN - 1,"^x04^x01%s",read)
			num_textmessages++
		}
		else if(containi(read,"Hud")==0)
		{
			read_file(configfile,i+1,read,STRING_LEN - 1,trash)
			new j = 0, position = 0;
			while(position < strlen(read) && i<4)
			{
				while(contain(read[position]," ")==0) position++
				if(containi(read[position],"[blue]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 6])
					position = containi(read[position],"[/blue]") + 7 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/blue]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 0
					hud_message_colors[num_hudmessages][j][1] = 0
					hud_message_colors[num_hudmessages][j][2] = 255
				}
				else if(containi(read[position],"[red]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 5])
					position = containi(read[position],"[/red]") + 6 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/red]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 0
					hud_message_colors[num_hudmessages][j][2] = 0
				}
				else if(containi(read[position],"[green]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 7])
					position = containi(read[position],"[/green]") + 8 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/green]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 0
					hud_message_colors[num_hudmessages][j][1] = 255
					hud_message_colors[num_hudmessages][j][2] = 0
				}
				else if(containi(read[position],"[Yellow]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 8])
					position = containi(read[position],"[/Yellow]") + 9 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/Yellow]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 255
					hud_message_colors[num_hudmessages][j][2] = 0
				}
				else if(containi(read[position],"[Orange]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 8])
					position = containi(read[position],"[/Orange]") + 9 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/Orange]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 128
					hud_message_colors[num_hudmessages][j][2] = 64
				}
				else if(containi(read[position],"[Pink]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 6])
					position = containi(read[position],"[/Pink]") + 7 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/Pink]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 0
					hud_message_colors[num_hudmessages][j][2] = 128
				}
				else if(containi(read[position],"[Indigo]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 8])
					position = containi(read[position],"[/Indigo]") + 9 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/Indigo]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 0
					hud_message_colors[num_hudmessages][j][1] = 255
					hud_message_colors[num_hudmessages][j][2] = 255
				}
				else if(containi(read[position],"[White]")==0)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position + 8])
					position = containi(read[position],"[/White]") + 9 + position
					trash = containi(hud_messages[num_hudmessages][j],"[/White]")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 255
					hud_message_colors[num_hudmessages][j][2] = 255
				}
				else if(
				containi(read[position],"[blue]")==-1 &&
				containi(read[position],"[red]")==-1 &&
				containi(read[position],"[green]")==-1 &&
				containi(read[position],"[Yellow]")==-1 &&
				containi(read[position],"[Orange]")==-1 &&
				containi(read[position],"[Pink]")==-1 &&
				containi(read[position],"[Indigo]")==-1 &&
				containi(read[position],"[White]")==-1
				)
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position])
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 255
					hud_message_colors[num_hudmessages][j][2] = 255
					position = 129
				}
				else
				{
					format(hud_messages[num_hudmessages][j],STRING_LEN - 1,"%s",read[position])
					position = containi(read[position],"[") + 9 + position
					trash = containi(hud_messages[num_hudmessages][j],"[")
					if(trash!=-1) hud_messages[num_hudmessages][j][trash] = 0
					else break;
					hud_message_colors[num_hudmessages][j][0] = 255
					hud_message_colors[num_hudmessages][j][1] = 0
					hud_message_colors[num_hudmessages][j][2] = 0
				}
				j++
			}
			format(hud_messages[num_hudmessages][1],STRING_LEN - 1,"^n%s",hud_messages[num_hudmessages][1])
			format(hud_messages[num_hudmessages][2],STRING_LEN - 1,"^n^n%s",hud_messages[num_hudmessages][2])
			format(hud_messages[num_hudmessages][3],STRING_LEN - 1,"^n^n^n%s",hud_messages[num_hudmessages][3])
			num_hudmessages++
		}
	}
}

public display_hudmessage()
{
	new Float:loc[2]
	switch(get_cvar_num("advertise_hud_loc"))
	{
		case 2: 
		{
			loc[0] = -1.0
			loc[1] = -1.0
		}
		default:
		{
			loc[0] = -1.0
			loc[1] = 0.2
		}
	}
	set_hudmessage(hud_message_colors[cur_hudmessage][0][0],hud_message_colors[cur_textmessage][0][1],hud_message_colors[cur_textmessage][0][2],loc[0],loc[1], 0, 6.0, 12.0,0.1,0.2,-1)
	show_hudmessage(0,hud_messages[cur_hudmessage][0])
	if(hud_messages[cur_hudmessage][1][2]!=0)
	{
		set_hudmessage(hud_message_colors[cur_hudmessage][1][0],hud_message_colors[cur_textmessage][1][1],hud_message_colors[cur_textmessage][1][2],loc[0],loc[1], 0, 6.0, 12.0,0.1,0.2,-1)
		show_hudmessage(0,hud_messages[cur_hudmessage][1])
	}
	if(hud_messages[cur_hudmessage][2][4]!=0)
	{
		set_hudmessage(hud_message_colors[cur_hudmessage][2][0],hud_message_colors[cur_textmessage][2][1],hud_message_colors[cur_textmessage][2][2],loc[0],loc[1], 0, 6.0, 12.0,0.1,0.2,-1)
		show_hudmessage(0,hud_messages[cur_hudmessage][2])
	}
	if(hud_messages[cur_hudmessage][3][6]!=0)
	{
		set_hudmessage(hud_message_colors[cur_hudmessage][3][0],hud_message_colors[cur_textmessage][3][1],hud_message_colors[cur_textmessage][3][2],loc[0],loc[1], 0, 6.0, 12.0,0.1,0.2,-1)
		show_hudmessage(0,hud_messages[cur_hudmessage][3])
	}
	cur_hudmessage = (cur_hudmessage + 1 ) % num_hudmessages
}

public display_textmessage()
{
	new num, players[32], player
	get_players(players,num,"ch")
	for(new i=0;i<num;i++)
	{
		player = players[i]

		message_begin(MSG_ONE,saytext_msgid,{0,0,0},player)
		write_byte(player)
		write_string(text_messages[cur_textmessage])
		message_end()
	}
	cur_textmessage = (cur_textmessage + 1 ) % num_textmessages
}
