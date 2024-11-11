/* Say Rules

* Details :
 For the first you can use a type to how will be displayed rules
 You can choose display tipe : Print Chat, Print Center and Motd Display
 
* Commands : 
- /sayrules : Will display all rules from a .txt file (you must create one)
- /sayrules 1 : Will display rule from from a .txt file (also must create one)
- /sayrules 2 : Display rule 2 from that .txt file ..
  etc
  If you use for example "/sayrules 16" and not exists rule 16 on .txt file, 
will display "This rule not exists"
    This commands you must use in chat !


* Admin Commands:
- amx_forceread <name | @CT/@T/@ALL > - force player(s) to read server rules
- amx_addrule <rule> - add a new server rule
    

* Cvars:
- sayrules_type (default 1)

^ 1 = print_chat
^ 2 = print_center
^ 3 = show motd
  
* Install :
1) Enable Plugin
2) Create a new file on your "addons\amxmodx\configs\" folder, with name "sayrules.txt"
  In that file add your server rules
 Remember if you choose sayrules_type 3 will display a motd, so you will design "sayrules.txt"
in HTML Style

* Credits :
 Thanks to Fatalis for help me with a lot of codes 
 Black Rose because helping me on command "amx_addrule" to write file
 
* [UPDATE] 0.2 -> 0.3 (10/02/2007);
- Added a new command "amx_addrule" <rule> for posibility to add a new rule when you are on server
    

* [UPDATE] 0.1 -> 0.2
- Added new comand to force an player from server to read server rules
Command : amx_forceread <name | @CT/@T/@ALL > 

* That's all
* Have a nice day now

*/


#include <amxmodx>
#include <amxmisc>



#define PLUGIN "Say Rules"
#define VERSION "0.3"
#define AUTHOR "SAMURAI"




new p_type 

 
public plugin_init()
{
        register_plugin(PLUGIN, VERSION, AUTHOR);
        register_clcmd("say", "cmdSay", 0);
        p_type = register_cvar("sayrules_type","1");
        register_concmd("amx_forceread","forcerules",ADMIN_LEVEL_C,"Force player(s) to read rules !");
        register_concmd("amx_addrule","add_rule",ADMIN_RCON,"<rule> add a new server rule !");
	

}


public cmdSay(id)
{
        new gFILE[128]
        get_localinfo("amxx_configsdir",gFILE,127)
        format(gFILE,127,"%s/sayrules.txt",gFILE)
	
        if(!file_exists(gFILE))
        {	
        server_print("File %s not found !",gFILE)
         }
	
        new szArgs[17];
        read_args(szArgs, 16);
        replace_all(szArgs, 16, "^"", "");
        new szCmd[10], szParams[5];
        strbreak(szArgs, szCmd, 9, szParams, 4);
        if( equali(szCmd, "/sayrules", 0) )
        {
                if( strlen(szParams) > 0 )
                {
                        new szData[257], txtLen;
                        new line = str_to_num(szParams) - 1;                    
                        if( line < 0 || line > file_size(gFILE, 1) - 1 )
                        {
                                client_print(id, print_chat, "This rule not exists");
                                return PLUGIN_HANDLED;
                        }
                        read_file(gFILE, line, szData, 256, txtLen);  
		        switch (get_pcvar_num(p_type))
		      {
		      	case 1:
			{
                           client_print(id, print_chat, szData);
		          }
		         case 2:
		        {		         
		         client_print(id, print_center, szData);
		        }
		        case 3:
		        {
		         show_motd(id,gFILE,"Server Rules")
		        }  
		      }
                }
                else
                {
                    new szData[257];
                    new file = fopen(gFILE, "rt");
                    while( !feof(file) )
                    { 
                       fgets(file, szData, 256);
		       switch (get_pcvar_num(p_type))
		      {
		      	case 1:
			{
                           client_print(id, print_chat, szData);
		          }
		         case 2:
		        {		         
		         client_print(id, print_center, szData);
		        }
		        case 3:
		        {
		         show_motd(id,gFILE,"Server Rules")
		        }  
		      }
                     }
                    fclose(file);
                } 
        }
        return PLUGIN_CONTINUE;
} 


public forcerules(id,level,cid)
{
        if(!cmd_access(id,level,cid,2))
                return PLUGIN_HANDLED
        new arg[32],players[32],num
        read_argv(1,arg,4)
        if(equali(arg,"@T")) {
                get_players(players,num,"ace","TERRORIST")
        }
        else if(equali(arg,"@CT")) {
                get_players(players,num,"ace","CT")

        }
        else if(equali(arg,"@ALL")) {
                get_players(players,num,"ac")
        }
        else {
                read_argv(1,arg,31)
                new theone = cmd_target(id,arg,0)
                if(!theone)
                        return PLUGIN_HANDLED
                new name[32]
                get_user_name(theone,name,31)
                players[0] = theone
                num = 1
        }
        new player
        for(new i=0;i<num;i++) {
                player = players[i]
                client_cmd(player,"say /sayrules")
        }
        return PLUGIN_HANDLED
}

public add_rule(id,level,cid)
{
	if( ! cmd_access ( id , level, cid , 2) )
	return PLUGIN_HANDLED;
	
	new g_FILE[128]
	get_localinfo("amxx_configsdir",g_FILE,127)
	format(g_FILE,127,"%s/sayrules.txt",g_FILE)
	
	new text[32]
	read_args(text,31)
	
	new fileh = fopen(g_FILE, "a");
	
	if ( ! fileh )
	return PLUGIN_CONTINUE
	
	fprintf(fileh, "%s", text);
	console_print(id,"[SayRules] Added a new rule on your server");
	
	fclose(fileh);
	
	return PLUGIN_HANDLED;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
