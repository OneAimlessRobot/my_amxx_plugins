/* zp bank
initiallly this plugin started off with just the auto save feature making it just a plain save system
but it was decided that making it more like a bank would be more interesting and slowly it was converted
to include commands etc while leaving the original auto save function in place.  Later advanced bank accounts
with interest where added as was sql support.

say commands
deposit, send, store <amount/all>				//deposites stated amount in bank account
			
withdraw, take, retrieve <amount/all>			//retrieves stated amount from bank account

mybank, account, bank <blank/name of person>	//if second parameter is left blank, states how many ap you have in your account
												//if second parameter is specified it attempts to give a status on the said person's account

upgrade account									//will give a warning about what a advanced account does, after which person must say "advanced account" again to advance

server commands
zp_give_packs <steamid not name> <amount>	//gives ammo packs even if person not in game
zp_bank_amount <name/steamid>				//same as bank say command, but works from server console
zp_reset_bank <time> 						//will prune database by time based in days. time 0 = clean all 


cvars copy/paste into your zombieplague.cfg file

zp_bank 1							//plugin on or off?
zp_bank_auto 0						//0 = no auto save, 1 = auto save, 2 = auto save + auto withdraw all on connect
zp_bank_blockstart 0				//if set we strip ammo packs zp gives when client first connects if they have an open bank account
zp_bank_upgradable 1				//advanced accounts availalbe?
zp_bank_cost 1000					//cost to advance an account
zp_bank_interest 0.03				//interest earned every x(zp_bank_clock) minutes
zp_bank_clock 60					//think is done in 1 minute intervals so 60 = 1 hr
zp_bank_transfee 3					//fee applied each time ammo packs are stored

*/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <zombieplague>

enum {
	SAVE_NVAULT = 1,
	SAVE_SQL
}

#define SAVE_TYPE SAVE_NVAULT

#if SAVE_TYPE == SAVE_SQL
	#include <sqlx>
	
	new Handle:g_SqlX;
	new const sql_table[] = "zp_bank"
	new query_buff[1028];
#else
	#include <nvault>
	
	new gVault;
#endif

new const version[] = "4.4";
new const plugin[] = "ZP Bank";

enum pcvar
{ enable = 0, auto, start, account2, charge, interest, charge3, repitions }

new pcvars[pcvar];
new bankstorage[33], sessionstore[33];
new special[33], bool:warning[33], bool:xploaded[33], bool:lock_cmd[33];
new clockstore[33];

new thinkobj, g_msgSayText, loop_count;

public plugin_init()
{
	register_plugin(plugin, version, "Random1");
	
	pcvars[enable] =			register_cvar("zp_bank", "1");
	pcvars[auto] =				register_cvar("zp_bank_auto", "0");
	pcvars[start] =				register_cvar("zp_bank_blockstart", "0");
	pcvars[account2] =			register_cvar("zp_bank_upgradable", "1");
	pcvars[charge] =			register_cvar("zp_bank_cost", "1000");
	pcvars[interest] =			register_cvar("zp_bank_interest", "0.03");
	pcvars[repitions] =			register_cvar("zp_bank_clock", "60");
	pcvars[charge3] =			register_cvar("zp_bank_transfee", "3");
		
	register_clcmd("say", "handle_say");
	register_clcmd("say_team", "handle_say");
	register_concmd("zp_bank_amount", "serverbank", ADMIN_RCON, "<name/steamid>");
	register_concmd("zp_reset_bank", "prune_task", ADMIN_RCON, "<time> in days. time 0 = clean all");
	register_concmd("zp_give_packs", "givex_cmd", ADMIN_RCON, "<steamid not name> <amount>, gives ammo packs even if person not in game");
	
	#if SAVE_TYPE == SAVE_SQL
	set_task(0.5, "sql_init");
	register_logevent("logevent_round_end", 2, "1=Round_End");	
	#else
	gVault = nvault_open("zp_bank_data");
	#endif
	
	
	g_msgSayText = get_user_msgid("SayText");
	
	thinkobj = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if ( pev_valid(thinkobj) )
	{
		set_pev(thinkobj, pev_classname, "advertisement_loop");
		set_pev(thinkobj, pev_nextthink, get_gametime() + 60.0);
		register_forward(FM_Think, "onemin_think");
	}
}

public plugin_natives()
{
	register_native("zp_get_all_ammopacks", "native_retrieve_all_ap", 1);
	register_native("zp_get_bank_ammopacks", "native_retrieve_ap", 1);
	register_native("zp_set_bank_ammopacks", "native_set_ap", 1);
}

#if SAVE_TYPE == SAVE_SQL
public sql_init()
{
	g_SqlX = SQL_MakeStdTuple();
	
	formatex(query_buff, charsmax(query_buff), "CREATE TABLE IF NOT EXISTS `%s` (\
				USER_KEY VARCHAR(36) NOT NULL PRIMARY KEY, \
				AMMOPACK DECIMAL( 10 ) UNSIGNED NOT NULL DEFAULT '0', \
				ADVANCED TINYINT(3) UNSIGNED NOT NULL DEFAULT 0, \
				TIMECLOCK INT(10) NOT NULL DEFAULT 0, \
				LAST_PLAY_DATE TIMESTAMP(10) NOT NULL \
			) ENGINE=MyISAM DEFAULT CHARSET=utf8;", sql_table)
	
	SQL_ThreadQuery(g_SqlX, "handle_error", query_buff);
}
	
public logevent_round_end()
{
	for( new id = 1; id <= 32; id++ )
		if ( is_user_connected(id) && !xploaded[id] )
			retrieve_data(id);
}
#endif
	
public prune_task(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) {
		console_print(id,"You have no access to that command");
		return;
	}
	new connum = read_argc()
	if (connum > 2) {
		console_print(id,"Too many arguments supplied.");
		return;
	}
	if ( connum == 1 ) return;	//person just typed command to see the description
	//we check this because str_to_num will return 0 on an empty string thus doing the same thing as "zp_reset_bank 0" which does a full reset
	
	new adminname[32];
	get_user_name(id, adminname, 31);
	new arg[10];
	read_argv(1,arg,9);
	new timeamnt = str_to_num(arg);
	if ( timeamnt == 0 ) {
#if SAVE_TYPE == SAVE_NVAULT
		nvault_prune(gVault, 0, 0);
#else
		formatex(query_buff, charsmax(query_buff), "TRUNCATE TABLE `%s`", sql_table);
		
		SQL_ThreadQuery(g_SqlX, "handle_error", query_buff)
#endif
		zp_colored_print(0, "^x04[%s]^x03 The Bank's Been Robbed!, those dirty crooks stole all your money!", plugin);
		log_to_file("zp_error.log", "[%s] bank has been reset(completly) by admin %s", plugin, adminname);
		//for those who are in the server at the time of prune need to whipe out there stuff as well
		for( new o = 1; o < 33; o++)
		{
			if ( !is_user_connected(o) || is_user_bot(o) ) continue;
			
			special[o] = 0;
			warning[o] = false;
			bankstorage[o] = 0;
			clockstore[o] = -1;
		}
	}
	else {
#if SAVE_TYPE == SAVE_NVAULT
		nvault_prune(gVault, 0, get_systime() - (timeamnt * 86400));
#else
		formatex(query_buff, charsmax(query_buff), "DELETE FROM `%s` WHERE LAST_PLAY_DATE<(SYSDATE() - INTERVAL '%d' DAY)", sql_table, timeamnt);
		
		SQL_ThreadQuery(g_SqlX, "handle_error", query_buff)		
#endif
		log_to_file("zp_error.log", "[%s] bank has been pruned %d day%s by admin %s", plugin, timeamnt, timeamnt == 1 ? "" : "'s", adminname);		
	}
}

public givex_cmd(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) {
		console_print(id,"You have no access to that command");
		return;
	}
	
	if ( read_argc() > 3 ) return;
		
	new arg1[32], arg2[10], amount;
	read_argv(1, arg1, sizeof(arg1) - 1);
	read_argv(2, arg2, sizeof(arg2) - 1);
	if ( arg1[0] != 'S' && !isdigit(arg1[6]) )
	{
		server_print("[%s] please only use steamid and be sure to append the STEAM_0:", plugin);
		return;
	}
	if ( !isdigit(arg2[0]) && !isdigit(arg2[1]) ) {
		server_print("[%s] error argument2 = %s, should be a number", plugin, arg2);
		return;
	}
	
	amount = str_to_num(arg2);
	//first see if our player is not currently in server
	new i, AuthID[32];
	for( i = 1; i <= 32; i++ )
	{
		get_user_authid(i,AuthID,31);
		if ( equal(AuthID, arg1) )
		{
			bankstorage[i] += amount;
			server_print( "[%s] Succesfuly %s %d ammo packs %s %s. Account now has %d", plugin, amount > 0 ? "gave" : "took", amount, amount > 0 ? "to" : "from", arg1, bankstorage[i]);
			log_to_file( "zp_banking.log", "[%s] Succesfuly %s %d ammo packs %s %s. Account now has %d", plugin, amount > 0 ? "gave" : "took", amount, amount > 0 ? "to" : "from", arg1, bankstorage[i]); 
			return;
		}
	}
	//not in the server so have to check our nvault file now
#if SAVE_TYPE == SAVE_NVAULT
	new vaultkey[38], vaultdata[64]; 
	
	formatex(vaultkey, 37, "__%s__", arg1);

	nvault_get(gVault, vaultkey, vaultdata, 63); 
	if ( strlen(vaultdata) == 0 )
	{
		server_print( "[%s] player does not exsist within database, make sure your passing right steamid", plugin);
		return;
	}
	new cashamnt[51], has2[4], clockamnt[10], buffer[3];
	parse(vaultdata, cashamnt, 50, has2, 3, clockamnt, 9);	
	
	buffer[0] = str_to_num(cashamnt);
	buffer[1] = str_to_num(has2);
	buffer[2] = str_to_num(clockamnt);
	server_print( "[%s] %s has %d ammo packs before applying %d from zp_give_packs command", plugin, arg1, buffer[0], amount);
	//now apply the command
	buffer[0] += amount;
	if ( buffer[0] < 0 ) buffer[0] = 0;
	formatex(vaultdata, 63, "%i %i %i", buffer[0], buffer[1], buffer[2]);
	
	nvault_set(gVault, vaultkey, vaultdata);
	server_print( "[%s] Succesfuly %s %d ammo packs %s %s. Account now has %d", plugin, amount > 0 ? "gave" : "took", amount, amount > 0 ? "to" : "from", arg1, buffer[0]);
#else
	new data[38]
	data[0] = amount
	formatex(data[1], charsmax(data)-1, arg1);

	formatex(query_buff, charsmax(query_buff), "INSERT INTO `%s` SET USER_KEY='%s', AMMOPACK=%d ON DUPLICATE KEY UPDATE AMMOPACK=AMMOPACK+(%d)",
		sql_table, arg1, amount, amount);
		
	SQL_ThreadQuery(g_SqlX, "handle_error", query_buff, data, charsmax(data));
#endif
}

public onemin_think(ent)
{
	if ( ent != thinkobj ) return FMRES_IGNORED;
	if ( --loop_count <= 0 )
	{
		advertisement();
		loop_count = 4;
	}
	
	if ( !get_pcvar_num(pcvars[account2]) ) return FMRES_IGNORED;
	
	for ( new id = 1; id < 33; id++ )
	{
		if ( !is_user_alive(id) || is_user_bot(id) || lock_cmd[id] ) continue;
		
		save_data(id);
						
		if (special[id] ) {
			clockstore[id]--
			if ( clockstore[id] == 0 )
			{
				clockstore[id] = get_pcvar_num(pcvars[repitions]);
				add_interest(id);
			}
		}
	}
	set_pev(ent, pev_nextthink, get_gametime() + 60.0);
	
	return FMRES_HANDLED;	
}

add_interest(id)
{
	new Float:temp = float( bankstorage[id] );
	if ( temp <= 0.0 || temp > 100000.0 ) return;
	temp *= get_pcvar_float(pcvars[interest]);
	new temp2 = floatround(temp);
	if ( temp2 < 0 || temp2 > get_pcvar_num(pcvars[charge]) )
		return;
	
	localchange(id, temp2);
		
	zp_colored_print(id, "^x04[%s]^x03 interest applied new balance is %d", plugin, bankstorage[id]);
}

advertisement()
{
	if ( !get_pcvar_num(pcvars[enable]) ) return;
	
	zp_colored_print(0, "^x04[%s]^x03 Enabled. Transaction fee's of %d apply", plugin, get_pcvar_num(pcvars[charge3]) );
	zp_colored_print(0, "^x04[%s]^x03 Currently Ammo packs are %s", plugin,
		get_pcvar_num(pcvars[auto]) >= 1 ? "Saved automaticly during map change" : "Savable by typing ^"deposit <amount>^"." );
	zp_colored_print(0, "^x04[%s]^x03 %s", plugin,
		get_pcvar_num(pcvars[auto]) >= 2 ? "Ammo packs are withdrawn when connecting" : "To retrieve your ammo packs type ^"withdraw <amount>^"" );
	if ( get_pcvar_num(pcvars[account2]) )
	{
		new irepition = get_pcvar_num(pcvars[repitions]);
		new timetype[8];
		formatex(timetype, charsmax(timetype), "%s", irepition >= 60 ? "hours" : "minutes");
		if ( irepition >= 60 )
			irepition /= 60;
			
		zp_colored_print(0, "^x04[%s]^x03 Advance account's available, say ^"upgrade account^" for more details", plugin);
		zp_colored_print(0, "^x04[%s]^x03 An upgraded account will earn you %2.2f interest every %i %s", plugin, get_pcvar_float(pcvars[interest]), irepition, timetype);
	}
}
public plugin_end() {
	//one final save on all users before changing maps
	for ( new id = 1; id < 33; id++ )
		if ( is_user_connected(id) ) save_data(id);
		
#if SAVE_TYPE == SAVE_NVAULT
	nvault_close(gVault);
#else
	SQL_FreeHandle(g_SqlX);
#endif
}
	
public handle_say(id)
{
	if ( !get_pcvar_num(pcvars[enable]) || lock_cmd[id] ) return PLUGIN_CONTINUE;
	
	static text[70], arg1[32], arg2[32], arg3[6];
	read_args(text, sizeof(text)-1);
	remove_quotes(text);
	arg1[0] = '^0';
	arg2[0] = '^0';
	arg3[0] = '^0';
	parse(text, arg1, sizeof(arg1)-1, arg2, sizeof(arg2)-1, arg3, sizeof(arg3)-1);

	if (arg3[0] == 0)
	{
		//strip forward slash if present
		if ( equali(arg1, "/", 1) ) format(arg1, 31, arg1[1]);
		
		if ( equali(arg1, "deposit", 7) || equali(arg1, "send", 4) || equali(arg1, "store", 5) )
		{				
			if ( isdigit(arg2[0]) || (arg2[0] == '-' && isdigit(arg2[1])) ) 
			{
				new value = str_to_num(arg2);
				store_cash(id, value);
				return PLUGIN_HANDLED;
			}
			else if ( equali(arg2, "all") )
			{
				store_cash(id, -1);
				return PLUGIN_HANDLED;
			}				
			else if ( arg2[0] == 0 )
				zp_colored_print(id, "^x04[%s]^x03 to deposit ammo packs in bank say deposit <amount to deposit>", plugin);
			
			return PLUGIN_CONTINUE;
		}
		else if ( equali(arg1, "withdraw", 8) || equali(arg1, "take", 4) || equali(arg1, "retrieve", 8) )
		{				
			if ( isdigit(arg2[0]) || (arg2[0] == '-' && isdigit(arg2[1])) ) 
			{
				new value = str_to_num(arg2);
				take_cash(id, value);
				return PLUGIN_HANDLED;
			}
			else if ( equali(arg2, "all") )
			{
				take_cash(id, -1);
				return PLUGIN_HANDLED;
			}
			else if ( arg2[0] == 0 )
				zp_colored_print(id, "^x04[%s]^x03 to withdraw ammo packs from bank say withdraw <amount to withdraw>", plugin);
			
			return PLUGIN_CONTINUE;
		}
		else if ( equali(arg1, "mybank", 6) || equali(arg1, "account", 7) || equali(arg1, "bank", 4) )
		{
			if ( arg2[0] == 0 ) {
				zp_colored_print(id, "^x04[%s]^x03 Currently your [%s]account has %d ammo packs in it",plugin,special[id] ? "advanced" : "regular", bankstorage[id]);
				return PLUGIN_HANDLED;
			}
			else {
				new player = cmd_target(id,arg2,2);
				if ( !player ) return PLUGIN_CONTINUE;
				zp_colored_print(id, "^x04[%s]^x03 %s has %d ammo packs", plugin, arg2, bankstorage[player]);
				return PLUGIN_HANDLED;
			}
		}
		else if ( equali(arg1, "upgrade", 7) && equali(arg2, "account", 7) )
		{
			if ( !warning[id] )
				upgrade_account(id);
				
			else 
				do_upgrade(id);
		}
	}
	return PLUGIN_CONTINUE;
}

public serverbank(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) {
		console_print(id,"You have no access to that command");
		return;
	}
	
	new arg[35], player, playername[35], AuthID[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	if ( equali(arg, "all") )
	{
		for ( new i = 1; i < 33; i++ )
		{
			if ( !is_user_connected(i) ) continue;
			
			get_user_name( i, playername, sizeof(playername) - 1 );
			server_print("[%s] %s has %d ammo packs", plugin, playername, bankstorage[i]);
		}
		return;
	}
			
	player = 0
	for( new i = 1; i <= 32; i++ )
	{
		if ( !is_user_connected(i) || is_user_bot(i) ) continue;
		
		get_user_name( i, playername, charsmax(playername) );
		get_user_authid( i, AuthID, charsmax(AuthID) );
		if ( equal(AuthID, arg) || containi(playername, arg) )
		{
			player = i;
			break;
		}
	}

	if ( !player )
	{
		server_print("Error locating player");
		return;
	}
	server_print("[%s] %s has %d ammo packs", plugin, arg, bankstorage[player]);
}
 
upgrade_account(id)
{
	if ( !get_pcvar_num(pcvars[account2]) ) return;
	
	if ( special[id] )	
	{
		zp_colored_print(id, "^x04[%s]^x03 You already have an advanced account", plugin);
		return;
	}
	else
	{
		zp_colored_print(id, "^x04[%s]^x03 You have opted to upgrade your bank account type", plugin);
		zp_colored_print(id, "^x04[%s]^x03 An upgraded account will earn you %2.2f interest an hour", plugin, get_pcvar_float(pcvars[interest]));
		new temp = bankstorage[id] + zp_get_user_ammo_packs(id);
		if ( temp > get_pcvar_num(pcvars[charge]) )
		{
			zp_colored_print(id, "^x04[%s]^x03 There is a %d starting fee", plugin,	get_pcvar_num(pcvars[charge]) );	
			zp_colored_print(id, "^x04[%s]^x03 If you accept these conditions simply retype ^"upgrade account^", and your account will be upgraded", plugin);
			warning[id] = true;
		}
		else
			zp_colored_print(id, "^x04[%s]^x03 You do not have the required %d ammo packs to upgrade account yet", plugin, get_pcvar_num(pcvars[charge]) );
	}
}

do_upgrade(id)
{
	if ( !get_pcvar_num(pcvars[account2]) ) return;
	
	new temp2 = bankstorage[id] + zp_get_user_ammo_packs(id);
	new temp = get_pcvar_num(pcvars[charge]);
	if ( temp2 > temp )
	{
		if ( bankstorage[id] - 1 > temp )
			localchange(id, -temp);
		else
		{
			temp -= bankstorage[id] - 1
			bankstorage[id] = 1;
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) - temp);
		}
		special[id] = 1;
		clockstore[id] = 1;	//time to start the clock
		zp_colored_print(id, "^x04[%s]^x03 You account has been upgraded", plugin);
	}
	else {
		zp_colored_print(id, "^x04[%s]^x03 You don't have the necessary amount of ammo packs to upgrade your account", plugin);
		warning[id] = false;
	}		
}

public client_disconnect(id)
{
	if ( get_pcvar_num(pcvars[auto]) ) 
		store_cash(id, -1);
	
	if ( bankstorage[id] > 0 ) save_data(id);
	lock_cmd[id] = true;	//basically this prevents players attempting to dupe their ap by reconnecting
}

public client_putinserver(id)
	set_task(1.0, "delayed_connect", id);	//a small delay allows zp to load all its data before we mess with it
	
public delayed_connect(id)
{	
	warning[id] = false;
	special[id] = 0;
	xploaded[id] = false;
	bankstorage[id] = 0;
	sessionstore[id] = 0;
	clockstore[id] = -1;
	lock_cmd[id] = false;	//now they have officially connected and we allow bank commands again
	
	//attempt to retrive the data right away
	retrieve_data(id);
}

store_cash(id, amnt)
{
	if ( !get_pcvar_num(pcvars[enable]) ) return;
	
	new userpacks = zp_get_user_ammo_packs(id);
	if ( amnt == -1 )
	{
		localchange(id, userpacks);
		zp_set_user_ammo_packs(id, 0);
	}
	else if ( amnt > 0 )
	{
		if ( amnt > get_pcvar_num(pcvars[charge3]) )
		{
			deduction(id);
			amnt -= get_pcvar_num(pcvars[charge3]);
		}
		
		if ( userpacks >= amnt )
		{			
			localchange(id, amnt);
			zp_set_user_ammo_packs(id, userpacks - amnt);
		}
		else
			zp_colored_print(id, "^x04[%s]^x03 Amount specified(%d) is greater than current ammo pack count(%d)", plugin,
			amnt, userpacks);			
	}
	else
		take_cash(id, -amnt);
}

take_cash(id, amnt)
{
	if ( !get_pcvar_num(pcvars[enable]) ) return;
	
	if ( amnt == 0 ) return;	//otherwise a non terminal loop is possible
	
	if ( amnt == -1 )
	{
		if ( special[id] ) 
		{
			zp_set_user_ammo_packs(id, bankstorage[id] - 1)
			bankstorage[id] = 1;
		}
		else
		{
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + bankstorage[id])
			bankstorage[id] = 0;
		}
	}
	else if ( amnt > 0 )
	{
		if ( bankstorage[id] >= amnt )
		{
			deduction(id);
											
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + amnt);
			localchange(id, -amnt);
		} else {
			zp_colored_print(id, "^x04[%s]^x03 Amount specified(%d) is greater than whats in bank(%d)", plugin, amnt, bankstorage[id]);		
		}	
	}
	else store_cash(id, -amnt);
}

localchange(id, amount, mainload = 0)
{
	new playerAP = bankstorage[id]
	new newTotal = playerAP + amount

	if ( amount > 0 && newTotal < playerAP ) {
		// Max possible signed 32bit int
		bankstorage[id] = 2147483647
	}
	else if ( amount < 0 && (newTotal < -1000000 || newTotal > playerAP) ) {
		bankstorage[id] = -1000000
	}
	else {
		bankstorage[id] = newTotal
	}
	if ( mainload )
		sessionstore[id] += amount;
}
	
deduction(id)
{
	new temp = bankstorage[id] + zp_get_user_ammo_packs(id) - 1;
	new temp2 = get_pcvar_num(pcvars[charge3]);
	if ( temp >= temp2 )
	{
		if ( bankstorage[id] - 1 > temp2 )
			localchange(id, -temp2);
			
		else
		{
			temp2 -= ( bankstorage[id] - 1 );
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) - temp2);
			bankstorage[id] = 1;
		}
	}
}

#if SAVE_TYPE == SAVE_NVAULT

save_data(id)
{
	if ( !xploaded[id] ) {
		retrieve_data(id);
		return;
	}
	
	new AuthID[35];
	get_user_authid(id, AuthID, charsmax(AuthID));
	if ( !strlen(AuthID) ) return;
	
	new vaultdata[64], temp;

	temp = special[id] ? 1 : 0;
	
	formatex( vaultdata, 511, "%i %i %i", bankstorage[id], temp, clockstore[id] );

	nvault_set(gVault, AuthID, vaultdata); 
}

retrieve_data(id)
{
	if ( xploaded[id] || !is_user_connected(id) ) return;
	
	new AuthID[35];
	get_user_authid(id, AuthID, charsmax(AuthID));
	if ( !strlen(AuthID) ) return;

	new vaultdata[64]; 
	
	nvault_get(gVault, AuthID, vaultdata, 63); 
	
	new cashamnt[51], has2[4], clockamnt[10];
	parse(vaultdata, cashamnt, charsmax(cashamnt), has2, charsmax(has2), clockamnt, charsmax(clockamnt));	
	
	localchange(id, str_to_num(cashamnt), 1);
	special[id] = ( str_to_num(has2) == 1 );
	clockstore[id] = str_to_num(clockamnt);
	xploaded[id] = true;
	
	// If they have an account don't allow zombie mod to give them 5 ammo packs at beggining
	if ( get_pcvar_num(pcvars[start]) && bankstorage[id] > 0 ) 
		zp_set_user_ammo_packs(id, 0);
		
	if ( get_pcvar_num(pcvars[auto]) == 2 ) 	
		take_cash(id, -1);
}

#else

save_data(id)
{	
	if ( !xploaded[id] ) {
		retrieve_data(id);
		return;
	}
	new AuthID[35];
	get_user_authid(id, AuthID, charsmax(AuthID));
	if ( !strlen(AuthID) || bankstorage[id] <= 0 ) return;
		
	formatex(query_buff, charsmax(query_buff), "INSERT INTO `%s` SET USER_KEY='%s', AMMOPACK=%d, ADVANCED=%d, TIMECLOCK=%d, LAST_PLAY_DATE=SYSDATE() ON DUPLICATE KEY UPDATE AMMOPACK=AMMOPACK+(%d), ADVANCED=%d, TIMECLOCK=%d, LAST_PLAY_DATE=SYSDATE()",
		sql_table, AuthID, bankstorage[id], special[id] ? 1 : 0, clockstore[id], sessionstore[id], special[id] ? 1 : 0, clockstore[id]);
	
	SQL_ThreadQuery(g_SqlX, "handle_error", query_buff);
}
public handle_error(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		server_print("[%s] SQL error: '%s'", plugin, error);
		log_to_file("zp_error.log", "[%s] SQL error: '%s'", plugin, error);
		return;
	}
	if ( size > 36 ) {
		new authid[35], amount;
		amount = data[0];
		copy(authid, charsmax(authid), data[1]);
		server_print( "[%s] Succesfuly %s %d ammo packs %s %s.", plugin, amount > 0 ? "gave" : "took", amount, amount > 0 ? "to" : "from", authid);
		log_to_file( "zp_banking.log", "[%s] Succesfuly %s %d ammo packs %s %s.", plugin, amount > 0 ? "gave" : "took", amount, amount > 0 ? "to" : "from", authid);
	}	
}

retrieve_data(id)
{
	new buffer[38], AuthID[35];
	get_user_authid(id, AuthID, charsmax(AuthID));
	if ( !strlen(AuthID) ) return;

	formatex(query_buff, charsmax(query_buff), "SELECT AMMOPACK,ADVANCED,TIMECLOCK FROM `%s` WHERE USER_KEY='%s'", sql_table, AuthID);
	
	buffer[0] = id;
	copy(buffer[1], charsmax(buffer)-1, AuthID);
	
	SQL_ThreadQuery(g_SqlX, "handle_retrieve", query_buff, buffer, charsmax(buffer));
}
public handle_retrieve(failstate, Handle:hrquery, error[], errnum, data[], size)
{
	new id = data[0];
	if ( xploaded[id] || !is_user_connected(id) ) return;
	
	new AuthExpected[35], AuthCalled[35];
	get_user_authid(id, AuthExpected, 34);
	copy(AuthCalled, 34, data[1]);
	if ( !equali(AuthExpected, AuthCalled) )
	{
		log_to_file("zp_error.log", "[%s] Load Glitch, expected = %s, passed = %s", plugin, AuthExpected, AuthCalled);
		return;
	}			
	if (failstate)
	{
		log_to_file("zp_error.log", "[%s] SQL error: '%s'", plugin, error);
		return;
	}
	else
	{		
		if ( !SQL_NumResults(hrquery) )
			console_print(id, "[%s] No save data located", plugin);				

		else
		{
			new ipacks = 0;
			ipacks = SQL_ReadResult(hrquery, 0);
				
			special[id] = SQL_ReadResult(hrquery, 1) >= 1 ? 1 : 0;
			clockstore[id] = SQL_ReadResult(hrquery, 2);
			
			if( special[id] && !clockstore[id] )
				clockstore[id] = get_pcvar_num(pcvars[repitions]);	//in case an error occured durig saving process before
	
			localchange(id, ipacks, 1);
			console_print(id, "[%s] account has been loaded from save table", plugin);
			
			// If they have an account don't allow zombie mod to give them 5 ammo packs at beggining
			if ( get_pcvar_num(pcvars[start]) && bankstorage[id] > 0 ) 
				zp_set_user_ammo_packs(id, 0);
		}
		xploaded[id] = true;
	}
		
	if ( get_pcvar_num(pcvars[auto]) == 2 ) 	
		take_cash(id, -1);
}

#endif
	
// Prints a colored message to target (use 0 for everyone), supports ML formatting.
zp_colored_print(target, const message[], any:...)
{
	new buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		new player
		for (player = 1; player <= 33; player++)
		{
			// Not connected
			if ( !is_user_connected(player) || is_user_bot(player) )
				continue;
			
			// Remember changed arguments
			new changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// Replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format message for player
			vformat(buffer, sizeof buffer - 1, message, 3)
			
			// Send it
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// Replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	
	// Send to specific target
	else
	{		
		// Format message for player
		vformat(buffer, sizeof buffer - 1, message, 3)
		
		// Send it
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

public native_retrieve_all_ap(id)
	return zp_get_user_ammo_packs(id) + bankstorage[id];

public native_retrieve_ap(id)
	return bankstorage[id];
	
public native_set_ap(id, amount, bool:addto)
{
	if ( !is_user_connected(id) ) return;
	
	bankstorage[id] = addto ? bankstorage[id] + amount : amount;
}