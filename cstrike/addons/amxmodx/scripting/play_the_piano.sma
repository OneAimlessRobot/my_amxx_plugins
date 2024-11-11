
/* AMX Mod X Script

***************************************************************************
 * amx_ejl_piano.sma     version 1.0                  Date: 7/01/2003
 *  Author: Eric Lidman      ejlmozart@hotmail.com
 *  Alias: Ludwig van        Upgrade: http://lidmanmusic.com/cs/plugins.html
 *
 *  Play the piano in any Half-Life mod. Its great for CS in that it gives
 *   you something to do to entertain yourself, while you are dead for
 *   example. Admin can set player's pianos to broadcast to all players, to
 *   the dead plyers only, or just no broadcast to players (default for 
 *   regular players). An admin's default for his own piano is broadcast to
 *   all. Set your mode to 0 with command below to play only to yourself. 
 *   The notes of the piano are all mathematically created from a single
 *   sound. The range is 5 chromatic octaves. Sorry, the lowest notes are 
 *   out of tune, a limitation in Half-Life pitch adjustments. There are 4
 *   different piano sounds to choose from.
 *
 *
 * *******************************************************************************
 *  
 *	Ported By KingPin( kingpin@onexfx.com ). I take no responsibility 
 *	for this file in any way. Use at your own risk. No warranties of any kind. 
 *
 * *******************************************************************************
 *
 *  ADMIN COMMANDS:
 *
 *   amx_pinao_mode <player> <mode>  --Sets a players piano broadcast mode
 *                                     to determine who can hear his piano
 *                                      0 = no broadcast
 *                                      1 = only to dead
 *                                      2 = to all players       
 *   amx_piano_mode_all <mode>       --same as above command, but sets mode
 *                                     for every player on the server 
 *
 *  CLIENT COMMANDS:
 *
 *   say /piano       --in chat:    Get help and info on setting up piano
 *   amx_set_piano    --in console: Set key binds to piano mode
 *   amx_unset_piano  --in console: Return key binds to normal, whatever is
 *                      in client's config.cfg
 *   amx_piano_wtf    --in console: Returns key binds to original default
 *                      settings in the event amx_unset_piano cannot do it
 *   amx_pianonote    <number from 1 to 13>  1 = C natural
 *   amx_pianooctave  <number from 1 to 5> Default octave is 3 for medium
 *                    pitch range playing 
 *   amx_pianosound   <number from 0 to 3> Default is 0 for fvox/boop sound  
 *
 *
 *  WARNING: If you should become disconnected while in piano mode, your keys
 *   may be stuck in piano mode. If the unset command doesnt work, enter this
 *   in console: amx_piano_wtf and your binds will go back to original default
 *   for the keys that were used for piano. Those keys are:
 *
 *    Change Note Keys: 1,2,3,4,5,6,7,8,9,0,-,=,backspace
 *    Change Octave Keys: F3,F4,F5,F6,F7
 *    Change instrument type: F8
 *
 *   Normally I am not a fan of changing peoples binds or doing anything that
 *   can possibly be destructive to the config.cfg, but there are safegaurds
 *   built into the plugin to help minimize such an occurance. Use at your
 *   own risk.
 *
 ****************************************************************************/

#include <amxmodx>
#include <amxmisc>

new g_broadcastmode
new broadcastmode[33]
new octave[33]
new instrument[33]
new instrument_sound[4][] = {"fvox/boop","fvox/beep","buzwarn","bizwarn"}
new Float:transpose[4] = {86.4,102.9,111.5,94.5} 
new are_you_sure[33]

public plugin_init() {
	register_plugin("PLAY THE PIANO","1.0","EJL")
	register_concmd("amx_piano_mode","admin_piano_bmode",ADMIN_MAP,"<player> <mode 0|1|2 : 0=no broadcast 1=only to dead 2=to all>")
	register_concmd("amx_piano_mode_all","admin_piano_bmode",ADMIN_MAP,"<mode 0|1|2 : 0=no broadcast 1=only to dead 2=to all>")
	register_clcmd("amx_pianonote", "admin_piano")
	register_clcmd("amx_pianooctave","admin_octave")
	register_clcmd("amx_set_piano","admin_bindk")
	register_clcmd("amx_unset_piano","admin_unbindk")
	register_clcmd("amx_pianosound","admin_instr")
	register_clcmd("amx_piano_wtf","admin_piano_wtf")
	register_clcmd("say /piano","piano_motd")
	register_clcmd("say","HandleSay")
	return PLUGIN_CONTINUE
}

public client_connect(id){
	octave[id] = 3
	instrument[id] = 0
	if(get_user_flags(id) & ADMIN_MAP)
		broadcastmode[id] = 2
	else
		broadcastmode[id] = g_broadcastmode
	return PLUGIN_CONTINUE
}	

public admin_piano_bmode(id,level,cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	new cmd[32]
	read_argv(0,cmd,31)
	if(equal(cmd[15],"a",1)){
		new arg[8]
		read_argv(1,arg,7)
		new bmode = str_to_num(arg)
		if(bmode < 0 || bmode > 2)
			bmode = 0	
		g_broadcastmode = bmode
		new maxpl = get_maxplayers()
		for(new i = 1;i<maxpl;i++)
			broadcastmode[i] = bmode
		switch(g_broadcastmode){
			case 0:{
				console_print(id,"[AMXX]  You have set everyone's piano to no broadcast mode.")
				client_print(0,print_chat,"[AMXX] Admin has set server so only you hear yourself playing piano. Help: say  /piano")	
			}
			case 1:{
				console_print(id,"[AMXX]  You have set everyone's piano to broadcast to dead only mode.")
				client_print(0,print_chat,"[AMXX] Admin has set server so only dead hear you playing piano. Help: say  /piano")
			}
			case 2:{
				console_print(id,"[AMXX]  You have set everyone's piano to broadcast to all players.")
				client_print(0,print_chat,"[AMXX] Admin has set server so everone hear everyone playing piano. Help: say  /piano")
			}
		}
	}else{
		new arg[32], arg2[8]
		read_argv(1,arg,31)
		read_argv(2,arg2,7)
		new player = cmd_target(id,arg,1)
		if (!player) return PLUGIN_HANDLED
		new bmode = str_to_num(arg2)
		if(bmode < 0 || bmode > 2)
			bmode = 0	
		broadcastmode[player] = bmode
		new pname[32]
		get_user_name(player,pname,31)
		switch(broadcastmode[player]){
			case 0:{
				console_print(id,"[AMXX]  You have set %s's piano to no broadcast mode.",pname)
				client_print(0,print_chat,"[AMXX] Admin has set %s's piano to no broadcast mode.",pname)	
			}
			case 1:{
				console_print(id,"[AMXX]  You have set %s's piano to broadcast to dead only mode.",pname)
				client_print(0,print_chat,"[AMXX] Admin has set %s's paino so only dead hear him playing piano.",pname)
			}
			case 2:{
				console_print(id,"[AMXX]  You have set %s's piano to broadcast to all players.",pname)
				client_print(0,print_chat,"[AMXX] Admin has set %s's piano to broadcast to all players.",pname)
			}
		}
	}
	return PLUGIN_HANDLED
}

public HandleSay(id) {
	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	if( (containi(Speech, "piano") != -1) || (containi(Speech, "music") != -1) ){
		switch(broadcastmode[id]){
			case 0: client_print(id,print_chat,"[AMXX] Only you can hear yourself playing piano.  Help: say  /piano")
			case 1: client_print(id,print_chat, "[AMXX] Only the dead can hear you playing piano.  Help: say  /piano")
			case 2: client_print(id,print_chat, "[AMXX] Everyone can hear you playing piano.  Help: say  /piano")
		}
	}
	return PLUGIN_CONTINUE
}

public piano_motd(id){
	new la_motd[1300]
	new temp[768]
	temp = "Set keys to piano mode, in console: amx_set_piano^n\
			 Return keys back to normal, in console: amx_unset_piano^n^n\
			 WARNING: If you should become disconnected while in piano^n\
			 mode, your keys may be stuck in piano mode. If the unset^n\
			 command doesnt work, enter this in console: amx_piano_wtf^n\
			 and your binds will go back to original default for the keys^n\
			 that are used for piano. Those keys are:^n^n"
	add(la_motd,1299,temp)
	temp = "Change Note Keys: 1,2,3,4,5,6,7,8,9,0,-,=,backspace^n\
			 Change Octave Keys: F3,F4,F5,F6,F7^n\
			 Change instrument type: F8^n^n"
	add(la_motd,1299,temp)
	temp = "If you prefer not to use the premade binds and to make,^n\
			 your own binds, the direct console piano commands are:^n^n\
			 amx_pianonote <number from 1 to 13>^n\
			 amx_pianooctave <number from 1 to 5>^n\
			 amx_pianosound <number from 0 to 3>^n"
	add(la_motd,1299,temp)
	show_motd(id,la_motd,"Piano Help:")
	return PLUGIN_CONTINUE
}

public admin_piano_wtf(id){
	client_cmd(id,"bind 1 slot1;bind 2 slot2;bind 3 slot3;bind 4 slot4;bind 5 slot5;bind 6 slot6;bind 7 slot7;\
	bind 8 slot8; bind 9 slot9;bind 0 slot10;bind - sizedown;bind = sizeup;bind backspace ^" ^";bind f3 ^" ^";\
	bind f4 ^" ^";bind f5 snapshot;bind f6 ^" ^";bind f7 ^" ^";bind f8 ^" ^"")
	client_print(id,print_chat,"[AMXX] Piano deactivated. Keys returned to factory defaults.")	
	return PLUGIN_HANDLED
}

public admin_bindk(id){
	if(are_you_sure[id] == 0){
		are_you_sure[id] = 1
		new ays[2]
		ays[0] = id
		set_task(35.0,"reset_sure",0,ays,1)
		client_cmd(id,"echo ") 
		client_cmd(id,"echo ")
		client_cmd(id,"echo ")  
		client_cmd(id,"echo [AMXX] Welcome to Piano Mode:   WARNING:  PIANO MODE WILL CHANGE YOUR KEY BINDS")	
		client_cmd(id,"echo ") 
		client_cmd(id,"echo 13 Note Keys: 1,2,3,4,5,7,8,9,0,-,=,backspace") 
		client_cmd(id,"echo Change Octave: F3,F4,F5,F6,F7") 
		client_cmd(id,"echo Change instrument: F8") 
		client_cmd(id,"echo ") 
		client_cmd(id,"echo To get your old key binds back after playing piano: amx_unset_piano")
		client_cmd(id,"echo and that will re-execute your config.cfg to restore your keys. Should") 
		client_cmd(id,"echo you have trouble getting them back that way, try: amx_piano_wtf")
		client_cmd(id,"echo but only if the first way doesnt work. Proceed at your own risk.")
		client_cmd(id,"echo ") 
		client_cmd(id,"echo YOUR KEYS ARE NOT BOUND YET TO PIANO, to go ahead and bind your keys to")
		client_cmd(id,"echo piano, do amx_set_piano again in the next 30 seconds again. If you change")
		client_cmd(id,"echo your mind, don't issue the command again and your keys will be left alone")  
		client_cmd(id,"echo ") 
		return PLUGIN_HANDLED
	}     
	client_cmd(id,"bind 1 ^"amx_pianonote 1^";bind 2 ^"amx_pianonote 2^";bind 3 ^"amx_pianonote 3^";\
	bind 4 ^"amx_pianonote 4^";bind 5 ^"amx_pianonote 5^";bind 6 ^"amx_pianonote 6^";bind 7 ^"amx_pianonote 7^";\
	bind 8 ^"amx_pianonote 8^";bind 9 ^"amx_pianonote 9^";bind 0 ^"amx_pianonote 10^";bind - ^"amx_pianonote 11^";\
	bind = ^"amx_pianonote 12^";bind backspace ^"amx_pianonote 13^"")
	client_cmd(id,"bind f3 ^"amx_pianooctave 1^";bind f4 ^"amx_pianooctave 2^";bind f5 ^"amx_pianooctave 3^";\
	bind f6 ^"amx_pianooctave 4^";bind f7 ^"amx_pianooctave 5^";bind f8 ^"amx_pianosound^"")
	client_print(id,print_chat,"[AMXX] Piano Mode activated")	
	switch(broadcastmode[id]){
		case 0: client_print(id,print_chat,"[AMXX] Only you can hear yourself playing piano.  Help: say  /piano")
		case 1: client_print(id,print_chat, "[AMXX] Only the dead can hear you playing piano.  Help: say  /piano")
		case 2: client_print(id,print_chat, "[AMXX] Everyone can hear you playing piano.  Help: say  /piano")
	}
	return PLUGIN_HANDLED
}

public reset_sure(ays[]){
	are_you_sure[ays[0]] = 0
	return PLUGIN_CONTINUE
}	

public admin_unbindk(id){
	client_cmd(id,"exec config.cfg")
	client_print(id,print_chat,"[AMXX] Piano off. Keys returned to whats in config.cfg.  Bind problems still: amx_piano_wtf")	
	return PLUGIN_HANDLED
}

public admin_octave(id){
	new arg[10]
	read_argv(1,arg,9)
	octave[id] = str_to_num(arg)
	if(octave[id] < 1 || octave[id] > 5)
		octave[id] = 2 
	return PLUGIN_HANDLED
}

public admin_instr(id){
	instrument[id] += 1
	if(instrument[id] > 3)
		instrument[id] = 0
	return PLUGIN_HANDLED
}

public admin_piano(id){
	new Float:fl_pitch = transpose[instrument[id]] 
	new pitch
	new ccmd[32]
	new arg[10]
	read_argv(1,arg,9)
	new iarg = str_to_num(arg)
	if(iarg < 1 || iarg > 13)
		iarg = 1
	for(new i = 1;i<octave[id];i++)
		iarg += 12
	for(new i = 1;i<iarg;i++)
		fl_pitch = fl_pitch * 1.059464
	pitch = floatround(fl_pitch) / 4	
	format(ccmd,31,"spk ^"%s(p%d)^"",instrument_sound[instrument[id]],pitch)
	switch(broadcastmode[id]){
		case 0: client_cmd(id,ccmd)
		case 1: {
			if(is_user_alive(id) == 1)
				client_cmd(id,ccmd)
			new players[32],inum
			get_players(players,inum,"bc")
			for(new i = 0 ;i < inum; ++i)
				client_cmd(players[i],ccmd)			
		}
		case 2: client_cmd(0,ccmd)
	}
	return PLUGIN_HANDLED
}

