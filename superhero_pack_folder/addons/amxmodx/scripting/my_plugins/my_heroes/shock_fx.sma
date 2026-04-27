#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define PLUGIN "Superhero co2 fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNSHOCK_TASKID
new is_shock_mask=0

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNSHOCK_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_shock","a")
	register_event("ResetHUD","stun_newround","b")

}

//----------------------------------------------------------------------------------------------
public stun_newround(id)
{	
	if(sh_is_active()&&client_hittable(id)){
		if(Get_BitVar(is_shock_mask,id)){
			sh_unshock_user(id)
		}

	}
	
}

public plugin_natives(){
	
	register_native("sh_shock_user","_sh_shock_user",0);
	register_native("sh_unshock_user","_sh_unshock_user",0);
	register_native("sh_get_user_is_shocked","_sh_get_user_is_shocked",0);
}
public _sh_get_user_is_shocked(iPlugin,iParams){
	new id= get_param(1);
	return Get_BitVar(is_shock_mask,id)

}
public _sh_shock_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!Get_BitVar(is_shock_mask,user)){
		shock_user(user)
	}
	
	
	
}
public plugin_precache(){
	engfunc(EngFunc_PrecacheSound,SHOCK_GRENADE_SOUND)
}

public _sh_unshock_user(iPlugin,iParams){
	
	new user=get_param(1)
	unshock_user(user)
	
	
	
	
}
public unshock_task(id){
	id-=UNSHOCK_TASKID
	
	if(!sh_is_active()||!is_user_connected(id)){
		
		return
	}
	unshock_user(id)
	
}
shock_user(id){
	
    if(!sh_is_active()||!client_hittable(id)) return


    emit_sound(id, CHAN_WEAPON,SHOCK_GRENADE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

    static entlist[33];
    new numfound = find_sphere_class(id,"player",SHOCK_RADIUS, entlist ,charsmax(entlist));

    for( new i= 0;(i< numfound);i++){

        new pid = entlist[i];
        
        if( !client_hittable(pid) ) continue
        
        if( Get_BitVar(is_shock_mask, pid)) continue
        
        shock_user(pid)
    }


    sh_unsleep_user(id)
    sh_set_stun(id,SHOCK_TIME,180.0)

    set_render_with_color_const(id,LTBLUE,1,50,50,1,1)

    remove_glow_user(id,SHOCK_TIME)


    Set_BitVar(is_shock_mask,id)

    set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[LTBLUE])
    set_task(SHOCK_TIME,"unshock_task",id+UNSHOCK_TASKID)
	
	
	
}
public unshock_user(id){
	
	sh_set_rendering(id)
	UnSet_BitVar(is_shock_mask,id)
	set_damage_icon(id,0,DMG_ICON_SHOCK)
	
	
	
}

public on_death_shock()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unshock_user(id)
	
	}
	
}