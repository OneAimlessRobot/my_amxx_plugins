
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "jetplane_inc/sh_jetplane_funcs.inc"
#include "jetplane_inc/sh_jetplane_engine_funcs.inc"
#include "jetplane_inc/sh_jetplane_bomb_funcs.inc"
#include "jetplane_inc/sh_jetplane_rocket_funcs.inc"
#include "jetplane_inc/sh_jetplane_radio_funcs.inc"
#include "jetplane_inc/sh_jetplane_mg_funcs.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero yandere jetty funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum



new g_jetplane_cooldown[SH_MAXSLOTS+1];
new g_jetplane_loaded[SH_MAXSLOTS+1];
new g_jetplane_deployed[SH_MAXSLOTS+1];
new g_jetplane[SH_MAXSLOTS+1];
new camera[SH_MAXSLOTS+1]

new Float:jetplane_cooldown,
Float:jetplane_hp;
new hud_sync_charge
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("yandere_jetplane_hp", "5")
	register_cvar("yandere_jetplane_cooldown", "5")
	arrayset(g_jetplane_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_jetplane_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_jetplane_deployed,0,SH_MAXSLOTS+1)
	arrayset(g_jetplane,0,SH_MAXSLOTS+1)
	hud_sync_charge=CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink")
	register_forward(FM_Think, "jet_think")
	RegisterHam(Ham_TakeDamage,"player","jet_Damage")
	
	
	
}


public plugin_cfg(){

	loadCVARS();
}
public plugin_natives(){

	register_native("clear_jets","_clear_jets",0);
	register_native("reset_jet_user","_reset_jet_user",0);
	register_native("jet_get_user_jet_cooldown","_jet_get_user_jet_cooldown",0);
	register_native("jet_uncharge_user","_jet_uncharge_user",0);
	register_native("jet_charge_user","_jet_charge_user",0);
	register_native("jet_loaded","_jet_loaded",0);
	register_native("jet_deployed","_jet_deployed",0);
	register_native("jet_destroy","_jet_destroy",0);
	register_native("jet_get_user_jet","_jet_get_user_jet",0);

	

}
public loadCVARS(){
	jetplane_cooldown=get_cvar_float("yandere_jetplane_cooldown");
	jetplane_hp=get_cvar_float("yandere_jetplane_hp")
}
public plugin_precache(){


	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_model(JETPLANE_MODEL)
	precache_model(JETPLANE_CAMERA_MODEL)
	precache_explosion_fx()
	
	
}
public _jet_get_user_jet(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane[id]


}
public _jet_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_loaded[id]


}
public _jet_deployed(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_deployed[id]


}
public _jet_get_user_jet_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_cooldown[id]


}
public _jet_charge_user(iPlugin, iParams){
	
	new id= get_param(1)
	if(!g_jetplane_loaded[id]){
		
		sh_chat_message(id,yandere_get_hero_id(),"Shield not loaded")
		return
	}
	g_jetplane_loaded[id]=0
	
	new material[128]
	new health[128]	
	g_jetplane[id] = create_entity( "func_breakable" );
	new NewEnt=g_jetplane[id]
	if(!is_valid_ent(g_jetplane[id])||(g_jetplane[id] == 0)) {
		
		return
	}
	set_pev(NewEnt, pev_classname, JETPLANE_FUSELAGE_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, JETPLANE_MODEL)
	float_to_str(1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_mins,jetplane_min_dims)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_maxs,jetplane_max_dims)
	
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
	set_pev(g_jetplane[id],pev_owner,id)
	new parm[2]
	parm[0]=id
	parm[1]=g_jetplane[id]
	set_task(jetplane_cooldown,"load_jet",id+JET_LOAD_TASKID,"", 0,  "a",1)
	set_task(JET_CHARGE_PERIOD,"charge_task",id+JET_CHARGE_TASKID,parm, 2,  "b")
	return
	
	
	
}
public jet_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!shModActive() || !is_user_connected(this)||!is_user_alive(this)||!yandere_get_has_yandere(this)) return HAM_IGNORED
	
	if(!g_jetplane_deployed[this]) return HAM_IGNORED

	damage=0.0;
	return HAM_SUPERCEDE



}
public _jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)


}
uncharge_user(id){
	remove_task(id+JET_CHARGE_TASKID)
	g_jetplane_deployed[id]=0
	if(is_valid_ent(g_jetplane[id])){
		emit_sound(g_jetplane[id], CHAN_ITEM, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=0;
	}
	g_jetplane_loaded[id]=1
	return 0
	
	
	
}

public _reset_jet_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_jetplane_loaded[id]=true;
	g_jetplane_cooldown[id]=0;
	g_jetplane_deployed[id]=false;
	if(is_valid_ent(g_jetplane[id])){
		emit_sound(g_jetplane[id], CHAN_ITEM, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=0;
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
	
	
	
}

public jet_deploy_task(parm[],id){
	
	id-=JET_DEPLOY_TASKID
	
	new attacker=parm[0];
	new jetplane_id=parm[1];
	if(!is_valid_ent(jetplane_id)){
		
		return;
	}
	
	set_pev(jetplane_id, pev_takedamage, DAMAGE_YES)
	set_pev(jetplane_id, pev_movetype, MOVETYPE_BOUNCE) 
	set_pev(jetplane_id, pev_solid, SOLID_BBOX)
	if(get_user_gravity(attacker)>0.0001){
		set_user_gravity(attacker,0.0001)
	
	}
	new alpha=190
	set_pev(jetplane_id,pev_renderamt,float(alpha))
	set_pev(attacker, pev_takedamage, DAMAGE_NO)
	set_pev(attacker, pev_solid, SOLID_NOT)
	reset_jet_fuel(jetplane_id)
	reset_jet_bombs(jetplane_id)
	reset_jet_shells(jetplane_id)
	reset_jet_rockets(jetplane_id)
	reset_jet_scans(jetplane_id)
	sh_chat_message(attacker,yandere_get_hero_id(),"jet armed!");
	camera[id] = create_entity("info_target")
	new Float:origin[3]
	new Float:angles[3]
	pev(jetplane_id,pev_origin,origin)
	origin[2]+=jetplane_max_dims[2]+10.0
	set_pev(jetplane_id,pev_origin,origin)
	origin[0]+=jetplane_max_dims[0]
	entity_get_vector(id, EV_VEC_v_angle, angles)
	angles[0] = - angles[0]
	if(camera[id] > 0)
	{
		entity_set_string(camera[id], EV_SZ_classname, "camera")
		entity_set_int(camera[id], EV_INT_solid, SOLID_NOT)
		entity_set_int(camera[id], EV_INT_movetype, MOVETYPE_NOCLIP)
		entity_set_size(camera[id], Float:{0,0,0}, Float:{0,0,0})
		entity_set_model(camera[id], JETPLANE_CAMERA_MODEL)
		set_rendering(camera[id], kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		
		entity_set_origin(camera[id], origin)
		entity_set_vector(camera[id], EV_VEC_angles, angles)
		
		attach_view(id, camera[id])
	}
	spawn_jetplane_mg(attacker)
	spawn_jetplane_law(attacker)
	set_pev(jetplane_id, pev_nextthink, get_gametime() + JET_THINK_PERIOD)
}
public load_jet(id){
	id-=JET_LOAD_TASKID
	
	g_jetplane_loaded[id]=1;	
	sh_chat_message(id,yandere_get_hero_id(),"JET loaded");
	
	
}
//----------------------------------------------------------------------------------------------
public jet_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, JETPLANE_FUSELAGE_CLASSNAME) ) return FMRES_IGNORED
	
	static Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	new Float:jet_health=float(pev(ent,pev_health))
	
	if ( (jet_health<1000.0)) {
		if(g_jetplane[owner]){
			jet_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet died!")
			uncharge_user(owner)
		}
		return FMRES_IGNORED
	}
	if(g_jetplane_deployed[owner]){
		
		new ammo, clip, wpnid=get_user_weapon(owner,ammo,clip)
		if(wpnid!=CSW_KNIFE){
			shSwitchWeaponID(owner,CSW_KNIFE)
		}
	
		new Float:vOrigin[3]
		Entvars_Get_Vector(jet_get_user_jet(owner), EV_VEC_origin, vOrigin)
		
		sh_set_rendering(owner,0,0,0,1,kRenderFxGlowShell,kRenderTransAlpha);
		ENT_SetOrigin(owner, vOrigin)
		set_pev(owner,pev_velocity,NULL_VECTOR)
		if(camera[owner]){
		
			
			new Float:angles[3]
			new Float:velocity[3]
			new Float:move_velocity[3]
			entity_get_vector(jet_get_user_jet(owner), EV_VEC_v_angle, angles)
			velocity_by_aim(jet_get_user_jet(owner),floatround(CAMERA_DIST),velocity)
			entity_get_vector(jet_get_user_jet(owner), EV_VEC_velocity, move_velocity)
			new Float:abs_velocity=vector_length(move_velocity)
			new Float:length=vector_length(velocity)
			if(abs_velocity==0.0){
			
				abs_velocity=1.0
			
			}
			vOrigin[2]-=velocity[2]*(CAMERA_DIST/length)
			vOrigin[2]+=40.0
			vOrigin[0]-=velocity[0]*(CAMERA_DIST/length)
			entity_set_vector(camera[owner], EV_VEC_angles, angles)
			entity_set_vector(camera[owner], EV_VEC_origin, vOrigin)
		
		}
		new hud_msg[1024]
		format(hud_msg,1023,"jetplane hp: %0.2f^njetplane fuel: %0.2f^njetplane BOMBS: %d^njetplane JETGATLING hp: %0.2f^njetplane JETGATLING rounds: %d^njetplane LAW hp: %0.2f^njetplane roquetos: %d^nGround scans left: %d^n",
					float(pev(ent,pev_health))-1000.0,
					get_user_fuel_ammount(owner),
					get_user_jet_bombs(owner),
					get_user_mg(owner)?(float(pev(get_user_mg(owner),pev_health))-1000.0):0.0,
					get_user_jet_shells(owner),
					get_user_mg(owner)?(float(pev(get_user_law(owner),pev_health))-1000.0):0.0,
					get_user_jet_rockets(owner),
					get_user_jet_scans(owner));
		set_hudmessage(jetplane_color[0], jetplane_color[1], jetplane_color[2], 0.35, 0.8, 1, 0.0, 0.5,0.0,0.0,1)
		ShowSyncHudMsg(owner, hud_sync_charge, "%s", hud_msg)
		draw_bbox(jet_get_user_jet(owner),0)
		set_pev(ent, pev_nextthink, gametime + (JET_THINK_PERIOD))
	}
	return FMRES_IGNORED
}

public charge_task(parm[],id){
	id-=JET_CHARGE_TASKID
	//if(client_isnt_hitter(id)) return
	
	
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])-40
	
	if(!is_valid_ent(g_jetplane[id])||(g_jetplane[id] == 0)) {
		return
	}
	ENT_SetOrigin(g_jetplane[id], vOrigin)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_angles, vAngles)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_velocity,  velocity)
	
	
	new hud_msg[128];
	set_pev(g_jetplane[id],pev_health,floatmin(jetplane_hp,floatadd(float(pev(g_jetplane[id],pev_health)),floatmul(JET_CHARGE_PERIOD,JET_CHARGE_RATE))))
	format(hud_msg,127,"[SH]: Curr build pct: %0.2f^n",float(pev(g_jetplane[id],pev_health)));
	set_hudmessage(jetplane_color[0], jetplane_color[1], jetplane_color[2], -1.0, -1.0, 1, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	new parm[2]
	parm[0]=id
	parm[1]=g_jetplane[id]
	
	emit_sound(g_jetplane[id], CHAN_ITEM,JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if((pev(g_jetplane[id],pev_health))>=floatround(jetplane_hp)){
	
		g_jetplane_deployed[id]=1;
		set_pev(g_jetplane[id],pev_health,1000.0+pev(g_jetplane[id],pev_health))
		jet_deploy_task(parm,id+JET_DEPLOY_TASKID)
		remove_task(id+JET_CHARGE_TASKID)
	}
	
	
	
	
	
	
}

public _jet_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	
	g_jetplane_loaded[id]=true;
	g_jetplane_cooldown[id]=0;
	g_jetplane_deployed[id]=false;
	if(is_valid_ent(g_jetplane[id])){
		if(client_hittable(id)){
			set_pev(id, pev_takedamage, DAMAGE_YES)
			set_pev(id, pev_solid, SOLID_SLIDEBOX)
			sh_set_rendering(id);
			new Float:origin[3],Float:plane_orig[3]
			pev(id,pev_origin,origin)
			pev(g_jetplane[id],pev_origin,plane_orig)
			origin[2]=plane_orig[2]+10.0
			set_pev(id,pev_origin,origin)
			
		}
		mg_destroy(id)
		law_destroy(id)
		draw_bbox(g_jetplane[id],1)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=0;
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
}
public _clear_jets(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JETPLANE_FUSELAGE_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, JETPLANE_FUSELAGE_CLASSNAME)
	}
}
