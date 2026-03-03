

#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"

#define PLUGIN "Superhero flora shield funcs"
#define VERSION "1.0.0"
#define AUTHOR "NULLTick"
#define Struct				enum
#define KILL_BEAM_TASKID 81292373
stock const  FLORA_HEAL_GLOWING_ON=0
stock Float:g_flora_field_cooldown[SH_MAXSLOTS+1];
stock g_flora_field_loaded[SH_MAXSLOTS+1];
stock g_flora_num_of_active_fields[SH_MAXSLOTS+1]
stock Float:g_field_teleport_time[SH_MAXSLOTS+1]
stock g_flora_user_is_cloaked[SH_MAXSLOTS+1]
stock g_flora_prev_inside[SH_MAXSLOTS+1]
stock g_flora_curr_inside[SH_MAXSLOTS+1]
stock g_flora_curr_charging[SH_MAXSLOTS+1]
stock g_flora_sheltered_value[SH_MAXSLOTS+1]
stock g_flora_dmg_color[SH_MAXSLOTS+1]
stock Float:g_flora_curr_dmg_mult[SH_MAXSLOTS+1]


stock Float:field_cooldown
stock Float:field_radius
stock Float:field_core_radius
stock Float:flora_field_time
stock Float:flora_charge_time
stock Float:flora_dmg_coeff
stock Float:flora_core_heal_mult
stock Float:flora_field_heal_mult
stock Float:flora_stun_time
stock Float:flora_invis_alpha_max
stock Float:flora_base_stun_speed
stock Float:flora_invis_alpha_min
stock Float:flora_invis_alpha_dec_per_lvl
stock Float:flora_teleport_crouch_time
stock Float:flora_teleport_reach_max_distance
stock flora_field_start_ammount
stock flora_field_max_active_ammount
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("flora_field_max_active_ammount", "10" )
	register_cvar("flora_field_start_ammount", "10" )
	register_cvar("flora_field_cooldown" ,"9.0" )
	register_cvar("flora_field_radius" ,"1000.0")
	register_cvar("flora_field_core_radius" ,"1000.0")
	register_cvar("flora_field_time" ,"30.0" )
	register_cvar("flora_dmg_coeff" ,"0.5" )
	register_cvar("flora_core_heal_mult" ,"0.5" )
	register_cvar("flora_field_heal_mult" ,"0.5" )
	register_cvar("flora_dmg_coeff" ,"0.5" )
	register_cvar("flora_charge_time" ,"30.0" )
	register_cvar("flora_stun_time" ,"30.0" )
	register_cvar("flora_teleport_crouch_time" ,"2.5" )
	register_cvar("flora_teleport_reach_max_distance" ,"1000.0" )
	register_cvar("flora_invis_alpha_max" ,"0.5" )
	register_cvar("flora_invis_alpha_min" ,"0.1" )
	register_cvar("flora_invis_alpha_dec_per_lvl" ,"0.05" )
	register_cvar("flora_base_stun_speed","210.0")

 
	
	
	arrayset(g_flora_field_cooldown,0.0,SH_MAXSLOTS+1)
	arrayset(g_flora_user_is_cloaked,0,SH_MAXSLOTS+1)
	arrayset(g_flora_prev_inside,-1,SH_MAXSLOTS+1)
	arrayset(g_flora_curr_inside,-1,SH_MAXSLOTS+1)
	arrayset(g_flora_sheltered_value,0,SH_MAXSLOTS+1)
	arrayset(g_flora_dmg_color,0,SH_MAXSLOTS+1)
	arrayset(g_flora_curr_charging,-1,SH_MAXSLOTS+1)
	arrayset(g_field_teleport_time,0.0,SH_MAXSLOTS+1)
	arrayset(g_flora_num_of_active_fields,0,SH_MAXSLOTS+1)
	arrayset(g_flora_field_loaded,1,SH_MAXSLOTS+1)

	
	register_forward(FM_Think, "field_think")
	
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
	register_native("flora_start_fields","_flora_start_fields",0)
	register_native("flora_get_cooldown","_flora_get_cooldown",0)
	register_native("flora_get_user_num_active_fields","_flora_get_user_num_active_fields",0)
	register_native("flora_set_user_num_active_fields","_flora_set_user_num_active_fields",0)
	register_native("flora_dec_user_num_active_fields","_flora_dec_user_num_active_fields",0)
	register_native("flora_inc_user_num_active_fields","_flora_inc_user_num_active_fields",0)
	
	
	register_native("flora_get_user_is_cloaked","_flora_get_user_is_cloaked",0)
	register_native("flora_get_user_is_crouched","_flora_get_user_is_crouched",0)
	register_native("flora_get_user_is_airborne","_flora_get_user_is_airborne",0)
	register_native("flora_get_curr_inside","_flora_get_curr_inside",0)
	register_native("flora_get_prev_inside","_flora_get_prev_inside",0)
	register_native("start_flora_checks","_start_flora_checks",0)
	

	

}
public _start_flora_checks(iPlugin,iParams){
	new id=get_param(1)
	
	if(client_hittable(id)&&flora_get_has_flora(id)){
		set_task(FLORA_THINK_PERIOD,"flora_checks",id+FLORA_CHECKS_TASKID,"",0,"b")
	}
}
public _flora_get_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_num_of_active_fields[id]

}
public _flora_set_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]= value

}
public _flora_dec_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]= (g_flora_num_of_active_fields[id]>0)? (g_flora_num_of_active_fields[id]-value):0

}
public _flora_inc_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]=((g_flora_num_of_active_fields[id]+value)>=flora_field_max_active_ammount)? flora_field_max_active_ammount:g_flora_num_of_active_fields[id]+value

}
public _field_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)


}
public _field_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_field_loaded[id]


}
public _flora_max_fields(iPlugins, iParams){
	
	return flora_field_max_active_ammount
	
}
public _flora_start_fields(iPlugins, iParams){
	
	return flora_field_start_ammount
	
}
public Float:_flora_get_cooldown(iPlugins, iParams){
	
	return field_cooldown
	
}
public _clear_user_fields(iPlugin,iParams){
	
	new id= get_param(1)
	if(!is_user_connected(id)) return
	new grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME, id);
	while(grenada) {
		destroy_field(grenada,1)
		grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME, id);
	}
	if(is_user_connected(id)){
		emit_sound(id, CHAN_VOICE, FIELD_NULL, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(id, CHAN_VOICE, FIELD_HEAL, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(id, CHAN_AUTO, FIELD_NULL, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(id, CHAN_AUTO, FIELD_TELEPORT, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	}
	
}
public _clear_fields(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, FLORA_FIELD_CLASSNAME)
	while(grenada) {
		
		destroy_field(grenada,1)
		grenada = find_ent_by_class(grenada,  FLORA_FIELD_CLASSNAME)
		
	}
}

public Float:_field_get_user_field_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_field_cooldown[id]


}
public _flora_get_user_is_cloaked(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_user_is_cloaked[id]


}
public _flora_get_user_is_crouched(iPlugin,iParams){
	new id=get_param(1)
	
	return (entity_get_int( id, EV_INT_flags ) & FL_DUCKING )


}
public _flora_get_user_is_airborne(iPlugin,iParams){
	new id=get_param(1)
	
	return !(entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  )


}
public _flora_get_curr_inside(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_curr_inside[id]


}
public _flora_get_prev_inside(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_prev_inside[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	flora_field_start_ammount=get_cvar_num("flora_field_start_ammount")
	flora_field_max_active_ammount=get_cvar_num("flora_field_max_active_ammount")
	field_cooldown=get_cvar_float("flora_field_cooldown");
	field_radius=get_cvar_float("flora_field_radius");
	field_core_radius=get_cvar_float("flora_field_core_radius");
	flora_field_time=get_cvar_float("flora_field_time")
	flora_stun_time=get_cvar_float("flora_stun_time")
	flora_charge_time=get_cvar_float("flora_charge_time")
	flora_dmg_coeff=get_cvar_float("flora_dmg_coeff")
	flora_core_heal_mult=get_cvar_float("flora_core_heal_mult")
	flora_field_heal_mult=get_cvar_float("flora_field_heal_mult")
	flora_invis_alpha_max=get_cvar_float("flora_invis_alpha_max")
	flora_invis_alpha_min=get_cvar_float("flora_invis_alpha_min")
	flora_invis_alpha_dec_per_lvl=get_cvar_float("flora_invis_alpha_dec_per_lvl")
	flora_teleport_reach_max_distance=get_cvar_float("flora_teleport_reach_max_distance")+field_radius
	flora_teleport_crouch_time=get_cvar_float("flora_teleport_crouch_time")
	flora_base_stun_speed=get_cvar_float("flora_base_stun_speed")
}
Float:get_player_alpha(id){
	
	new Float:alphaMult=1.0;
	new player_lvl,hero_lvl,lvl_diff;
	if(client_hittable(id)){
		if(flora_get_has_flora(id)){
			player_lvl=sh_get_user_lvl(id)
			hero_lvl=flora_get_hero_lvl()
			lvl_diff=player_lvl-hero_lvl
			alphaMult=floatmax(flora_invis_alpha_min,flora_invis_alpha_max-(float(lvl_diff)*flora_invis_alpha_dec_per_lvl))
		}
	}
	return alphaMult
	

}
public _reset_flora_user(iPlugin,iParams){
	
	new id= get_param(1)
	
	uncharge_user(id)
	clear_user_fields(id)
	g_flora_field_loaded[id]=1;
	g_flora_field_cooldown[id]=0.0;
	g_field_teleport_time[id]=0.0
	g_flora_num_of_active_fields[id]=0
	g_flora_user_is_cloaked[id]=0
	g_flora_curr_charging[id]=-1
	g_flora_curr_inside[id]=-1
	g_flora_prev_inside[id]=-1
	remove_task(id+FLORA_CHECKS_TASKID)
	
	
}
destroy_field(field_id,make_sound=0,planting=0){

	if(is_valid_ent(field_id)){
		new owner=pev(field_id,pev_owner);
		if(make_sound){
			emit_sound(field_id, CHAN_AUTO, FIELD_DESTROYED, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		suck_in_sound(field_id,0)
		emit_sound(field_id, CHAN_ITEM, FIELD_NULL, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(field_id, CHAN_ITEM, FIELD_HUM, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(field_id, CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		if(is_user_connected(owner)){
			if(flora_get_has_flora(owner)){
				if(!planting){
					flora_dec_user_num_active_fields(owner,1)
				}
				g_flora_user_is_cloaked[owner]=0;
				apply_cloak(owner)
				if(field_id==g_flora_curr_inside[owner]){
			
					g_flora_curr_inside[owner]=-1;
				}
				if(field_id==g_flora_prev_inside[owner]){
			
					g_flora_prev_inside[owner]=-1;
				}
		
			}
		}
		remove_entity(field_id)
	}
	
}
find_next_nearest_flora_field(player_id,field_to_exclude=-1,Float:distance){
	
	if ( !client_hittable(player_id)||!flora_get_has_flora(player_id) ){
		
	
			return -1
	
	}
	new Float:distance_to_contain=floatmin(flora_teleport_reach_max_distance,floatmax(distance,field_radius*2.0))
	
	
	new Float:pos[3]
	pev(player_id, pev_origin, pos)
	new Float:best_distance=9999999.0
	new field_id = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME,player_id)
	new best_id=-1
	while(field_id) {
		new new_field_id= find_ent_by_owner(field_id, FLORA_FIELD_CLASSNAME,player_id)
		
		if(is_valid_ent(field_to_exclude)){
			
			if(field_to_exclude==field_id){
				field_id=new_field_id
				
				continue
			}
			
		}
		new Float:other_pos[3]
		pev(field_id, pev_origin, other_pos)
		
		new Float:distance_between=VecDist(pos,other_pos)
		if((distance_between<distance_to_contain)&&(distance_between<best_distance)){
			
				best_distance=distance_between
				best_id=field_id
			
		}
		field_id=new_field_id
	}
	
	return best_id
	
}
public flora_checks(id){
	
	id-=FLORA_CHECKS_TASKID
	if(!client_hittable(id)||!flora_get_has_flora(id)){
		
		remove_task(id+FLORA_CHECKS_TASKID)
		return
		
	}
	if(!g_flora_field_loaded[id]){
		
		g_flora_curr_dmg_mult[id]=0.0
		g_field_teleport_time[id]=0.0
		g_flora_prev_inside[id]=g_flora_curr_inside[id]
		g_flora_curr_inside[id]=-1
		return
		
	}
	
	new field_id,flora_sheltered_value=is_flora_user_in_owned_field(id,field_id)
	g_flora_sheltered_value[id]=flora_sheltered_value;
	
	if(g_flora_curr_inside[id]!=field_id){
		g_flora_prev_inside[id]=g_flora_curr_inside[id]
		g_flora_curr_inside[id]=field_id
	}
	
	new crouched=flora_get_user_is_crouched(id)
	if(g_flora_sheltered_value[id]&&crouched){
		
		switch(g_flora_sheltered_value[id]){
			case OUTSIDE:
			{
				g_flora_dmg_color[id]=GREEN
				g_flora_curr_dmg_mult[id]=1.0
				g_field_teleport_time[id]=0.0
				g_flora_prev_inside[id]=g_flora_curr_inside[id]
				g_flora_curr_inside[id]=-1
				if(g_flora_user_is_cloaked[id]){
					g_flora_user_is_cloaked[id]=0
					if(!g_flora_sheltered_value[id]){
						sh_chat_message(id,flora_get_hero_id(),FLORA_UNCLOAKED_OUT_OF_RANGE_MSG)
					}
				}
				apply_cloak(id)
				return
			}
			case SHELTERED:
			{
				g_flora_dmg_color[id]=YELLOW
				g_flora_curr_dmg_mult[id]=flora_field_heal_mult
				g_field_teleport_time[id]=0.0
			}
			case DUNGEON_DWELLER:
			{
				g_flora_dmg_color[id]=RED
				g_flora_curr_dmg_mult[id]=flora_field_heal_mult*flora_core_heal_mult
				apply_teleport(id,field_id)
			}
		}
		if(!g_flora_user_is_cloaked[id]){
			g_flora_user_is_cloaked[id]=1
			sh_chat_message(id,flora_get_hero_id(),FLORA_CLOAKED_MSG)
			apply_cloak(id)
		}
	}
	else{
		
		g_flora_curr_dmg_mult[id]=0.0
		g_field_teleport_time[id]=0.0
		g_flora_prev_inside[id]=g_flora_curr_inside[id]
		g_flora_curr_inside[id]=-1
		if(g_flora_user_is_cloaked[id]){
			g_flora_user_is_cloaked[id]=0
			if(!g_flora_sheltered_value[id]){
				sh_chat_message(id,flora_get_hero_id(),FLORA_UNCLOAKED_AIRBORNE_MSG)
			}
			if(!crouched){
				sh_chat_message(id,flora_get_hero_id(),FLORA_UNCLOAKED_UNDUCKED_MSG)
			}
			apply_cloak(id)
		}
	}
}
is_flora_user_in_owned_field(player_id,&field_id=-1){
	
	if ( !client_hittable(player_id)||!flora_get_has_flora(player_id) ){
		
	
			field_id=-1
			return 0
	
	}
	else if( !(entity_get_int( player_id, EV_INT_flags ) & FL_ONGROUND  )){
		
			field_id=-1
			return 0
	
	}
	new Float:pos[3],Float:field_pos[3]
	pev(player_id, pev_origin, pos)
	new grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME,player_id)
	while(grenada) {
			pev(grenada,pev_origin,field_pos)
			new Float:distance=VecDist(pos,field_pos)
			if(distance<field_radius){
				field_id=grenada;
				if(distance<field_core_radius){
					return DUNGEON_DWELLER
				}
				return SHELTERED
			}
			grenada = find_ent_by_owner(grenada, FLORA_FIELD_CLASSNAME,player_id)
	}
	field_id=-1
	return OUTSIDE
	
}
public plugin_end(){
	
	
}
public plugin_precache(){


	precache_model(FIELD_MDL)
	
	precache_sound(FIELD_DEPLOYED)
	precache_sound(FIELD_DESTROYED)
	precache_sound(FIELD_HUM)
	precache_sound(FIELD_TELEPORT)
	precache_sound(FIELD_HEAL)
	precache_sound(FIELD_CHARGING)
	precache_explosion_fx()
	
	
}

public _form_field(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!flora_get_has_flora(id)||!client_hittable(id)) return PLUGIN_HANDLED
	
	if(!flora_get_user_num_fields(id)){
		
		client_print(id,print_center,"You ran out of fields")
		return PLUGIN_HANDLED
		
	}
	if(!g_flora_field_loaded[id]){
		
		sh_chat_message(id,flora_get_hero_id(),"Field not loaded")
		return PLUGIN_HANDLED
	}
	
	new Float: Origin[3],  Ent
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	
	Origin[2]+=50.0
	Ent = create_entity("info_target")
	
	if(pev_valid(Ent)!=2){
		
		sh_chat_message(id,flora_get_hero_id(),"Field failure!");
		return PLUGIN_HANDLED
	}
	
	entity_set_string(  Ent, EV_SZ_classname, FLORA_FIELD_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX);
	entity_set_model(  Ent , FIELD_MDL );
	new Float:fl_vecminsx[3]
	new Float:fl_vecmaxsx[3]
	for (new i=0;i<3;i++){
		fl_vecminsx[i]=-field_core_radius
		fl_vecmaxsx[i]=field_core_radius
	
	}
	entity_set_vector(Ent, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(Ent, EV_VEC_maxs,fl_vecmaxsx)
	
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	entity_set_float(Ent,EV_FL_fuser1,0.0)
	g_flora_curr_charging[id]=Ent
	g_flora_field_loaded[id]=0;
	
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	entity_set_int(Ent,EV_INT_rendermode,kRenderTransAlpha)
	entity_set_int(Ent,EV_INT_renderfx,kRenderFxGlowShell)
	
	
	
	glow(Ent,LineColors[ORANGE][0],LineColors[ORANGE][1],LineColors[ORANGE][2],100,1)
	
	new parm[2]
	parm[0]=id
	parm[1]=Ent
	set_task(FLORA_CHARGE_PERIOD,"charge_task",id+FLORA_CHARGE_TASKID,parm, 2,  "b")
	
	
	return PLUGIN_CONTINUE
}
public cooldown_update_task(id){
	
	id-=FLORA_COOLDOWN_TASKID
	g_flora_field_cooldown[id]=g_flora_field_cooldown[id]-FLORA_CHARGE_PERIOD
	if(g_flora_field_cooldown[id]<=0.0){
		g_flora_field_loaded[id]=1
	
	}
	
	
}
public end_cooldown_update_tasks(id){
	
	
	remove_task(id+FLORA_COOLDOWN_TASKID)
}
public field_deploy_task(parm[],id){
	
	id-=FLORA_DEPLOY_TASKID
	
	new field_id=parm[1];
	if(pev_valid(field_id)!=2){
		
		return
	
	}
	entity_set_int(field_id,EV_INT_solid, SOLID_BBOX)
	entity_set_vector(field_id,EV_VEC_velocity,null_vector)
	entity_set_int(field_id,EV_INT_movetype, MOVETYPE_FLY)
	flora_dec_user_num_fields(id,1)
	flora_inc_user_num_active_fields(id,1)
	
	client_print(id,print_center,"You have %d fields left!",flora_get_user_num_fields(id))
	g_flora_field_cooldown[id]=field_cooldown
	set_task(FLORA_CHARGE_PERIOD,"cooldown_update_task",id+FLORA_COOLDOWN_TASKID,"", 0,  "a",floatround(field_cooldown/FLORA_CHARGE_PERIOD)+1)
	
	entity_set_float(field_id,EV_FL_fuser2,floatadd(flora_field_time,FIELD_ACTIVE_TIME_BUFFER))
	g_flora_curr_charging[id]=-1
	
	emit_sound(field_id, CHAN_ITEM, FIELD_HUM, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	entity_set_float(field_id,EV_FL_nextthink,floatadd(get_gametime(),FLORA_THINK_PERIOD))
	
}
public apply_teleport(id,field_inside) {
	
	if(pev_valid(field_inside)!=2){
		
		return
	
	}
	if(!client_hittable(id)||!flora_get_has_flora(id)){
		
		return

	}
	new Float: fOrigin[ 3 ],Float:other_field_origin[3]
	entity_get_vector( id, EV_VEC_origin, fOrigin );
	
	
	g_field_teleport_time[id]= g_field_teleport_time[id]+FLORA_THINK_PERIOD
	client_print(id,print_center,"[SH] flora: Teleporting time: %0.2f",g_field_teleport_time[id])
	
	if(g_field_teleport_time[id]>=flora_teleport_crouch_time){
		if(flora_get_user_num_active_fields(id)>1){
			new field_id=find_next_nearest_flora_field(id,field_inside,999999.0)
			if(is_valid_ent(field_id)){
				entity_get_vector( field_id, EV_VEC_origin, other_field_origin );
				entity_set_vector( id, EV_VEC_origin, other_field_origin );
				emit_sound(id, CHAN_AUTO, FIELD_TELEPORT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				sh_chat_message(id,flora_get_hero_id(),"You just got teleported to the next nearest field! (hopefully)")
			}
			else{
				sh_chat_message(id,flora_get_hero_id(),"Teleporting was not possible (too far)")
				
				
			}
		}
		else{
			
			sh_chat_message(id,flora_get_hero_id(),"Teleporting was not possible (no other fields)")
				
				
		}
		g_field_teleport_time[id]=0.0
	}
	return
}

apply_cloak(id){
	
	if(!client_hittable(id)||!flora_get_has_flora(id)){
		
		g_flora_user_is_cloaked[id]=0
		return 

	}

	new Float:alpha_to_use=get_player_alpha(id)
	new alpha_value_to_use=floatround(float(255)*alpha_to_use)
	if(g_flora_user_is_cloaked[id]){
		sh_set_rendering(id,0,0,0,alpha_value_to_use,kRenderFxGlowShell,kRenderTransAlpha);
	}
	else{
		
		set_user_rendering(id)
	}
}
//----------------------------------------------------------------------------------------------
public field_think(ent)
{
	if ( pev_valid(ent)!=2 ){
		
	
			return FMRES_IGNORED
	
	}
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, FLORA_FIELD_CLASSNAME) ){
		
			
		return FMRES_IGNORED
	}
	
	new Float:gametime
	static Float:ent_pos[3]
	static ient_pos[3],entlist[33];
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	if (entity_get_float(ent,EV_FL_fuser2)<FIELD_ACTIVE_TIME_BUFFER) {
		if(pev_valid(ent)==2){
			sh_chat_message(owner,flora_get_hero_id(),"Field died!")
			
			destroy_field(ent,1)
		}
		return FMRES_IGNORED
	}
	else{
		entity_get_vector(ent, EV_VEC_origin, ent_pos)
		FVecIVec(ent_pos,ient_pos)
		make_shockwave(ient_pos,field_radius,{255, 255, 0,60})
		make_shockwave(ient_pos,field_core_radius,{255, 128, 0,60})
		new numfound = find_sphere_class(ent,"player", field_radius ,entlist, 32);
		new CsTeams:owner_team=cs_get_user_team(owner)
		for( new i= 0;(i< numfound);i++){
		
			new pid = entlist[i];
			if(!client_hittable(pid)){
				continue
			
			}
			else if(cs_get_user_team(pid)==owner_team){
				continue
			}
			if(g_flora_sheltered_value[owner]>0){
				new Float:fdamage=floatmul(float(get_user_health(pid)),floatmin(floatmax(0.0,flora_dmg_coeff*g_flora_curr_dmg_mult[owner]),0.99))
				
				sh_extra_damage(pid,owner,floatround(fdamage),"Flora field damage")
				
				sh_set_stun(pid,flora_stun_time*g_flora_curr_dmg_mult[owner],flora_base_stun_speed/g_flora_curr_dmg_mult[owner])
				
				sh_set_rendering(pid, LineColorsWithAlpha[g_flora_dmg_color[owner]][0],
				
									LineColorsWithAlpha[g_flora_dmg_color[owner]][1],
									
									LineColorsWithAlpha[g_flora_dmg_color[owner]][2],
									
									LineColorsWithAlpha[g_flora_dmg_color[owner]][3], 
									kRenderFxGlowShell,
									
									kRenderTransAlpha)
				set_task(flora_stun_time*g_flora_curr_dmg_mult[owner],"remove_glow_task",pid+FLORA_REMOVE_GLOW_TASKID,"", 0,  "a",1)
				flora_heal(owner,fdamage,g_flora_dmg_color[owner])
				
			}
		}
		emit_sound(ent, CHAN_ITEM, FIELD_HUM, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		entity_set_float(ent,EV_FL_nextthink,floatadd(gametime,FLORA_THINK_PERIOD))
		entity_set_float(ent,EV_FL_fuser2,floatsub(entity_get_float(ent,EV_FL_fuser2),FLORA_THINK_PERIOD))
	
	}
	return FMRES_IGNORED
}
uncharge_user(id){
	
	remove_task(id+FLORA_CHARGE_TASKID)
	if(pev_valid(g_flora_curr_charging[id])==2){
		
		
		emit_sound(g_flora_curr_charging[id], CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(g_flora_curr_charging[id], CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		destroy_field(g_flora_curr_charging[id],0,1)
		g_flora_field_loaded[id]=1
		g_flora_curr_charging[id]=-1;
	}
	if ( flora_get_prev_weapon(id) != CSW_KNIFE ){
		shSwitchWeaponID(id, flora_get_prev_weapon(id))
	}
	return 0
	
	
	
}

public remove_glow_task(id){

id-=FLORA_REMOVE_GLOW_TASKID
if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)) return
set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)

}
public load_field(id){
	id-=FLORA_LOAD_TASKID
	
	g_flora_field_loaded[id]=1;	
	sh_chat_message(id,flora_get_hero_id(),"Field loaded");
	
	
}
public charge_task(parm[],id){
	id-=FLORA_CHARGE_TASKID
	new owner= parm[0]
	new field_id=parm[1]
	
	
	if(!client_hittable(owner)||!flora_get_has_flora(owner)){
		return
	}
	
	if(pev_valid(field_id)!=2) {
		return
	}
	
	new test_edict=find_next_nearest_flora_field(owner,field_id,0.0)
	if(is_valid_ent(test_edict)){
		sh_sound_deny(id)
		sh_chat_message(id,flora_get_hero_id(),"This spore is too close to another one of yours! Will not plant.")
		uncharge_user(owner)
		return
	}
	
	if(!(entity_get_int( owner, EV_INT_flags ) & FL_ONGROUND  )){
		
		sh_sound_deny(owner)
		sh_chat_message(owner, flora_get_hero_id(), "Charging stopped. You cannot charge a field while airborne")
		uncharge_user(owner)
		return
		
	}
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(owner, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(owner, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	ENT_SetOrigin(field_id, vOrigin)
	Entvars_Set_Vector(field_id, EV_VEC_angles, vAngles)
	Entvars_Get_Vector(owner, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(field_id, EV_VEC_velocity,  velocity)
	
	// switch to knife
	engclient_cmd(id, "weapon_knife")
	
	new hud_msg[128];
	entity_set_float(field_id,EV_FL_fuser1,floatadd(entity_get_float(field_id,EV_FL_fuser1),FLORA_CHARGE_PERIOD))
	format(hud_msg,127,"[SH] flora: Charging... ^n %0.2f percent done",(entity_get_float(field_id,EV_FL_fuser1)/flora_charge_time)*100.0);
	client_print(id,print_center,"%s",hud_msg)
	
	emit_sound(field_id, CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	if(entity_get_float(field_id,EV_FL_fuser1)>flora_charge_time){
	
		new parm[2]
		parm[0]=owner
		parm[1]=field_id
		field_deploy_task(parm,id+FLORA_DEPLOY_TASKID)
		uncharge_user(owner)
	}
	
	
	
	
	
	
}

public remove_glisten_task(id){

id-=FLORA_UNGLISTEN_TASKID
if(!sh_is_active()||!client_hittable(id)) return

set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
emit_sound(id, CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

}

public flora_glisten(id,heal_color){
	
	
	setScreenFlash(id,LineColors[heal_color][0],LineColors[heal_color][1],LineColors[heal_color][2],3,180)
	glow(id,LineColors[heal_color][0],LineColors[heal_color][1],LineColors[heal_color][2],100,1)
	new color[4];
	color[0]=LineColors[heal_color][0]
	color[1]=LineColors[heal_color][1]
	color[2]=LineColors[heal_color][2]
	color[3]=230
	aura(id,color)
	emit_sound(id, CHAN_VOICE, FIELD_HEAL, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(FLORA_HEAL_GLOW_TIME,"remove_glisten_task",id+FLORA_UNGLISTEN_TASKID,"", 0,  "a",1)	
	
}
public flora_heal(id,Float:damage,color){
	
	new Float: mate_health=float(get_user_health(id))
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	new new_damage= min(floatround(damage), clamp(0,sh_get_max_hp(id)-get_user_health(id)))
	if(new_damage>0){
		if(FLORA_HEAL_GLOWING_ON){
			flora_glisten(id,color)
		}
		else{
			emit_sound(id, CHAN_VOICE, FIELD_HEAL, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			
		}
	}
	new Float: new_health=floatadd(mate_health,float(new_damage))
	set_user_health(id,min(sh_get_max_hp(id),floatround(new_health)))
	return true

}