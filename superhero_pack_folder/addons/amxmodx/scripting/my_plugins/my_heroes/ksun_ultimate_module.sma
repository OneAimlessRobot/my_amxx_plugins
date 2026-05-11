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



new pcvar_ksun_supply_capacity;
new pcvar_ksun_health_to_supply_ratio
new pcvar_ksun_dmg_absorption_index

new pcvar_ksun_ultimate_fire_rate_mult
new pcvar_ksun_ultimate_reload_rate_mult

new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]
new g_played_sound[SH_MAXSLOTS+1]
new dmg_source_name_short_r5[SAFE_BUFFER_SIZE+1]="r5_rifle"
new dmg_source_name_long_r5[SAFE_BUFFER_SIZE+1]="r5_rifle"
new custom_dmg_id_r5


new g_player_supply_amount[SH_MAXSLOTS+1]

new g_player_in_ultimate[SH_MAXSLOTS+1]

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
	
	RegisterHam(Ham_TakeDamage, "player", "ksun_ultimate_damage_hook",_,true)
	register_event("CurWeapon", "ksun_rifle_laser", "be", "1=1", "3>0")

	KSUN_ULTIMATE_TASKID=allocate_typed_task_id(player_task)
	
	
	static wpnName[32]
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{
		if ( !(FAST_RELOAD_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
		{
			RegisterHam(Ham_Item_PostFrame, wpnName, "Item_PostFrame_Post", 1,true)
		}
	}
	custom_dmg_id_r5=sh_log_custom_damage_source(spores_ksun_hero_id(),dmg_source_name_short_r5,dmg_source_name_long_r5,0)
	
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

public Item_PostFrame_Post(iEnt)
{    
	if(pev_valid(iEnt)!=2){
		return HAM_IGNORED
	}
	new id = entity_get_edict(iEnt, EV_ENT_owner);
	if(!is_user_alive(id)){
		return HAM_IGNORED
	}
	if (!sh_is_active()||!sh_user_has_hero(id,spores_ksun_hero_id())||!ksun_player_is_in_ultimate(id)){
		return HAM_IGNORED
	}
	do_fast_reload(id,iEnt,cvar_val(float,pcvar_ksun_ultimate_reload_rate_mult))

	return HAM_IGNORED
}
public ksun_ultimate_damage_hook(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !sh_is_active() || !is_user_alive(id) || !is_user_alive(attacker)) return HAM_IGNORED

new bool:has_hero=bool:sh_user_has_hero(id,spores_ksun_hero_id())

if(!has_hero&&!sh_user_has_hero(attacker,spores_ksun_hero_id())) return HAM_IGNORED



new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)


if(has_hero&&ksun_player_is_in_ultimate(id)){

	new Float:dmgSnatched= damage* cvar_val(float, pcvar_ksun_dmg_absorption_index)
	
	new Float:newDamage=damage- dmgSnatched
	SetHamParamFloat(4, newDamage);
	

}
if(has_hero&&ksun_player_is_in_ultimate(attacker)){

	
	if(weapon==KSUN_WEAPON_ID){
		new Float:dmgAdded= damage*cvar_val(float, pcvar_ksun_dmg_absorption_index)
		new Float:newDamage=damage+ dmgAdded
		SetHamParamFloat(4, 0.0);
		sh_extra_damage(id,attacker,floatround(newDamage),dmg_source_name_long_r5,MY_HIT_HEAD,_,_,_,_,_,_,custom_dmg_id_r5)
	}
}
return HAM_IGNORED

}	

sound_fiscalization(id){
	if((g_player_supply_amount[id]==cvar_val(num, pcvar_ksun_supply_capacity))){
		
		
		if(!g_played_sound[id]){
			emit_sound(id,CHAN_WEAPON,SPORE_HEAL_SFX,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
			g_played_sound[id]=1
		}
		
	}	
	else if(g_played_sound[id]){
		g_played_sound[id]=0
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
	sound_fiscalization(id)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_READY_SOUND)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_DRONE_SOUND)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_SOUND)
}

public _ksun_get_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	
	return g_player_supply_amount[id]
	
}
public _ksun_player_is_in_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	return g_player_in_ultimate[id]
	
	
}

public _ksun_player_engage_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	
	if(!is_user_alive(id)) return
	if(!sh_user_has_hero(id,spores_ksun_hero_id())) return
	
	g_player_in_ultimate[id]=1
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(KSUN_ULTIMATE_LOOP_PERIOD,"ultimate_task",id+KSUN_ULTIMATE_TASKID)
}


public ultimate_task(id){
	id-=KSUN_ULTIMATE_TASKID
	if(!is_user_alive(id)) return
	
	if(!ksun_player_is_in_ultimate(id)||!sh_user_has_hero(id,spores_ksun_hero_id())) return
	static hud_msg[128];
	ksun_dec_player_supply_points(id,KSUN_ULTIMATE_LOOP_DEC)
	ksun_glisten(id)
	
	if(!is_user_bot(id)){
		formatex(hud_msg,127,"[SH](ksun): Curr charge: %0.2f^n",
		100.0*(floatdiv(float(g_player_supply_amount[id]),
				float(cvar_val(num, pcvar_ksun_supply_capacity))))
		);
		client_print(id,print_center,"%s",hud_msg)

	}
	if(ksun_get_player_supply_points(id)>0){
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
	
	g_player_in_ultimate[id]=0
	g_played_sound[id]=0
	g_player_supply_amount[id]=take_away_supply?0:g_player_supply_amount[id]
	
	
	
}
public _ksun_player_is_ultimate_ready(iPlugins, iParams){
	
	new id=get_param(1)
	
	
	return g_player_supply_amount[id]>=cvar_val(num, pcvar_ksun_supply_capacity)
	
}

public ksun_rifle_laser(id)
{

if(!is_user_alive(id)) return PLUGIN_CONTINUE 
if ( !sh_user_has_hero(id,spores_ksun_hero_id())) return PLUGIN_CONTINUE 
new wpnid = read_data(2)		// id of the weapon 
new ammo = read_data(3)		// ammo left in clip 

if ( (wpnid ==KSUN_WEAPON_ID)&&(ksun_player_is_in_ultimate(id)))
{
	if (gLastWeapon[id] == 0){
		gLastWeapon[id] = wpnid
	}
	if ((gLastClipCount[id] > ammo)&&(gLastWeapon[id] == wpnid)) 
	{
		
		
		draw_aim_vector(id,{PURPLE,PURPLE,PURPLE})
		do_fast_shot(id,wpnid,cvar_val(float, pcvar_ksun_ultimate_fire_rate_mult))
		emit_sound(id,CHAN_WEAPON,SPORE_PREPARE_SFX,VOL_NORM,ATTN_NORM,0,PITCH_NORM)

	}
	gLastClipCount[id] = ammo
	gLastWeapon[id]=wpnid;
}
return PLUGIN_CONTINUE 

}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &my_hitpoint_enum:bodypart ,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	
	if ( !sh_is_active() ||  !is_user_connected(victim)){
	
		return DMG_FWD_PASS
	}
	if(sh_user_has_hero(victim,spores_ksun_hero_id())&&ksun_player_is_in_ultimate(victim)){

	
		return DMG_FWD_BLOCK
	}
	
	return DMG_FWD_PASS
}
