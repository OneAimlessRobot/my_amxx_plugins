
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "mines_inc/sh_sapper_get_set.inc"
#include "mines_inc/sh_mine_funcs.inc"

#define PLUGIN "Superhero sapper mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new mine_loaded[SH_MAXSLOTS+1]

new mine_armed[SH_MAXSLOTS+1]
new disarmer_on[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]
new Float:curr_disarm_charge[SH_MAXSLOTS+1]

new Float:min_charge_time

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	g_msgFade = get_user_msgid("ScreenFade");
	arrayset(mine_loaded,true,SH_MAXSLOTS+1)
	arrayset(mine_armed,0,SH_MAXSLOTS+1)
	arrayset(disarmer_on,0,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	arrayset(curr_disarm_charge,0.0,SH_MAXSLOTS+1)
	register_cvar("sapper_mine_min_charge_time", "1.0")
}

public plugin_natives(){
	
	
	register_native( "clear_mines","_clear_mines",0)
	register_native( "mine_get_mine_loaded","_mine_get_mine_loaded",0)
	register_native( "mine_get_mine_armed","_mine_get_mine_armed",0)
	register_native( "mine_set_mine_armed","_mine_set_mine_armed",0)
	register_native( "mine_uncharge_mine","_mine_uncharge_mine",0)
	register_native( "mine_charge_mine","_mine_charge_mine",0)
	register_native( "mine_disarm_mine","_mine_disarm_mine",0)
	register_native( "mine_undisarm_mine","_mine_undisarm_mine",0)
	register_native( "mine_get_mine_charging","_mine_get_mine_charging",0)
	register_native( "mine_get_mine_disarming","_mine_get_mine_disarming",0)
	register_native( "mine_get_mine_disarmer_on","_mine_get_mine_disarmer_on",0)
	register_native( "mine_set_mine_disarmer_on","_mine_set_mine_disarmer_on",0)
	register_native( "plant_mine","_plant_mine",0)
	
	
	
}
public _mine_get_mine_charging(iPlugins,iParams){

	new id=get_param(1);
	return curr_charge[id]<min_charge_time;


}
public _mine_get_mine_disarming(iPlugins,iParams){

	new id=get_param(1);
	return curr_disarm_charge[id]<min_charge_time;


}
public _mine_get_mine_armed(iPlugins,iParams){

	new id=get_param(1);
	return mine_armed[id]


}
public _mine_set_mine_armed(iPlugins,iParams){

	new id=get_param(1);
	new value_to_set=get_param(2)
	mine_armed[id]=value_to_set


}
public _mine_get_mine_disarmer_on(iPlugins,iParams){

	new id=get_param(1);
	return disarmer_on[id]


}
public _mine_set_mine_disarmer_on(iPlugins,iParams){

	new id=get_param(1);
	new value_to_set=get_param(2)
	disarmer_on[id]=value_to_set


}
public _mine_get_mine_loaded(iPlugins,iParams){

	new id=get_param(1);
	return mine_loaded[id]


}
public _plant_mine(iPlugins,iParams)
{
	new id= get_param(1)
	
	if ( !is_user_alive(id)||!client_hittable(id,sapper_get_has_sapper(id))) return FMRES_IGNORED;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, MINE_CLASSNAME);
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, MINE_WORLD_MDL);
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	

	glow(ent,1,1,1,120,1)
	drop_to_floor(ent);
	sapper_dec_num_mines(id);
	new parm[2];
	parm[0]=id;
	parm[1]=ent
	sh_chat_message(id,sapper_get_hero_id(),"You have %d mines left",sapper_get_num_mines(id));
	set_task(MINE_ARMING_TIME,"mine_arm_task",ent+MINE_ARMING_TASKID, parm, 2, "a",1)
	
	return PLUGIN_CONTINUE;
}
public mine_arm_task(parm[],mine_taskid){
	
	
	new attacker=parm[0];
	new mine_id=parm[1];
	if(!is_valid_ent(mine_id)){
	
		return;
	}
	set_task(MINE_WAIT_PERIOD,"mine_wait_task",mine_id+MINE_WAIT_TASKID, parm, 2, "b")
	if(!is_user_bot(attacker)){
		sh_chat_message(attacker,sapper_get_hero_id(),"The mine is armed!");
	}
}
public mine_wait_task(parm[],mine_taskid){
	
	
	new attacker=parm[0];
	new mine_id=parm[1];
	if(!is_valid_ent(mine_id)){
	
		return;
	}
	
	new entlist[33];
	new numfound = find_sphere_class(mine_id,"player", DETECT_RADIUS ,entlist, 32);
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
			
		
		if (!is_user_alive(pid) ||!client_hittable(pid)){
			continue;
		}
		if((get_user_team(attacker) == get_user_team(pid))){
			continue;
		}
		blow_mine_up(mine_id,pid);
	}


}

public blow_mine_up(ent, id)
{
		if(pev_valid(ent)!=2){
		
			return;
		}
		new attacker = entity_get_edict(ent, EV_ENT_owner);
		if(!client_hittable(attacker,sapper_get_has_sapper(attacker))){
		
			return
		}
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
		
		explosion(sapper_get_hero_id(),ent,EXPLODE_RADIUS,MINE_DAMAGE)
		
		new parm[2];
		parm[0]=id;
		parm[1]=ent;
		remove_mine(parm)
}
public remove_mine(parm[]){

if(!is_valid_ent(parm[1])) return
remove_task(parm[1]+MINE_WAIT_TASKID);
remove_task(parm[1]+MINE_ARMING_TASKID);
mine_loaded[parm[0]]=true
remove_entity(parm[1])


}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	
	min_charge_time=get_cvar_float("sapper_mine_min_charge_time")
}


public disarm_task(param[],id){
	id-=MINE_DISARM_TASKID
	curr_disarm_charge[id]=floatadd(curr_disarm_charge[id],MINE_DISARM_PERIOD)
	if(!is_user_bot(id)){
		new hud_msg[128];
		format(hud_msg,127,"[SH]: DISARMING MINE: %0.2f^n",
		100.0*(curr_disarm_charge[id]/min_charge_time)
		);
		client_print(id,print_center,"%s",hud_msg)
	}
	sapper_update_disarming(id)
	if(!mine_get_mine_disarming(id)){
		new parm[2];
		parm[1]=param[0];
		parm[0]=id;
		sapper_set_num_mines(id,sapper_get_num_mines(id)+1)
		remove_mine(parm);
		
		if(!is_user_bot(id)){
			client_print(id,print_center,"You retrieved and disarmed 1 mine! %d mines left now!",sapper_get_num_mines(id));
		}
	}
	
	
	
	
	
	
}
public _mine_undisarm_mine(iPlugin,iParams){
	new id=get_param(1)
	undisarm_user(id)
	
	
}
public undisarm_task(id){
	id-=UNMINE_DISARM_TASKID
	remove_task(id+MINE_DISARM_TASKID)
	disarmer_on[id]=0
	return 0
	
	
	
}

undisarm_user(id){
	remove_task(id+UNMINE_DISARM_TASKID)
	remove_task(id+MINE_DISARM_TASKID)
	disarmer_on[id]=0
	return 0
	
	
}
public _mine_disarm_mine(iPlugins,iParams){

	new id=get_param(1);
	new mine_id=get_param(2)
	new param[1];
	param[0]=mine_id
	curr_disarm_charge[id]=0.0
	set_task(MINE_DISARM_PERIOD,"disarm_task",id+MINE_DISARM_TASKID,param, 1,  "a",MINE_DISARM_TIMES)
	set_task(floatmul(MINE_DISARM_PERIOD,float(MINE_DISARM_TIMES))+1.0,"undisarm_task",id+UNMINE_DISARM_TASKID,"", 0,  "a",1)
	return 0
	
	
	
	
}
public _mine_charge_mine(iPlugins,iParams){

	new id=get_param(1);
	curr_charge[id]=0.0
	set_task(MINE_CHARGE_PERIOD,"charge_task",id+MINE_CHARGE_TASKID,"", 0,  "a",MINE_CHARGE_TIMES)
	set_task(floatmul(MINE_CHARGE_PERIOD,float(MINE_CHARGE_TIMES))+1.0,"uncharge_task",id+UNMINE_CHARGE_TASKID,"", 0,  "a",1)
	return 0
	
	
	
	
}

sapper_update_planting(id){
new butnprs

butnprs = Entvars_Get_Int(id, EV_INT_button)

if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD||butnprs&IN_USE){

	
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_uncharge_mine(id)
}
if (butnprs&IN_JUMP){


	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_uncharge_mine(id)

}
if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_uncharge_mine(id)


}
if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_uncharge_mine(id)
}
if(!(butnprs&IN_DUCK)){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You werent ducked while planting, so your action was canceled");
	}
	mine_uncharge_mine(id)
}



}
sapper_update_disarming(id){
new butnprs

butnprs = Entvars_Get_Int(id, EV_INT_button)

if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD){

	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_undisarm_mine(id)
}
if (butnprs&IN_JUMP){


	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_undisarm_mine(id)

}
if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_undisarm_mine(id)


}
if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You moved while planting, so your action was canceled");
	}
	mine_undisarm_mine(id)
}
if(!(butnprs&IN_DUCK)){
	if(!is_user_bot(id)){
		sh_chat_message(id,sapper_get_hero_id(),"You werent ducked while planting, so your action was canceled");
	}
	mine_undisarm_mine(id)
}



}
public charge_task(id){
	id-=MINE_CHARGE_TASKID
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return
	
	}
	curr_charge[id]=floatadd(curr_charge[id],MINE_CHARGE_PERIOD)
	if(!is_user_bot(id)){
		new hud_msg[128];
		format(hud_msg,127,"[SH]: Curr mine charge: %0.2f^n",
		100.0*(curr_charge[id]/min_charge_time)
		);
		client_print(id,print_center,"%s",hud_msg)
	}
	sapper_update_planting(id)
	if(!mine_get_mine_charging(id)){
		plant_mine(id)
		if(!is_user_bot(id)){
			client_print(id,print_center,"You have %d mines left",
			sapper_get_num_mines(id));
		}
	}
	
	
	
	
	
	
}
public _mine_uncharge_mine(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	
	
}
public uncharge_task(id){
	id-=UNMINE_CHARGE_TASKID
	remove_task(id+MINE_CHARGE_TASKID)
	mine_armed[id]=0
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNMINE_CHARGE_TASKID)
	remove_task(id+MINE_CHARGE_TASKID)
	mine_armed[id]=0
	return 0
	
	
}
public _clear_mines(iPlugin,iParams){

new grenada = find_ent_by_class(-1, MINE_CLASSNAME)
while(grenada) {
	remove_task(grenada+MINE_WAIT_TASKID);
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, MINE_CLASSNAME)
}
}
public plugin_precache()
{
precache_explosion_fx()
precache_model( MINE_WORLD_MDL );

}
