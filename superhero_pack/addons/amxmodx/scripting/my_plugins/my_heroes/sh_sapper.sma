

#include "../my_include/superheromod.inc"
#include "mines_inc/sh_sapper_get_set.inc"
#include "mines_inc/sh_mine_funcs.inc"


#define SAPPER_TASKID 12812

// GLOBAL VARIABLES
new gHasSapper[SH_MAXSLOTS+1]
new gNumMines[SH_MAXSLOTS+1]

new m_spriteTexture

new hud_sync
new gHeroLevel
new num_mines
new mine_cooldown
new disarmable

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Sapper", "1.0", "TastyMedula")
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("sapper_level", "8")
	register_cvar("sapper_mines", "8")
	register_cvar("sapper_disarmable", "1")
	register_cvar("sapper_mine_cooldown", "10")
	register_event("ResetHUD","newRound","b")
	hud_sync = CreateHudSyncObj()
	gHeroID=shCreateHero(gHeroName, "Sapper", "Get a P90 and plant mines", true, "sapper_level" )
	sapper_set_hero_id(gHeroID)
	register_event("DeathMsg","death","a")
	
	register_srvcmd("sapper_init", "sapper_init")
	shRegHeroInit(gHeroName, "sapper_init")
	
	register_srvcmd("sapper_kd", "sapper_kd")
	shRegKeyDown(gHeroName, "sapper_kd")
	register_srvcmd("sapper_ku", "sapper_ku")
	shRegKeyUp(gHeroName, "sapper_ku")
}

public plugin_natives(){

register_native("sapper_set_num_mines","_sapper_set_num_mines",0)
register_native("sapper_get_num_mines","_sapper_get_num_mines",0)

register_native("sapper_dec_num_mines","_sapper_dec_num_mines",0)



register_native("sapper_set_has_sapper","_sapper_set_has_sapper",0)
register_native("sapper_get_has_sapper","_sapper_get_has_sapper",0)
register_native("sapper_get_disarmable","_sapper_get_disarmable",0)

register_native("sapper_set_hero_id","_sapper_set_hero_id",0)
register_native("sapper_get_hero_id","_sapper_get_hero_id",0)
	

}
public _sapper_set_has_sapper(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set= get_param(2)
	gHasSapper[id]=value_to_set;
}
public _sapper_get_has_sapper(iPlugin,iParams){
	new id= get_param(1)
	return gHasSapper[id]
}
public _sapper_get_disarmable(iPlugin,iParams){
	
	return disarmable
}

public _sapper_get_hero_id(iPlugin,iParams){
	return gHeroID
}
public _sapper_set_hero_id(iPlugin,iParams){
	gHeroID=get_param(1)
}

public _sapper_set_num_mines(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumMines[id]=value_to_set;
}
public _sapper_get_num_mines(iPlugin,iParams){


	new id= get_param(1)
	return gNumMines[id]

}

public _sapper_dec_num_mines(iPlugin,iParams){


	new id= get_param(1)
	gNumMines[id]-= (gNumMines[id]>0)? 1:0

}

public sapper_init()
{
	
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	gHasSapper[id]=(hasPowers!=0)
	if(gHasSapper[id]){
		
		sapper_weapons(id);
		reset_sapper_user(id)
		
		set_task( 0.2, "sapper_loop", id+SAPPER_TASKID, "", 0, "b")
	}
	else{
		reset_sapper_user(id)
		remove_task(id+SAPPER_TASKID)
		sh_drop_weapon(id, CSW_P90, true)
	}
	
}
public reset_sapper_user(id){
	
	mine_uncharge_mine(id)
	mine_undisarm_mine(id)
	gNumMines[id]=num_mines
	
	
	
}

public status_hud(id){
	
	new hud_msg[1000];
	format(hud_msg,500,"[SH] %s:^nNumber of mines: %d^n",gHeroName,sapper_get_num_mines(id));
	
	set_hudmessage(255, 255, 255, 0.0, 0.2, 0, 0.0, 0.2)
	ShowSyncHudMsg(id, hud_sync, "%s", hud_msg)
	
	
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
}
sapper_weapons(id)
{
if ( sh_is_active() && is_user_alive(id) && gHasSapper[id] ) {
	sh_give_weapon(id, CSW_P90)
}
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
gHeroLevel=get_cvar_num("sapper_level");
num_mines=get_cvar_num("sapper_mines");
mine_cooldown=get_cvar_num("sapper_mines");
disarmable=get_cvar_num("sapper_disarmable");
}
//----------------------------------------------------------------------------------------------
public sapper_loop(id)
{
id -= SAPPER_TASKID

if ( !is_user_connected(id)||!is_user_alive(id)||!gHasSapper[id]){
	
	return PLUGIN_HANDLED
	
}
status_hud(id)
return PLUGIN_HANDLED
}
public sh_client_spawn(id)
{
if ( gHasSapper[id] ) {
	sapper_weapons(id)
	sh_end_cooldown(id+SH_COOLDOWN_TASKID)
}

}
public sapper_morph(id){


	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "Sapper ready.")

}
public sapper_unmorph(id){


	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "Mission failed.")

}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
if ( gHasSapper[id]&&is_user_alive(id) && shModActive() &&!hasRoundStarted() ) {
	
	reset_sapper_user(id)
	sapper_weapons(id)
	sapper_morph(id)
}
return PLUGIN_HANDLED

}

public sh_round_end(){

	clear_mines()

}
public plugin_precache()
{




}
public death()
{
new id = read_data(2)
if(gHasSapper[id]){

	sapper_unmorph(id)
	mine_uncharge_mine(id)
	mine_undisarm_mine(id)
}
}

//----------------------------------------------------------------------------------------------
public sapper_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!sapper_get_has_sapper(id)) {
		return PLUGIN_HANDLED
	}
	new mine_id
	if(!(mine_id=player_touching_mine(id))){
		if(gPlayerUltimateUsed[id]){
			
			sh_chat_message(id,gHeroID,"N spammes!!!!")
			playSoundDenySelect(id)
			return PLUGIN_HANDLED
		}
		if(!sapper_get_num_mines(id)){
				sh_chat_message(id,gHeroID,"Nao tens mais minas!!!!")
				playSoundDenySelect(id)
				return PLUGIN_HANDLED;
		
		}
		
		if(!mine_get_mine_armed(id)){
				mine_set_mine_armed(id,1)
				mine_charge_mine(id)
					
		}
	}
	else if(disarmable){
		if(!mine_get_mine_disarmer_on(id)){
			mine_set_mine_disarmer_on(id,1)
			mine_disarm_mine(id,mine_id)
		}
	
	}
	return PLUGIN_HANDLED
}

public player_touching_mine(id)
{
	
	if (id <= 0) return 0
	if (!is_user_connected(id)||!is_user_alive(id)||!sh_is_active()||!sapper_get_has_sapper(id)) return 0
	
	new entlist[MAX_ENTITIES+1];
	new num_found = find_sphere_class(id,MINE_CLASSNAME, 50.0 ,entlist, MAX_ENTITIES);
	
	if(!num_found){
	
		return 0
	}
	
	for(new i=0;i<num_found;i++){
	
		new attacker = entity_get_edict(entlist[i], EV_ENT_owner);
		new terror_name[128];
		get_user_name(attacker,terror_name,127);
		sh_chat_message(id,sapper_get_hero_id(),"Touching a mine from %s!",(attacker==id)?"You":terror_name);
		return entlist[i];
	
	}
	return 0
}
//----------------------------------------------------------------------------------------------
public sapper_ku()
{
	new temp[6]

	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!sapper_get_has_sapper(id)||!(mine_get_mine_disarmer_on(id)||mine_get_mine_armed(id))) {
		return PLUGIN_HANDLED
	}
	if(mine_get_mine_disarming(id)&&mine_get_mine_charging(id)){
	
			sh_chat_message(id,sapper_get_hero_id(),"Mine not disarmed. Action interrupted");
			mine_uncharge_mine(id)
			mine_undisarm_mine(id)
			return PLUGIN_HANDLED
	
	
	
	}
	else if(mine_get_mine_disarming(id)){
			sh_chat_message(id,sapper_get_hero_id(),"Mine not disarmed. Action interrupted");
			mine_undisarm_mine(id)
			return PLUGIN_HANDLED
	}
	else if(mine_get_mine_charging(id)){
			sh_chat_message(id,sapper_get_hero_id(),"Mine not charged. Not planting...");
			mine_uncharge_mine(id)
			return PLUGIN_HANDLED
			
	}
	ultimateTimer(id, float(mine_cooldown))
	mine_uncharge_mine(id)
	mine_undisarm_mine(id)
			
		
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------