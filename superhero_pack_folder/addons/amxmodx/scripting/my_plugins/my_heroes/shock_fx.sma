#define I_WANT_CONSTANTS
#define I_WANT_BASIC_MACROS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "Superhero shock fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNSHOCK_TASKID = -1
new generic_dmg_source_shock = -1
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNSHOCK_TASKID=allocate_typed_task_id(player_task)

}
public plugin_cfg(){

	generic_dmg_source_shock = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_SHOCK)
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

	new user=get_param(1),
		attacker = get_param(2),
		Float:the_time = get_param_f(3),
		bool:should_spread = bool:get_param(4),
		Float:shock_damage_to_do = get_param_f(5),
		Float:spread_radius = get_param_f(6),
		bool:spread_to_og_shocker = bool:get_param(7),
		custom_weapon_id = get_param(8)

	custom_weapon_id = ((custom_weapon_id<0)?generic_dmg_source_shock:custom_weapon_id)


	if(!sh_get_id_bit(user,SH_IS_SHOCKED)){
		shock_user(user,attacker,the_time,should_spread,shock_damage_to_do, spread_radius, spread_to_og_shocker,custom_weapon_id)
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
shock_user(id,attacker, Float:the_time, bool:should_spread, Float:damage_to_do, Float:spread_radius, bool:spread_to_og_shocker, custom_weapon_id, bool:played_sound = false ){
	
	if(!sh_is_active()||!is_user_alive(id)||sh_get_id_bit(id,SH_IS_SHOCKED)||!is_user_connected(attacker)) return

	if(!played_sound){
		emit_sound(id, CHAN_WEAPON,SHOCK_GRENADE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		played_sound = true
	}
	new bool:user_is_lightning_rod = sh_get_player_has_hero_prop(id, SH_LIGHTNING_ROD_HERO)
	
	if(floatround(damage_to_do) > 0){
		sh_extra_damage(id,attacker,floatround(damage_to_do),
						_,
						SH_DMG_NORM,
						_,_,_,
						SH_NEW_DMG_SHOCK,
						custom_weapon_id)
	}

	
	
	if(user_is_lightning_rod){
		return
	}
	if(sh_get_id_bit(id,SH_IS_SLEEPING)){
		sh_unsleep_user(id)
	}

	sh_set_stun(id,the_time,180.0)
	
	set_render_with_color_const(id,LTBLUE,1,50,50,1,1,the_time,_,_,kRenderNormal,PRIO_RENDER_DELETE_INVISIBILITY)


	sh_assign_id_bit(id,SH_IS_SHOCKED,true)
	static two_fifty_five = 255 //annoying ass redundant expression warning
	if(should_spread){

		static entlist[33];
		new numfound = find_sphere_class(id,"player",spread_radius, entlist ,charsmax(entlist));

		for( new i= 0;(i< numfound);i++){

			new pid = entlist[i];
			
			if( !is_user_alive(pid) ) continue

			if( (pid == attacker) && !spread_to_og_shocker) continue
			
			if( sh_get_id_bit(pid,SH_IS_SHOCKED)) continue

			directed_spark(id, pid,clamp_macro(floatround(damage_to_do),23,two_fifty_five),60,200,50,LTBLUE,24,0)
			shock_user(pid,attacker,the_time,should_spread,damage_to_do,spread_radius, spread_to_og_shocker, custom_weapon_id, played_sound)
		}
	}

	set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[LTBLUE])
	set_task(the_time,"unshock_task",id+UNSHOCK_TASKID)

	
	
}
unshock_user(id){
	
	if ( !sh_is_active() ||!is_user_connected(id)) return

	remove_task(id+UNSHOCK_TASKID)
	if(sh_get_id_bit(id,SH_IS_SHOCKED)){
		remove_glow_user(id,PRIO_RENDER_DELETE_INVISIBILITY,_,kRenderNormal)
		set_damage_icon(id,0,DMG_ICON_SHOCK)
		sh_assign_id_bit(id,SH_IS_SHOCKED,false)
	}
	
	
}

public sh_client_death(id){
	
	unshock_user(id)
	
}