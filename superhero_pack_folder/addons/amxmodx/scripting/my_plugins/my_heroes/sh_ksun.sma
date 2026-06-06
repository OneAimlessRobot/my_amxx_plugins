#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "./superheromod_help_files_includes/superheromod_help_files.inc"
#include "chikoi_inc/chikoi_inc.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "custom_grenades/custom_grenades.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"

#define MIN_KSUN_PAYCUT 0.01
#define MAX_KSUN_PAYCUT 0.6

new pcvar_cooldown
new pcvar_ksun_kill_type_broadness_level
new pcvar_ksun_spores_per_kill
new pcvar_ksun_spore_m4_mult
new pcvar_ksun_dmg_paycut
new pcvar_num_sleep_nades
new pcvar_ksun_max_victims
new pcvar_ksun_when_reset_spores;

// GLOBAL VARIABLES
new gHeroName[]="ksun"
new gMaxSporesUsable[SH_MAXSLOTS+1]
new gWeaponPlayerKilledPlayerWith[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new gHeroID
new gHeroID_chikoi = -1


//cvar_val(float, pcvar_

new dmg_source_name_short_ksun_debt[SAFE_BUFFER_SIZE+1]="ksun_debt"
new dmg_source_name_log_ksun_debt[SAFE_BUFFER_SIZE+1]="ksun_debt"
new custom_dmg_id_ksun_debt

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun","1.1",AUTHOR)
	
	create_cvar("ksun_level", "12" )
	pcvar_cooldown = create_cvar("ksun_cooldown", "10.0" )
	pcvar_ksun_dmg_paycut = create_cvar("ksun_dmg_paycut", "0.05" )
	set_pcvar_bounds(pcvar_ksun_dmg_paycut,CvarBound_Lower,true,MIN_KSUN_PAYCUT)
	set_pcvar_bounds(pcvar_ksun_dmg_paycut,CvarBound_Upper,true,MAX_KSUN_PAYCUT)
	pcvar_num_sleep_nades = create_cvar("ksun_num_of_sleep_nades","6")
	pcvar_ksun_kill_type_broadness_level = create_cvar("ksun_kill_type_broadness_level","0")
	pcvar_ksun_spores_per_kill = create_cvar("ksun_spores_per_kill","0")
	pcvar_ksun_spore_m4_mult = create_cvar("ksun_spore_m4_mult","0")
	pcvar_ksun_when_reset_spores = create_cvar("ksun_when_reset_spores","0")
	pcvar_ksun_max_victims = create_cvar("ksun_max_victims", "4" )
 
	
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Spore Launcher", "Launch spores that follow enemies!", true, "ksun_level",true)
	sh_register_superheromod_model(gHeroID,
								KSUN_PLAYER_MODEL,
								KSUN_PLAYER_MODEL,
								"ksun",
								"ksun: '...'",
								"ksun: '...'")
	
	sh_register_hero_healthcap(gHeroID, 210.0)


	sh_register_superheromod_weapon_model(gHeroID,KSUN_WEAPON_ID,KSUN_WPN_MODEL_V,KSUN_WPN_MODEL_P)



	sh_assign_hero_bit(gHeroID,SH_DREAM_EATER_HERO, true)
	
	
	sh_assign_hero_bit(gHeroID,SH_SMALL_HERO,true);

	
	static hero_name_arr[STRLEN_FOR_NAMES];
	arrayset(hero_name_arr,0,sizeof hero_name_arr)
	add(hero_name_arr,charsmax(hero_name_arr),gHeroName,charsmax(gHeroName))
	superheromod_help_link_hero(gHeroID, "ksun: Help file","ksun_folder/","ksun_help_file.html",hero_name_arr)
	
	custom_dmg_id_ksun_debt=
		sh_log_custom_damage_source(gHeroID,dmg_source_name_short_ksun_debt,
								dmg_source_name_log_ksun_debt,0)

	RegisterHam(Ham_TakeDamage, "player", "ksun_damage_debt",1,true)
	RegisterHam(Ham_TraceAttack,"player","ksun_physical_body",_,true)


	set_task(1.0,"ksun_step_silent",_,_,_,"b")
}
public plugin_natives(){
	
	
	register_native("ksun_get_num_available_spores","_ksun_get_num_available_spores");
	
	register_native("ksun_dec_num_available_spores","_ksun_dec_num_available_spores");
	
	
	
	register_native("ksun_get_when_reset_spores","_ksun_get_when_reset_spores");
	
	register_native("spores_ksun_hero_id","_spores_ksun_hero_id")
	
	
	
}
public plugin_cfg(){

	gHeroID_chikoi = chikoi_get_hero_id()
}
stock covert_spike_damage(id, &bool:spored_someone = false){
	static the_players[SH_MAXSLOTS], pnum, payer	
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		payer = the_players[k]
		
		if(sh_clients_are_same_team(payer,id) || (payer==id)) continue
		
		static Float:ksun_health
		
		ksun_health = entity_get_float(id,EV_FL_health)
		new max_hp_to_check = min(floatround(sh_get_player_healthcap(id)),sh_get_max_hp(id))

		if(sh_get_player_has_hero_prop(id,SH_HEALTH_CAP_HERO)&&
						floatround(ksun_health)>=(max_hp_to_check)){
				
				continue
		
		}
			
		new Float:times_spiked_by_me=float(get_times_player_spiked_by_player(payer,id))
		if((times_spiked_by_me>0.0)){
			spored_someone= true
			static Float:dmg_to_drain,
					Float:tmp_it_pct,
					Float:remaining,
					Float:tg_health

			tmp_it_pct=cvar_val(float,pcvar_ksun_dmg_paycut)
			tg_health=entity_get_float(payer,EV_FL_health)
			remaining = floatmul(tg_health, floatpower(1.0 - tmp_it_pct, times_spiked_by_me))
			dmg_to_drain = tg_health - remaining
			new actual_dmg_done = 0
			spored_someone = ksun_heal(id,dmg_to_drain, actual_dmg_done)

			if(spored_someone){
				sh_extra_damage(payer,id,actual_dmg_done,
						_,_,_,_,_,
						SH_NEW_DMG_DRAIN,
						custom_dmg_id_ksun_debt)
			}
		}
	}
}

stock overt_spike_damage(attacker,&Float:damage,is_in_ham_hook=1, &bool:spored_someone = false){
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	
	static the_players[SH_MAXSLOTS], pnum, collector		
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		collector = the_players[k]
		
		if(!sh_get_user_has_hero(collector,gHeroID)){

			continue
		}
		
		new CsTeams:collector_team=cs_get_user_team(collector)
		if(att_team==collector_team){
			
			continue
		}
		new times_spiked_by_them=get_times_player_spiked_player(collector,attacker)
		if((times_spiked_by_them>0)){
			new Float: pctDmgLost=cvar_val(float,pcvar_ksun_dmg_paycut)*float(times_spiked_by_them)
			new Float: dmgSnatched=1.0+(damage*pctDmgLost)
			new actual_dmg_done = 0
			spored_someone = ksun_heal(collector,dmgSnatched, actual_dmg_done)
			new Float:newDamage=damage- actual_dmg_done
			if(is_in_ham_hook){
				SetHamParamFloat(4, newDamage);
			}
			else{
				damage=newDamage
			}
		}


	}

}
public ksun_damage_debt(id, idinflictor, attacker, Float:damage, damagebits)
{
	if ( !sh_is_active() || !is_user_alive(id) || !is_user_alive(attacker)) return HAM_IGNORED
	

	if((damage<1.0)){
		
		return HAM_IGNORED

	}

	new bool:spored_someone_covert = false,
		bool:spored_someone_overt = false,
		bool:vic_has_hero = sh_get_user_has_hero(id,gHeroID),
		bool:att_has_hero = sh_get_user_has_hero(attacker,gHeroID)

	new weapon=get_user_weapon(attacker)
	
	if (idinflictor != attacker)
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = CSW_HEGRENADE;
	}
	else
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = weapon;
	}
	if(vic_has_hero &&COVERT_ABUSE_ENABLED){

		covert_spike_damage(id, spored_someone_covert)

	}

	if((attacker!=id)&&OVERT_ABUSE_ENABLED){
		overt_spike_damage(attacker,damage,1, spored_someone_overt)
	}
	if(spored_someone_overt||spored_someone_covert){

		emit_sound(id, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	if(att_has_hero){
		if(weapon==KSUN_WEAPON_ID){
			if(sh_get_id_bit(id, SH_IS_SLEEPING)){
			
				static tger_name[128], vic_name[128]
				get_user_name(attacker,vic_name,127)
				get_user_name(id,tger_name,127)
				ksun_heal(attacker,damage)
				new CsTeams:payer_team=cs_get_user_team(id)
				new CsTeams:att_team=cs_get_user_team(attacker)
				if(att_team!=payer_team){
					ksun_inc_player_supply_points(attacker,floatround(damage))
					if(vic_has_hero && (ksun_get_player_supply_points(id)>0)){
						ksun_dec_player_supply_points(id,floatround(damage))
					}
				}
			}
		}
	
	}
	return HAM_IGNORED
}

public ksun_physical_body(id, attacker, Float:damage, Float:direction[3], tracehandle, damagebits){
	
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!sh_is_active()) return HAM_IGNORED
	
	if(!is_user_alive(id)){

		return HAM_IGNORED;

	}
	if(!sh_get_user_has_hero(id,gHeroID) ){

		return HAM_IGNORED;

	}
	if(sh_get_user_has_hero(id,gHeroID_chikoi)){

		return HAM_IGNORED;

	}
	if(sh_clients_are_same_team(id,attacker)){

		return HAM_IGNORED
	}
	new hitgroup=get_tr2(tracehandle,TR_iHitgroup);
	switch(hitgroup){
		case HIT_CHEST:{
			set_tr2(tracehandle,TR_iHitgroup,HIT_HEAD);
		}
		case HIT_HEAD:{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED;
}
public client_disconnected(id){
	
	spores_reset_user(id)
	ksun_unultimate_user(id,_,1)
	gMaxSporesUsable[id] = 0
	
	
}

public sh_round_end(){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE
	for(new i=1;i< sh_maxplayers()+1;i++){
		if(!is_user_connected(i)){

			continue
		}
		if(!sh_get_user_has_hero(i,gHeroID) ){

			continue
		}
		arrayset(gWeaponPlayerKilledPlayerWith[i],0,SH_MAXSLOTS+1)
		
		ksun_unultimate_user(i,0,0)
	
	}
	
	if(any:cvar_val(num, pcvar_ksun_when_reset_spores)&reset_on_new_round){
		arrayset(gMaxSporesUsable,0,SH_MAXSLOTS+1)
	}
	return PLUGIN_CONTINUE
}

public _ksun_get_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	return gMaxSporesUsable[id]

}

public _ksun_get_when_reset_spores(iPlugin,iParams){

	return cvar_val(num, pcvar_ksun_when_reset_spores);

}
ksun_multi_inc_num_available_spores_primitive(id,value){

	gMaxSporesUsable[id]=((gMaxSporesUsable[id]+value)>=
							cvar_val(num, pcvar_ksun_max_victims))? 
								cvar_val(num, pcvar_ksun_max_victims):gMaxSporesUsable[id]+value

}
public _ksun_dec_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	gMaxSporesUsable[id]-= (gMaxSporesUsable[id]>0)? 1:0

}
public _spores_ksun_hero_id(iPlugins, iParms){

	return gHeroID
}
ksun_weapons(id)
{

if ( sh_is_active() && is_user_alive(id) && sh_get_user_has_hero(id,gHeroID) ) {
	give_custom_grenades(id,GREN_SLEEP,cvar_val(num, pcvar_num_sleep_nades))
	sh_give_weapon(id, KSUN_WEAPON_ID)
}
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}
	spores_reset_user(id)
	if ( sh_get_user_has_hero(id,gHeroID) ) {
		ksun_weapons(id)
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
	}
	return
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if(sh_get_user_has_hero(id, gHeroID)){

		ksun_weapons(id)
		
	
	}
	else{
		sh_drop_weapon(id, KSUN_WEAPON_ID, true)
	}
	ksun_unultimate_user(id,_,1)
	spores_reset_user(id)
	gMaxSporesUsable[id] = 0
	clean_ksun_spores_from_players(1,0,id);
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		ksun_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
public ksun_kd(id)
{
	
	if ( !is_user_alive(id) ) return PLUGIN_HANDLED
	
	if(!sh_get_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

	// Let them know they already used their ultimate if they have
	if ( sh_get_cooldown_flag(id)) {
		if(!is_user_bot(id)){
			sh_sound_deny(id)
		}
		return PLUGIN_HANDLED
	}
	else if(spores_busy(id)||ksun_player_is_in_ultimate(id)){
		
		if(!is_user_bot(id)){
			sh_sound_deny(id)
			if(!ksun_player_is_in_ultimate(id)){
				sh_chat_message(id,gHeroID,"Some launched spores still busy!");
			}
			else if(!spores_busy(id)){
				
				
				sh_chat_message(id,gHeroID,"Already in ultimate! Ignoring!");
					
				
			}
		}
		return PLUGIN_HANDLED
		
		
	}
	
	if(!ksun_player_is_ultimate_ready(id)){
		if(!gMaxSporesUsable[id]){
		
			
			if(!is_user_bot(id)){
				client_print(id,print_center,"%s",
					(cvar_val(num, pcvar_ksun_kill_type_broadness_level)<=1)?"[SH] ksun:^nKill someone with your M4A1 first":"[SH] ksun:^nKill someone first");
				sh_sound_deny(id)
			}
			return PLUGIN_HANDLED
		
		}
	
		if(!is_user_bot(id)){
			client_print(id,print_center,"%s",SEARCH_MSG)
		}
		spores_launch(id)
	}
	else{
		if(!is_user_bot(id)){
			static owner_name[128]
			get_user_name(id,owner_name,127)
			client_print(0,print_chat,"[SH](ksun): %s is glistening",owner_name)
		}
		spores_reset_user(id)
		ksun_player_engage_ultimate(id)
	}
	
	sh_set_cooldown(id, cvar_val(float, pcvar_cooldown))
	return PLUGIN_HANDLED
}



//----------------------------------------------------------------------------------------------
public ksun_step_silent(task_id)
{
	if (! sh_is_active()) return
	
	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]
		if((entity_get_int(id,EV_INT_flags)& FL_ONGROUND)){
			if(sh_get_user_has_hero(id,gHeroID) ){
				new alive=0,dead=0
				sh_get_player_counts(id,1,alive,dead)
				if((alive<=0)) {
					entity_set_int(id, EV_INT_flTimeStepSound, 2000)
				}
			}
		}
	}
}
stock ksun_death_handler(id){
	if(!sh_is_active()) return
	
	if(is_user_connected(id)){
		if(sh_get_user_has_hero(id,gHeroID) ){
			ksun_unultimate_user(id,1,0)

			if(any:cvar_val(num, pcvar_ksun_when_reset_spores)&reset_on_death){
				ammo_hud(id,gMaxSporesUsable[id],0)
				
				gMaxSporesUsable[id] = 0

				spores_reset_user(id)
				
			}
			clean_ksun_spores_from_players(1,0,id);

		}
		
	}

}
public sh_client_death(id, killer){
	
	ksun_death_handler(id)
	if(is_user_alive(killer)&&is_user_connected(id)){
		if(sh_get_user_has_hero(killer,gHeroID) &&!ksun_player_is_in_ultimate(killer)){
			ammo_hud(killer,gMaxSporesUsable[killer],0)
			if(cvar_val(num, pcvar_ksun_kill_type_broadness_level)<=1){
				if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){

					ksun_multi_inc_num_available_spores_primitive(killer,cvar_val(num, pcvar_ksun_spores_per_kill))
				}
			}
			else if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){
					

					ksun_multi_inc_num_available_spores_primitive(killer,
											cvar_val(num, pcvar_ksun_spores_per_kill)*
											cvar_val(num, pcvar_ksun_spore_m4_mult))

			}
			else{
				ksun_multi_inc_num_available_spores_primitive(killer,cvar_val(num, pcvar_ksun_spores_per_kill))
			}
			ammo_hud(killer,gMaxSporesUsable[killer],1)
		}
		gWeaponPlayerKilledPlayerWith[killer][id]=0;
	}
	
}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage,  &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)|| (damage < 1)){
	
		return DMG_FWD_PASS
	}
	new bool:spored_someone_covert= false,
		bool:spored_someone_overt= false
	new bool:victim_has_hero=sh_get_user_has_hero(victim,gHeroID)
	if(victim_has_hero&&COVERT_ABUSE_ENABLED){

	
		covert_spike_damage(victim,spored_someone_covert)

	}

	if((victim!=attacker)&&OVERT_ABUSE_ENABLED){
		new Float:flDamage=float(damage)
		overt_spike_damage(attacker,flDamage,0,spored_someone_overt)
		damage=floatround(flDamage)
	}
	

	if(spored_someone_overt||spored_someone_covert){

		emit_sound(victim, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return DMG_FWD_PASS
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)

}