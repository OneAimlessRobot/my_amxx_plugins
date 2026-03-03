/*
* -| Simple Rules Plugin |-
*------------------------------------------------------------------------
*   Installation:
*
* - put Rules.AMX into the plugins folder
* - add this line to Plugins.ini ..... Rules.AMX
* - open rules.txt (in zip file) with notepad and add your server rules
* - put rules.txt in the amxx folder
*------------------------------------------------------------------------
*   Usage:
*
* - when in game say "/rules"
*
*------------------------------------------------------------------------
*/
  
#include <amxmodx> 
#include <amxmisc>

public admin_rules(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	show_motd(id,"/addons/amxx/rules.txt","Server Rules")
	new name[32] 
	get_user_name(id,name,31)
	client_print(0,print_chat,"dont shoot s% because he is reading the server rules!!",name)
	return PLUGIN_HANDLED   
}

public plugin_init() { 
    register_plugin("Rules","1.0","toxic") 
    register_concmd("say /rules","admin_rules",0,"< shows the server rules >")  
    return PLUGIN_CONTINUE 
} 