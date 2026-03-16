#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_consts.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt3.inc"
#include "sh_aux_stuff/sh_aux_quick_checks.inc"
#include "sh_aux_stuff/sh_aux_math_funcs_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
/*

//#include "sh_aux_stuff/sh_aux_fx_natives_const_pt2.inc"
	#include "sh_aux_stuff/sh_aux_fx_funcs_pt1.inc"
	#include "sh_aux_stuff/sh_aux_fx_funcs_pt2.inc"
*/


new RADIOACTIVE_TASK_ID
new UNRADIOACTIVE_TASK_ID


#define PLUGIN "Superhero aux natives"
#define VERSION "1.0.0"
#define AUTHOR "ThrashBrat"
#define Struct				enum

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RADIOACTIVE_TASK_ID=allocate_typed_task_id(player_task)
	UNRADIOACTIVE_TASK_ID=allocate_typed_task_id(player_task)
	prepare_shero_aux_lib_pt3()

    
	
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,  crush_stunned)
}
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt3","_prepare_shero_aux_lib_pt3",0);
	register_native("unradioactive_user","_unradioactive_user",0)
	register_native("explosion_player","_explosion_player",0);
	register_native("explosion","_explosion",0);
	register_native("explosion_custom_entity","_explosion_custom_entity",0);
	register_native("track_user","_track_user",0);
	register_native("sh_damage_display_stock","_sh_damage_display_stock",0)
}


public _prepare_shero_aux_lib_pt3(iPlugins, iParams){
	
	attacker_dmg_hud_msg_sync=CreateHudSyncObj()
	victim_dmg_hud_msg_sync=CreateHudSyncObj()
	xs_seed(get_systime(0));
	server_print("Shero lib pt3 innited!^n")
}
//native sh_damage_display_stock(victim, attacker,bool:att_bool=true,bool:vic_bool=true,damage);

public _sh_damage_display_stock(iPlugin,iParams){
	new victim= get_param(1),
		attacker= get_param(2),
		att_bool=get_param(3),
		vic_bool=get_param(4),
		damage=get_param(5);

	if ( !is_user_connected(victim) || !is_user_connected(attacker) ) return
	if(sh_clients_are_same_team(victim,attacker)) return

	if(!is_user_bot(attacker)){
		if ( att_bool&&(attacker!=victim)) {
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(attacker, attacker_dmg_hud_msg_sync, "%d", damage)
		}
	}

	
	if(!is_user_bot(victim)){
		if ( vic_bool) {
			set_hudmessage(200, 0, 0, -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(victim, victim_dmg_hud_msg_sync, "%d", damage)
		}
	}
}

public track_task(array[],id){
	id-=RADIOACTIVE_TASK_ID
	if(!client_hittable(id)){
		
		unradioactive_user(id);
		return
	}
	new hud_msg[256]
	new client_name[128]
	new distance, origin[3], eorigin[3],att_origin[3]
	new Float:Pos[3],Float:vEnd[3]
	get_user_name(id,client_name,127)
	
	get_user_origin(id, eorigin)
	get_user_origin(array[0], origin)
	get_user_origin(array[0], att_origin)
			
	distance = get_distance(eorigin, origin)
	format(hud_msg,256,"%s.^nDistance: %d^n",client_name,distance);
	set_hudmessage(LineColorsWithAlpha[ORANGE][0], LineColorsWithAlpha[ORANGE][1], LineColorsWithAlpha[ORANGE][2],  0.0, 0.2, 0, 0.0, 1.0)
	ShowSyncHudMsg(array[0],array[1],"%s", hud_msg)
	detect_user(array[0],id,vEnd);
	IVecFVec(origin,Pos)
	IVecFVec(eorigin,vEnd)
	laser_line(array[0],Pos,vEnd,true,{LTBLUE,LTBLUE,LTBLUE},true)
	for(new i=0;i<array[2];i++){
		if(!client_hittable(array[i+5])){
		
			continue
		}
		get_user_origin(array[i+5], origin)
			
		distance = get_distance(eorigin, origin)
		format(hud_msg,127,"%s.^nDistance: %d^n",client_name,distance);
		ShowSyncHudMsg(array[i+5],array[1], "%s", hud_msg)
		detect_user(array[i+5],id,vEnd);
		IVecFVec(origin,Pos)
		laser_line(array[i+5],Pos,vEnd,true,{LTBLUE,LTBLUE,LTBLUE},true)
		
	}
	sh_set_rendering(id, tag_color[0],  tag_color[1], tag_color[2], tag_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, tag_color[0], tag_color[1], tag_color[2],  50)
	new the_fucking_argument[4];
	copy(the_fucking_argument,4,tag_color)
	aura(id,the_fucking_argument)
	if(array[3]){
		sh_extra_damage(id,array[0],array[4],"SH_TRACKING",0,SH_DMG_NORM)
	}
	
}


public _track_user(iPlugins, iParams){

    new id=get_param(1),
        attacker=get_param(2),
        do_damage=get_param(3),
        damage=get_param(4),
        Float:period=get_param_f(5),
        Float:time=get_param_f(6)

    new  radioactive_times=floatround(time/period)
    new players[SH_MAXSLOTS]
    new team_name[32]
    new client_name[128]
    new enemy_name[128]
    new player_count;

    get_user_name(id,enemy_name,127)
    get_user_name(attacker,client_name,127)

    get_user_team(attacker,team_name,32)
    get_players(players,player_count,"eah",team_name)

    new array[5+SH_MAXSLOTS+1]
    arrayset(array,-1,sizeof array)
    array[0] = attacker
    array[1] = CreateHudSyncObj()
    array[2] = player_count
    array[3] = do_damage
    array[4] = damage
    for(new i=0;i<player_count;i++){
        
        if(client_hittable(players[i])){
            array[5+i]=players[i]
        }
    }
    set_task(period,"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array),  "a",radioactive_times)
    set_task(floatsub(floatmul(period,float(radioactive_times)),0.1),"unradioactive_task",id+UNRADIOACTIVE_TASK_ID,"", 0,  "a",1)
    return 0



}
public _unradioactive_user(iPlugin,iParams){
    new id=get_param(1)
    remove_task(id+UNRADIOACTIVE_TASK_ID)
    remove_task(id+RADIOACTIVE_TASK_ID)
    if(client_hittable(id)){
        set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
    }
    return 0



}

public unradioactive_task(id){
	id-=UNRADIOACTIVE_TASK_ID
	remove_task(id+RADIOACTIVE_TASK_ID)
	if(client_hittable(id)){
		set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	}
	return 0



}
public _explosion_player(iPlugins,iParams){
	

    new hero_id=get_param(1),
        ent_id=get_param(2),
        Float:explosion_radius=get_param_f(3),
        Float:peak_power=get_param_f(4),
        Float:optional_force=get_param_f(5),
        ignore_owner=get_param(6),
        set_stun=get_param(7),
        Float:upward_shift=get_param_f(8),
        Float:damage_frac_ignore_owner=get_param_f(9)

    if(!is_user_connected(ent_id)){
        return

    }
    new Float:fOrigin[3];
    entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

    new iOrigin[3];
    for(new i=0;i<3;i++)
        iOrigin[i] = floatround(fOrigin[i]);

    explode_fx(iOrigin,floatround(explosion_radius))

    new entlist[33];
    new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);

    new CsTeams:idTeam = cs_get_user_team(ent_id)
        
    for (new i=0; i < numfound; i++)
    {	
            
        new pid = entlist[i];
        
        if(!client_hittable(pid)){
            continue
        
        }
        sh_screen_shake(pid,10.0,3.0,10.0)
        if(pid!=ent_id){
            if(cs_get_user_team(pid)==idTeam){
                continue
            }
        }
        damage_player(hero_id,ent_id,ent_id,pid,explosion_radius,peak_power,ignore_owner,optional_force,set_stun,upward_shift,damage_frac_ignore_owner)
        
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
        Float:upward_shift=get_param_f(8),
        Float:damage_frac_ignore_owner=get_param_f(9)

    if((pev_valid(ent_id)!=2)){

        return 

    }

    new Float:fOrigin[3];
    entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

    new iOrigin[3];
    for(new i=0;i<3;i++)
        iOrigin[i] = floatround(fOrigin[i]);

    explode_fx(iOrigin,floatround(explosion_radius))

    new entlist[33];
    new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);

    new owner_id=pev(ent_id,pev_owner)
    new name_of_player[128];
    get_user_name(owner_id,name_of_player,127)
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
        damage_player(hero_id,ent_id,owner_id,pid,explosion_radius,peak_power,ignore_owner,optional_force,set_stun,upward_shift,damage_frac_ignore_owner)

    }
}
public _explosion_custom_entity(iPlugins,iParams){

    new ent_classname[128]

    get_string(4,ent_classname,128)

    new ent_id=get_param(1),
        Float:explosion_radius=get_param_f(2),
        Float:peak_power=get_param_f(3),
        Float:optional_force=get_param_f(5),
        Float:upward_shift=get_param_f(6);

    if((pev_valid(ent_id)!=2)){

        return 

    }

    new Float:fOrigin[3];
    entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

    new iOrigin[3];
    for(new i=0;i<3;i++)
        iOrigin[i] = floatround(fOrigin[i]);

    explode_fx(iOrigin,floatround(explosion_radius))

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
        damage_entity(ent_id,owner_id,eid,explosion_radius,peak_power,_,optional_force,upward_shift)
    }
}
stock damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0,set_stun=0,Float:upward_shift=1.0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER){
	
	
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
	
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	new parm[5]
	
	Entvars_Get_Vector(pid, EV_VEC_origin, vOrig)
	Entvars_Get_Vector(ent_id, EV_VEC_origin, usOrig)
	
	Entvars_Get_Vector(ent_id, EV_VEC_velocity, b_vel)
	
	new Float:distance=get_distance_f(vOrig,usOrig);
	new client_name[128];
	new attacker_name[128];
	get_user_name(pid,client_name,127);
	get_user_name(owner_id,attacker_name,127);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(pid,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	distance=vector_distance(vic_origin,mine_origin);
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
	sh_extra_damage(pid,owner_id,idamage,"SH_Explosion");
	
	b_vel[0]=((vOrig[0] -usOrig[0]) )*force
	b_vel[1]=((vOrig[1] -usOrig[1]) )*force
	b_vel[2]=((vOrig[2] -usOrig[2]) )*force
	
		
	parm[0] = floatround(b_vel[0])
	parm[1] = floatround(b_vel[1])
	parm[2] = floatround(b_vel[2])
	parm[3] = pid
	parm[4] = floatround(upward_shift)
	move_enemy(parm)
	if(set_stun){
		sh_set_stun(pid,3.0,0.5)
	}
	sh_screen_shake(pid,10.0,3.0,10.0)
	unfade_screen_user(pid)
	emit_sound(pid, CHAN_VOICE, crush_stunned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	sh_chat_message(owner_id,hero_id,"%s was shattered by you!",client_name);
	sh_chat_message(pid,hero_id,"%s shattered you!",attacker_name);
}
stock damage_entity(ent_id,owner_id,tg_id,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0,Float:upward_shift=1.0){


	if((pev_valid(ent_id)!=2)||(pev_valid(tg_id)!=2)){
	
		return 
	
	}
	
	if(is_user_connected(tg_id)&&(tg_id==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		
		
	
	}
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	new parm[5]
	
	Entvars_Get_Vector(tg_id, EV_VEC_origin, vOrig)
	Entvars_Get_Vector(ent_id, EV_VEC_origin, usOrig)
	
	Entvars_Get_Vector(ent_id, EV_VEC_velocity, b_vel)
	
	new Float:distance=get_distance_f(vOrig,usOrig);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(tg_id,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	distance=vector_distance(vic_origin,mine_origin);
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
	new this_ent_owner = entity_get_edict(tg_id, EV_ENT_owner)
	if(client_hittable(this_ent_owner)){
		ExecuteHam(Ham_TakeDamage, tg_id, ent_id, owner_id, float(idamage), 0);
	}
	if(!is_valid_ent(tg_id)){
		
		return;
	}
	if(pev_valid(tg_id)!=2){
		
		return
	
	}
	b_vel[0]=((vOrig[0] -usOrig[0]) )*force
	b_vel[1]=((vOrig[1] -usOrig[1]) )*force
	b_vel[2]=((vOrig[2] -usOrig[2]) )*force
	
		
	parm[0] = floatround(b_vel[0])
	parm[1] = floatround(b_vel[1])
	parm[2] = floatround(b_vel[2])
	parm[3] = tg_id
	parm[4] = floatround(upward_shift)
	move_entity(parm)
}
