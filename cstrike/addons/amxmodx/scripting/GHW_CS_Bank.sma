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
*  Last Edited: 12-31-07
*
*  ============
*   Changelog:
*  ============
*
*  v2.0
*    -Added ML
*
*  v1.5
*    -Optimized Reading/Writing Files
*
*  v1.2
*    -Misc. Bug Fixes
*
*  v1.0
*    -Initial Release
*
*/

#define VERSION	"2.0"

#include <amxmodx>
#include <amxmisc>
#include <cstrike>

new bank[33]
new configfile[200]
new authid[33][32]
new pcvar

public plugin_init()
{
	register_plugin("Simple CS Bank",VERSION,"GHW_Chronic")
	pcvar = register_cvar("bank_save","1")

	new configsdir[200]
	get_configsdir(configsdir,199)
	format(configfile,199,"%s/cs_bank.ini",configsdir)

	register_dictionary("GHW_CS_Bank.txt")
}

public client_putinserver(id)
{
	if(!is_user_bot(id)) set_task(5.0,"client_authorized2",id)
}

public client_authorized2(id)
{
	bank[id] = 0
	if(get_pcvar_num(pcvar))
		set_task(10.0,"read_file2",id)
	set_task(0.1,"cpt",id,"",0,"b")
}

public client_disconnect(id)
{
	if(!is_user_bot(id) && get_pcvar_num(pcvar))
		save_money(id)
}

public cpt(id)
{
	if(is_user_alive(id))
	{
		if(cs_get_user_money(id)>10000)
		{
			bank[id]+= cs_get_user_money(id) - 10000
			cs_set_user_money(id,10000)
		}
		if(cs_get_user_money(id)<10000)
		{
			if(bank[id] < 10000 - cs_get_user_money(id))
			{
				cs_set_user_money(id,cs_get_user_money(id)+bank[id])
				bank[id]=0
			}
			else
			{
				bank[id]-=  10000 - cs_get_user_money(id)
				cs_set_user_money(id,10000)
			}
		}
		set_hudmessage(0, 255, 0, 0.7, 0.87, 0, 6.0, 0.1, 0.1, 0.2, next_hudchannel(id) )
		show_hudmessage(id,"%L",id,"MSG_BANK",bank[id])
	}
}

public read_file2(id)
{
	if(is_user_connected(id) && file_exists(configfile))
	{
		get_user_authid(id,authid[id],31)
		new read[32]
		new filepointer = fopen(configfile,"r")
		while(fgets(filepointer,read,31))
		{
			replace(read,31,"^n","")
			if(equali(read,authid[id]))
			{
				fgets(filepointer,read,31)
				if(cs_get_user_money(id)<10000)
				{
					if(cs_get_user_money(id) + str_to_num(read)<=10000)
					{
						cs_set_user_money(id,cs_get_user_money(id) + str_to_num(read))
					}
					if(cs_get_user_money(id) + str_to_num(read)>10000)
					{
						bank[id] += (str_to_num(read) + cs_get_user_money(id)) - 10000
						cs_set_user_money(id,10000)
					}
				}
				else
				{
					bank[id] += str_to_num(read)
				}
				break;
				
			}
		}
		fclose(filepointer)
	}
}

public save_money(id)
{
	new string[32]
	format(string,31,"%d",bank[id])
	new i, line
	new filepointer = fopen(configfile,"r")
	if(filepointer)
	{
		new read[32]
		while(fgets(filepointer,read,31))
		{
			replace(read,31,"^n","")
			server_print("%d. %s",i,read)
			if(equali(read,authid[id]))
			{
				line=1
				break;
			}
			i++
		}
	}
	fclose(filepointer)
	if(!line) write_file(configfile,authid[id],i)
	write_file(configfile,string,i+1)
}
