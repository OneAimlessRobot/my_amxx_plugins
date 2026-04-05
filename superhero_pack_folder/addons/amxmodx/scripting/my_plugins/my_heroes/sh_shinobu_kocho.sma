#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <xs>
#include "shinobu_knife/shinobu_general.inc"
#include "shinobu_knife/shinobu_knife_funcs.inc"
#include "shinobu_knife/shinobu_usp_funcs.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"
#include "../my_include/my_author_header.inc"


stock SHINOBU_POISON_KICK_DELAYED_TASKID

// GLOBAL VARIABLES
new gHeroName[]="Shinobu Kocho"
new bool:gHasShinobu[SH_MAXSLOTS+1]
new g_shinobu_tagged_player[SH_MAXSLOTS+1]
new Float:shinobu_cooldown
new Float:shinobu_poison_kick_delay
new gHeroID
new dmg_source_name_short_poison_kick[SAFE_BUFFER_SIZE+1]="poison_kick"
new dmg_source_name_long_poison_kick[SAFE_BUFFER_SIZE+1]="shinobu_poison_kick"
new custom_weapon_damage_sharp_poison_kick_id

new Float:shinobu_poison_kick_stun_time,
	Float:shinobu_poison_kick_stun_speed,
	Float:shinobu_max_health


new shinobu_poison_kick_knockback

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Shinobu Kocho","1.0",AUTHOR)
	
	register_cvar("shinobu_level", "19" )
	register_cvar("shinobu_cooldown", "10.0" )
	register_cvar("shinobu_max_health", "100.0" )
	register_cvar("shinobu_poison_kick_delay","2.0")
	register_cvar("shinobu_poison_kick_stun_time", "10.0" )
	register_cvar("shinobu_poison_kick_stun_speed", "110.0" )
	register_cvar("shinobu_poison_kick_knockback","1")
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Poison Hashira", "Be polite, be sneaky. And make them suffer", true, "shinobu_level" )
	register_event("Damage","shinobuDamage","b", "2!0")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	register_logevent("ev_SendAudio", 2, "1=Round_End")
	register_logevent("ev_SendAudio", 2, "1&Restart_Round_")
	register_srvcmd("shinobu_init", "shinobu_init")
	shRegHeroInit(gHeroName, "shinobu_init")
	RegisterHam(Ham_TakeDamage,"player","ham_Shinobu_fallDamage")

	register_message(get_user_msgid("Health"), "Shinobu_Limit_HP")

	
	register_srvcmd("shinobu_kd", "shinobu_kd")
	shRegKeyDown(gHeroName, "shinobu_kd")

	register_forward(FM_PlayerPreThink, "shinobu_prethink")
	register_forward(FM_CmdStart,"Crouch")
	SHINOBU_POISON_KICK_DELAYED_TASKID=allocate_typed_task_id(player_task)
	
	custom_weapon_damage_sharp_poison_kick_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_poison_kick,
								dmg_source_name_long_poison_kick,
								0)
	init_hud_syncs()
}
public plugin_natives(){
	
	register_native("shinobu_get_user_tagged_player","_shinobu_get_user_tagged_player",0)
	register_native("shinobu_set_user_tagged_player","_shinobu_set_user_tagged_player",0)
	register_native("shinobu_get_cooldown","_shinobu_get_cooldown",0)
	register_native("shinobu_get_hero_id","_shinobu_get_hero_id",0)
	register_native("shinobu_get_max_hp","_shinobu_get_max_hp",0)
	
	
	
}


//----------------------------------------------------------------------------------------------
public ham_Shinobu_fallDamage(this, inflictor, attacker, Float:damage, damagebits)
{
	if ( damagebits & DMG_FALL && gHasShinobu[this] ) return HAM_SUPERCEDE

	return HAM_IGNORED
}
public Shinobu_Limit_HP(msgid, dest, id)
{
	if(!sh_is_active()) return

	if(!client_hittable(id)) return

	if(!gHasShinobu[id]) return

	static the_health_to_be_set
	the_health_to_be_set = get_msg_arg_int(1)

	static the_resulting_health;
	the_resulting_health=min(floatround(shinobu_max_health),the_health_to_be_set)
	
	set_user_health(id,the_resulting_health)
	
	if ( the_resulting_health <= 255 ) {
		set_msg_arg_int(1, ARG_BYTE, the_resulting_health)
	}

}
public client_disconnected(id){

	g_shinobu_tagged_player[id]=0
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		if(is_user_connected(i)){
			g_shinobu_tagged_player[i]=((g_shinobu_tagged_player[i]==id)?0:g_shinobu_tagged_player[i])
		}

	}

}

public ev_SendAudio(){
	
	return PLUGIN_CONTINUE
}
public _shinobu_get_user_tagged_player(iPlugin,iParams){
	new id= get_param(1)
	return g_shinobu_tagged_player[id]
}
public _shinobu_set_user_tagged_player(iPlugin,iParams){
	new id= get_param(1)
	new value= get_param(2)
	g_shinobu_tagged_player[id]=value
}

public _shinobu_get_hero_id(iPlugins, iParms){
	
	return gHeroID
	
}
public Float:_shinobu_get_max_hp(iPlugins, iParms){
	
	return shinobu_max_health
	
}
public Float:_shinobu_get_cooldown(iPlugins, iParms){
	
	return shinobu_cooldown
	
}

public shinobuDamage(id)
{
	if ( !shModActive() || !client_hittable(id)) return PLUGIN_CONTINUE
	new victim=id
	new weapon, attacker = get_user_attacker(victim, weapon)
	if ( !client_hittable(attacker)||!attacker) return PLUGIN_CONTINUE
	
	if(sh_clients_are_same_team(victim,attacker)||(victim==attacker)){
		return PLUGIN_CONTINUE
	}	
	if((weapon==CSW_KNIFE)){
		
		if ( gHasShinobu[victim] ) {
			
			shinobu_burst_damage_task_bootstrap(victim,attacker)

		}
		if(gHasShinobu[attacker]){

			do_bleed_knife_attack(victim,attacker,gHeroID,10,35,gHasShinobu[attacker],_,_,0);
			shinobu_burst_damage_task_bootstrap(attacker,victim)
		}	
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	shinobu_cooldown = get_cvar_float("shinobu_cooldown")
	shinobu_max_health = get_cvar_float("shinobu_max_health")
	shinobu_poison_kick_delay = get_cvar_float("shinobu_poison_kick_delay")
	shinobu_poison_kick_stun_time = get_cvar_float("shinobu_poison_kick_stun_time")
	shinobu_poison_kick_stun_speed = get_cvar_float("shinobu_poison_kick_stun_speed")
	shinobu_poison_kick_knockback = get_cvar_num("shinobu_poison_kick_knockback")

}
//----------------------------------------------------------------------------------------------
public shinobu_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	
	gHasShinobu[id] = (hasPowers!=0)
	if(gHasShinobu[id]){

		shinobu_weapons(id)
	}
	else{

		shinobu_unweapons(id)


	}
	g_shinobu_tagged_player[id]=0
}
public shinobu_burst_damage_task_bootstrap(attacker,tg){
	if(g_shinobu_tagged_player[attacker]==tg) return
	g_shinobu_tagged_player[attacker]=tg
	new parm[1]
	parm[0]=tg
	set_task(shinobu_poison_kick_delay, "shinobu_burst_damage_task",attacker+SHINOBU_POISON_KICK_DELAYED_TASKID,parm,sizeof parm)

}
public shinobu_burst_damage_task(array[],attacker){
	attacker-=SHINOBU_POISON_KICK_DELAYED_TASKID
	
	if(!client_hittable(attacker)) return

	new tg= array[0]

	if(!client_hittable(tg)) return

	
	if(!gHasShinobu[attacker] ) return

	if(!is_user_bot(tg)){
		sh_chat_message(tg,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[shinobu_shinobu_shinobu_shinobu_dickery_sentences_id:random_num(0,_:MAX_DICKERY-1)])
	}
	if(!is_user_bot(attacker)){
		sh_chat_message(attacker,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[shinobu_shinobu_shinobu_shinobu_dickery_sentences_id:random_num(0,_:MAX_DICKERY-1)])
	}

	new enemy_health=get_user_health(tg)

	new damage_to_cause=floatround((float(enemy_health)/2.0)-1.0,floatround_floor)

	sh_extra_damage(tg,attacker,damage_to_cause,dmg_source_name_long_poison_kick,0,_,_,_,_,_,
					SH_NEW_DMG_DRAIN,
					custom_weapon_damage_sharp_poison_kick_id)

	
	if(!client_hittable(tg)) return

	user_slap(tg, shinobu_poison_kick_knockback,0)

	generic_heal(heal_hp_hud_msg_sync,attacker,float(damage_to_cause),_,PURPLE,_,_,50,1,1)


	sh_screen_shake(tg, 14.0, 14.0, 14.0)
	
	sh_set_stun(tg,shinobu_poison_kick_stun_time,shinobu_poison_kick_stun_speed)
	
	sh_bleed_user(tg,attacker,MINI_BLEED,gHeroID,0)
	
	sh_effect_user_direct(tg,attacker,gHeroID,_:POISON)
}
shinobu_teleport_init(id){

	sh_chat_message(id,gHeroID,"Shinobu teleport initted!");
	nani_behind_player(id,g_shinobu_tagged_player[id],80.0)

}
//----------------------------------------------------------------------------------------------
public shinobu_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !client_hittable(id) ) return PLUGIN_HANDLED
	
	if(!gHasShinobu[id]) return PLUGIN_HANDLED
	
	if(sh_get_user_is_asleep(id)) return PLUGIN_HANDLED
	if(sh_get_user_is_chaffed(id)) return PLUGIN_HANDLED

	// Let them know they already used their ultimate if they have
	
	if(g_shinobu_tagged_player[id]<=0){

		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID,"Tag someone to teleport!");
		}
		return PLUGIN_HANDLED
	}
	else if(!client_hittable(g_shinobu_tagged_player[id])){
		new tg_is_connected=is_user_connected(g_shinobu_tagged_player[id])
		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID, "Unavailable. They are %s",
						tg_is_connected?"Not alive! (Try again when they respawn ^^-^^)":"Not connected.");
		}
		return PLUGIN_HANDLED
	}
	sh_chat_message(id,shinobu_get_hero_id(),"%s",shinobu_visiting_sentences[shinobu_visiting_sentences_id:random_num(0,_:MAX_SHINOBU_VISITING_SENTENCES-1)])	
	shinobu_teleport_init(id)
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public shinobu_prethink(id)
{
	if ( sh_is_active()){
		if(client_hittable(id)){
			if(gHasShinobu[id]){
				static weapon;
				weapon=cs_get_user_weapon(id)
				if((weapon==CSW_KNIFE)||(weapon==SHINOBU_WEAPON_CLASSID)) {
					set_pev(id, pev_flTimeStepSound, 999)
					}
				}
			}
	}
}
public death()
{
	if(!sh_is_active()) return
	
	new id = read_data(2)
	new killer= read_data(1)
	
	if(is_user_connected(killer)&&is_user_connected(id)){
		if(gHasShinobu[killer]){
			
			if(g_shinobu_tagged_player[killer]==id){
				if(!is_user_bot(id)){
					sh_chat_message(id,gHeroID,"%s",happy_sentences[shinobu_happy_sentence_id:random_num(0,_:MAX_SHINOBU_HAPPY_SENTENCES-1)])
				}
				if(!is_user_bot(killer)){
					sh_chat_message(killer,gHeroID,"%s",happy_sentences[shinobu_happy_sentence_id:random_num(0,_:MAX_SHINOBU_HAPPY_SENTENCES-1)])
				}
				remove_task(killer+SHINOBU_POISON_KICK_DELAYED_TASKID)
			}
		}
		if(gHasShinobu[id]){
			
			g_shinobu_tagged_player[id]=0
			remove_task(id+SHINOBU_POISON_KICK_DELAYED_TASKID)
		}
		
	}
		
}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if ( !sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)){
	
		return DMG_FWD_PASS
	}
	if(new_dmg_type==SH_NEW_DMG_DRUG_POISON){
		if(gHasShinobu[victim]){
			sh_chat_message(victim,gHeroID,"Awww? That was a [nice] try! But I drank it like pina colada ;)")
			generic_heal(heal_hp_hud_msg_sync,victim,float(damage),_,PURPLE,_,_,50,1,1)
			return DMG_FWD_BLOCK
		}
	}
	
	return DMG_FWD_PASS
}
