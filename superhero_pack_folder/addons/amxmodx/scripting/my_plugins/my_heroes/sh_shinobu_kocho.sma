
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_PDATA_ALIASES
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_PRECACHE_UTILITIES
#include <amxconst>
#include <csx>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "shinobu_knife/shinobu_knife_funcs.inc"
#include "shinobu_knife/shinobu_usp_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "../my_include/my_author_header.inc"


new num_happy_sentences = 0
new happy_sentences[][]={

    "Ara ara~ Enjoy the nap ^^-^^",
    "Hmm? What was that? ^"Mi Mi Mi^"?",
    "Ops, Im sorry! Can you repeat from earlier?",
    "Oooh... You were feeling sick earlier. Are you feeling better?",
    "I SHANKED EM DEMON GUTS NOW I SMELL BAD ^^-^^",
    ""

}


new num_that_fucker_sentences = 0
new shinobu_shinobu_shinobu_shinobu_dickery_sentences[][]={

    "Awww, does tummy hurt?",
    "I drink this stuff daily~ Is it really that bad?",
    "Its not hurting... Its a cure~",
    "Parsing tomfoolery files~",
    ""

}

new num_neurodivergent_inclusivity_sentences = 0

new rehearsed_neurodivergent_inclusivity[][]={

    "Aww! Im so sorry! Im sure they have crayons in hell, though...",
    "Let it go, now.Your obnixious 4chan posts do not matter past the pearly gates :P",
    ""

}



new const DEBUG = 0

stock SHINOBU_POISON_KICK_DELAYED_TASKID

// GLOBAL VARIABLES
#define gHeroName "Shinobu Kocho"
new g_shinobu_tagged_player[SH_MAXSLOTS+1]

new dmg_source_name_short_poison_kick[SAFE_BUFFER_SIZE+1]="poison_kick"
new dmg_source_name_log_poison_kick[SAFE_BUFFER_SIZE+1]="shinobu_poison_kick"
new custom_weapon_damage_sharp_poison_kick_id

new pcvar_shinobu_poison_kick_stun_time,
	pcvar_shinobu_poison_kick_stun_speed

new pcvar_shinobu_cooldown
new pcvar_shinobu_poison_kick_delay


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
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Poison Hashira", "Be polite, be sneaky. And make them suffer", true, "shinobu_level")
	
	RegisterHam(Ham_TakeDamage, "player", "shinobuDamage",1,true)
	
	
	sh_register_hero_healthcap(gHeroID, 90.0)

	sh_assign_hero_bit(gHeroID, SH_ANNOYING_HERO, true)

	sh_assign_hero_bit(gHeroID, SH_BOT_RESTRICTED, true)

	sh_assign_hero_bit(gHeroID, SH_ANTI_FALL_DAMAGE_HERO, true)

	sh_assign_hero_bit(gHeroID, SH_PARASITE_HERO_I_HATE_THEM, true)


	SHINOBU_POISON_KICK_DELAYED_TASKID=allocate_typed_task_id(player_task)
	
	custom_weapon_damage_sharp_poison_kick_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_poison_kick,
								dmg_source_name_log_poison_kick,
								0)

}

public plugin_natives(){
	
	register_native("shinobu_get_user_tagged_player","_shinobu_get_user_tagged_player")
	register_native("shinobu_set_user_tagged_player","_shinobu_set_user_tagged_player")
	register_native("shinobu_get_cooldown","_shinobu_get_cooldown")
	register_native("shinobu_get_hero_id","_shinobu_get_hero_id")
	
	
	
}


public client_disconnected(id){

	for(new i=1;i< sh_maxplayers()+1;i++){
		if(is_user_connected(i)){
			
			g_shinobu_tagged_player[i]=((g_shinobu_tagged_player[i]==id)?0:g_shinobu_tagged_player[i])
			
		}	

	}
	task_safeguard_macro_for_player_task(id,SHINOBU_POISON_KICK_DELAYED_TASKID,SH_MAXSLOTS)
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
public Float:_shinobu_get_cooldown(iPlugins, iParms){
	
	return cvar_val(float, pcvar_shinobu_cooldown)
	
}
shinobu_damage_interaction(attacker,victim){

	if (sh_get_user_has_hero(victim,gHeroID)  ) {
		
		shinobu_burst_damage_task_bootstrap(victim,attacker,0)

	}
	if(sh_get_user_has_hero(attacker,gHeroID) ){

		shinobu_burst_damage_task_bootstrap(attacker,victim,1)
	}	
}
public shinobuDamage(id, idinflictor, attacker, Float:damage, damagebits)
{
	if ( sh_is_freezetime() ||!sh_is_inround() ||  !sh_is_active() || !is_user_connected(id)) return HAM_IGNORED
	
	if ( !is_user_alive(attacker)||!attacker) return HAM_IGNORED
	
	new weapon, my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)
	
	weapon = get_user_weapon(attacker)
	
	pev(id, pev_dmg_take, damage)

	if(sh_clients_are_same_team(id,attacker)||(id==attacker)){
		return HAM_IGNORED
	}	
	if((weapon==CSW_KNIFE)){

		do_bleed_knife_attack(id,attacker,gHeroID,10,35,sh_get_user_has_hero(attacker,gHeroID) ,_,_,0,
					the_hitpoint);
		shinobu_damage_interaction(attacker,id)

	}
	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if(sh_get_user_has_hero(id,gHeroID) ){

		shinobu_weapons(id)
	}
	else{

		shinobu_unweapons(id)


	}
	g_shinobu_tagged_player[id]=0
}
shinobu_burst_damage_task_bootstrap(attacker,tg,is_attacking=1){
	if((g_shinobu_tagged_player[attacker] == tg)&&is_attacking) return
	if(DEBUG){

		sh_chat_message(attacker,gHeroID,"you have been tagged by shinobu!")
	}
	if(task_exists(attacker+SHINOBU_POISON_KICK_DELAYED_TASKID)){

		if(DEBUG){

			sh_chat_message(attacker,gHeroID,"task already exists! Lucky!")
		}
		return
	}
	else if(DEBUG){

		sh_chat_message(attacker,gHeroID,"prepare for trouble, scumbag")
	}

	g_shinobu_tagged_player[attacker]=tg
	new parm[1]
	parm[0]=tg
	set_task(cvar_val(float, pcvar_shinobu_poison_kick_delay),
				"shinobu_burst_damage_task",attacker+SHINOBU_POISON_KICK_DELAYED_TASKID,parm,sizeof parm)

}
public client_connect(id){


	task_safeguard_macro_for_player_task(id,SHINOBU_POISON_KICK_DELAYED_TASKID,SH_MAXSLOTS)
	
}
public shinobu_burst_damage_task(array[1],attacker){
	attacker-=SHINOBU_POISON_KICK_DELAYED_TASKID
	if(!is_user_connected(attacker)) return

	new tg= array[0]

	if(!is_user_alive(tg)) return

	
	if(!sh_get_user_has_hero(attacker,gHeroID)  ) return

	new the_num = generate_int(0,num_that_fucker_sentences-1)

	if(!is_user_bot(tg)){
		sh_chat_message(tg,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[the_num])
	}
	if(!is_user_bot(attacker)){
		sh_chat_message(attacker,gHeroID,"%s",shinobu_shinobu_shinobu_shinobu_dickery_sentences[the_num])
	}

	new enemy_health=get_user_health(tg)

	new damage_to_cause=floatround((float(enemy_health)/2.0)-1.0,floatround_floor)

	sh_extra_damage(tg,attacker,damage_to_cause,
					_,_,_,_,_,
					SH_NEW_DMG_DRAIN,
					custom_weapon_damage_sharp_poison_kick_id)

	
	if(!is_user_alive(tg)) return

	user_slap(tg, 0,0)

	generic_heal(attacker,float(damage_to_cause),_,PURPLE,_,_,50,1,1)


	sh_screen_shake(tg, 14.0, 14.0, 14.0)
	
	sh_set_stun(tg,
		cvar_val(float, pcvar_shinobu_poison_kick_stun_time),
		cvar_val(float, pcvar_shinobu_poison_kick_stun_speed))
	
	sh_bleed_user(tg,attacker,BLEED_MINI,gHeroID,0)
	
	sh_effect_user_direct(tg,attacker,10.0,gHeroID,POISON)
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
	if ( !is_user_alive(id) ) return
	
	if(!sh_get_user_has_hero(id,gHeroID) ) return
	

	// Let them know they already used their ultimate if they have
	
	if(g_shinobu_tagged_player[id]<=0){

		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id,gHeroID,"Tag someone to teleport!");
		}
		return
	}
	else if(!is_user_alive(g_shinobu_tagged_player[id])){
		new tg_is_connected=is_user_connected(g_shinobu_tagged_player[id])
		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id,gHeroID, "Unavailable. They are %s",
						tg_is_connected?"Not alive! (Try again when they respawn ^^-^^)":"Not connected.");
		}
		return
	}
	shinobu_teleport_init(id)
}
public sh_round_end(){

	for (new id = 1; id < sh_maxplayers()+1; id++) {
		
		if(task_exists(id + SHINOBU_POISON_KICK_DELAYED_TASKID)){
			remove_task(id + SHINOBU_POISON_KICK_DELAYED_TASKID)
		}
	}

}
public sh_round_new(){

	for (new id = 1; id < sh_maxplayers()+1; id++) {
		
		if(task_exists(id + SHINOBU_POISON_KICK_DELAYED_TASKID)){
			remove_task(id + SHINOBU_POISON_KICK_DELAYED_TASKID)
		}
	}

}
public plugin_precache(){


	num_happy_sentences = count_null_terminated_string_array(happy_sentences,
															"Shinobu happy sentences",
															"Sentence",
															DEBUG)

	num_that_fucker_sentences = count_null_terminated_string_array(shinobu_shinobu_shinobu_shinobu_dickery_sentences,
																"Shinobu fucker sentences",
																"Sentence",
																DEBUG)

															

	num_neurodivergent_inclusivity_sentences = count_null_terminated_string_array(rehearsed_neurodivergent_inclusivity,
																"Shinobu autist rights sentences",
																"Sentence",
																DEBUG)


}
public sh_client_death(id,killer)
{
	if(!sh_is_active()) return
	
	
	if(is_user_connected(killer)&&is_user_connected(id)){
		if(sh_get_user_has_hero(killer,gHeroID) ){
			
			if(g_shinobu_tagged_player[killer]==id){
				
				new bool:is_nd = sh_get_player_has_hero_prop(id, SH_NEURODIVERGENT_HERO)

				new happy_num = generate_int(0,num_happy_sentences-1),
					nd_num = generate_int(0,num_neurodivergent_inclusivity_sentences-1)

				if(!is_user_bot(id)){
					sh_chat_message(id,gHeroID,"%s", is_nd? rehearsed_neurodivergent_inclusivity[nd_num]:happy_sentences[happy_num])
				}
				if(!is_user_bot(killer)){
					sh_chat_message(killer,gHeroID,"%s",is_nd? rehearsed_neurodivergent_inclusivity[nd_num]:happy_sentences[happy_num])
				}
				remove_task(killer+SHINOBU_POISON_KICK_DELAYED_TASKID)
			}
		}
		if(sh_get_user_has_hero(id,gHeroID) ){
			
			remove_task(id+SHINOBU_POISON_KICK_DELAYED_TASKID)
			g_shinobu_tagged_player[id]=0
		}
		
	}
		
}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id, &bool:values_should_change){
	
	
	if(damage <= 0){
            
		return DMG_FWD_PASS
	}
	
	if ( sh_is_freezetime() ||!sh_is_inround() || !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	if(sh_clients_are_same_team(victim,attacker)||(victim==attacker)){
		return DMG_FWD_PASS
	}
	if(new_dmg_type==SH_NEW_DMG_DRUG_POISON){
		if(sh_get_user_has_hero(victim,gHeroID) ){
			generic_heal(victim,float(damage),_,PURPLE,_,_,50,1,1)
			return DMG_FWD_BLOCK
		}
	}
	if(is_valid_custom_dmg_source(custom_weapon_id)){
		new bool:is_melee = bool:xmod_is_melee_wpn(custom_weapon_id)
		if(is_melee){
			shinobu_damage_interaction(attacker,victim)
		}
	}
	
	return DMG_FWD_PASS
}
