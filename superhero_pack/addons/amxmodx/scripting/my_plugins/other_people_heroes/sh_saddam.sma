/* Saddam Hussein - CVARS - copy and paste to shconfig.cfg

// Saddam Hussein
saddam_level 1 // Level that this hero is available def=1
saddam_cooldown 30 // Time to wait until you can use the ultimate again def=30
saddam_delay 1 // Time delay before you go to your hole def=1
saddam_wait 5 // Time while in your hole def=5

*/

#include <amxmod>
#include <Vexd_Utilities>
#include <superheromod>


// VARIABLES
new gHeroName[]="Saddam Hussein" 
new bool:gHassaddamPower[SH_MAXSLOTS+1]
new bool:gHasSpawnPoint[SH_MAXSLOTS+1]
new userSpawn[SH_MAXSLOTS+1][3]
new userHide[SH_MAXSLOTS+1][3]

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Saddam Hussein","1.0","SolidSteelSnake/GenKernel")
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("saddam_level", "1" )
	register_cvar("saddam_cooldown", "30" )
	register_cvar("saddam_delay", "1.0")
	register_cvar("saddam_wait", "5.0")
	
	shCreateHero(gHeroName, "Escape from enemies", "Press bind key to hide in a hole for a while", true, "saddam_level" )
	
	// INIT
	register_srvcmd("saddam_init", "saddam_init")
	shRegHeroInit(gHeroName, "saddam_init")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// KEY DOWN
	register_srvcmd("saddam_kd", "saddam_kd")
	shRegKeyDown(gHeroName, "saddam_kd")
	
	// NEW ROUND
	register_event("ResetHUD","newRound","b")
	
}
//----------------------------------------------------------------------------------------------
public saddam_init()
{
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers=str_to_num(temp)
	gHassaddamPower[id]=(hasPowers!=0)
	
	gPlayerUltimateUsed[id] = false
	gHasSpawnPoint[id]=false
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound("shmod/saddamtest.wav") 
}
//----------------------------------------------------------------------------------------------
public newRound(id) 
{
	
	if ( gHassaddamPower[id] && is_user_alive(id) ) 
	{
		
		new origin[3]
		
		get_user_origin(id, origin, 0)
		
		userSpawn[id][0]=origin[0]
		userSpawn[id][1]=origin[1]
		userSpawn[id][2]=origin[2]
		
		gPlayerUltimateUsed[id] = false
		gHasSpawnPoint[id]=true
	}
}
//----------------------------------------------------------------------------------------------
public saddam_kd() 
{
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	new origin[3] 
	get_user_origin(id, origin, 0) 
	
	userHide[id][0]=origin[0]
	userHide[id][1]=origin[1]
	userHide[id][2]=origin[2]
	
	if ( !is_user_alive(id) || !gHassaddamPower[id] || !hasRoundStarted() ) return
	
	if ( gPlayerUltimateUsed[id] ) 
	{
		playSoundDenySelect(id)
		return
	}
	
	if ( !gHasSpawnPoint[id] ) 
	{
		client_print(id,print_chat,"[SH](Saddam Hussein) Saddam has no hole dug yet, wait til next round..") 
		return
	}
	
	new sndplayers[SH_MAXSLOTS], sndnum
	get_players(sndplayers, sndnum, "ac")
	for (new x = 0; x < sndnum; x++) {
		emit_sound(sndplayers[x], CHAN_AUTO, "shmod/saddamtest.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	
	set_task( get_cvar_float("saddam_delay") , "saddam_hide", id+520 )
	
	ultimateTimer( id, get_cvar_float("saddam_cooldown") )
}
//----------------------------------------------------------------------------------------------
public saddam_hide(id) 
{	
	id-=520   
	
	new spawnpoint[3]
	spawnpoint[0] = userSpawn[id][0]
	spawnpoint[1] = userSpawn[id][1]
	spawnpoint[2] = userSpawn[id][2] - 100
	
	set_user_origin(id, spawnpoint)
	
	set_task( get_cvar_float("saddam_wait"), "saddam_unhide", id+521)
}
//----------------------------------------------------------------------------------------------
public saddam_unhide(id) 
{	
	id-=521
	
	
	new hidepoint[3]
	hidepoint[0] = userHide[id][0]
	hidepoint[1] = userHide[id][1]
	hidepoint[2] = userHide[id][2] + 25 //add some hight so you dont get stuck
	
	set_user_origin(id, hidepoint)
}
//---------------------------------------------------------------------------------------------- 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
