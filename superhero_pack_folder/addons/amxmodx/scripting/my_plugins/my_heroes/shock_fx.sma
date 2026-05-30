#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"


#define PLUGIN "Superhero co2 fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNSHOCK_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNSHOCK_TASKID=allocate_typed_task_id(player_task)

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	unshock_user(id)

}

public plugin_natives(){
	
	register_native("sh_shock_user","_sh_shock_user");
	register_native("sh_unshock_user","_sh_unshock_user");
}
public _sh_shock_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!sh_get_id_bit(user,SH_IS_SHOCKED)){
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

	unshock_user(id)
	
}
shock_user(id){
	
	if(!sh_is_active()||!is_user_alive(id)||sh_get_id_bit(id,SH_IS_SHOCKED)) return


	emit_sound(id, CHAN_WEAPON,SHOCK_GRENADE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)


	sh_unsleep_user(id)
	sh_set_stun(id,SHOCK_TIME,180.0)

	set_render_with_color_const(id,LTBLUE,1,50,50,1,1,SHOCK_TIME)


	sh_assign_id_bit(id,SH_IS_SHOCKED,true)

	static entlist[33];
	new numfound = find_sphere_class(id,"player",SHOCK_RADIUS, entlist ,charsmax(entlist));

	for( new i= 0;(i< numfound);i++){

		new pid = entlist[i];
		
		if( !is_user_alive(pid) ) continue
		
		if( sh_get_id_bit(pid,SH_IS_SHOCKED)) continue
		
		shock_user(pid)
	}

	set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[LTBLUE])
	set_task(SHOCK_TIME,"unshock_task",id+UNSHOCK_TASKID)

	
	
}
public unshock_user(id){
	
	if ( !sh_is_active() ||!is_user_connected(id)) return


	if(sh_get_id_bit(id,SH_IS_SHOCKED)){
		sh_set_rendering(id)
		set_damage_icon(id,0,DMG_ICON_SHOCK)
		sh_assign_id_bit(id,SH_IS_SHOCKED,false)
	}
	
	
}

public sh_client_death(id){
	
	unshock_user(id)
	
}