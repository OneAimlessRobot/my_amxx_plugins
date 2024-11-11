#include <amxmodx>
#include <amxmisc>

new name[50],authid[50],ip[50]
new rules[]="rules.txt"
new agreedfile[]="addons/amxmodx/configs/agreed.ini"
new declinedfile[]="addons/amxmodx/configs/declined.ini"

public plugin_init() {
	register_plugin("Terms and Agreements","0.1","DahVid")
	register_menu("Terms and Agreements:",1023,"RulesMenu")
	register_clcmd("amx_removedecline","EraseDecline",-1,"amx_removedecline name -- removes user off of the decline list")
	set_task(1.0,"checkforfiles")
}

public checkforfiles() {
	if(!file_exists(agreedfile)) {
		write_file(agreedfile,"; First time user")
	}
	if(!file_exists(declinedfile)) {
		write_file(declinedfile,"; First time user")
	}
	if(!file_exists(rules)) {
		write_file(rules,"; Add your rules here, HTML can be used.")
	}
}

public client_putinserver(id) {
	new szData[3][56], line=0,k=0, szLine[256]
	new szPAuthid[36]
	get_user_authid(id,szPAuthid,35)
	while(read_file(agreedfile,line++,szLine,255,k)) {
		if((szLine[0] == ';') || !k) continue
		parse(szLine,szData[0],55,szData[1],55,szData[2],55) 
		if(equali(szPAuthid,szData[0])) {
			return PLUGIN_HANDLED //User has agree'd before.
		}
	}
	while(read_file(declinedfile,line++,szLine,255,k)) {
		if((szLine[0] == ';') || !k) continue
		parse(szLine,szData[0],55,szData[1],55,szData[2],55) 
		if(equali(szPAuthid,szData[0])) {
			set_task(5.0,"DeclinedFunc",id)
			return PLUGIN_HANDLED //User has declined.
		}
	}
	set_task(5.0,"DisplayRulesMenu",id)
	return PLUGIN_CONTINUE
}

public EraseDecline(id) {
	new player[50]
	read_argv(1,player,49)
	new target=cmd_target(id,player,9)
	get_user_authid(target,authid,49)
	
	new szData[3][56], line=0,k=0, szLine[256]
	new szPAuthid[36]
	get_user_authid(id,szPAuthid,35)
	while(read_file(declinedfile,line++,szLine,255,k)) {
		if((szLine[0] == ';') || !k) continue
		parse(szLine,szData[0],55,szData[1],55,szData[2],55) 
		if(equali(szPAuthid,szData[0])) {
			write_file(declinedfile,"",line)
		}
	}
	return PLUGIN_CONTINUE
}

public DisplayRulesMenu(id) {
	new szMenuBody[256]
	new keys
	format(szMenuBody,255,"Terms and Agreements:^n")
	add(szMenuBody,255,"^n1. Agree")
	add(szMenuBody,255,"^n2. Decline")
	add(szMenuBody,255,"^n^n3. Show Rules")
	keys = (1<<0|1<<1|1<<2|1<<3)
	show_menu(id,keys,szMenuBody,-1)
	return PLUGIN_CONTINUE
}

public RulesMenu(id,key) {
	switch(key) {
		case 0: {
			get_user_name(id,name,49)
			get_user_authid(id,authid,49)
			get_user_ip(id,ip,49)
			client_print(id,print_chat,"Thanks %s, have a fun time playing. [LOGGED %s %s %s]",name,authid,ip,name)
			
			new agreed[256]
			format(agreed,255,"%s %s %s",authid,ip,name)
			write_file(agreedfile,agreed)
		}
		case 1: {
			get_user_name(id,name,49)
			get_user_authid(id,authid,49)
			get_user_ip(id,ip,49)
			console_print(id,"Sorry %s, we frown upon those who do not agree to our rules. [LOGGED %s %s %s]",name,authid,ip,name)
			
			new declined[256]
			format(declined,255,"%s %s %s",authid,ip,name)
			write_file(declinedfile,declined)
			server_cmd("kick %s",name)
		}
		case 2: {
			get_user_name(id,name,49)
			client_print(id,print_chat,"%s please read the rules more deligently to risk being banned!",name)
			show_motd(id,rules,"MOTD:RULES")
			set_task(5.0,"DisplayRulesMenu")
		}
	}
}

public DeclinedFunc(id) {
	client_print(id,print_chat,"I'm sorry, you have declined the rules. You have 60 seconds before you will be kicked.")
	set_task(60.0,"KickUser",id)
}

public KickUser(id) {
	get_user_name(id,name,49)
	server_cmd("kick %s",name)
}
