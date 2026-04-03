#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "tranq_gun_inc/sh_molotov_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"


#define PLUGIN "Superhero molotov fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock MOLLY_TASKID,
		UNMOLLY_TASKID,
		BURN_TASKID_MAIN,
		BURN_TASKID_SOUND,
		BURN_TASKID_SCREAMS,
		BURN_TASKID_STOP_SOUND

new bool:gIsBurning[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(gIsBurning,false,SH_MAXSLOTS+1)
	register_event("Damage", "molotov_damage_vulnerability", "b", "2!0")
	register_event("DeathMsg","on_death_burning","a")
	MOLLY_TASKID=allocate_typed_task_id(player_task)
	UNMOLLY_TASKID=allocate_typed_task_id(player_task)
	BURN_TASKID_MAIN=allocate_typed_task_id(player_task)
	BURN_TASKID_SOUND=allocate_typed_task_id(player_task)
	BURN_TASKID_SCREAMS=allocate_typed_task_id(player_task)
	BURN_TASKID_STOP_SOUND=allocate_typed_task_id(player_task)
	register_event("ResetHUD","molotov_newRound","b")

}

//----------------------------------------------------------------------------------------------
public molotov_newRound(id)
{	
	if(shModActive()&&client_hittable(id)){
		if(gIsBurning[id]){
			sh_unmolly_user(id)
		}

	}
	
}
public plugin_precache(){
	
	precache_sound(gSoundBurning)
	precache_sound(gSoundScream)

}
public plugin_natives(){
	
	register_native("sh_molly_user","_sh_molly_user",0);
	register_native("sh_unmolly_user","_sh_unmolly_user",0);
}
public burn_task(array[],id)
{
	id-=BURN_TASKID_MAIN
	
	if ( !shModActive() || !client_hittable(id)||!client_hittable(array[0])) return PLUGIN_CONTINUE
	
	set_render_with_color_const(id,PINK,1,50,50,1,1)
	make_fire(id,30.0)
	new origin[3],dist,i,burned_origin[3]
	get_user_origin(id,burned_origin)
	for ( i = 1; i <= SH_MAXSLOTS; i++) {
		
		if( !client_hittable(i) || i==id || gIsBurning[i] ) continue
		get_user_origin(i,origin)
		dist = get_distance(origin,burned_origin)
		if (dist <= MOLLY_PROPAGATE_RADIUS) {
			
			sh_molly_user(i,id,tranq_get_hero_id())
			
		}
	}

	if ( !is_user_alive(id) || pev(id, pev_waterlevel) == 3 ) {
		gIsBurning[id] = false
		return PLUGIN_CONTINUE
	}

	if ( !gIsBurning[id] )
		return PLUGIN_CONTINUE
	

	sh_extra_damage(id,array[0],BURN_DAMAGE,"Burning",0,SH_DMG_NORM)
	return PLUGIN_CONTINUE
}

public molotov_damage_vulnerability(id){
	if ( !shModActive() || !client_hittable(id)) return
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

//----------------------------------------------------------------------------------------------
public fire_scream(id)
{
	id-=BURN_TASKID_SCREAMS
	if(!is_user_connected(id)) return

	emit_sound(id, CHAN_VOICE, gSoundScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
public stop_fire_sound(id)
{
	id-=BURN_TASKID_STOP_SOUND
	if(!is_user_connected(id)) return
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
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
	new array[1]
	array[0] = attacker
	gIsBurning[id]=true
	set_damage_icon(id,2,DMG_ICON_HEAT,LineColors[RED])
	set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID_MAIN,array, sizeof(array), "a",BURN_TIMES)
	set_task(BURN_PERIOD, "fire_sound", id+BURN_TASKID_SOUND, "", 0,  "a", BURN_TIMES);
	set_task(0.7, "fire_scream", id+BURN_TASKID_SCREAMS)
	set_task(5.5, "stop_fire_sound", id+BURN_TASKID_STOP_SOUND)
	set_task(floatsub(BURN_TIME,0.1),"unburn_task",id+UNMOLLY_TASKID,"", 0,  "a",1)
	
	
	
}
// Make fire sounds
public fire_sound(id) {
	id-=BURN_TASKID_SOUND
	emit_sound(id, CHAN_AUTO, MOLLY_FIRE_SFX , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public unburn_task(id){
	id-=UNMOLLY_TASKID
	remove_task(id+BURN_TASKID_MAIN)
	remove_task(id+BURN_TASKID_SOUND)
	remove_task(id+BURN_TASKID_SCREAMS)
	remove_task(id+BURN_TASKID_STOP_SOUND)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_damage_icon(id,0,DMG_ICON_HEAT)
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	set_user_rendering(id)
	unfade_screen_user(id)
	
	gIsBurning[id]=false
	
	
	
}

unburn_user(id){
	remove_task(id+BURN_TASKID_MAIN)
	remove_task(id+BURN_TASKID_SOUND)
	remove_task(id+BURN_TASKID_SCREAMS)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_damage_icon(id,0,DMG_ICON_HEAT)
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	unfade_screen_user(id)
	set_user_rendering(id)
	gIsBurning[id]=false
	
	
	
}

public on_death_burning()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unmolly_user(id)
	
	}
	
}