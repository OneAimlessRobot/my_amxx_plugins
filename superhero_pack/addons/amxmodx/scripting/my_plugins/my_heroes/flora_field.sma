

#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"

/*
* 
flora_field_max_ammount 10
flora_field_cooldown 9.0
flora_field_radius 1000.0
flora_field_time 30.0
*/

#define PLUGIN "Superhero flora shield funcs"
#define VERSION "1.0.0"
#define AUTHOR "NULLTick"
#define Struct				enum
#define KILL_BEAM_TASKID 81292373
new Float:g_flora_field_cooldown[SH_MAXSLOTS+1];
new g_flora_field_loaded[SH_MAXSLOTS+1];
new g_flora_num_of_active_fields[SH_MAXSLOTS+1]
new Float:g_field_teleport_time[SH_MAXSLOTS+1]
new g_flora_curr_charging[SH_MAXSLOTS+1]


new Float:field_cooldown
new Float:field_radius
new Float:flora_field_time
new Float:flora_charge_time
new Float:flora_dmg_coeff
new Float:flora_stun_time
new Float:flora_invis_alpha_max
new Float:flora_invis_alpha_min
new Float:flora_invis_alpha_dec_per_lvl
new Float:flora_teleport_crouch_time
new Float:flora_teleport_reach_max_distance
new flora_field_max_ammount
new hud_sync_charge
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("flora_field_max_ammount", "10" )
	register_cvar("lora_field_cooldown" ,"9.0" )
	register_cvar("flora_field_radius" ,"1000.0")
	register_cvar("flora_field_time" ,"30.0" )
	register_cvar("flora_dmg_coeff" ,"0.5" )
	register_cvar("flora_charge_time" ,"30.0" )
	register_cvar("flora_stun_time" ,"30.0" )
	register_cvar("flora_teleport_crouch_time" ,"2.5" )
	register_cvar("flora_teleport_reach_max_distance" ,"1000.0" )
	register_cvar("flora_invis_alpha_max" ,"0.5" )
	register_cvar("flora_invis_alpha_min" ,"0.1" )
	register_cvar("flora_invis_alpha_dec_per_lvl" ,"0.05" )

 
	
	
	arrayset(g_flora_field_cooldown,0.0,SH_MAXSLOTS+1)
	arrayset(g_flora_curr_charging,0,SH_MAXSLOTS+1)
	arrayset(g_field_teleport_time,0.0,SH_MAXSLOTS+1)
	arrayset(g_flora_num_of_active_fields,0,SH_MAXSLOTS+1)
	arrayset(g_flora_field_loaded,1,SH_MAXSLOTS+1)

	
	hud_sync_charge=CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink")
	register_forward(FM_Think, "field_think")
	register_forward(FM_Touch, "field_touch")
	
	// Add your code here...
}

public plugin_natives(){

	register_native("clear_fields","_clear_fields",0);
	register_native("reset_flora_user","_reset_flora_user",0);
	register_native("field_get_user_field_cooldown","_field_get_user_field_cooldown",0)
	register_native("field_uncharge_user","_field_uncharge_user",0)
	register_native("form_field","_form_field",0)
	register_native("field_loaded","_field_loaded",0)
	register_native("clear_user_fields","_clear_user_fields",0)
	register_native("flora_max_fields","_flora_max_fields",0)
	register_native("flora_get_cooldown","_flora_get_cooldown",0)
	register_native("flora_get_user_num_active_fields","_flora_get_user_num_active_fields",0)
	register_native("flora_set_user_num_active_fields","_flora_set_user_num_active_fields",0)
	register_native("flora_dec_user_num_active_fields","_flora_dec_user_num_active_fields",0)
	register_native("flora_inc_user_num_active_fields","_flora_inc_user_num_active_fields",0)
	

	

}

public _flora_get_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_num_of_active_fields[id]
}
public _flora_set_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	g_flora_num_of_active_fields[id]=value

}
public _flora_dec_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]= (g_flora_num_of_active_fields[id]>0)? (g_flora_num_of_active_fields[id]-value):0

}
public _flora_inc_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]=((g_flora_num_of_active_fields[id]+value)>=flora_field_max_ammount)? flora_field_max_ammount:g_flora_num_of_active_fields[id]+value

}
public _field_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	new ent_id=get_param(2)
	uncharge_user(id,ent_id)


}
public _field_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_field_loaded[id]


}
public _flora_max_fields(iPlugins, iParams){
	
	return flora_field_max_ammount
	
}
public Float:_flora_get_cooldown(iPlugins, iParams){
	
	return field_cooldown
	
}
public _clear_user_fields(iPlugin,iParams){
	
	new id= get_param(1)
	new grenada = find_ent_by_class(-1, FLORA_FIELD_CLASSNAME)
	while(grenada) {
		if(pev(grenada,pev_owner)==id){
			//g_field_active_time[grenada]=0.0
			//g_field_charging_time[grenada]=0.0
			remove_entity(grenada)
			grenada = find_ent_by_class(grenada,  FLORA_FIELD_CLASSNAME)
		}
	}
}
public _clear_fields(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, FLORA_FIELD_CLASSNAME)
	while(grenada) {
		//g_field_active_time[grenada]=0.0
		//g_field_charging_time[grenada]=0.0
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada,  FLORA_FIELD_CLASSNAME)
		
	}
}

public Float:_field_get_user_field_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_field_cooldown[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	flora_field_max_ammount=get_cvar_num("flora_field_max_ammount")
	field_cooldown=get_cvar_float("flora_field_cooldown");
	field_radius=get_cvar_float("flora_field_radius");
	flora_field_time=get_cvar_float("flora_field_time")
	flora_stun_time=get_cvar_float("flora_stun_time")
	flora_charge_time=get_cvar_float("flora_charge_time")
	flora_dmg_coeff=get_cvar_float("flora_dmg_coeff")
	flora_invis_alpha_max=get_cvar_float("flora_invis_alpha_max")
	flora_invis_alpha_min=get_cvar_float("flora_invis_alpha_min")
	flora_invis_alpha_dec_per_lvl=get_cvar_float("flora_invis_alpha_dec_per_lvl")
	flora_teleport_reach_max_distance=get_cvar_float("flora_teleport_reach_max_distance")+field_radius
	flora_teleport_crouch_time=get_cvar_float("flora_teleport_crouch_time")
}
Float:get_player_alpha(id){
	
	new Float:alphaMult=1.0;
	new player_lvl,hero_lvl,lvl_diff;
	if(client_hittable(id)&&flora_get_has_flora(id)){
		player_lvl=sh_get_user_lvl(id)
		hero_lvl=flora_get_hero_lvl()
		lvl_diff=player_lvl-hero_lvl
		alphaMult=floatmax(flora_invis_alpha_min,flora_invis_alpha_max-(float(lvl_diff)*flora_invis_alpha_dec_per_lvl))
	}
	return alphaMult
	

}
public _reset_flora_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_flora_field_loaded[id]=1;
	g_flora_field_cooldown[id]=0.0;
	g_field_teleport_time[id]=0.0
	g_flora_num_of_active_fields[id]=0
	clear_user_fields(id)
	
	
}
find_next_nearest_flora_field(ent,Float:distance){
	
	if ( !is_valid_ent(ent) ){
		
	
			return -1
	
	}
	new Float:distance_to_contain=floatmin(flora_teleport_reach_max_distance,floatmax(field_radius,distance))
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, FLORA_FIELD_CLASSNAME) ){
		
			
		return -1
	}
	new Float:pos[3]
	pev(ent, pev_origin, pos)
	new owner=pev(ent,pev_owner)
	new entlist[MAX_ENTITIES+1];
	new numfound = find_sphere_class(ent,FLORA_FIELD_CLASSNAME, distance_to_contain ,entlist, MAX_ENTITIES);
	
	
	new Float:best_distance=9999999.0
	new best_id=-1
	for( new i= 0;(i< numfound);i++){
		new searched_id=entlist[i]
		if((searched_id==ent)||!(pev(searched_id,pev_owner)==owner)){
				continue
		}
		new Float:other_pos[3]
		pev(searched_id, pev_origin, other_pos)
		
		new Float:distance_between=VecDist(pos,other_pos)
		if((distance_between<best_distance)){
			
				best_distance=distance_between
				best_id=searched_id
			
		}
		
	}
	return best_id
	
}
public plugin_end(){
	
	
}
public plugin_precache(){


	precache_model(FIELD_MDL)
	precache_explosion_fx()
	
	
}

public _form_field(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!flora_get_has_flora(id)||!is_user_alive(id)||!is_user_connected(id)) return PLUGIN_HANDLED
	
	if(!flora_get_user_num_fields(id)){
		
		client_print(id,print_center,"You ran out of fields")
		return PLUGIN_HANDLED
		
	}
	if(!g_flora_field_loaded[id]){
		
		sh_chat_message(id,flora_get_hero_id(),"Field not loaded")
		return PLUGIN_HANDLED
	}
	g_flora_field_loaded[id]=0
	
	new Float: Origin[3],  Ent
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	
	Origin[2]+=50.0
	Ent = create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,flora_get_hero_id(),"Field failure!");
		return PLUGIN_HANDLED
	}
	
	entity_set_string(  Ent, EV_SZ_classname, FLORA_FIELD_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX);
	entity_set_model(  Ent , FIELD_MDL );
	new Float:fl_vecminsx[3]
	new Float:fl_vecmaxsx[3]
	for (new i=0;i<3;i++){
		fl_vecminsx[i]=-field_radius 
		fl_vecmaxsx[i]=field_radius 
	
	}
	entity_set_vector(Ent, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(Ent, EV_VEC_maxs,fl_vecmaxsx)
	
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	entity_set_float(Ent,EV_FL_fuser1,0.0)
	g_flora_curr_charging[id]=Ent
	
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_NONE) //5 = movetype_fly, No grav, but collides.
	entity_set_int(Ent,EV_INT_rendermode,kRenderTransAlpha)
	entity_set_int(Ent,EV_INT_renderfx,kRenderFxGlowShell)
	
	
	
	//emit_sound(id, CHAN_WEAPON, FIELD_DE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	glow(Ent,LineColors[GREEN][0],LineColors[GREEN][1],LineColors[GREEN][2],100,1)
	
	new parm[2]
	parm[0]=id
	parm[1]=Ent
	set_task(FLORA_CHARGE_PERIOD,"charge_task",id+FLORA_CHARGE_TASKID,parm, 2,  "b")
	
	
	return PLUGIN_CONTINUE
}
public cooldown_update_task(id){
	
	id-=FLORA_COOLDOWN_TASKID
	if(g_flora_field_cooldown[id]>=0.0){
		g_flora_field_cooldown[id]=g_flora_field_cooldown[id]-FLORA_CHARGE_PERIOD
	}
	else{
		end_cooldown_update_tasks(id)
		g_flora_field_loaded[id]=1
	
	}
	
	
}
public end_cooldown_update_tasks(id){
	
	
	remove_task(id+FLORA_COOLDOWN_TASKID)
}
public field_deploy_task(parm[],id){
	
	id-=FLORA_DEPLOY_TASKID
	
	new field_id=parm[1];
	if(!is_valid_ent(field_id)){
		
		return;
	}
	entity_set_int(field_id,EV_INT_solid, SOLID_BBOX)
	entity_set_vector(field_id,EV_VEC_velocity,null_vector)
	entity_set_int(field_id,EV_INT_movetype, MOVETYPE_FLY)
	server_print("Deployed shield!!!")
	flora_dec_user_num_fields(id,1)
	flora_inc_user_num_active_fields(id,1)
	
	client_print(id,print_center,"You have %d fields left!",flora_get_user_num_fields(id))
	g_flora_field_cooldown[id]=field_cooldown
	set_task(FLORA_CHARGE_PERIOD,"cooldown_update_task",id+FLORA_COOLDOWN_TASKID,"", 0,  "a",floatround(field_cooldown/FLORA_CHARGE_PERIOD))
	sh_chat_message(id,flora_get_hero_id(),"Field armed!");
	
	entity_set_float(field_id,EV_FL_fuser2,floatadd(flora_field_time,FIELD_ACTIVE_TIME_BUFFER))
	g_flora_curr_charging[id]=0
	entity_set_float(field_id,EV_FL_nextthink,floatadd(get_gametime(),FLORA_THINK_PERIOD))
	
}
public check_crouch(id,field_standing_on) {
			
	if(!client_hittable(id)||!flora_get_has_flora(id)){
		
		//client_print(id,print_console,"failing in the first check for client validity and hero possession!!!");
		return FMRES_IGNORED

	}
	new Float:alpha_to_use=get_player_alpha(id)
	new alpha_value_to_use=floatround(float(255)*alpha_to_use)
	
	
	static Float: fOrigin[ 3 ],Float:here_field_origin[3],Float:other_field_origin[3]
	entity_get_vector( id, EV_VEC_origin, fOrigin );
	entity_get_vector( field_standing_on, EV_VEC_origin, here_field_origin );
	
	new Float:distance=VecDist(fOrigin,here_field_origin)
	if( !(entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  )){
		//client_print(id,print_console,"failing in the second check for client contact with ground!!!");
		set_user_rendering(id)
		g_field_teleport_time[id]=0.0
		return FMRES_IGNORED;
	
	
	}
	
	
	static iButton;
	iButton = entity_get_int( id, EV_INT_button );
	
	if( ( iButton & IN_DUCK ) && (distance<=field_radius)){
		g_field_teleport_time[id]= g_field_teleport_time[id]+FLORA_THINK_PERIOD
		client_print(id,print_center,"[SH] flora: Teleporting time: %0.2f",g_field_teleport_time[id])
		if(g_field_teleport_time[id]>=flora_teleport_crouch_time){
			
			new field_id=find_next_nearest_flora_field(field_standing_on,99999.0)
			if(is_valid_ent(field_id)){
				entity_get_vector( field_id, EV_VEC_origin, other_field_origin );
				entity_set_vector( id, EV_VEC_origin, other_field_origin );
				sh_chat_message(id,flora_get_hero_id(),"You just got teleported to the next nearest field! (hopefully)")
			}
			else{
				sh_chat_message(id,flora_get_hero_id(),"Teleporting was not possible (maybe no other fields?)")
				
				
			}
			g_field_teleport_time[id]=0.0
		}
		sh_set_rendering(id,0,0,0,alpha_value_to_use,kRenderFxGlowShell,kRenderTransAlpha);
	}
	else
	{
		
		g_field_teleport_time[id]=0.0
		set_user_rendering(id)
		return FMRES_IGNORED;
			
	}
	
	return FMRES_IGNORED;
}
public kill_laser_beam(ent_id){
	
	ent_id-=KILL_BEAM_TASKID
	if ( !is_valid_ent(ent_id) ) return
	if(!client_hittable(pev(ent_id, pev_owner))) return
	
	//Kill the Beam
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
	write_byte(TE_KILLBEAM)
	write_short(ent_id) // entity
	message_end()
	
}
//----------------------------------------------------------------------------------------------
public field_think(ent)
{
	if ( !is_valid_ent(ent) ){
		
	
			return FMRES_IGNORED
	
	}
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, FLORA_FIELD_CLASSNAME) ){
		
			
		return FMRES_IGNORED
	}
	static Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	
	if (entity_get_float(ent,EV_FL_fuser2)<FIELD_ACTIVE_TIME_BUFFER) {
		if(is_valid_ent(ent)){
			sh_chat_message(owner,flora_get_hero_id(),"Field died!")
			
			field_uncharge_user(owner,ent)
		}
		return FMRES_IGNORED
	}
	else{
		new iPos[3]
		FVecIVec(Pos,iPos)
		new entlist[33];
		make_shockwave(iPos,field_radius,LineColorsWithAlpha[GREEN])
		new numfound = find_sphere_class(ent,"player", field_radius ,entlist, 32);
		new CsTeams:idTeam = cs_get_user_team(owner)
		for( new i= 0;(i< numfound);i++){
		
			new pid = entlist[i];
			if(!client_hittable(pid)){
				continue
			
			}
			
			if((cs_get_user_team(pid)==idTeam)){
				if(pid==owner){
				
					check_crouch(owner,ent)
		
				}
				continue
			}
			new Float:enemy_pos[3]
			entity_set_vector(pid,EV_VEC_origin,enemy_pos)
			laser_line(ent,Pos,enemy_pos,0)
			set_task(1.0,"kill_laser_beam",ent+KILL_BEAM_TASKID,"",0)
			new damage=floatround(floatmul(float(get_user_health(pid)),floatmin(floatmax(0.0,flora_dmg_coeff),1.0)))
			sh_extra_damage(pid,owner,damage,"Flora field damage")
			sh_set_stun(pid,flora_stun_time,0.5)
			sh_set_rendering(pid, LineColorsWithAlpha[GREEN][0], LineColorsWithAlpha[GREEN][1], LineColorsWithAlpha[GREEN][2], LineColorsWithAlpha[GREEN][3], kRenderFxGlowShell, kRenderTransAlpha)
			heal(owner,float(damage))
	}
	
	
	}
	if(is_valid_ent(ent)){
		entity_set_float(ent,EV_FL_nextthink,floatadd(gametime,FLORA_THINK_PERIOD))
		entity_set_float(ent,EV_FL_fuser2,floatsub(entity_get_float(ent,EV_FL_fuser2),FLORA_THINK_PERIOD))
	}
	return FMRES_IGNORED
}
uncharge_user(id,ent=-1){
	remove_task(id+FLORA_CHARGE_TASKID)
	if(is_valid_ent(ent)){
		remove_entity(ent);
	}
	else if(is_valid_ent(g_flora_curr_charging[id])){
		
		
		remove_entity(g_flora_curr_charging[id]);
	}
	sh_set_rendering(id)
	g_flora_field_loaded[id]=1
	if ( flora_get_prev_weapon(id) != CSW_KNIFE ){
		shSwitchWeaponID(id, flora_get_prev_weapon(id))
	}
	return 0
	
	
	
}

public load_field(id){
	id-=FLORA_LOAD_TASKID
	
	g_flora_field_loaded[id]=1;	
	sh_chat_message(id,flora_get_hero_id(),"Field loaded");
	
	
}
public charge_task(parm[],id){
	id-=FLORA_CHARGE_TASKID
	//if(client_isnt_hitter(id)) return
	
	new owner= parm[0]
	new field_id=parm[1]
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(owner, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(owner, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	if(!is_valid_ent(field_id)||(field_id == 0)) {
		return
	}
	ENT_SetOrigin(field_id, vOrigin)
	Entvars_Set_Vector(field_id, EV_VEC_angles, vAngles)
	Entvars_Get_Vector(owner, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(field_id, EV_VEC_velocity,  velocity)
	
	// switch to knife
	engclient_cmd(id, "weapon_knife")
	
	
	new hud_msg[128];
	entity_set_float(field_id,EV_FL_fuser1,floatadd(entity_get_float(field_id,EV_FL_fuser1),FLORA_CHARGE_PERIOD))
	format(hud_msg,127,"[SH] flora: Charging... ^n %0.2f percent done",(entity_get_float(field_id,EV_FL_fuser1)/flora_charge_time)*100.0);
	set_hudmessage(LineColors[GREEN][0], LineColors[GREEN][1], LineColors[GREEN][2], -1.0, -1.0, 1, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(owner, hud_sync_charge, "%s", hud_msg)
	new parm[2]
	parm[0]=owner
	parm[1]=field_id
	new test_edict=find_next_nearest_flora_field(field_id,0.0)
	if(is_valid_ent(test_edict)){
		sh_sound_deny(id)
		sh_chat_message(id,flora_get_hero_id(),"This spore is too close to another one of yours! Will not plant.")
		uncharge_user(owner,field_id)
		return
	}
	if(entity_get_float(field_id,EV_FL_fuser1)>flora_charge_time){
	
		field_deploy_task(parm,id+FLORA_DEPLOY_TASKID)
		uncharge_user(owner)
	}
	
	
	
	
	
	
}
stock glow(id, r, g, b,a, on) {
	if(on) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderTransAlpha, a)
	}
	else{
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderTransAlpha, a)
	}
}


public remove_glisten_task(id){

id-=FLORA_UNGLISTEN_TASKID
if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)) return

set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)

}

public flora_glisten(id){
	
	
	setScreenFlash(id,LineColors[GREEN][0],LineColors[GREEN][1],LineColors[GREEN][2],3,180)
	glow(id,LineColors[GREEN][0],LineColors[GREEN][1],LineColors[GREEN][2],100,1)
	new color[4];
	color[0]=LineColors[GREEN][0]
	color[1]=LineColors[GREEN][1]
	color[2]=LineColors[GREEN][2]
	color[3]=230
	aura(id,color)
	set_task(FLORA_HEAL_GLOW_TIME,"remove_glisten_task",id+FLORA_UNGLISTEN_TASKID,"", 0,  "a",1)	
	
}
public heal(id,Float:damage){
	
	new Float: mate_health=float(get_user_health(id))
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	new new_damage= min(floatround(damage), clamp(0,sh_get_max_hp(id)-get_user_health(id)))
	if(new_damage>0){
		flora_glisten(id)
	}
	new Float: new_health=floatadd(mate_health,float(new_damage))
	set_user_health(id,min(sh_get_max_hp(id),floatround(new_health)))
	return true

}