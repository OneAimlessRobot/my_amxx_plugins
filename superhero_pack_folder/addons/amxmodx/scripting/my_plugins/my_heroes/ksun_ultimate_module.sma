#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "../my_include/my_author_header.inc"


new gHeroID = -1

new pcvar_ksun_supply_capacity;
new pcvar_ksun_health_to_supply_ratio
new pcvar_ksun_dmg_absorption_index

new pcvar_ksun_ultimate_fire_rate_mult
new pcvar_ksun_ultimate_reload_rate_mult
new pcvar_ksun_dmg_mult_super_weapon


new g_played_sound_mask = 0
new g_player_in_ultimate_mask = 0

new dmg_source_name_short_r5[SAFE_BUFFER_SIZE+1]="r5_rifle"
new dmg_source_name_long_r5[SAFE_BUFFER_SIZE+1]="r5_rifle"
new custom_dmg_id_r5


new g_player_supply_amount[SH_MAXSLOTS+1]


stock KSUN_ULTIMATE_TASKID


public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun supply","1.1",AUTHOR)
	pcvar_ksun_ultimate_fire_rate_mult = register_cvar("ksun_ultimate_fire_rate_mult", "3.0" )
	pcvar_ksun_ultimate_reload_rate_mult = register_cvar("ksun_ultimate_reload_rate_mult", "3.0" )
	pcvar_ksun_dmg_absorption_index = register_cvar("ksun_dmg_absorption_index", "1.0" )
	pcvar_ksun_supply_capacity = register_cvar("ksun_supply_capacity", "1000" )
	pcvar_ksun_health_to_supply_ratio = register_cvar("ksun_health_to_supply_ratio","0.25")
	pcvar_ksun_dmg_mult_super_weapon = register_cvar("ksun_dmg_mult_super_weapon","0.25")

	RegisterHam(Ham_TraceAttack, "player", "ksun_trace_attack_damage_hook",_,true)

	register_ham_for_weapon_bitsum(Ham_Weapon_PrimaryAttack,(1<<KSUN_WEAPON_ID),"ksun_rifle_laser",_, true, false)

	KSUN_ULTIMATE_TASKID=allocate_typed_task_id(player_task)
	
	
	register_ham_for_weapon_bitsum(Ham_Item_PostFrame,(1<<KSUN_WEAPON_ID),"Item_PostFrame_Post",1, true, false)
}

public plugin_natives(){
	
	
	
	
	register_native("ksun_set_player_supply_points","_ksun_set_player_supply_points",0)
	register_native("ksun_get_player_supply_points","_ksun_get_player_supply_points",0)
	
	register_native("ksun_dec_player_supply_points","_ksun_dec_player_supply_points",0)
	register_native("ksun_inc_player_supply_points","_ksun_inc_player_supply_points",0)
	
	register_native("ksun_player_is_in_ultimate","_ksun_player_is_in_ultimate",0)
	
	
	register_native("ksun_player_is_ultimate_ready","_ksun_player_is_ultimate_ready",0)
	
	
	register_native("ksun_player_engage_ultimate","_ksun_player_engage_ultimate",0)
	
	register_native("ksun_unultimate_user","_ksun_unultimate_user",0)
	
}
public plugin_cfg(){

	gHeroID = spores_ksun_hero_id()
	custom_dmg_id_r5=sh_log_custom_damage_source(gHeroID,dmg_source_name_short_r5,dmg_source_name_long_r5,0)
	
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
	if (!sh_is_active()||!sh_user_has_hero(id,gHeroID)||!Get_BitVar(g_player_in_ultimate_mask, id)){
		return HAM_IGNORED
	}
	do_fast_reload(id,iEnt,cvar_val(float,pcvar_ksun_ultimate_reload_rate_mult))

	return HAM_IGNORED
}
public ksun_trace_attack_damage_hook(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
if ( !sh_is_active() || !is_user_alive(Victim) || !is_user_alive(Attacker)) return HAM_IGNORED

new bool:victim_has_hero = bool:sh_user_has_hero(Victim,gHeroID),
		bool:attacker_has_hero = bool:sh_user_has_hero(Attacker,gHeroID)

if(!victim_has_hero&&!attacker_has_hero) return HAM_IGNORED

new return_result= HAM_IGNORED

new weapon=get_user_weapon(Attacker)

new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_tr2(Ptr,TR_Hitgroup)

if(victim_has_hero&&Get_BitVar(g_player_in_ultimate_mask, Victim)){

	new Float:dmgSnatched= Damage* cvar_val(float, pcvar_ksun_dmg_absorption_index)
	
	new Float:newDamage=Damage- dmgSnatched
	SetHamParamFloat(3, newDamage);
	
	return_result=HAM_HANDLED

}
if(attacker_has_hero&&Get_BitVar(g_player_in_ultimate_mask, Attacker)){

	
	if(weapon==KSUN_WEAPON_ID){
		new Float:dmgAdded= Damage*cvar_val(float, pcvar_ksun_dmg_mult_super_weapon)
		new Float:newDamage=Damage+ dmgAdded
		sh_extra_damage(Victim,Attacker,floatround(newDamage),
			dmg_source_name_long_r5,
			the_hitpoint,
			_,_,_,_,
			SH_NEW_DMG_DARK_ARTS,
			custom_dmg_id_r5)
			
	}
}
return return_result

}	

sound_fiscalization(id){
	if((g_player_supply_amount[id]==cvar_val(num, pcvar_ksun_supply_capacity))){
		
		
		if(!Get_BitVar(g_played_sound_mask, id)){
			if(!is_user_bot(id)){

				client_print(id,print_center,"The ultimate is ready.")
			}
			emit_sound(id,CHAN_WEAPON,"shmod/frostnova.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		
			emit_sound(id,CHAN_ITEM,"shmod/frostnova.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		
			emit_sound(id,CHAN_BODY,"shmod/frostnova.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		
			Assign_BitVar(g_played_sound_mask, id, true_for_macro)
		}
		
	}	
	else if(Get_BitVar(g_played_sound_mask, id)){
		Assign_BitVar(g_played_sound_mask, id, false_for_macro)
	}
}
calculate_untaxed_health_to_filtered_supply(supply_parcel){

	return max(0,floatround(floatmul(float(supply_parcel),cvar_val(float, pcvar_ksun_health_to_supply_ratio))))
	
}
public _ksun_set_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	g_player_supply_amount[id]= max(0,min(cvar_val(num, pcvar_ksun_supply_capacity),
											value))
	sound_fiscalization(id)
}
public _ksun_dec_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	g_player_supply_amount[id]= max(0,g_player_supply_amount[id]-value)
	sound_fiscalization(id)
}
public _ksun_inc_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	
	g_player_supply_amount[id]= max(0,
									min(cvar_val(num, pcvar_ksun_supply_capacity),
									g_player_supply_amount[id]+
									calculate_untaxed_health_to_filtered_supply(value)))
	if(!is_user_bot(id)&&(g_player_supply_amount[id]<cvar_val(num,pcvar_ksun_supply_capacity))){

		client_print(id,print_center,"You now have %d supply points",g_player_supply_amount[id])
	}
	sound_fiscalization(id)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_READY_SOUND)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_DRONE_SOUND)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_SOUND)
	engfunc(EngFunc_PrecacheSound, "shmod/frostnova.wav")
}

public _ksun_get_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	
	return g_player_supply_amount[id]
	
}
public _ksun_player_is_in_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	return Get_BitVar(g_player_in_ultimate_mask, id)
	
	
}

public _ksun_player_engage_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	
	if(!is_user_alive(id)) return
	if(!sh_user_has_hero(id,gHeroID)) return
	
	Assign_BitVar(g_player_in_ultimate_mask, id, true_for_macro);
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(KSUN_ULTIMATE_LOOP_PERIOD,"ultimate_task",id+KSUN_ULTIMATE_TASKID)
}


public ultimate_task(id){
	id-=KSUN_ULTIMATE_TASKID
	if(!is_user_alive(id)) return
	
	if(!Get_BitVar(g_player_in_ultimate_mask, id)||!sh_user_has_hero(id,gHeroID)) return
	static hud_msg[128];
	g_player_supply_amount[id]= max(0,g_player_supply_amount[id]-KSUN_ULTIMATE_LOOP_DEC)
	ksun_glisten(id)
	
	if(!is_user_bot(id)){
		formatex(hud_msg,127,"[SH](ksun): Curr charge: %0.2f^n",
		100.0*(floatdiv(float(g_player_supply_amount[id]),
				float(cvar_val(num, pcvar_ksun_supply_capacity))))
		);
		client_print(id,print_center,"%s",hud_msg)

	}
	if(g_player_supply_amount[id]>0){
		set_task(KSUN_ULTIMATE_LOOP_PERIOD,"ultimate_task",id+KSUN_ULTIMATE_TASKID)
	}
	else{
		unultimate_user(id,1)

	}
	
	
	
}
public _ksun_unultimate_user(iPlugin,iParams){
	new id=get_param(1)
	new dying_or_new_round=get_param(2)
	new force_take=get_param(3)
	new should_i_remove_points=(force_take||(ksun_get_when_reset_spores()&(dying_or_new_round?reset_on_death:reset_on_new_round)))
	unultimate_user(id,should_i_remove_points)
	
	
}
unultimate_user(id,take_away_supply=1){
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, KSUN_ULTIMATE_DRONE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_WEAPON, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
	Assign_BitVar(g_player_in_ultimate_mask, id, false_for_macro);
	Assign_BitVar(g_played_sound_mask, id, false_for_macro);
	g_player_supply_amount[id]=take_away_supply?0:g_player_supply_amount[id]
	
	
	
}
public _ksun_player_is_ultimate_ready(iPlugins, iParams){
	
	new id=get_param(1)
	
	
	return g_player_supply_amount[id]>=cvar_val(num, pcvar_ksun_supply_capacity)
	
}

public ksun_rifle_laser(entity)
{

	if(pev_valid(entity)!=2)
		return HAM_IGNORED


	new id = get_pdata_cbase(entity, m_pPlayer, XO_WEAPON)

	if(!client_is_hero_user(id, gHeroID)){
		return HAM_IGNORED
	}
	if(!Get_BitVar(g_player_in_ultimate_mask, id)){
		return HAM_IGNORED
	}

	new iClip= get_pdata_int(entity,m_iClip,XO_WEAPON)

	if(iClip<=0){

		return HAM_SUPERCEDE

	}
	draw_aim_vector(id,sh_custom_color:{PURPLE,PURPLE,PURPLE})
	emit_sound(entity,CHAN_WEAPON,SPORE_PREPARE_SFX,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	return do_fast_shot(entity,cvar_val(float, pcvar_ksun_ultimate_fire_rate_mult))

}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &my_hitpoint_enum:bodypart ,&dmgMode, &sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	
	if ( !sh_is_active() ||  !is_user_connected(victim)){
	
		return DMG_FWD_PASS
	}

	if(sh_user_has_hero(victim,gHeroID)&&Get_BitVar(g_player_in_ultimate_mask, victim)){

	
		return DMG_FWD_BLOCK
	}
	
	return DMG_FWD_PASS
}
