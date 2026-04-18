
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "shield_inc/sh_jaqueo_get_set.inc"
#include "shield_inc/sh_jaqueo_shield.inc"


#define PLUGIN "Superhero jaqueo ratty funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_jaqueo_shield_cooldown[SH_MAXSLOTS+1];
new g_jaqueo_shield_loaded[SH_MAXSLOTS+1];
new g_jaqueo_shield_deployed[SH_MAXSLOTS+1];
new g_jaqueo_shield[SH_MAXSLOTS+1];
new g_normal_ptr[SH_MAXSLOTS+1]

#define MAX_BURST_FIRE_TIME 0.2
#define GUNS_BIT_SUM ((1<<CSW_P228) | (1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_ELITE) | (1<<CSW_FIVESEVEN) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_GALIL) | (1<<CSW_FAMAS) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_P90))
#define BURSTGUNS_BIT_SUM ((1<<CSW_FAMAS) | (1<<CSW_GLOCK18))
new Float:shield_cooldown
new Float:shield_radius
new Float:shield_max_hp



stock	JAQUEO_LOAD_TASKID,
		JAQUEO_CHARGE_TASKID,
		JAQUEO_DEPLOY_TASKID

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	arrayset(g_jaqueo_shield_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield_deployed,0,SH_MAXSLOTS+1)
	arrayset(g_normal_ptr,0,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield,0,SH_MAXSLOTS+1)

	register_think(JAQUEO_SHIELD_CLASSNAME, "shield_think")
	RegisterHam(Ham_TakeDamage,"player","Shield_Damage",_,true)
	JAQUEO_LOAD_TASKID=allocate_typed_task_id(player_task)
	JAQUEO_DEPLOY_TASKID=allocate_typed_task_id(player_task)
	JAQUEO_CHARGE_TASKID=allocate_typed_task_id(player_task)
	
	// Add your code here...
}
public Shield_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!shModActive() || !is_user_connected(this)||!is_user_alive(this)||!sh_user_has_hero(this,jaqueo_get_hero_id())) return HAM_IGNORED
	
	if(!g_jaqueo_shield_deployed[this]) return HAM_IGNORED

	damage=0.0;
	return HAM_SUPERCEDE



}
public plugin_natives(){

	register_native("reset_jaqueo_user","_reset_jaqueo_user",0);
	register_native("shield_get_user_shield_cooldown","_shield_get_user_shield_cooldown",0)
	register_native("shield_uncharge_user","_shield_uncharge_user",0)
	register_native("shield_charge_user","_shield_charge_user",0)
	register_native("shield_loaded","_shield_loaded",0)
	register_native("shield_deployed","_shield_deployed",0)
	register_native("shield_destroy","_shield_destroy",0)

	

}

public _shield_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)


}
public _shield_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_loaded[id]


}
public _shield_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	g_jaqueo_shield_loaded[id]=true;
	g_jaqueo_shield_cooldown[id]=0;
	g_jaqueo_shield_deployed[id]=false;
	if(is_valid_ent(g_jaqueo_shield[id])){
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
}
public _shield_deployed(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_deployed[id]


}
public _shield_get_user_shield_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_cooldown[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	shield_cooldown=get_cvar_float("jaqueo_shield_cooldown");
	shield_radius=get_cvar_float("jaqueo_shield_radius");
	shield_max_hp=get_cvar_float("jaqueo_shield_max_hp")
}

public _reset_jaqueo_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_jaqueo_shield_loaded[id]=true;
	g_jaqueo_shield_cooldown[id]=0;
	g_jaqueo_shield_deployed[id]=false;
	if(is_valid_ent(g_jaqueo_shield[id])){
		emit_sound(g_jaqueo_shield[id], CHAN_ITEM, shield_hum, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
	
	
}

public shield_deploy_task(parm[],id){
	
	id-=JAQUEO_DEPLOY_TASKID
	
	new attacker=parm[0];
	new shield_id=parm[1];
	if(!is_valid_ent(shield_id)){
		
		return;
	}
	set_pev(shield_id, pev_iuser1, 1)
	set_pev(shield_id, pev_takedamage, DAMAGE_YES)
	set_pev(shield_id, pev_solid, SOLID_BBOX)
	set_pev(shield_id,pev_owner,pev(shield_id,pev_euser1))
	new alpha=190
	set_pev(shield_id,pev_renderamt,float(alpha))
	sh_chat_message(attacker,jaqueo_get_hero_id(),"Shield armed!");
	emit_sound(shield_id, CHAN_ITEM,shield_deploy, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_pev(shield_id, pev_nextthink, get_gametime() + JAQUEO_THINK_PERIOD)
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheModel,  shield_mdl)
	engfunc(EngFunc_PrecacheSound,  shield_deploy)
	engfunc(EngFunc_PrecacheSound,  shield_hum)
	engfunc(EngFunc_PrecacheSound,  shield_destroyed)
	
	
}

//----------------------------------------------------------------------------------------------
public shield_think(ent)
{
	if ( pev_valid(ent)!=2 ) return FMRES_IGNORED
	
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_euser1)
	new Float:shield_health=float(pev(ent,pev_health))
	
	if ( (shield_health<1000.0)) {
		if(g_jaqueo_shield[owner]){
			emit_sound(ent, CHAN_ITEM,shield_destroyed, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			sh_chat_message(owner,jaqueo_get_hero_id(),"Shield died!")
			uncharge_user(owner)
		}
		return FMRES_IGNORED
	}
	if(g_jaqueo_shield_deployed[owner]){
		
		new Float:vOrigin[3]
		new Float:vAngles[3]
		new Float:velocity[3]
		entity_get_vector(owner, EV_VEC_origin, vOrigin)
		entity_get_vector(owner, EV_VEC_v_angle, vAngles)
		new notFloat_vOrigin[3]
		notFloat_vOrigin[0] = floatround(vOrigin[0])
		notFloat_vOrigin[1] = floatround(vOrigin[1])
		notFloat_vOrigin[2] = floatround(vOrigin[2])
		
		entity_set_origin(g_jaqueo_shield[owner], vOrigin)
		entity_set_vector(g_jaqueo_shield[owner], EV_VEC_angles, vAngles)
		entity_get_vector(owner, EV_VEC_velocity, velocity)
		entity_set_vector(g_jaqueo_shield[owner], EV_VEC_velocity,  velocity)
	
	
		
		if(!is_user_bot(owner)){
			client_print(owner,print_center,"jaqueo shield hp: %0.2f",float(pev(ent,pev_health))-1000.0)
		}
	}
	set_pev(ent, pev_nextthink, gametime + (JAQUEO_THINK_PERIOD))
	return FMRES_IGNORED
}
public _shield_charge_user(iPlugin, iParams){
	
	new id= get_param(1)

	if(!client_hittable(id)) return

	if(!sh_user_has_hero(id,jaqueo_get_hero_id())) return

	if(!g_jaqueo_shield_loaded[id]){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,jaqueo_get_hero_id(),"Shield not loaded")
		}
		return
	}
	new Float: Origin[3]
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	g_jaqueo_shield_loaded[id]=0
	
	new material[128]
	new health[128]	
	g_jaqueo_shield[id] = create_entity( "func_breakable" );
	new NewEnt=g_jaqueo_shield[id]
	if(!is_valid_ent(g_jaqueo_shield[id])||(g_jaqueo_shield[id] == 0)) {
		
		return
	}
	
	set_pev(NewEnt, pev_classname, JAQUEO_SHIELD_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, shield_mdl)
	float_to_str(1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	new Float:fl_vecminsx[3]
	new Float:fl_vecmaxsx[3]
	for (new i=0;i<3;i++){
		fl_vecminsx[i]=-shield_radius
		fl_vecmaxsx[i]=shield_radius
	
	}
	entity_set_vector(g_jaqueo_shield[id], EV_VEC_mins,fl_vecminsx)
	entity_set_vector(g_jaqueo_shield[id], EV_VEC_maxs,fl_vecmaxsx)
	
	set_pev(NewEnt, pev_health, 0)
	set_pev(NewEnt, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	set_pev(NewEnt, pev_solid, SOLID_NOT)
	set_pev(NewEnt, pev_body, 3)
	set_pev(NewEnt, pev_sequence, 7)	// 7 = TRIPMINE_WORLD
	set_pev(NewEnt, pev_takedamage, DAMAGE_NO)
	set_pev(NewEnt,pev_rendermode,kRenderTransAlpha)
	set_pev(NewEnt,pev_renderfx,kRenderFxGlowShell)
	new alpha=100
	set_pev(NewEnt,pev_renderamt,float(alpha))
	set_pev(g_jaqueo_shield[id],pev_euser1,id)

	entity_set_origin(g_jaqueo_shield[id], Origin)

	new parm[2]
	parm[0]=id
	parm[1]=g_jaqueo_shield[id]
	set_task(shield_cooldown,"load_shield",id+JAQUEO_LOAD_TASKID,"", 0,  "a",1)
	remove_task(id+JAQUEO_CHARGE_TASKID)
	set_task(JAQUEO_CHARGE_PERIOD,"charge_task",id+JAQUEO_CHARGE_TASKID,parm, 2,  "b")
	return
	
	
	
}
uncharge_user(id){
	remove_task(id+JAQUEO_CHARGE_TASKID)
	g_jaqueo_shield_deployed[id]=0
	if(is_valid_ent(g_jaqueo_shield[id])){
		emit_sound(g_jaqueo_shield[id], CHAN_ITEM, shield_hum, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
	g_jaqueo_shield_loaded[id]=1
	return 0
	
	
	
}
public load_shield(id){
	id-=JAQUEO_LOAD_TASKID
	
	g_jaqueo_shield_loaded[id]=1;	
	
	if(!is_user_bot(id)){
		sh_chat_message(id,jaqueo_get_hero_id(),"Shield loaded");
	}
	
}
public charge_task(parm[],id){
	id-=JAQUEO_CHARGE_TASKID
	if(!client_hittable(id)){
		
		uncharge_user(id)
		return
	}
	if(!sh_user_has_hero(id,jaqueo_get_hero_id())){
		

		uncharge_user(id)
		return
	}
	
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return
	
	}
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	if(!is_valid_ent(g_jaqueo_shield[id])||(g_jaqueo_shield[id] == 0)) {
		return
	}
	entity_set_origin(g_jaqueo_shield[id], vOrigin)
	entity_set_vector(g_jaqueo_shield[id], EV_VEC_angles, vAngles)
	entity_get_vector(id, EV_VEC_velocity, velocity)
	entity_set_vector(g_jaqueo_shield[id], EV_VEC_velocity,  velocity)
	
	
	
	if(!is_user_bot(id)){
		new hud_msg[128];
		set_pev(g_jaqueo_shield[id],pev_health,floatmin(shield_max_hp,floatadd(float(pev(g_jaqueo_shield[id],pev_health)),floatmul(JAQUEO_CHARGE_PERIOD,JAQUEO_CHARGE_RATE))))
		formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",float(pev(g_jaqueo_shield[id],pev_health)));
		client_print(id,print_center,"%s",hud_msg)
	}
	new parm[2]
	parm[0]=id
	parm[1]=g_jaqueo_shield[id]
	
	emit_sound(g_jaqueo_shield[id], CHAN_ITEM,shield_hum, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if((pev(g_jaqueo_shield[id],pev_health))>=floatround(shield_max_hp)){
	
		g_jaqueo_shield_deployed[id]=1;
		set_pev(g_jaqueo_shield[id],pev_health,1000.0+pev(g_jaqueo_shield[id],pev_health))
		shield_deploy_task(parm,id+JAQUEO_DEPLOY_TASKID)
		remove_task(id+JAQUEO_CHARGE_TASKID)
	}
	
	
	
	
	
	
}