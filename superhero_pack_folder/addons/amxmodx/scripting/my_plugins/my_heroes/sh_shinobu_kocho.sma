#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "shinobu_knife/shinobu_knife_funcs.inc"
#include "shinobu_knife/shinobu_usp_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "../my_include/my_author_header.inc"

stock const DEBUG= 0

stock SHINOBU_POISON_KICK_DELAYED_TASKID,
	SHINOBU_GLOBAL_SILENT_FOOTSTEPS_LOOP

// GLOBAL VARIABLES
new gHeroName[]="Shinobu Kocho"
new g_shinobu_tagged_player[SH_MAXSLOTS+1]
new gHeroID
new dmg_source_name_short_poison_kick[SAFE_BUFFER_SIZE+1]="poison_kick"
new dmg_source_name_log_poison_kick[SAFE_BUFFER_SIZE+1]="shinobu_poison_kick"
new custom_weapon_damage_sharp_poison_kick_id

new pcvar_shinobu_poison_kick_stun_time,
	pcvar_shinobu_poison_kick_stun_speed

static const shinobu_max_health = 90

new gMessageID_Health
new pcvar_shinobu_cooldown
new pcvar_shinobu_poison_kick_delay


new pcvar_shinobu_poison_kick_knockback

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Shinobu Kocho","1.0",AUTHOR)
	
	create_cvar("shinobu_level", "19" )
	pcvar_shinobu_cooldown = create_cvar("shinobu_cooldown", "10.0" )
	pcvar_shinobu_poison_kick_delay = create_cvar("shinobu_poison_kick_delay","2.0")
	pcvar_shinobu_poison_kick_stun_time = create_cvar("shinobu_poison_kick_stun_time", "10.0" )
	pcvar_shinobu_poison_kick_stun_speed = create_cvar("shinobu_poison_kick_stun_speed", "110.0" )
	pcvar_shinobu_poison_kick_knockback = create_cvar("shinobu_poison_kick_knockback","1")
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Poison Hashira", "Be polite, be sneaky. And make them suffer", true, "shinobu_level",true )
	register_event("Damage","shinobuDamage","b", "2!0")
	
	RegisterHam(Ham_TakeDamage,"player","ham_Shinobu_fallDamage",_, true)
	
	gMessageID_Health = get_user_msgid("Health")

	register_message(gMessageID_Health, "Shinobu_Limit_HP")


	SHINOBU_POISON_KICK_DELAYED_TASKID=allocate_typed_task_id(player_task)
	SHINOBU_GLOBAL_SILENT_FOOTSTEPS_LOOP=allocate_typed_task_id(generic_task)
	
	custom_weapon_damage_sharp_poison_kick_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_poison_kick,
								dmg_source_name_log_poison_kick,
								0)
	set_task(1.0,"shinobu_step_silent",SHINOBU_GLOBAL_SILENT_FOOTSTEPS_LOOP,_,_,"b")
	init_hud_syncs()
}
public plugin_natives(){
	
	register_native("shinobu_get_user_tagged_player","_shinobu_get_user_tagged_player")
	register_native("shinobu_set_user_tagged_player","_shinobu_set_user_tagged_player")
	register_native("shinobu_get_cooldown","_shinobu_get_cooldown")
	register_native("shinobu_get_hero_id","_shinobu_get_hero_id")
	register_native("shinobu_get_max_hp","_shinobu_get_max_hp")
	
	
	
}

//----------------------------------------------------------------------------------------------
public shinobu_step_silent(task_id)
{
	if (! sh_is_active()) return
	
	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]
		if((entity_get_int(id,EV_INT_flags)& FL_ONGROUND)){
			if(sh_get_user_has_hero(id,gHeroID) ){
				static wpnid
				wpnid=get_user_weapon(id)
				if((wpnid==CSW_KNIFE)||(wpnid==SHINOBU_WEAPON_CLASSID)) {
					entity_set_int(id, EV_INT_flTimeStepSound, 2000)
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_get_user_has_hero(id,gHeroID) ) {
		new the_health_to_send = min(get_user_health(id),shinobu_max_health)

		set_user_health(id, the_health_to_send)
		
		message_begin(MSG_ONE_UNRELIABLE, gMessageID_Health, {0,0,0}, id);
		
		write_byte(the_health_to_send);
		
		message_end();
	}
}
//----------------------------------------------------------------------------------------------
public ham_Shinobu_fallDamage(this, inflictor, attacker, Float:damage, damagebits)
{
	if(!sh_is_active()||sh_is_freezetime()) return HAM_IGNORED

	if ( damagebits & DMG_FALL && sh_get_user_has_hero(this,gHeroID) ) return HAM_SUPERCEDE

	return HAM_IGNORED
}
public Shinobu_Limit_HP(msgid, dest, id)
{
	if(!sh_is_active()) return

	if(!is_user_alive(id)) return

	if(!sh_get_user_has_hero(id,gHeroID) ) return

	static the_health_to_be_set
	the_health_to_be_set = get_msg_arg_int(1)

	static the_resulting_health;
	the_resulting_health=min(
					shinobu_max_health,
						the_health_to_be_set)
	
	set_user_health(id,the_resulting_health)
	
	if ( the_resulting_health <= 255 ) {
		set_msg_arg_int(1, ARG_BYTE, the_resulting_health)
	}

}

public client_disconnected(id){

	for(new i=1;i< sh_maxplayers()+1;i++){
		if(is_user_connected(i)){
			
			g_shinobu_tagged_player[i]=((g_shinobu_tagged_player[i]==id)?0:g_shinobu_tagged_player[i])
			
		}	

	}
	g_shinobu_tagged_player[id]=0
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
public _shinobu_get_max_hp(iPlugins, iParms){
	
	return shinobu_max_health
	
}
public Float:_shinobu_get_cooldown(iPlugins, iParms){
	
	return cvar_val(float, pcvar_shinobu_cooldown)
	
}
shinobu_damage_interaction(attacker,victim,my_hitpoint_enum:hitpoint){

	if (sh_get_user_has_hero(victim,gHeroID)  ) {
		
		shinobu_burst_damage_task_bootstrap(victim,attacker,0)

	}
	if(sh_get_user_has_hero(attacker,gHeroID) ){

		do_bleed_knife_attack(victim,attacker,gHeroID,10,35,sh_get_user_has_hero(attacker,gHeroID) ,_,_,_,0,
					hitpoint);
		shinobu_burst_damage_task_bootstrap(attacker,victim,1)
	}	
}
public shinobuDamage(id)
{
	if ( !sh_is_active() || !is_user_connected(id)) return PLUGIN_CONTINUE
	new victim=id
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	if ( !is_user_alive(attacker)||!attacker) return PLUGIN_CONTINUE
	
	if(sh_clients_are_same_team(victim,attacker)||(victim==attacker)){
		return PLUGIN_CONTINUE
	}	
	if((weapon==CSW_KNIFE)){
		shinobu_damage_interaction(attacker,victim,my_hitpoint_enum:bodypart)
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if(sh_get_user_has_hero(id,gHeroID) ){

		shinobu_weapons(id)
		set_user_health(id,min(sh_get_max_hp(id),shinobu_max_health))
		manual_cloak_check(id)
	}
	else{

		shinobu_unweapons(id)
		uncloak_shinobu(id)


	}
	g_shinobu_tagged_player[id]=0
}
shinobu_burst_damage_task_bootstrap(attacker,tg,is_attacking=1){
	if((g_shinobu_tagged_player[attacker]==tg)&&is_attacking) return
	if(DEBUG){

		sh_chat_message(tg,gHeroID,"you have been tagged by shinobu!")
	}
	g_shinobu_tagged_player[attacker]=tg
	new parm[1]
	parm[0]=tg
	if(task_exists(attacker+SHINOBU_POISON_KICK_DELAYED_TASKID)){

		if(DEBUG){

			sh_chat_message(tg,gHeroID,"task already exists! Lucky!")
		}
		return
	}
	else if(DEBUG){

		sh_chat_message(tg,gHeroID,"prepare for trouble, scumbag")
	}
	set_task(cvar_val(float, pcvar_shinobu_poison_kick_delay),
				"shinobu_burst_damage_task",attacker+SHINOBU_POISON_KICK_DELAYED_TASKID,parm,sizeof parm)

}
public shinobu_burst_damage_task(array[1],attacker){
	attacker-=SHINOBU_POISON_KICK_DELAYED_TASKID
	if(!is_user_connected(attacker)) return

	new tg= array[0]

	if(!is_user_alive(tg)) return

	
	if(!sh_get_user_has_hero(attacker,gHeroID)  ) return

	if(!is_user_bot(tg)){
		sh_chat_message(tg,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[shinobu_shinobu_shinobu_shinobu_dickery_sentences_id:generate_int(0,
																								sizeof(shinobu_shinobu_shinobu_shinobu_dickery_sentences)-1)])
	}
	if(!is_user_bot(attacker)){
		sh_chat_message(attacker,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[shinobu_shinobu_shinobu_shinobu_dickery_sentences_id:generate_int(0,
																								sizeof(shinobu_shinobu_shinobu_shinobu_dickery_sentences)-1)])
	}

	new enemy_health=get_user_health(tg)

	new damage_to_cause=floatround((float(enemy_health)/2.0)-1.0,floatround_floor)

	sh_extra_damage(tg,attacker,damage_to_cause,
					_,_,_,_,_,
					SH_NEW_DMG_DRAIN,
					custom_weapon_damage_sharp_poison_kick_id)

	
	if(!is_user_alive(tg)) return

	user_slap(tg, cvar_val(num, pcvar_shinobu_poison_kick_knockback),0)

	generic_heal(heal_hp_hud_msg_sync,attacker,float(damage_to_cause),_,PURPLE,_,_,50,1,1)


	sh_screen_shake(tg, 14.0, 14.0, 14.0)
	
	sh_set_stun(tg,
		cvar_val(float, pcvar_shinobu_poison_kick_stun_time),
		cvar_val(float, pcvar_shinobu_poison_kick_stun_speed))
	
	sh_bleed_user(tg,attacker,BLEED_MINI,gHeroID,0)
	
	sh_effect_user_direct(tg,attacker,gHeroID,POISON)
}
shinobu_teleport_init(id){

	sh_chat_message(id,gHeroID,"Shinobu teleport initted!");
	nani_behind_player(id,g_shinobu_tagged_player[id],80.0)

}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		shinobu_kd(id)
	}
	
}
}
//----------------------------------------------------------------------------------------------
public shinobu_kd(id)
{
	if ( !is_user_alive(id) ) return PLUGIN_HANDLED
	
	if(!sh_get_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED
	

	// Let them know they already used their ultimate if they have
	
	if(g_shinobu_tagged_player[id]<=0){

		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID,"Tag someone to teleport!");
		}
		return PLUGIN_HANDLED
	}
	else if(!is_user_alive(g_shinobu_tagged_player[id])){
		new tg_is_connected=is_user_connected(g_shinobu_tagged_player[id])
		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID, "Unavailable. They are %s",
						tg_is_connected?"Not alive! (Try again when they respawn ^^-^^)":"Not connected.");
		}
		return PLUGIN_HANDLED
	}
	sh_chat_message(id,gHeroID,"%s",shinobu_visiting_sentences[shinobu_visiting_sentences_id:generate_int(0,sizeof(shinobu_visiting_sentences)-1)])	
	shinobu_teleport_init(id)
	return PLUGIN_HANDLED
}

public sh_client_death(id,killer)
{
	if(!sh_is_active()) return
	
	
	if(is_user_connected(killer)&&is_user_connected(id)){
		if(sh_get_user_has_hero(killer,gHeroID) ){
			
			if(g_shinobu_tagged_player[killer]==id){
				if(!is_user_bot(id)){
					sh_chat_message(id,gHeroID,"%s",happy_sentences[shinobu_happy_sentence_id:generate_int(0,sizeof(happy_sentences)-1)])
				}
				if(!is_user_bot(killer)){
					sh_chat_message(killer,gHeroID,"%s",happy_sentences[shinobu_happy_sentence_id:generate_int(0,sizeof(happy_sentences)-1)])
				}
				remove_task(killer+SHINOBU_POISON_KICK_DELAYED_TASKID)
			}
		}
		if(sh_get_user_has_hero(id,gHeroID) ){
			
			g_shinobu_tagged_player[id]=0
			remove_task(id+SHINOBU_POISON_KICK_DELAYED_TASKID)
		}
		
	}
		
}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	if(sh_clients_are_same_team(victim,attacker)||(victim==attacker)){
		return DMG_FWD_PASS
	}
	if(new_dmg_type==SH_NEW_DMG_DRUG_POISON){
		if(sh_get_user_has_hero(victim,gHeroID) ){
			generic_heal(heal_hp_hud_msg_sync,victim,float(damage),_,PURPLE,_,_,50,1,1)
			return DMG_FWD_BLOCK
		}
	}
	if(is_valid_custom_dmg_source(custom_weapon_id)){
		new bool:is_melee = bool:xmod_is_melee_wpn(custom_weapon_id)
		if(is_melee){
			shinobu_damage_interaction(attacker,victim,bodypart)
		}
	}
	
	return DMG_FWD_PASS
}
