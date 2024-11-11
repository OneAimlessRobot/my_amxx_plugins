/*	Superhero XP/AP/HP Merchant	-     Ver 1.18  9/12/05
	angelfire.com/clone/me2			by: werdpad
	67.84.157.138:27015	         Superhero Slaughterhouse
	__________________________________________________
	I wrote this program because people complained it was too hard
	to level against higher levels and that made the exp too slow.
	I have mercy exp configured but it still made it slow for lower
	level players so i decided to write this plugin. I do have bill gates
	running on the server with this set at $15,000. This plugin can be
	configured with the cvars to be balanced with bill gates.

	//NOTE: the values below are not the defaut, these are the values
	//i have chosen for my server

	//sh merchant cvars (copy and paste into shconfig.cfg or amxmodx.cfg)
	sv_merchant 1		//enable / disable plugin 0=disabled, 1=enabled

	//shm_mode 1		//mode for buying 0=all players, 1=alive, 2=dead
	shm_buyxpamt 100		//amount of exp given per buy (set to zero to disable)
	shm_buyhpamt 250		//amount of life given per buy (set to zero to disable)
	shm_buyapamt 99		//amount of armor given per buy (set to zero to disable)
	shm_buyframt 1		//amount of armor given per buy (set to zero to disable)

	shm_buyxpcost 5000	//cost per purchase of exp amount
	shm_buyhpcost 5000	//cost per purchase of life amount
	shm_buyapcost 1500	//cost per purchase of armor amount
	shm_buyfrcost 1000	//cost per purchase of armor amount

	--------------------------------------------------------------------------------------
	NOTES:
		1) the cost is the same for xp and ap because the
	plugin only uses 1 cvar for cost (i figured keep the #of cvars
	to a minimum.

		2) to reduce bandwidth requirements and make it
	easier for the players the XP will buy up to $15,000 worth at
	a time. this way if you start a user with 30k with bill gates,
	they only have to say buyxp twice to buy the maximum.

		3) buying frags does NOT give EXP nor does it even
	count towards the users rank / stats.

		4) thanks to JTP for the individual disable/enable
	item method
	--------------------------------------------------------------------------------------
	v0.00 -> 1.00 : buyxp complete and works well 
	v1.03 -> 1.04 : added ability to buy hitpoints
	v1.03 -> 1.04 : minor tweaks to buyxp and buyhp
	v1.04 -> 1.05 : added ability to buy armor
	v1.05 -> 1.06 : disabled buyap due to crashing problems
	v1.06 -> 1.07 : fixed and reenabled buyap
	v1.07 -> 1.08 : added ability to buy frags
	v1.08 -> 1.09 : tweaked buyfr and added MAX_FRAGS
			tweaked buyhp and added HP_MAX
			added a command for admins to enable/disable
			client-side with ability to kick
	v1.09 -> 1.10 : condensed checks into 1 function to reduce size of the plugin and clean up code
	v1.10 -> 1.11 : added the MODE feature & cleaned up code
	v1.11 -> 1.12 : changed to define for map time left check
	v1.12 -> 1.13 : cleaned up code and added server messages
	v1.13 -> 1.14 : new method to calculate the exp buy
	v1.14 -> 1.15 : shows your total new HP when you buyhp
			made it max out hp on final buy
	v1.15 -> 1.16 : gave hud messages seperate colors and alternated between tsay and csay
	v1.16 -> 1.17 : disabled messages (for stability and overflow reasons)
			able to disable individual items (set cvar to zero)
	v1.17 -> 1.18 : cooldown 1 minute before and after mapchanges
			removed /myhp command
			dead players now can purchase anything except life
	---------------------------------------------------------------------------------------
	DISCLAIMER:  This software is distributed as freeware. There
	is no warranty or guarantee of any kind. The author of this
	software is not responsible for any damages, misuse, or altered
	code by users.
	__________________________________________________
*/

#include <amxmodx>
#include <cstrike>
#include <fun>


#define APP_VER 1.17

//defines used for the check function
#define CHECK_OK 1	//returned if all checks are ok
#define CHECK_BAD 0	//returned if any check goes bad
#define MAP_TIMELEFT 11	//used to stop people from buying 10 seconds before a map change
			//precautionary measure to prevent crashes, if you have 32 people rushing
			//to buy exp with a map change imminent it may cause problems (set to 1 or 0 to disable)

//team defs
#define TEAM_CT 2
#define TEAM_T 1
#define TEAM_SPEC 0

//max defs
#define AP_MAX 999    //WARNING: going above 999 armor IS possible but could result in memory leaks or crashes (not recommended)
#define MAX_FRAGS 1024
#define HP_MAX 999

new cvar_xp, cvar_hp, cvar_fr, cvar_ap
new cvar_xpcost, cvar_hpcost, cvar_frcost, cvar_apcost

public plugin_init(){
	register_plugin("SHero Merchant","APP_VER","Werdpad")

	register_cvar("sv_merchant", "1")		//enable cvar
	//register_cvar("shm_mode", "1")		//plugin mode

	register_cvar("shm_buyxpamt", "20")		//-----------------------------
	register_cvar("shm_buyhpamt", "10")		//    amount per purchase
	register_cvar("shm_buyapamt", "0")		//    evertything defaulted to zero (disabled) except EXP
	register_cvar("shm_buyframt", "0")		//-----------------------------
	register_cvar("shm_buyxpcost", "3000")		//-----------------------------
	register_cvar("shm_buyhpcost", "1600")		//    cost per purchase
	register_cvar("shm_buyapcost", "1500")		//
	register_cvar("shm_buyfrcost", "1000")		//-----------------------------

	register_concmd ("say /buyxp","func_buyxp")
	register_concmd ("say buyxp","func_buyxp")	// buy exp client commands for chat and console
	register_concmd ("buyxp","func_buyxp")

	register_concmd ("say /buyhp","func_buyhp")
	register_concmd ("say buyhp","func_buyhp")	// buy life client commands for chat and console
	register_concmd ("buyhp","func_buyhp")

	register_concmd ("say /buyfr","func_buyfr")
	register_concmd ("say buyfr","func_buyfr")	// buy frag client commands for chat and console
	register_concmd ("buyfr","func_buyfr")

	register_concmd ("say /buyap","func_buyap")	//buy armor client commands for chat and console
	register_concmd ("say buyap","func_buyap")
	register_concmd ("buyap","func_buyap")

	register_concmd ("shm_buyon","func_enable")	// admin commands to enable / disable plugin
	register_concmd ("shm_buyoff","func_disable")

	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)
	console_print(0, "[SHM APP_VER] %d - Merchant initialized", id)

	return PLUGIN_CONTINUE
}


//===============================================================================


public func_enable(id)
//client side command for admins to enable the shero merchant
{
	new name[33]

	if ( (get_user_flags(id)&ADMIN_KICK) ){
		set_cvar_num("sv_merchant", 1)
		get_user_name(id,name,32)
		
		console_print(0, "[SHM APP_VER] %s :ENABLED", name)
	}
	else{
		client_print(id,print_chat,"[SHM APP_VER] You dont not have access to this command.")
	}

	return PLUGIN_CONTINUE
}



//===============================================================================


public func_disable(id)
//client side admin command to disable the shero merchant
{
	new name[33]

	if ( (get_user_flags(id)&ADMIN_KICK) ){
		set_cvar_num("sv_merchant", 0)
		get_user_name(id,name,32)
		
		console_print(0, "[SHM APP_VER] %s :DISABLED", name)
	}
	else{
		client_print(id,print_chat,"[SHM APP_VER] You dont not have access to this command.")
	}
	return PLUGIN_CONTINUE
}


//===============================================================================


public func_buyxp(id)
{
	//initialize variables
	new xpp, xpcost, money
	new numbuys
	new name[33], authid[33]

	cvar_xp = get_cvar_num("shm_buyxpamt")
	cvar_xpcost = get_cvar_num("shm_buyxpcost")

	xpcost	= cvar_xpcost
	xpp	= 0

	if( cvar_xp < 1 ){	//check if buyxp is disabled
		client_print(id,print_chat,"[SHM APP_VER] Sorry, buying experience is disabled.")
		return PLUGIN_CONTINUE
	}

	if ( CHECK_BUY(id) == CHECK_BAD )
		return PLUGIN_CONTINUE

	money = cs_get_user_money(id)
	get_user_authid(id,authid,32)
	get_user_name(id,name,32)

	//check to see if user has enough cash
	if( money < cvar_xpcost ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. You need at least $%d to buy exp", name, cvar_xpcost )
		return PLUGIN_CONTINUE
	}

	numbuys = money / cvar_xpcost		//calculate the max number of transactions (originally used in for loop)
	xpp = numbuys * cvar_xp			//calculate how much exp they can buy using numbuys
	xpcost = numbuys * cvar_xpcost		//calculate the cost of the above amount of exp

	//conduct transaction
	console_print(0, "[SHM APP_VER] %s PURCHASED %d XP : COST %d", name, xpp, xpcost)

	cs_set_user_money(  id, (money - xpcost) ,1 )				//subtract money from buys
	server_cmd("amx_shaddxp ^"%s^" %d", authid, xpp)			//add exp for buys

	if( cs_get_user_money(id) < 0 ){
		cs_set_user_money( id, 0, 1 )
	}

	//server_cmd("amx_csay yellow [SHM APP_VER] %s has purchased %d exp.^nTo buy exp say buyxp", name, xpp)

	return PLUGIN_CONTINUE
} //end func_buyxp()


//===============================================================================


public func_buyhp(id)
{
	//initialize variables
	new name[33], authid[33]

	cvar_hp = get_cvar_num("shm_buyhpamt")
	cvar_hpcost = get_cvar_num("shm_buyhpcost")

	if( cvar_hp < 1 ){	//check if buyhp is disabled
		client_print(id,print_chat,"[SHM APP_VER] Sorry, buying health is disabled.")
		return PLUGIN_CONTINUE
	}

	if ( CHECK_BUY(id) == CHECK_BAD )
		return PLUGIN_CONTINUE

	new money = cs_get_user_money(id)
	new userlife = get_user_health(id)
	get_user_authid(id,authid,32)
	get_user_name(id,name,32)

	if( !is_user_alive(id) ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Dead players may not purchase life.", name )
		return PLUGIN_CONTINUE
	}

	//check to see if user has enough cash
	if( money < cvar_hpcost ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. You need at least $%d to buy hp", name, cvar_hpcost )
		return PLUGIN_CONTINUE
	}

	if( userlife == (HP_MAX) ){
		client_print(id,print_chat,"[SHM APP_VER]  You are at the max amount of life." )
		return PLUGIN_CONTINUE
	}
	cs_set_user_money(  id, (money - cvar_hpcost) ,1 )			//subtract money from buys
	if( cs_get_user_money(id) < 0 ){				//make sure user isnt left with negative money
		cs_set_user_money( id, 0, 1 )
	}

	new newlife = userlife + cvar_hp
	if( newlife > HP_MAX )
		newlife=999

	set_user_health(id, newlife)

	console_print(0, "[SHM APP_VER] %s PURCHASED %d HP : COST %d", name, cvar_hp, cvar_hpcost)

	client_print(id,print_chat,"[SHM APP_VER] You have purchased hp. Your new HP is %d", newlife)
	//server_cmd("amx_tsay red [SH][SHM APP_VER] %s has purchased %d life.^nTo buy life say buyhp", name, cvar_hp)

	return PLUGIN_CONTINUE

} //end func_buyhp()


//===============================================================================


public func_buyfr(id)
{
	//initialize variables
	new name[33], authid[33]

	new money = cs_get_user_money(id)
	new frags = get_user_frags(id)

	get_user_authid(id,authid,32)
	get_user_name(id,name,32)
	cvar_fr  = get_cvar_num("shm_buyframt")
	cvar_frcost  = get_cvar_num("shm_buyfrcost")

	//===========================================
	// CHECK SECTION.

	if( cvar_fr < 1 ){	//check if buyfr is disabled
		client_print(id,print_chat,"[SHM APP_VER] Sorry, buying frags is disabled.")
		return PLUGIN_CONTINUE
	}

	if ( CHECK_BUY(id) == CHECK_BAD )
		return PLUGIN_CONTINUE

	//check to see if user has enough cash
	if( money < cvar_frcost ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. You need at least $%d to buy frags", name, cvar_frcost )
		return PLUGIN_CONTINUE
	}

	// END CHECK SECTION.
	//===========================================

	cs_set_user_money(  id, (money - cvar_frcost) ,1 )			//subtract money from buys
	if( cs_get_user_money(id) < 0 ){				//make sure user isnt left with negative money
		cs_set_user_money( id, 0, 1 )
	}

	new newfrags = frags + cvar_fr

	if( newfrags > MAX_FRAGS ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s another frag purchase would put you over the limit.", name )
	}
	else{
		client_print(id,print_chat,"[SHM APP_VER] You have purchased %d frag(s)", cvar_fr)
		console_print(0, "[SHM APP_VER] %s PURCHASED %d FRAG(S) : COST %d", name, cvar_fr, cvar_frcost)
		set_user_frags(id, newfrags)
		//server_cmd("amx_tsay green [SH][SHM APP_VER] %s has purchased %d frags. To buy frags say buyfr", name, cvar_fr)
	}

	return PLUGIN_CONTINUE

} //end func_buyfr()


//===============================================================================


public func_buyap(id)
{
	//initialize variables
	new name[33], authid[33]

	cvar_ap = get_cvar_num("shm_buyapamt")
	cvar_apcost = get_cvar_num("shm_buyapcost")

	if ( CHECK_BUY(id) == CHECK_BAD )
		return PLUGIN_CONTINUE

	if( cvar_ap < 1 ){	//check if buyap is disabled
		client_print(id,print_chat,"[SHM APP_VER] Sorry, buying armor is disabled.")
		return PLUGIN_CONTINUE
	}

	new money = cs_get_user_money(id)
	new armor = get_user_armor(id)
	get_user_authid(id,authid,32)
	get_user_name(id,name,32)

	if( !is_user_alive(id) ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Dead players may not purchase armor", name )
		return PLUGIN_CONTINUE
	}

	//check to see if user has enough cash
	if( money < cvar_apcost ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. You need at least $%d to buy exp", name, cvar_apcost )
		return PLUGIN_CONTINUE
	}

	//check to see if it would exceed the AP_MAX which also prevents crashes
	if( armor+cvar_ap > AP_MAX ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. You cannot purchase anymore armor.", name )
		return PLUGIN_CONTINUE
	}


	//conduct transaction
	new newarmor = armor + cvar_ap
	cs_set_user_money(  id, (money - cvar_apcost) ,1 )				//subtract money from buys
	set_user_armor(id, newarmor)

	console_print(0, "[SHM APP_VER] %s PURCHASED %d ARMOR : COST %d", name, cvar_ap, cvar_apcost)

	//server_cmd("amx_csay blue [SH][SHM APP_VER] %s has purchased %d armor.^nTo buy exp say buyap", name, cvar_ap)
	
	return PLUGIN_CONTINUE
} 


//=============================================================


public CHECK_BUY(id)
{
	new name[33]
	get_user_name(id,name,32)

	//check to see if mechant plugin is enabled
	if ( get_cvar_num("sv_merchant") != 1 ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. The SH merchant is disabled.", name)
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: SH Merchant is disabled")
		return CHECK_BAD
	}


	//check to make sure specs arent whording money and buying
	//also prevents problems incase users are buying life/armor or if they are revived from the spec team
	if( (get_user_team(id) != TEAM_T) && (get_user_team(id) != TEAM_CT) ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Spectators may not make purchases.", name )
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: user in spec")
		return CHECK_BAD
	}


	//check for invalid IDs
	if( id < 1 || id > 32 ){
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: Invalid player ID")
		return CHECK_BAD
	}
	if( is_user_bot(id) != 0 ){
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: User appears to be a bot")
		return CHECK_BAD
	}


	//check if SHmod is disabled
	if( get_cvar_num("sv_superheros") != 1 ){
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: SHero mod is disabled")
		return CHECK_BAD
	}

/*	removed temporarily
	//check the mode
	switch( get_cvar_num("shm_mode") )
	{
		case 1: {
			if( !is_user_alive(id) ){
				client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Dead players may not make purchases.", name )
				return CHECK_BAD
			}
			}
		case 2: {
			if( is_user_alive(id) ){
				client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Live players may not make purchases.", name )
				return CHECK_BAD
			}
			}
	}
*/
	//disable when loading a map
	new time_elasped = (get_cvar_num("mp_timelimit") * 60) - get_timeleft() 
	if( time_elasped < 60 ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. Please wait until 1 minute after a map change to purchase.", name )
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: map just changed")
		return CHECK_BAD	
	}

	//disable just before a map change
	if( get_timeleft() < MAP_TIMELEFT ){
		client_print(id,print_chat,"[SHM APP_VER] Sorry, %s. It is too close to the end of the map to purchase.", name )
		console_print(0, "[SHM APP_VER] CHECK_BUY() failed for reason: map change imminent")
		return CHECK_BAD
	}

	return CHECK_OK
}