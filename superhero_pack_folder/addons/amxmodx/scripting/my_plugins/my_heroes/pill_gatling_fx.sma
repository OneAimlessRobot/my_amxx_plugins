#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_WEAPONS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_funcs_misc_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "track_fx_inc/track_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"

#define PLUGIN "Superhero yakui pt2 pt1"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
new g_last_weapon[SH_MAXSLOTS+1]
enum fx_task_parameter_id{
	Float:fx_task_period,
	Float:fx_task_time,
	Float:fx_rarity_weight,
	fx_task_repeats,
	fx_task_apply_id,
	fx_task_apply_func_name[128],
	fx_task_remove_func_name[128],
	fx_name[128],
	fx_on_remove_string[128],
	fx_task_will_glow_user_screen,
	damage_icon_types:fx_task_status_icon
}

stock fx_task_parameters[fx_id][fx_task_parameter_id]={	
					{-1.0,5.0,0.0,-1,-1,"","","no drug","We have removed nothing!",0,damage_icon_types:-1},

					
					{-1.0,5.0,1.0,-1,-1,"","","cyanide","We have removed nothing! You should be dead...",0,damage_icon_types:-1},
					
					{1.0,2.0,20.0,-1,-1,"this_shite_do_nothin","uneffect_task_generic","glowstick juice","Removed ur glow bro!",-1,damage_icon_types:-1},
					
					{0.5,4.0,30.0,-1,-1,"poison_task","uneffect_task_generic","poison","Removed ur poisan!",1,DMG_ICON_POISON},
					
					{9.0,9.0,40.0,1,-1,"this_shite_do_nothin","uneffect_task_generic","stunner","Removed ur stun bro!",1,DMG_ICON_DROWN},
					
					{1.0,5.0,50.0,1,-1,"radioactive_task","","uranium","Removed ur chernobyl!",1,DMG_ICON_RADIATION},
					
					{1.0,10.0,60.0,-1,-1,"morphine_task","uneffect_task_generic","morphine","Removed ur heals!",1,DMG_ICON_HEALTH},
					
					{1.0,7.0,71.0,-1,-1,"weed_task","unweed_task","weed","Removed ur weed!",0,DMG_ICON_LONGJUMP},
					
					{1.0,9.0,79.0,-1,-1,"cocaine_task","uncocaine_task","cocaine","Removed ur 80s!",1,DMG_ICON_POISON},
					
					{0.5,10.0,85.0,-1,-1,"blind_task","uneffect_task_generic","blindness","Removed ur blindess!",1,damage_icon_types:-1},
					
					{20.0,20.0,90.0,1,-1,"this_shite_do_nothin","uneffect_task_generic","metylphenidate","Removed ur college pills!",0,DMG_ICON_SHOCK},
					
					{20.0,20.0,100.0,1,-1,"this_shite_do_nothin","uneffect_task_generic","bath salts","Removed ur spicy college pills!",0,DMG_ICON_ARMOR}

}

new Float:myeloma_doenca_cancro_morte_demonio_recoil_vector[SH_MAXSLOTS+1][3]

new dmg_source_name_short_poison_vuln[SAFE_BUFFER_SIZE+1]="poison_vuln"
new dmg_source_name_log_poison_vuln[SAFE_BUFFER_SIZE+1]="poison_vuln"
new custom_dmg_id_poison_vuln

new dmg_source_name_short_crackhead_rage[SAFE_BUFFER_SIZE+1]="crackhead_rage"
new dmg_source_name_log_crackhead_rage[SAFE_BUFFER_SIZE+1]="crackhead_rage"
new custom_dmg_id_crackhead_rage

new dmg_source_name_short_cyanide[SAFE_BUFFER_SIZE+1]="cyanide"
new dmg_source_name_log_cyanide[SAFE_BUFFER_SIZE+1]="cyanide"
new custom_dmg_id_cyanide

new generic_dmg_poison_id = -1

public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);

register_ham_for_weapon_bitsum(Ham_Weapon_PrimaryAttack,NO_RECOIL_WEAPONS_BITSUM,"Ham_Weapon_PrimaryAttack_Post",1, true, true)

register_ham_hook_multiple(Ham_TraceAttack,
					full_entity_array_for_trace_attack,
					length_of_trace_attack_entity_array,
					"make_tracer",
					1,
					true)

register_ham_for_weapon_bitsum(Ham_Weapon_PrimaryAttack,NO_RECOIL_WEAPONS_BITSUM,"Ham_Weapon_PrimaryAttack_Pre",_, true, true)



register_ham_for_weapon_bitsum(Ham_Item_PostFrame,FAST_RELOAD_BITSUM,"Item_PostFrame_Post",1, true, true)

for(new fx_id:i=GLOW;i<fx_id;i++){
	
	if(strlen(fx_task_parameters[i][fx_task_apply_func_name])){
		fx_task_parameters[i][fx_task_apply_id]=allocate_typed_task_id(player_task)
	}
	if(fx_task_parameters[i][fx_task_repeats]<0){
		fx_task_parameters[i][fx_task_repeats]=floatround(
						floatdiv(fx_task_parameters[i][fx_task_time],
								fx_task_parameters[i][fx_task_period]))
	}
}

custom_dmg_id_poison_vuln=sh_log_custom_damage_source(-1,
				dmg_source_name_short_poison_vuln,
				dmg_source_name_log_poison_vuln,
				0)

custom_dmg_id_crackhead_rage=sh_log_custom_damage_source(-1,
				dmg_source_name_short_crackhead_rage,
				dmg_source_name_log_crackhead_rage,
				0)
				
custom_dmg_id_cyanide=sh_log_custom_damage_source(-1,
				dmg_source_name_short_cyanide,
				dmg_source_name_log_cyanide,
				0)

RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1,true) 
register_event("Damage", "fx_damage", "b", "2!0")
register_event("CurWeapon", "weaponChange", "be", "1=1")

init_hud_syncs()
}

public plugin_cfg(){
	generic_dmg_poison_id = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_DRUG_POISON)
}
public plugin_natives(){


	register_native("sh_effect_user","_sh_effect_user");
	register_native("sh_gen_effect","_get_fx_num");
	register_native("sh_get_user_effect","_sh_get_user_effect");
	register_native("sh_effect_user_direct","_sh_effect_user_direct");
	register_native("sh_uneffect_user","_sh_uneffect_user");
	register_native("sh_get_fx_color_name","_sh_get_fx_color_name");
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,PIERCE_WOUND_SFX)

}
public Item_PostFrame_Post(iEnt)
{    
	if(pev_valid(iEnt)!=2){
		return HAM_IGNORED
	}
	new id = entity_get_edict(iEnt, EV_ENT_owner);
	if(!is_user_alive(id)){
		return HAM_IGNORED
	}
	if (!sh_is_active()||(gatling_get_fx_num(id)!=COCAINE))return HAM_IGNORED
	
	do_fast_reload(id,iEnt,COCAINE_RELOAD_RATE_MULT)
	return HAM_IGNORED
} 

public fx_damage(id)
{
	if ( !sh_is_active() || !is_user_alive(id)) return
	
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if ( !is_user_alive(attacker)||attacker==id) return
	
	new fx_num_att=(gatling_get_fx_num(attacker));
	new fx_num_vic=(gatling_get_fx_num(id));
	switch (fx_num_att){
		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			if (floatround(extraDamage)>0){
				
				sh_extra_damage(id, attacker, floatround(extraDamage),
							my_hitpoint_enum:bodypart ,
							_,_,_,_,
							SH_NEW_DMG_DRUG_POISON,
							custom_dmg_id_crackhead_rage)
			}	
		}
		case METYLPHENIDATE:{
			new gained_xp= floatround(FOCUS_XPMULT*damage);
			new current_xp= sh_get_user_xp(attacker)
			new new_xp= gained_xp+ current_xp;
			sh_set_user_xp(attacker,new_xp);
		}
	}
	switch(fx_num_vic){

		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			extraDamage*=((sh_get_id_bit(id,SH_IS_BLEEDING)?2.0:1.0)*(sh_get_id_bit(id,SH_IS_FROZEN)?0.5:1.0))
			if (floatround(extraDamage)>0){
		
				sh_extra_damage(id, attacker, floatround(extraDamage),
							my_hitpoint_enum:bodypart ,
							_,_,_,_,
							SH_NEW_DMG_DRUG_POISON,
							custom_dmg_id_poison_vuln)
			}	
		}
	}
	
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)) return DMG_FWD_PASS

	new fx_num_att=(gatling_get_fx_num(attacker));
	switch (fx_num_att){
		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			if (floatround(extraDamage)>0){
				damage=floatround(extraDamage)
			}	
		}
		case METYLPHENIDATE:{
			new gained_xp= floatround(FOCUS_XPMULT*damage);
			new current_xp= sh_get_user_xp(attacker)
			new new_xp= gained_xp+ current_xp;
			sh_set_user_xp(attacker,new_xp);
		}
	}
	return DMG_FWD_PASS
}


//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Pre(weapon_ent)
{
	if(pev_valid(weapon_ent)!=2){

		return HAM_IGNORED;
	}
	if ( !sh_is_active() ){
		return HAM_IGNORED
	}
	static owner; owner = get_pdata_cbase(weapon_ent,m_pPlayer,XO_WEAPON)
	if(!is_user_alive(owner)){
		return HAM_IGNORED
	}
	new fx_id:fx_num_of_owner=gatling_get_fx_num(owner)
	switch(fx_num_of_owner){
		case METYLPHENIDATE:{

			entity_get_vector(owner, EV_VEC_punchangle,myeloma_doenca_cancro_morte_demonio_recoil_vector[owner])
		}
		case COCAINE:{
			
			return do_fast_shot(weapon_ent,COCAINE_FIRE_RATE_MULT)
		}
		
		
	}
	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	if(pev_valid(weapon_ent)!=2){

		return
	}
	if ( !sh_is_active() ){
		return
	}
	static owner; owner = get_pdata_cbase(weapon_ent,m_pPlayer,XO_WEAPON)
	if(!is_user_alive(owner)){
		return
	}

	
	static iClip; iClip= get_pdata_int(weapon_ent,m_iClip,XO_WEAPON)
	
	if(iClip<=0){

		return

	}
	new fx_id:fx_num_of_owner=gatling_get_fx_num(owner)
	switch(fx_num_of_owner){
		case METYLPHENIDATE:{

			static Float:Push[3]
			entity_get_vector(owner, EV_VEC_punchangle, Push)

			sub_3d_vectors(Push, myeloma_doenca_cancro_morte_demonio_recoil_vector[owner], Push)
			
			multiply_3d_vector_by_scalar(Push, METYLPHENIDATE_RECOIL_COEFF, Push)
			add_3d_vectors(Push, myeloma_doenca_cancro_morte_demonio_recoil_vector[owner], Push)
			entity_set_vector(owner, EV_VEC_punchangle, Push)
		
		}
	}
}

public make_tracer(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_alive(Attacker)){
		return
	}
	new fx_id:fx_num_of_owner=gatling_get_fx_num(Attacker)

	generic_weapon_tracer_logic(Attacker,((fx_num_of_owner==POISON)||(fx_num_of_owner==COCAINE)),
				-1,
				-1,
				true,
				(fx_num_of_owner==POISON)?
				(sh_custom_color:{GREEN,GREEN,GREEN}):
				(sh_custom_color:{PINK,PINK,PINK}))
}
public Player_TakeDamage(id)
{
 if ( !sh_is_active() || !is_user_alive(id) || !(gatling_get_fx_num(id)==BATH)) return
 
 set_pdata_float(id, fPainShock, 1.0, 5)
} 
public fx_id:_sh_get_user_effect(iPlugins,iParams){
	
	new id=get_param(1)
	if(!is_user_alive(id)||!sh_is_active()){
		
		return fx_id:FX_ID_NONE;
	}
	
	return gatling_get_fx_num(id)

}

public _sh_get_fx_color_name(iPlugins,iParams){
	
	new fx_id:fx_num=fx_id:get_param(1)
	set_array(2,LineColors[FX_COLOR_OFFSET(fx_num)],3)
	set_array(3,fx_task_parameters[fx_num][fx_name],128)
	


}
fx_task_user(id,attacker,fx_id:fx_num){
	if ( !sh_is_active() ||!is_user_alive(id)) return
	new any:array[3]
	array[0] = fx_num
	array[1] = attacker
	//curr_num_repeats
	array[2] = 0
	new strlen_of_init_task_func_name=strlen(fx_task_parameters[fx_num][fx_task_apply_func_name])
	if(((fx_task_parameters[fx_num][fx_task_status_icon])>=enum_zero)){

		new Float:the_time_to_set=((strlen_of_init_task_func_name>0)?
												fx_task_parameters[fx_num][fx_task_period]:
												fx_task_parameters[fx_num][fx_task_time])

		
		set_damage_icon(id,1,fx_task_parameters[fx_num][fx_task_status_icon],LineColors[FX_COLOR_OFFSET(fx_num)],the_time_to_set)
	}
	if(strlen(fx_task_parameters[fx_num][fx_task_apply_func_name])){
		
		set_render_with_color_const(id,FX_COLOR_OFFSET(fx_num),_,_,_,fx_task_parameters[fx_num][fx_task_will_glow_user_screen])
		
	
		callfunc_begin_i(get_func_id(fx_task_parameters[fx_num][fx_task_apply_func_name]))
		callfunc_push_array(array,sizeof(array))
		callfunc_push_int(id+fx_task_parameters[fx_num][fx_task_apply_id])
		callfunc_end()
	}
}
task_cycle(array[3],id){


	set_render_with_color_const(id,FX_COLOR_OFFSET(fx_id:array[0]),_,_,_,fx_task_parameters[fx_id:array[0]][fx_task_will_glow_user_screen])
	
	if(((fx_task_parameters[fx_id:array[0]][fx_task_status_icon])>=enum_zero)){
		
		set_damage_icon(id,1,fx_task_parameters[fx_id:array[0]][fx_task_status_icon],LineColors[FX_COLOR_OFFSET(fx_id:array[0])],
				fx_task_parameters[fx_id:array[0]][fx_task_period])
	}

	if((array[2]<fx_task_parameters[fx_id:array[0]][fx_task_repeats])&&is_user_alive(id)&&sh_is_inround()&&(gatling_get_fx_num(id)==fx_id:array[0])){

		array[2]++
		set_task(fx_task_parameters[fx_id:array[0]][fx_task_period],
						fx_task_parameters[fx_id:array[0]][fx_task_apply_func_name],
						id+fx_task_parameters[fx_id:array[0]][fx_task_apply_id],
						array,
						sizeof(array))

	}
	else if(strlen(fx_task_parameters[fx_id:array[0]][fx_task_remove_func_name])){
		
		callfunc_begin_i(get_func_id(fx_task_parameters[fx_id:array[0]][fx_task_remove_func_name]))
		callfunc_push_array(array,1)
		callfunc_push_int(id)
		callfunc_end()
	}
}
public _get_fx_num(iPlugin,iParams){


	new Float:chance=generate_float(0.0,(fx_task_parameters[fx_id-fx_id:1][fx_rarity_weight])*0.02)

	for(new fx_id:i=KILL;i<fx_id;i++){
		new Float:compared=fx_task_parameters[i][fx_rarity_weight]*0.01;
		if(chance<compared){

			return i;
		}

	}
	return FX_ID_NONE

}
public fx_id:_sh_effect_user_direct(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new fx_id:fx_num=fx_id:get_param(4)
	if(fx_num==KILL){

		if(user==attacker){
			new attacker_name[128]
			get_user_name(attacker,attacker_name,127)
			sh_chat_message(0,gHeroID,"%s: Dont worry guys! Momma Yakui has everything under control... what doesnt kill me can only... *thud*",attacker_name)
		
		}
		kill_user(user,attacker)

	}
	else if(fx_num){
		gatling_set_fx_num(user,fx_num)
		fx_task_user(user,attacker,fx_id:fx_num)
		switch(fx_num){
			case STUN:{
				
				stun_user(user)
			
			}
			case COCAINE:{
				
				sh_bleed_user(user,attacker,BLEED_MINI,gHeroID,0)
			
			}


		}
	}

	return fx_num;




}
public fx_id:_sh_effect_user(iPlugin,iParams){

	new fx_id:fx_num=sh_gen_effect()
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	sh_effect_user_direct(user,attacker,gHeroID,fx_num)
	return fx_num;




}



public _sh_uneffect_user(iPlugin,iParams){

	new user=get_param(1)
	
	if((gatling_get_fx_num(user)>KILL)&&(gatling_get_fx_num(user)<=BATH)){
		uneffect_user_primitive(user)
	}




}
kill_user(id,attacker){
	
	
	if ( !sh_is_active() ||!is_user_alive(id)) return
	sh_screen_fade(id, 0.1, 0.9,
						LineColors[FX_COLOR_OFFSET(KILL)][0],
						LineColors[FX_COLOR_OFFSET(KILL)][1],
						LineColors[FX_COLOR_OFFSET(KILL)][2], 50)

	sh_extra_damage(id,attacker,1,
				_,
				SH_DMG_KILL,
				_,_,_,
				SH_NEW_DMG_DRUG_POISON,
				custom_dmg_id_cyanide)

	gatling_set_fx_num(id,FX_ID_NONE)


}

stun_user(id){

	
	if ( !sh_is_active() ||!is_user_alive(id)) return
	set_render_with_color_const(id, FX_COLOR_OFFSET(STUN),_,_,_,fx_task_parameters[STUN][fx_task_will_glow_user_screen])
	sh_set_stun(id, fx_task_parameters[STUN][fx_task_time], STUN_SPEED)
	sh_screen_shake(id, 16.0, fx_task_parameters[STUN][fx_task_time], 2.0)



}
public blind_task(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !sh_is_active() ||!is_user_alive(id)) return
	set_render_with_color_const(id,FX_COLOR_OFFSET(array[0]),0,_,255,1)
	task_cycle(array,id)
}

public poison_task(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]

	if ( !sh_is_active() ||!is_user_alive(id)||!is_user_connected(array[1])) return
	sh_extra_damage(id,array[1],floatround(float(get_user_health(id))*
							(POISON_DAMAGE_PCT*(((sh_get_id_bit(id,SH_IS_BLEEDING)?2.0:1.0)*(sh_get_id_bit(id,SH_IS_FROZEN)?0.5:1.0))))),
							_,_,_,_,_,
							SH_NEW_DMG_DRUG_POISON,
							generic_dmg_poison_id)
	
	sh_set_stun(id,0.33,140.0)
	emit_sound(id, CHAN_STATIC, PIERCE_WOUND_SFX, 1.0, ATTN_NORM, 0, PITCH_NORM)
	task_cycle(array,id)


}

public radioactive_task(array[3],id){
	id-=fx_task_parameters[fx_id:array[0]][fx_task_apply_id]
	new attacker=array[1]
	track_user(id,attacker,
						1,
						RADIOACTIVE_DAMAGE_HEALTH_PCT,
						fx_task_parameters[fx_id:array[0]][fx_task_period],
						fx_task_parameters[fx_id:array[0]][fx_task_time],
						FX_COLOR_OFFSET(fx_id:array[0]))
}
public morphine_task(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !sh_is_active() ||!is_user_alive(id)) return
	generic_heal(heal_hp_hud_msg_sync,
					id,
					float(MORPHINE_HP_ADD),
					sh_get_max_hp(id),FX_COLOR_OFFSET(array[0]),_,_,_,0)
	
	task_cycle(array,id)
}
public weed_task(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !sh_is_active() ||!is_user_alive(id)) return
	set_user_gravity(id,WEED_GRAVITY)
	task_cycle(array,id)
}
public cocaine_task(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !sh_is_active() ||!is_user_alive(id)) return
	set_user_maxspeed(id,COCAINE_SPEED)
	task_cycle(array,id)
}
public this_shite_do_nothin(any:array[3],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	task_cycle(array,id)

}

public uneffect_task_generic(array[3],id){

	uneffect_user_primitive(id)
}


public unweed_task(array[3],id){
	uneffect_task_generic(array,id)
	sh_reset_min_gravity(id)

}
public uncocaine_task(array[3],id){
	uneffect_task_generic(array,id)
	sh_reset_max_speed(id)

}




uneffect_user_primitive(id){
	if ( !sh_is_active() ||!is_user_connected(id)) return
	new fx_id:the_fx_id=gatling_get_fx_num(id)
	sh_set_rendering(id)
	if(fx_task_parameters[the_fx_id][fx_task_status_icon]>=enum_zero){
		set_damage_icon(id,0,fx_task_parameters[the_fx_id][fx_task_status_icon])
	}
	new bool:will_remove_task
				=
				bool:task_exists(id+fx_task_parameters[the_fx_id][fx_task_apply_id])

	if(will_remove_task){
		
		remove_task(id+fx_task_parameters[the_fx_id][fx_task_apply_id])
	}
	gatling_set_fx_num(id, FX_ID_NONE)

}

public sh_client_death(id)
{
	if(is_user_connected(id)&&sh_is_active()){
		
		new fx_id:the_fx=gatling_get_fx_num(id)

		if((the_fx>KILL)&&(the_fx<=BATH)){
			uneffect_user_primitive(id)
		}
	}
	
}
public sh_client_spawn(id)
{
	if(is_user_connected(id)&&sh_is_active()){
		
		new fx_id:the_fx=gatling_get_fx_num(id)

		if((the_fx>KILL)&&(the_fx<=BATH)){
			uneffect_user_primitive(id)
		}
	}
	
}
//----------------------------------------------------------------------------------------------

public weaponChange(id)
{
	if ( (gatling_get_fx_num(id)!=COCAINE)||!sh_is_active()) return

	new wpnid = read_data(2)

	if ( g_last_weapon[id] != wpnid ) {
		if ((get_user_maxspeed(id) < COCAINE_SPEED)&&!sh_get_stun(id)){
			set_user_maxspeed(id, COCAINE_SPEED)
		}
	}
	g_last_weapon[id]=wpnid;
}