/**********************
amx_advanced_hp_ap.sma v0.2 by MagicShot ...*...

***********
*Change.Log
***********
Verson: 0.2
Fixed: Problem with only being able to add to players health. Now able to add or subtract from players current health.
Added:
amx_armor <authid, nick, @team or #userid> "armor" - Add or subtract amout of armor you want..
amx_maxarmor <- Set Max Armor Allowed
amx_armorround <- 1 to Enable. If Max armor is greater than 0 & players amrmor is grater than 0 @ end of round player will respawn with at amount of armor
amx_start_armor <- Set the amount of armor you want players to start with..

Verson 0.11
Fixed amx_start_health cvar bug
Added cvar: amx_start_health

Verson 0.1
Usage: amx_health <authid, nick, @team or #userid> "health" - Add or Subtract Health From Player.
Cvars:
amx_maxhealth <- Set Max Health Allowed
amx_healthround <- 1 to Enable. If Max health is over 100 & players health is over 100 player will get to keep added health into next round
amx_start_health <- Health You want a player to start with...
**********************/
#include <amxmodx>
#include <amxmisc>
#include <fun> 

new endhealth[32]
new endarmor[32]

public plugin_init() {
	register_plugin("Amx HP","0.1","MagicShot")
	register_clcmd("amx_health","set_health",ADMIN_LEVEL_A,"amx_armor:  Changes a Players Health")
	register_event("ResetHUD", "start_health", "be")
	register_event("SendAudio","round_end","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")
	register_cvar("amx_maxhealth","100")
	register_cvar("amx_healthround","0")
	register_cvar("amx_start_health","100")
	register_clcmd("amx_armor","set_armor",ADMIN_LEVEL_A,"amx_armor:  Changes a Players Armor")
	register_event("ResetHUD", "start_armor", "be")
	register_cvar("amx_maxarmor","100")
	register_cvar("amx_start_armor","0")
	register_cvar("amx_armorround","0")
	register_cvar("amx_start_health","100")
	return PLUGIN_CONTINUE
}

public start_health(id) {
	if (get_cvar_num("amx_maxhealth") == 100) {
		return PLUGIN_HANDLED
	}
	new playerlist1[32], inum2
	get_players(playerlist1,inum2,"abcfhkl","")
	if (get_cvar_num("amx_healthround") == 1) {
		for(new d=0; d<=32; ++d) {
			if (endhealth[d] > 100)
				set_user_health(playerlist1[d],endhealth[d])
		}
	}else {
		set_user_health(id,get_cvar_num("amx_start_health"))
	}
	return PLUGIN_CONTINUE
}

public round_end(id) {
	{
	new playerlist[32], inum1
	get_players(playerlist,inum1,"abcfhkl","")
	for(new c=0;c<=32;++c) {
		endhealth[c] = get_user_health(playerlist[c])
		endarmor[c] = get_user_health(playerlist[c])
	}
}
}

public set_health(id,level,cid) {
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED
	new who[32], hp[5], admin[32]
	read_argv(1,who,31)
	read_argv(2,hp,4)
	get_user_name(id,admin,31)
	new sethp = str_to_num(hp)
	new maxhealth
	maxhealth = get_cvar_num("amx_maxhealth")

	if (equal(who[0],"@")) {
		new players[32], inum
		get_players(players,inum,"ae",who[1])
		if (inum == 0) {
			console_print(id,"No Players on that Team")
			return PLUGIN_HANDLED
		}
		for(new a=0;a<=inum;++a) {
			new health = (get_user_health(players[a]) + sethp)
			if (health >= maxhealth) {
				set_user_health(players[a], maxhealth)
			}else {
				set_user_health(players[a], health)
			}
		}
		console_print(id,"Everyone HP has been set for Team: %s",who)
	}else {
		new player = cmd_target(id,who,3)
		if (!player) return PLUGIN_HANDLED
		new health = get_user_health(player) + sethp
		if (health >= maxhealth) {
			set_user_health(player,maxhealth)
		}else {
			set_user_health(player,health)						
		}
		new pname[32]
		get_user_name(player,pname,31)
		console_print(id,"Changed %s Health to &s",pname,health)
	}
	return PLUGIN_HANDLED
}



public start_armor(id) {
	if (get_cvar_num("amx_maxarmor") == 0) {
		return PLUGIN_HANDLED
	}
	new armorplist[32], inumap
	get_players(armorplist,inumap,"abcfhkl","")
	if (get_cvar_num("amx_armorround") == 1) {
		for(new f=0; f<=inumap; ++f) {
			if (endarmor[f] > 100)
				set_user_armor(armorplist[f],endarmor[f])
		}
	}else {
		set_user_armor(id,get_cvar_num("amx_start_armor"))
	}
	return PLUGIN_CONTINUE
}

public set_armor(id,level,cid) {
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED
	new apwho[32], ap[5], apadmin[32], maxarmor
	read_argv(1,apwho,31)
	read_argv(2,ap,4)
	get_user_name(id,apadmin,31)
	new setap = str_to_num(ap)
	maxarmor = get_cvar_num("amx_maxarmor")

	if (equal(apwho[0],"@")) {
		new applayers[32], apinum
		get_players(applayers,apinum,"ae",apwho[1])
		if (apinum == 0) {
			console_print(id,"No Players on that Team")
			return PLUGIN_HANDLED
		}
		for(new g=0;g<=apinum;++g) {
			new armor = (get_user_armor(applayers[g]) + setap)
			if (armor >= maxarmor) {
				set_user_health(applayers[g], maxarmor)
			}else {
				set_user_health(applayers[g], armor)
			}
		}
		console_print(id,"Everyone HP has been set for Team: %s",apwho)
	}else {
		new applayer = cmd_target(id,apwho,3)
		if (!applayer) return PLUGIN_HANDLED
		new armor = get_user_armor(applayer) + setap
		if (armor >= maxarmor) {
			set_user_armor(applayer,maxarmor)
		}else {
			set_user_armor(applayer,armor)						
		}
		new apname[32]
		get_user_name(applayer,apname,31)
		console_print(id,"Changed %s Armor to &s",apname,armor)
	}
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
