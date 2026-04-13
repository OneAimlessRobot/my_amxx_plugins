#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt3.inc"
#include "sh_aux_stuff/sh_aux_quick_checks.inc"
#include "sh_aux_stuff/sh_aux_math_funcs_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"


new RADIOACTIVE_TASK_ID
new UNRADIOACTIVE_TASK_ID
new REMOVE_GLOW_TASKID


#define PLUGIN "Superhero aux natives pt3"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


enum{
	
	TRACK_TASK_ATTACKER=0,
	TRACK_TASK_PLAYER_COUNT,
	TRACK_TASK_DO_DAMAGE,
	TRACK_TASK_DAMAGE,
	TRACK_TASK_TRACK_COLOR,
	NUM_INIT_TRACK_PARAMS


	
}

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RADIOACTIVE_TASK_ID=allocate_typed_task_id(player_task)
	UNRADIOACTIVE_TASK_ID=allocate_typed_task_id(player_task)
	REMOVE_GLOW_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_tracked","a")
	prepare_shero_aux_lib_pt3()

    
	
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,  crush_stunned)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
}


				
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt3","_prepare_shero_aux_lib_pt3",0);
	register_native("unradioactive_user","_unradioactive_user",0)
	register_native("explosion","_explosion",0);
	register_native("explosion_custom_entity","_explosion_custom_entity",0);
	register_native("track_user","_track_user",0);
	register_native("sh_damage_display_stock","_sh_damage_display_stock",0)
	register_native("remove_glow_user","_remove_glow_user",0)
	register_native("generic_heal","_generic_heal",0)
	register_native("superhero_protected_hud_message","_superhero_protected_hud_message",0)
}


public _prepare_shero_aux_lib_pt3(iPlugins, iParams){
	
	init_explosion_defaults()
	xs_seed(get_systime(0));
	server_print("Shero lib pt3 innited!^n")
}
//native sh_damage_display_stock(victim, attacker,bool:att_bool=true,bool:vic_bool=true,damage);

public _sh_damage_display_stock(iPlugin,iParams){
	new hud_msg_sync_vic=get_param(1),
		hud_msg_sync_att=get_param(2),
		victim= get_param(3),
		attacker= get_param(4),
		att_bool=get_param(5),
		vic_bool=get_param(6),
		damage=get_param(7);

	if(!is_user_connected(victim)||!is_user_connected(attacker)) return

	if((hud_msg_sync_vic<=0)||(hud_msg_sync_att<=0)) return
	if ( !is_user_connected(victim) || !is_user_connected(attacker) ) return
	if(sh_clients_are_same_team(victim,attacker)) return

	if(!is_user_bot(attacker)){
		if ( att_bool&&(attacker!=victim)) {
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(attacker,hud_msg_sync_att, "%d", damage)
		}
	}

	
	if(!is_user_bot(victim)){
		if ( vic_bool) {
			set_hudmessage(200, 0, 0, -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(victim, hud_msg_sync_vic, "%d", damage)
		}
	}
}

public track_task(array[],id){
	id-=RADIOACTIVE_TASK_ID
	if(!client_hittable(id)){
		
		unradioactive_user(id);
		return
	}
	if(client_hittable(array[TRACK_TASK_ATTACKER])){
		new client_name[128]
		new origin[3], eorigin[3],att_origin[3]
		new Float:Pos[3],Float:vEnd[3]
		new color_const=array[TRACK_TASK_TRACK_COLOR]
		get_user_name(id,client_name,127)
		
		get_user_origin(id, eorigin)
		get_user_origin(array[TRACK_TASK_ATTACKER], origin)
		get_user_origin(array[TRACK_TASK_ATTACKER], att_origin)			
		
		detect_user(array[TRACK_TASK_ATTACKER],id,vEnd);
		IVecFVec(origin,Pos)
		IVecFVec(eorigin,vEnd)
		new color_const_arr[3];
		for(new i=0;i<sizeof color_const_arr;i++){

			color_const_arr[i]=color_const
		}
		laser_line(array[TRACK_TASK_ATTACKER],Pos,vEnd,true,color_const_arr,true)
		for(new i=0;i<array[1];i++){
			if(!client_hittable(array[i+NUM_INIT_TRACK_PARAMS])){
			
				continue
			}
			get_user_origin(array[i+NUM_INIT_TRACK_PARAMS], origin)
			
			detect_user(array[i+NUM_INIT_TRACK_PARAMS],id,vEnd);
			IVecFVec(origin,Pos)
			laser_line(array[i+NUM_INIT_TRACK_PARAMS],Pos,vEnd,true,color_const_arr,true)
			
		}
		sh_set_rendering(id, LineColors[color_const][0],  LineColors[color_const][1], LineColors[color_const][2], 255,kRenderFxGlowShell, kRenderTransAlpha)
		sh_screen_fade(id, 0.1, 0.9, LineColors[color_const][0], LineColors[color_const][1], LineColors[color_const][2],  50)
		aura(id,LineColors[color_const])
		if(array[TRACK_TASK_DO_DAMAGE]){
			sh_extra_damage(id,array[TRACK_TASK_ATTACKER],array[TRACK_TASK_DAMAGE],
							new_dmg_type_names[_:SH_NEW_DMG_RADIATION_POISON],
							_,_,_,_,_,_,
							SH_NEW_DMG_RADIATION_POISON,
							get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_RADIATION_POISON))
		}
	}
	else{

		unradioactive_user(id);
	}
}


public _track_user(iPlugins, iParams){

	new id=get_param(1),
		attacker=get_param(2),
		do_damage=get_param(3),
		damage=get_param(4),
		Float:period=get_param_f(5),
		Float:time=get_param_f(6),
		track_color=get_param(7)

	
	if(!is_user_connected(id)||!is_user_connected(attacker)) return 

	new  radioactive_times=floatround(time/period)
	new players[SH_MAXSLOTS]
	new team_name[32]
	new player_count;
	gatling_set_fx_num(id, RADIOACTIVE)
	
	set_damage_icon(id,2,DMG_ICON_RADIATION,LineColors[track_color])

	get_user_team(attacker,team_name,32)
	get_players(players,player_count,"eah",team_name)

	new array[NUM_INIT_TRACK_PARAMS+SH_MAXSLOTS+1]
	arrayset(array,-1,sizeof array)
	array[TRACK_TASK_ATTACKER] = attacker
	array[TRACK_TASK_PLAYER_COUNT] = player_count
	array[TRACK_TASK_DO_DAMAGE] = do_damage
	array[TRACK_TASK_DAMAGE] = damage
	array[TRACK_TASK_TRACK_COLOR] = track_color
	for(new i=0;i<player_count;i++){
		
		if(client_hittable(players[i])){
			array[NUM_INIT_TRACK_PARAMS+i]=players[i]
		}
	}
	set_task(period,"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array),  "a",radioactive_times)
	set_task(floatsub(time,0.1),"unradioactive_task",id+UNRADIOACTIVE_TASK_ID,"", 0,  "a",1)



}
public _unradioactive_user(iPlugin,iParams){
	new id=get_param(1)
	remove_task(id+UNRADIOACTIVE_TASK_ID)
	unradioactive_task(id+UNRADIOACTIVE_TASK_ID)

}

public unradioactive_task(id){
	id-=UNRADIOACTIVE_TASK_ID
	remove_task(id+RADIOACTIVE_TASK_ID)
	if(is_user_connected(id)){
		set_user_rendering(id)
		set_damage_icon(id,0,DMG_ICON_RADIATION)
		gatling_set_fx_num(id, 0)
	}



}
public _explosion(iPlugins,iParams){


	new hero_id=get_param(1),
		ent_id=get_param(2),
		Float:explosion_radius=get_param_f(3),
		Float:peak_power=get_param_f(4),
		Float:optional_force=get_param_f(5),
		ignore_owner=get_param(6),
		set_stun=get_param(7),
		Float:damage_frac_ignore_owner=get_param_f(8),
		bool:use_fx=bool:get_param(9),
		sh_custom_color:fx_color=sh_custom_color:get_param(10),
		bool:use_sound=bool:get_param(11)

	new custom_sound_sample[128]

	get_string(12,custom_sound_sample,(sizeof custom_sound_sample)-1)

	if((pev_valid(ent_id)!=2)){

		return 

	}
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);

	if(use_fx){
		explode_fx(iOrigin,floatround(explosion_radius),fx_color)
		if(use_sound){
			emit_sound(ent_id, CHAN_VOICE, custom_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	new owner_id=((is_user_connected(ent_id))?ent_id:pev(ent_id,pev_owner))

	new CsTeams:idTeam = cs_get_user_team(owner_id)
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		if(!client_hittable(pid)){
			continue
		
		}
		sh_screen_shake(pid,10.0,3.0,10.0)
		if(pid!=owner_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
		}
		damage_player(hero_id,ent_id,owner_id,pid,explosion_radius,peak_power,ignore_owner,optional_force,set_stun,damage_frac_ignore_owner)

	}
}
public _explosion_custom_entity(iPlugins,iParams){

	new ent_classname[128]

	get_string(4,ent_classname,128)

	new ent_id=get_param(1),
		Float:explosion_radius=get_param_f(2),
		Float:peak_power=get_param_f(3),
		Float:optional_force=get_param_f(5),
		bool:use_fx=bool:get_param(6),
		sh_custom_color:fx_color=sh_custom_color:get_param(7),
		bool:use_sound=bool:get_param(8)

	new custom_sound_sample[128]

	get_string(9,custom_sound_sample,(sizeof custom_sound_sample)-1)

	if((pev_valid(ent_id)!=2)){

		return 

	}

	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);

	if(use_fx){
		explode_fx(iOrigin,floatround(explosion_radius),fx_color)
		if(use_sound){
			emit_sound(ent_id, CHAN_VOICE, custom_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	emit_sound(ent_id, CHAN_VOICE, crush_stunned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new entlist[33];
	new numfound = find_sphere_class(ent_id,ent_classname, explosion_radius ,entlist, 32);

	new owner_id=pev(ent_id,pev_owner)
	for (new i=0; i < numfound; i++)
	{		
		new eid = entlist[i];
		
		if(!is_valid_ent(eid)){
			
			continue;
		}
		if(pev_valid(eid)!=2){
			continue
		
		}
		damage_entity(ent_id,owner_id,eid,explosion_radius,peak_power,_,optional_force)
	}
}
stock damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0,set_stun=0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER){
	
	
	if((pev_valid(ent_id)!=2)){
	
		return 
	
	}
	if(!is_user_connected(owner_id)){
	
		return 
	
	}
	if(!is_user_connected(pid)){
	
		return 
	
	}
	if(is_user_connected(pid)&&(pid==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		else{

			peak_power=peak_power*damage_frac_ignore_owner
		}
		
		
	
	}

	static client_name[128];
	static attacker_name[128];
	get_user_name(pid,client_name,127);
	get_user_name(owner_id,attacker_name,127);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(pid,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	new Float:distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= floatmin(1.0,distance/radius);
	new Float:force,Float:damage,idamage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	idamage=floatround(damage)
	if(optional_force!=0.0){
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}

	sh_extra_damage(pid,owner_id,idamage,new_dmg_type_names[_:SH_NEW_DMG_FRAG_BLAST],0,_,_,_,_,_,
			SH_NEW_DMG_FRAG_BLAST,
			get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FRAG_BLAST))
	
	set_velocity_from_origin(pid,mine_origin,force)

	if(set_stun){
		sh_set_stun(pid,3.0,default_stun_speed)
	}
	sh_screen_shake(pid,10.0,3.0,10.0)
	unfade_screen_user(pid)
	sh_chat_message(owner_id,hero_id,"%s was shattered by you!",client_name);
	sh_chat_message(pid,hero_id,"%s shattered you!",attacker_name);
}
stock damage_entity(ent_id,owner_id,tg_id,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0){


	if((pev_valid(ent_id)!=2)||(pev_valid(tg_id)!=2)){
	
		return 
	
	}
	
	if(is_user_connected(tg_id)&&(tg_id==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		
		
	
	}
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(tg_id,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	new Float:distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= floatmin(1.0,distance/radius);
	new Float:force,Float:damage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	if(optional_force!=0.0){
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}
	new this_ent_owner = entity_get_edict(tg_id, EV_ENT_owner)
	if(client_hittable(this_ent_owner)){
		ExecuteHam(Ham_TakeDamage, tg_id, ent_id, owner_id, damage, 0);
	}
	if(!is_valid_ent(tg_id)){
		
		return;
	}
	if(pev_valid(tg_id)!=2){
		
		return
	
	}
	set_velocity_from_origin(tg_id,mine_origin,force)
	
}

public on_death_tracked()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		unradioactive_user(id)
	
	}
	
}
public _remove_glow_user(iPlugin,iParams){
	new id=get_param(1)
	new Float:delay=get_param_f(2)

	set_task(delay,"remove_glow_task",id+REMOVE_GLOW_TASKID,"", 0,  "a",1)
				

}
public remove_glow_task(id){

id-=REMOVE_GLOW_TASKID
if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)){
	return
}
set_user_rendering(id)

}

public bool:_generic_heal(iPlugins, iParms){
	new hud_msg_sync=get_param(1),
		id= get_param(2),
		Float:added_hp=get_param_f(3),
		max_hp_to_clamp=get_param(4),
		color_const=get_param(5),
		user_will_glow=get_param(6),
		Float:glow_remove_timer=get_param_f(7),
		hud_alpha=get_param(8),
		hud_will_glow=get_param(9),
		make_sound=get_param(10),
		Float: mate_health=float(get_user_health(id))

	
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	if((max_hp_to_clamp>0)&&((max_hp_to_clamp)<=mate_health)){
		return false
	
	}
	if(sh_user_has_hero(id,shinobu_get_hero_id())&&(floatround(mate_health)>=shinobu_get_max_hp())){

		return false
	}
	if(make_sound){

		static sound_sample_string[128]

		get_string(11,sound_sample_string,127)
		emit_sound(id, CHAN_STATIC, sound_sample_string, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	new Float: new_health=floatadd(mate_health,added_hp)
	set_user_health(id,min((max_hp_to_clamp>0)?max_hp_to_clamp:sh_get_max_hp(id),floatround(new_health)))
	set_render_with_color_const(id,color_const,user_will_glow,_,hud_alpha,hud_will_glow)
	if(user_will_glow>0){
		remove_glow_user(id,glow_remove_timer)
	}
	if(hud_msg_sync>0){
		
		set_hudmessage(LineColors[color_const][0], LineColors[color_const][1], LineColors[color_const][2], -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(id, hud_msg_sync, "%0.2f", added_hp)
	
	}
	return true

}

public _superhero_protected_hud_message(iPlugin,iParams){

	new hud_msg_sync=get_param(1),
		id= get_param(2),
		r=get_param(5),
		g=get_param(6),
		b=get_param(7),
		Float:param1=get_param_f(8),
		Float:param2=get_param_f(9),
		param3=get_param(10),
		Float:param4=get_param_f(11),
		Float:param5=get_param_f(12),
		Float:param6=get_param_f(13),
		Float:param7=get_param_f(14)

	
	if(hud_msg_sync<=0){

		return
	}
	static message_text[SH_HUD_MSG_BUFF_SIZE+1],
		string[SH_HUD_MSG_BUFF_SIZE+1]
	
	get_string(3,message_text,SH_HUD_MSG_BUFF_SIZE)
	get_string(4,string,SH_HUD_MSG_BUFF_SIZE)

	if(is_user_connected(id)&&!is_user_bot(id)){
		
		set_hudmessage(r,g,b,param1,param2,param3,param4,param5,param6,param7)
		if(strlen(string)){
			ShowSyncHudMsg(id,hud_msg_sync,message_text,string)
		}
		else{

			ShowSyncHudMsg(id,hud_msg_sync,message_text)
		}
	}

}