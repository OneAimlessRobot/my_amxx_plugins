#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero molotov fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock MOLLY_TASKID,
		BURN_TASKID_MAIN

new bool:gIsBurning[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("Damage", "molotov_damage_vulnerability", "b", "2!0")
	register_event("DeathMsg","on_death_burning","a")
	MOLLY_TASKID=allocate_typed_task_id(player_task)
	BURN_TASKID_MAIN=allocate_typed_task_id(player_task)
	register_event("ResetHUD","molotov_newRound","b")

}

//----------------------------------------------------------------------------------------------
public molotov_newRound(id)
{	
	if(sh_is_active()&&client_hittable(id)){
		if(gIsBurning[id]){
			sh_unmolly_user(id)
		}

	}
	
}
public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound,gSoundBurning)
	engfunc(EngFunc_PrecacheSound,gSoundScream)
	engfunc(EngFunc_PrecacheSound,MOLLY_FIRE_SFX)

}
public plugin_natives(){
	
	register_native("sh_molly_user","_sh_molly_user",0);
	register_native("sh_unmolly_user","_sh_unmolly_user",0);
}
public burn_task(array[2],id)
{
	id-=BURN_TASKID_MAIN
	
	if ( !sh_is_active() || !client_hittable(id)||!is_user_connected(array[0])){
		unburn_user(id)
		return
	}
	set_render_with_color_const(id,PINK,1,50,50,1,1)
	remove_glow_user(id,BURN_PERIOD)
	make_fire(id,30.0)
	static players[33];

	new num_players=find_sphere_class(id,"player",MOLLY_PROPAGATE_RADIUS,players,sizeof(players)-1)
	for ( new i = 0; i < num_players; i++) {
		new pid=players[i]

		if( !client_hittable(pid) || pid==id || gIsBurning[pid] ) continue
		sh_molly_user(pid,id,tranq_get_hero_id())
		
	}

	if ( pev(id, pev_waterlevel) == 3 ) {
		unburn_user(id)
		return
	}
	sh_extra_damage(id,array[0],BURN_DAMAGE,new_dmg_type_names[_:SH_NEW_DMG_FIRE],0,_,_,_,_,_,
			SH_NEW_DMG_FIRE,
			get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FIRE))

	if(gIsBurning[id]&&(array[1]<BURN_TIMES)){
		array[1]++
		emit_sound(id, CHAN_AUTO, MOLLY_FIRE_SFX , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID_MAIN,array, sizeof(array))

	}
	else{
		unburn_user(id)
	}
}

public molotov_damage_vulnerability(id){
	if ( !sh_is_active() || !client_hittable(id)) return
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if(gIsBurning[id]){
		new Float:extraDamage = damage * BURN_DAMAGE_VULNERABILITY_COEFF + damage
		if (floatround(extraDamage)>0){
			sh_extra_damage(id, attacker, floatround(extraDamage), "Burn vuln", headshot)
		}
	}

	
}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if (!sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)) return DMG_FWD_PASS

	if(gIsBurning[victim]){
		new Float:extraDamage = damage * BURN_DAMAGE_VULNERABILITY_COEFF  + damage
		if (floatround(extraDamage)>0){
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
	if(!gIsBurning[user]){
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
	unburn_user(user)
	
	
	
	
}
stock burn_user(id,attacker){

	gIsBurning[id]=true
	new array[2]
	array[0] = attacker
	array[1] = 0
	emit_sound(id, CHAN_VOICE, gSoundScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_damage_icon(id,2,DMG_ICON_HEAT,LineColors[RED])
	set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID_MAIN,array, sizeof(array))
	
	
	
}


unburn_user(id){
	if ( !sh_is_active() ||!is_user_connected(id)) return
	set_damage_icon(id,0,DMG_ICON_HEAT)
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	unfade_screen_user(id)
	gIsBurning[id]=false
	
	
	
}

public on_death_burning()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unmolly_user(id)
	
	}
	
}