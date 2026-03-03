/*
*	
*   Admin Slash by mike_cao <mike@mikecao.com>
*   Super enhancements by [DeathTV] Sid 6.7
*	This file is provided as is (no warranties).
*
*	This plugin allows admins to execute amx commands
*	using 'say' and a slash '/'. It can also execute
*	a command on all players or a team using '@all' and
*	'@team' in place of the authid/nick parameter.
*
*	Examples:
*	To kick a player type '/kick playername'
*	To kick all players type '/kick @all'
*	To kick all players on a team type '/kick @team:TEAMID'
*	To ban all players for 10 minutes, type '/ban 10 @all'
*
*
*	Important: place this plugin at the bottom of your plugins.ini file 
*	so it doesn't interfere with other plugin that may use the '/'.
*
* 	Super Enhancements:
*   Slash is available only to admins now, so it will not interfere with things such as
*   /rope or /chickenme for normal players. This means super_admin_slash's position
*   in the plugins.ini file is not as important
* 
* 	Say /command @ blahblah, the empty @ sign will popup a menu of users and teams
* 
*   (Counter-Strike) Say /R command @all blahblah, the command will repeat every new round
*   say / and the wipe action menu will popup
* 
* 	There is an X-Target system that will emulate @ functionality for commands that can't.
*   For commands that can you can use the native @ALL @CT etc.
* 
*   Ex.   say /swap @ @  and you may pick 2 ppl to swap teams
* 
*/ 

#include <amxmodx>
#include <amxmisc>

#define VERBOSE
#define MAX_NAME_LENGTH 32
#define MAX_TEXT_LENGTH 80
#define MAX_PLAYERS 32
new PLUGIN[] = "Super Admin Slash"

new sMessage[MAX_TEXT_LENGTH], Array:repeatStorage, Array:repeatIDs, repeaters[MAX_PLAYERS+1]

enum {
	GET_TEAM_TARGET_ISNOBODY,
	GET_TEAM_TARGET_ISALL,
	GET_TEAM_TARGET_ISTEAMCT,
	GET_TEAM_TARGET_ISTERRORIST
}

enum {
	GET_TEAM_TARGET_SKIPNOBODY,
	GET_TEAM_TARGET_SKIPBOTS,
	GET_TEAM_TARGET_SKIPDEADPEOPLE
}

stock tokenlen(string[]){
	for(new i; i < strlen(string)+1; i++){
		if(string[i] < 33) return i
	}
	return 0
}

stock get_team_target(arg[],players[32],&pnum,skipMode=GET_TEAM_TARGET_SKIPNOBODY){
	//Modular Tea	m Targeting code by Sid 6.7
	new whoTeam
	new cmdflags[4]
	switch(skipMode){
		case GET_TEAM_TARGET_SKIPBOTS: cmdflags = "ce"
		case GET_TEAM_TARGET_SKIPNOBODY: cmdflags = "e"
		case GET_TEAM_TARGET_SKIPDEADPEOPLE: cmdflags = "ae"
	}
	if(equali(arg[1],"ALL",tokenlen(arg[1]))) 	{
		switch(skipMode){
			case GET_TEAM_TARGET_SKIPBOTS: cmdflags = "c"
			case GET_TEAM_TARGET_SKIPNOBODY: cmdflags = ""
			case GET_TEAM_TARGET_SKIPDEADPEOPLE: cmdflags = "a"
		}
		whoTeam = GET_TEAM_TARGET_ISALL
		get_players(players,pnum,cmdflags)
	}
		
	if(equali(arg[1],"TERRORIST",tokenlen(arg[1]))) {
		whoTeam = GET_TEAM_TARGET_ISTERRORIST
		get_players(players,pnum,cmdflags,"TERRORIST")
	}
	if(equali(arg[1],"CT",2)	|| equali(arg[1],"C",1)) {
		whoTeam = GET_TEAM_TARGET_ISTEAMCT
		get_players(players,pnum,cmdflags,"CT")
	}
	return whoTeam
}

public admin_slash(id){
	if(!is_user_admin(id)) return PLUGIN_CONTINUE
	new sArg[MAX_NAME_LENGTH]	
	read_argv(1,sArg,charsmax(sArg))
	
	// Check for '/' char
	if ( sArg[0] == '/' ){
		read_args(sMessage,charsmax(sMessage))
		remove_quotes(sMessage)
		replace(sMessage,charsmax(sMessage),"/","")
		process(id,sMessage)		
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

process(id,line[sizeof sMessage]){
	if(equal(line,"")){
		new menu = menu_create("Wipe Repeaters","imh")
		menu_additem(menu,"Wipe All","wipe0")
		new pnum, p[32], n[24], c[32]
		get_players(p,pnum,"c")
		for(new i; i < pnum; i++){
			get_user_name(p[i],n,charsmax(n))
			formatex(c,charsmax(c),"[%d] %s",repeaters[p[i]],n)
			formatex(n,6,"wipe%d",p[i])
			menu_additem(menu,c,n)
		}
		menu_display(id,menu)
		return
	}
	new a = contain(line,"@")
	if(a != -1 && !isalnum(line[a+1])) intellimenu(id,line)
	else {
		//check for @Xall @XT @XCT, these are manual controls for commands not supporting @ symbol
		new line2[sizeof line]
		copy(line2,charsmax(line2),line)
		if(line[0] == 'R') {
			replace(line2,charsmax(line2),"R","")
			addrepeater(id,line2)
			client_print(id,print_chat,"[%s] Command set for repeat on new rounds",PLUGIN)
			return
		}
		a = contain(line,"@X")
		if(a == -1) client_cmd(id,"amx_%s",line)
		else {
			new teammates[32], pnum
			//start cycling thru targets
			client_print(id,print_chat,"[%s] Emulation called for @%s",PLUGIN,line[a+2])
			replace(line2,charsmax(line2),"@X","@")
			if(get_team_target(line2[a],teammates,pnum) == GET_TEAM_TARGET_ISNOBODY)
				client_print(id,print_chat,"[%s] No clients on team",PLUGIN)
			else {
				new r[16], j[2]
				strtok(line2[a],r,charsmax(r),j,1)
				replace(line2,charsmax(line2),r,"#%d")
				#if defined VERBOSE
				server_print(line2,12345)
				#endif
			}
			new line3[sizeof line]
			for(new i; i < pnum; i++){
				formatex(line3,charsmax(line3),line2,get_user_userid(teammates[i]))
				#if defined VERBOSE
				server_print(line3)
				#endif
				client_cmd(id,"amx_%s",line3)
			}
		}
	}
}

intellimenu(id,const line[sizeof sMessage]){
	new players[32], pnum, commandlabel[48], gumstick[sizeof line], userid[8]
	get_players(players,pnum)
	new menu = menu_create("AMXX Super Slash Users Menu","imh")
	new targets[][] = {"@ALL","@CT","@T"}
	if(cstrike_running()){
		if(line[0] == 'R'){
			copy(gumstick,charsmax(gumstick),line[1])
			commandlabel = "Repeat\R\yON"
		} else {
			formatex(gumstick,charsmax(gumstick),"R%s",line)
			commandlabel = "Repeat\R\dOFF"
		}
		menu_additem(menu,commandlabel,gumstick)
		for(new i; i < sizeof targets; i++){
			copy(gumstick,charsmax(gumstick),line)
			replace(gumstick,charsmax(gumstick),"@",targets[i])
			menu_additem(menu,targets[i],gumstick)
		}
	}
	menu_addblank(menu,0)
	for(new i; i < pnum; i++){
		copy(gumstick,charsmax(gumstick),line)
		formatex(userid,charsmax(userid),"#%d",get_user_userid(players[i]))
		replace(gumstick,charsmax(gumstick),"@",userid)
		get_user_name(players[i],commandlabel,charsmax(commandlabel))
		if(cstrike_running()) 
			if(get_user_flags(players[i]) & ADMIN_IMMUNITY) strcat(commandlabel,"\R\yIMMUNITY",charsmax(commandlabel))
		menu_additem(menu,commandlabel,gumstick)
	}
	menu_addblank(menu,0)
	new Xtargets[][] = {"@XALL","@XCT","@XT"}
	for(new i; cstrike_running() ? i < sizeof Xtargets : i < 1; i++){
		copy(gumstick,charsmax(gumstick),line)
		replace(gumstick,charsmax(gumstick),"@",Xtargets[i])
		menu_additem(menu,Xtargets[i],gumstick)
	}
	menu_display(id,menu)			
}

public imh(id, menu, item){
	if(item <= MENU_EXIT) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new a, bubblegum[MAX_TEXT_LENGTH], name[32]
	menu_item_getinfo(menu, item, a, bubblegum, charsmax(bubblegum),name,sizeof(name)-1, a)
	menu_destroy(menu)
	if(equal(bubblegum,"wipe",4)) wiperepeaters(str_to_num(bubblegum[4]))
	else process(id,bubblegum)
	return PLUGIN_HANDLED
}

public plugin_init(){
	register_plugin(PLUGIN,"2008","mike_cao & Sid 6.7")
	register_clcmd("say","admin_slash",0,"say /command < params >")
	if(cstrike_running()) register_logevent("logevent_round_start", 2, "1=Round_Start")
	repeatStorage = ArrayCreate(MAX_TEXT_LENGTH)
	repeatIDs = ArrayCreate()
}

public logevent_round_start(){
	for(new i; i < ArraySize(repeatIDs); i++){
		ArrayGetString(repeatStorage,i,sMessage,charsmax(sMessage))
		process(ArrayGetCell(repeatIDs,i),sMessage)
	}
}

addrepeater(id, r[]){
	ArrayPushCell(repeatIDs,id)
	ArrayPushString(repeatStorage,r)
	repeaters[id]++
}

//id 0 = all
wiperepeaters(id){
	for(new i; i < ArraySize(repeatIDs); i++){
		if(!id || ArrayGetCell(repeatIDs,i) == id){
			repeaters[ArrayGetCell(repeatIDs,i)]--
			ArrayDeleteItem(repeatIDs,i)
			ArrayDeleteItem(repeatStorage,i)
			i--
		}
	}
}

public client_disconnected(id){
	wiperepeaters(id)
}