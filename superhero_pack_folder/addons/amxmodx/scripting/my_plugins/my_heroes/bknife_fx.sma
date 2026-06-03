#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include <float>
#include <xs>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "freeze_fx/freeze_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "Superhero bleed fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

enum bleed_alpha_type{
  hud_alpha,
  render_alpha
}
enum bleed_task_parameter_id{
	Float:bleed_task_period,
	Float:bleed_task_time,
	Float:bleed_type_damage_pct,
	bleed_task_repeats,
	bleed_task_apply_id,
	bleed_type_name[128],
	bleed_type_alphas[bleed_alpha_type]
}
stock bleed_task_parameters[fx_bleed_type][bleed_task_parameter_id]={	
					{-1.0,5.0,0.0,0,-1,"no bleeding",{0,0}},
					{1.0,5.0,0.01,0,-1,"mini bleeding",{50,255}},
					{1.0,5.0,0.04,0,-1,"bleeding",{75,255}},
					{0.25,5.0,0.04,0,-1,"ultrableeding",{120,255}}

}

new dmg_source_name_short_shanking[SAFE_BUFFER_SIZE+1]="shanking"
new dmg_source_name_log_shanking[SAFE_BUFFER_SIZE+1]="shanking"
new custom_dmg_id_shanking = -1,
	custom_dmg_id_bleeding = -1

public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);

for(new fx_bleed_type:i=BLEED_MINI;i<fx_bleed_type;i++){
	
	bleed_task_parameters[i][bleed_task_apply_id]=allocate_typed_task_id(player_task)
	static Float:the_period;
	the_period=bleed_task_parameters[i][bleed_task_period]
	static Float:the_time;
	the_time=bleed_task_parameters[i][bleed_task_time]
	bleed_task_parameters[i][bleed_task_repeats]=floatround(floatdiv(the_time,the_period))
}

custom_dmg_id_shanking=sh_log_custom_damage_source(-1,
				dmg_source_name_short_shanking,
				dmg_source_name_log_shanking,
				0)

init_hud_syncs()

}
public plugin_cfg(){

	custom_dmg_id_bleeding = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_BLEED)
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unbleed_user(id)
	}
	
}
public plugin_natives(){


	register_native("sh_bleed_user","_sh_bleed_user");
	register_native("sh_unbleed_user","_sh_unbleed_user");
	register_native("do_bleed_knife_attack","_do_bleed_knife_attack")

}
public _do_bleed_knife_attack(iPlugin,iParam){

new id= get_param(1)
new attacker= get_param(2)
new hero_id= get_param(3)
new slash_damage=get_param(4)
new stab_damage=get_param(5)
new optional_bool=get_param(6)
new custom_wpn_id=get_param(7)
new attack_name_string[128]
get_string(8,attack_name_string,127)
new blood_sound_sample[128]
get_string(9,blood_sound_sample,127)
new heal_attacker=get_param(10)
new my_hitpoint_enum:the_hitpoint= my_hitpoint_enum:get_param(11)

if(!is_user_alive(attacker)||!is_user_alive(id)) return HAM_IGNORED

new weapon=get_user_weapon(attacker)

if(optional_bool&&!(sh_clients_are_same_team(id,attacker))&&(attacker!=id)){

	if(weapon==CSW_KNIFE){
		emit_sound(attacker, CHAN_WEAPON, blood_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new button = pev(attacker, pev_button);
		new bool:slashing;
		new bool:stabbing;
		if(button & IN_ATTACK2){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
			slashing=false
		}
		if(button & IN_ATTACK){
			
			button &= ~IN_ATTACK;
			stabbing=false;
			slashing=true
		}
		new Float: vec2LOS[2];
		new Float: vecForward[3];
		new Float: vecForward2D[2];
	
		velocity_by_aim( attacker, 1, vecForward );
      
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
    
		velocity_by_aim(id, 1, vecForward ); 
        
		xs_vec_make2d( vecForward, vecForward2D );
		new damage=(stabbing?stab_damage:slash_damage)
		if(stabbing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.8) )
			{
				sh_bleed_user(id,attacker,BLEED_ULTRA,hero_id,heal_attacker,the_hitpoint)
				damage=damage*4;
			}
			else{
				sh_bleed_user(id,attacker,BLEED_NORMAL,hero_id,heal_attacker,the_hitpoint)
			}
		}
		else if(slashing){
			
			sh_bleed_user(id,attacker,BLEED_MINI,hero_id,heal_attacker,the_hitpoint)
		}
		new is_valid_dmg_src=is_valid_custom_dmg_source(custom_wpn_id)
		sh_extra_damage(id,attacker,damage,
								the_hitpoint,
								_,_,_,_,
								SH_NEW_DMG_BLEED,
								is_valid_dmg_src?custom_wpn_id:custom_dmg_id_shanking)
								
	}
}
return HAM_IGNORED
}

bleed_task_user(id,attacker,heal_user,my_hitpoint_enum:hitplace, fx_bleed_type:bleed_type){
	if ( !sh_is_active()  || !is_user_alive(id)||!is_user_connected(attacker)) return
	new any:array[5]
	array[0] = bleed_type
	array[1] = attacker
	array[2] = heal_user
	array[3] = hitplace
	array[4] = 0
	bleed_task(array,id+bleed_task_parameters[bleed_type][bleed_task_apply_id])



}

public _sh_bleed_user(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new fx_bleed_type:bleed_type=fx_bleed_type:get_param(3)
	new gHeroID=get_param(4)
	new heal_user=get_param(5)
	new my_hitpoint_enum:hitplace= my_hitpoint_enum:get_param(6)
	if ( !sh_is_active() || !is_user_alive(user)||!is_user_alive(attacker)||sh_get_id_bit(user,SH_IS_BLEEDING)) return

	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
		
	if(!is_user_bot(user)){
		sh_chat_message(user,gHeroID,"%s has bled you!!!",attacker_name)
	}
	if(!is_user_bot(attacker)){
		sh_chat_message(attacker,gHeroID,"You just bled %s!!!",user_name)
	
	}
	emit_sound(user, CHAN_STATIC, PIERCE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	sh_assign_id_bit(user,SH_IS_BLEEDING,true)
	if(bleed_type==BLEED_ULTRA){

		sh_chat_message(attacker,gHeroID,"Ultra bleeding!!!")
	}
	bleed_task_user(user,attacker,heal_user, hitplace,bleed_type)

}
public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound, PIERCE_WOUND_SFX)

}

public _sh_unbleed_user(iPlugin,iParams){

	new user=get_param(1)
	unbleed_user(user)




}

public make_bleed_fx(id,my_hitpoint_enum:hitplace){

	new origin[3]
	get_user_origin(id,origin)
	fx_blood(origin,origin,hitplace,false)
}

public bleed_task(any:array[5],id){
	id-=bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_apply_id]
	if ( !sh_is_active() ||!is_user_alive(id)||!is_user_connected(array[1])){
		

		unbleed_user(id)
		return
	}
	new Float:victim_hp=float(get_user_health(id)),
		Float:damage_to_deal=victim_hp*
							bleed_task_parameters[fx_bleed_type:array[0]][bleed_type_damage_pct]

	set_render_with_color_const(id,RED,1,bleed_task_parameters[fx_bleed_type:array[0]][bleed_type_alphas][render_alpha],
							bleed_task_parameters[fx_bleed_type:array[0]][bleed_type_alphas][hud_alpha],
							_,_,
							bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_period])
							
	if(array[2]){
		generic_heal(heal_hp_hud_msg_sync,
					array[1],
					damage_to_deal,
					_,
					RED,
					_,
					_,
					bleed_task_parameters[fx_bleed_type:array[0]][bleed_type_alphas][hud_alpha],1,0)
	}
	else{
		set_render_with_color_const(array[1],RED,0,_,bleed_task_parameters[fx_bleed_type:array[0]][bleed_type_alphas][hud_alpha],
							1,
							_,
							bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_period])
	}
	make_bleed_fx(id,array[3])
	sh_extra_damage(id,array[1],
							floatround(damage_to_deal),
			_,_,_,_,_,
			SH_NEW_DMG_BLEED,
			custom_dmg_id_bleeding)


	if(array[4]<bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_repeats]){

		array[4]++
		set_task(bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_period],
					"bleed_task",
					id+bleed_task_parameters[fx_bleed_type:array[0]][bleed_task_apply_id],
					array,
					sizeof(array))
	}
	else{

		unbleed_user(id)
	}

}
unbleed_user(id){

	if ( !sh_is_active() || !is_user_connected(id) ||!sh_get_id_bit(id,SH_IS_BLEEDING)) return
	
	sh_set_rendering(id)
	sh_assign_id_bit(id,SH_IS_BLEEDING,false)



}

public sh_client_death(id)
{
	
	if(is_user_connected(id)&&sh_is_active()){
		unbleed_user(id)
	
	}
	
}