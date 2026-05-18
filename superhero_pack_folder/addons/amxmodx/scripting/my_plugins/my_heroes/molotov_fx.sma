#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "co2_fx_inc/co2_fx.inc"
#include "tomie_yu_inc/tomie_yu.inc"
#include "freeze_fx/freeze_fx.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero molotov fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = 0

new gHeroID_erica = 0
stock MOLLY_TASKID,
		BURN_TASKID_MAIN

new gIsBurningMask = 0


new dmg_source_name_short_fire_vuln[SAFE_BUFFER_SIZE+1]="fire_vuln"
new dmg_source_name_long_fire_vuln[SAFE_BUFFER_SIZE+1]="fire_vuln"
new custom_dmg_id_fire_vuln

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("Damage", "molotov_damage_vulnerability", "b", "2!0")
	MOLLY_TASKID=allocate_typed_task_id(player_task)
	BURN_TASKID_MAIN=allocate_typed_task_id(player_task)

}
public plugin_cfg(){

	gHeroID = tomie_yu_hero_id()
	gHeroID_erica = tranq_get_hero_id()
	custom_dmg_id_fire_vuln=sh_log_custom_damage_source(-1,
				dmg_source_name_short_fire_vuln,
				dmg_source_name_long_fire_vuln,
				0)
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unburn_user(id)
	}
	
}
public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound,gSoundBurning)
	engfunc(EngFunc_PrecacheSound,gSoundScream)
	engfunc(EngFunc_PrecacheSound,MOLLY_FIRE_SFX)

}
public plugin_natives(){
	
	register_native("sh_molly_user","_sh_molly_user",0);
	register_native("sh_is_user_burning","_sh_is_user_burning",0);
	register_native("sh_unmolly_user","_sh_unmolly_user",0);
}
public burn_task(array[2],id)
{
	id-=BURN_TASKID_MAIN
	
	if ( !sh_is_active() || !is_user_alive(id)||!is_user_connected(array[0])){
		unburn_user(id)
		return
	}
	if(!Get_BitVar(gIsBurningMask,id)){
		return
	}
	set_render_with_color_const(id,PINK,1,50,50,1,1)
	remove_glow_user(id,BURN_PERIOD)
	make_fire(id,30.0)

	
	new bool:is_tomie_user=bool:sh_user_has_hero(id,gHeroID)
	if(!is_tomie_user){
		static players[33];

		new num_players=find_sphere_class(id,"player",MOLLY_PROPAGATE_RADIUS,players,sizeof(players)-1)
		for ( new i = 0; i < num_players; i++) {
			new pid=players[i]

			if( !is_user_alive(pid) || pid==array[0] || Get_BitVar(gIsBurningMask,pid)) continue
			
			sh_molly_user(pid,array[0],gHeroID_erica)
			
		}
	}
	if ( pev(id, pev_waterlevel) == 3 ) {
		unburn_user(id)
		return
	}
	sh_extra_damage(id,array[0],BURN_DAMAGE,new_dmg_type_names[_:SH_NEW_DMG_FIRE],
			_,_,_,_,_,
			SH_NEW_DMG_FIRE,
			get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FIRE))

	if(Get_BitVar(gIsBurningMask,id)&&(array[1]<BURN_TIMES)){
		array[1]++
		emit_sound(id, CHAN_AUTO, MOLLY_FIRE_SFX , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID_MAIN,array, sizeof(array))

	}
	else{
		unburn_user(id)
	}
}

public molotov_damage_vulnerability(id){
	if ( !sh_is_active() || !is_user_alive(id)) return
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if(Get_BitVar(gIsBurningMask,id)){
		new Float:extraDamage = damage * BURN_DAMAGE_VULNERABILITY_COEFF + damage
		if (floatround(extraDamage)>0){
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage),
							dmg_source_name_short_fire_vuln,
							my_hitpoint_enum:bodypart,
							_,_,_,_,
							SH_NEW_DMG_FIRE,
							custom_dmg_id_fire_vuln)
			}
		}
	}

	
}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &my_hitpoint_enum:bodypart ,&dmgMode, &sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)) return DMG_FWD_PASS

	if(Get_BitVar(gIsBurningMask,victim)){
		
		new Float:extraDamage = damage * BURN_DAMAGE_VULNERABILITY_COEFF - damage
		if (floatround(extraDamage)>0){
			new_dmg_type=SH_NEW_DMG_FIRE
			custom_weapon_id=custom_dmg_id_fire_vuln
			damage=floatround(extraDamage)
		}
	}
	

	
	return DMG_FWD_PASS
}
public _sh_molly_user(iPlugin,iParams){
	
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!sh_get_user_is_co2(user)&&!Get_BitVar(gIsBurningMask,user)){
		if((user==attacker)){
			if(CAN_SELF_MOLLY&&user){
				
					if(!is_user_bot(user)){
						sh_chat_message(user,gHeroID,"%s has burned you!!!",attacker_name)
					}
					
					if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"You burned %s!!!",user_name)
					}
					burn_user(user,attacker)
			}
		}
		else{
			
			if(!is_user_bot(user)){
				sh_chat_message(user,gHeroID,"%s has burned you!!!",attacker_name)
			}
			if(!is_user_bot(attacker)){
				sh_chat_message(attacker,gHeroID,"You burned %s!!!",user_name)
			}
			burn_user(user,attacker)
		}
	}
	
	
	
}
public _sh_unmolly_user(iPlugin,iParams){
	
	new user=get_param(1)
	
	if(Get_BitVar(gIsBurningMask,user)){
		unburn_user(user)
	}
	
	
	
}

public _sh_is_user_burning(iPlugin,iParams){
	new id=get_param(1)

	return Get_BitVar(gIsBurningMask,id)

}
stock burn_user(id,attacker){

	if(Get_BitVar(gIsBurningMask,id)) return

	Set_BitVar(gIsBurningMask,id)
	new bool:is_tomie_user=bool:sh_user_has_hero(id,gHeroID)
	new times_if_tomie_user=floatround(float(BURN_TIMES)/2.0,floatround_floor)
	new array[2]
	array[0] = attacker
	array[1] = sh_user_has_hero(id,gHeroID)?times_if_tomie_user:0
	
	if(sh_is_user_frozen(id)){
		sh_unfreeze_user(id)
	}
	if(!is_tomie_user){
		emit_sound(id, CHAN_VOICE, gSoundScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	set_damage_icon(id,2,DMG_ICON_HEAT,LineColors[RED])
	set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID_MAIN,array, sizeof(array))
	
	
}


unburn_user(id){
	if ( !sh_is_active() ||!is_user_connected(id)||!Get_BitVar(gIsBurningMask,id)) return

	set_damage_icon(id,0,DMG_ICON_HEAT)
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	unfade_screen_user(id)
	UnSet_BitVar(gIsBurningMask,id)
	
	
	
}

public sh_client_death(id)
{
	unburn_user(id)
	
}