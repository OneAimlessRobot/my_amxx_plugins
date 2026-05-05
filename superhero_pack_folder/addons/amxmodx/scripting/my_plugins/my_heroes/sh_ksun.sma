#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "./superheromod_help_files_includes/superheromod_help_files.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "custom_grenades/custom_grenades.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"

new pcvar_cooldown
new pcvar_ksun_kill_type_broadness_level
new pcvar_ksun_spores_per_kill
new pcvar_ksun_spore_m4_mult
new pcvar_num_sleep_nades
new pcvar_ksun_when_reset_spores=never_reset;

// GLOBAL VARIABLES
new gHeroName[]="ksun"
new gMaxSporesUsable[SH_MAXSLOTS+1]
new gWeaponPlayerKilledPlayerWith[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new gHeroID




new dmg_source_name_short_ksun_debt[SAFE_BUFFER_SIZE+1]="ksun_debt"
new dmg_source_name_long_ksun_debt[SAFE_BUFFER_SIZE+1]="ksun_debt"
new custom_dmg_id_ksun_debt

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun","1.1",AUTHOR)
	
	register_cvar("ksun_level", "12" )
	pcvar_cooldown = register_cvar("ksun_cooldown", "10.0" )
	pcvar_num_sleep_nades = register_cvar("ksun_num_of_sleep_nades","6")
	pcvar_ksun_kill_type_broadness_level = register_cvar("ksun_kill_type_broadness_level","0")
	pcvar_ksun_spores_per_kill = register_cvar("ksun_spores_per_kill","0")
	pcvar_ksun_spore_m4_mult = register_cvar("ksun_spore_m4_mult","0")
	pcvar_ksun_when_reset_spores = register_cvar("ksun_when_reset_spores","0")
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Spore Launcher", "Launch spores that follow enemies!", true, "ksun_level",true)
	sh_register_superheromod_model(gHeroID,
								KSUN_PLAYER_MODEL,
								KSUN_PLAYER_MODEL,
								"ksun",
								"ksun: '...'",
								"ksun: '...'")

	static hero_name_arr[STRLEN_FOR_NAMES];
	arrayset(hero_name_arr,0,sizeof hero_name_arr)
	add(hero_name_arr,charsmax(hero_name_arr),gHeroName,charsmax(gHeroName))
	superheromod_help_link_hero(gHeroID, "ksun: Help file","ksun_folder/","ksun_help_file.html",hero_name_arr)
	
	custom_dmg_id_ksun_debt=
		sh_log_custom_damage_source(gHeroID,dmg_source_name_short_ksun_debt,
								dmg_source_name_long_ksun_debt,0)

	RegisterHam(Ham_TakeDamage, "player", "ksun_damage_debt",_,true)
	RegisterHam(Ham_TraceAttack,"player","ksun_physical_body",_,true)
	// INIT
	register_srvcmd("ksun_init", "ksun_init")
	shRegHeroInit(gHeroName, "ksun_init")
	
	register_srvcmd("ksun_kd", "ksun_kd")
	shRegKeyDown(gHeroName, "ksun_kd")

	set_task(1.0,"ksun_step_silent",_,_,_,"b")
}
public plugin_natives(){
	
	
	register_native("ksun_get_num_available_spores","_ksun_get_num_available_spores",0);
	register_native("ksun_set_num_available_spores","_ksun_set_num_available_spores",0);
	register_native("ksun_dec_num_available_spores","_ksun_dec_num_available_spores",0);
	register_native("ksun_inc_num_available_spores","_ksun_inc_num_available_spores",0);
	
	register_native("ksun_multi_inc_num_available_spores","_ksun_multi_inc_num_available_spores",0);
	register_native("ksun_multi_dec_num_available_spores","_ksun_multi_dec_num_available_spores",0);
	
	
	
	register_native("ksun_get_when_reset_spores","_ksun_get_when_reset_spores",0);
	
	
	register_native("spores_cooldown","_spores_cooldown",0)
	register_native("spores_ksun_hero_id","_spores_ksun_hero_id",0)
	
	
	
}

stock covert_spike_damage(id){
	for(new payer=1;payer< sh_maxplayers()+1;payer++){

			if(!is_user_alive(payer)) continue
			
			if(sh_clients_are_same_team(payer,id) || (payer==id)) continue
			
			new Float:times_spiked_by_me=float(get_times_player_spiked_by_player(payer,id))
			if((times_spiked_by_me>0.0)){
				static Float:dmg_to_drain,
						Float:tmp_it_pct,
						Float:remaining,
						Float:tg_health

				tmp_it_pct=get_spike_base_damage_debt()
				tg_health=float(get_user_health(payer))
				remaining = floatmul(tg_health, floatpower(1.0 - tmp_it_pct, times_spiked_by_me))
				dmg_to_drain = tg_health - remaining
				
				sh_extra_damage(payer,id,floatround(dmg_to_drain,floatround_floor),
						dmg_source_name_short_ksun_debt,_,_,_,_,_,_,
						SH_NEW_DMG_DRAIN,custom_dmg_id_ksun_debt)
				ksun_heal(id,dmg_to_drain)
				
			}
		}
			

}

stock overt_spike_damage(attacker,&Float:damage,is_in_ham_hook=1){
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	for(new collector=1;collector< sh_maxplayers()+1;collector++){

		if(!is_user_alive(collector)){
			
			
			continue
		}
		
		new CsTeams:collector_team=cs_get_user_team(collector)
		if(att_team==collector_team){
			
			continue
		}
		new times_spiked_by_them=get_times_player_spiked_player(collector,attacker)
		if((times_spiked_by_them>0)){
			
			new Float: pctDmgLost=get_spike_base_damage_debt()*float(times_spiked_by_them)
			new Float: dmgSnatched=1.0+(damage*pctDmgLost)
		
			ksun_heal(collector,dmgSnatched)
			new Float:newDamage=damage- dmgSnatched
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

	new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)
	
	if (idinflictor != attacker)
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = CSW_HEGRENADE;
	}
	else
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = weapon;
	}
	if(sh_user_has_hero(id,gHeroID) &&COVERT_ABUSE_ENABLED){

	
		covert_spike_damage(id)

	}

	if((damage>0.0)&&OVERT_ABUSE_ENABLED){
		overt_spike_damage(attacker,damage,1)
	}

	if(sh_user_has_hero(attacker,gHeroID) ){
		if(weapon==KSUN_WEAPON_ID){
			if(sh_get_user_is_asleep(id)){
			
				new tger_name[128], vic_name[128]
				get_user_name(attacker,vic_name,127)
				get_user_name(id,tger_name,127)
				ksun_heal(attacker,damage)
				new CsTeams:payer_team=cs_get_user_team(id)
				new CsTeams:att_team=cs_get_user_team(attacker)
				if(att_team!=payer_team){
					ksun_inc_player_supply_points(attacker,floatround(damage))
					if(sh_user_has_hero(id,gHeroID) ){
						ksun_dec_player_supply_points(id,floatround(damage))
						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"You stol-- took back %d supply points rom %s! They now have %d supply points!",floatround(damage),tger_name,ksun_get_player_supply_points(id))
						}
					}
				}
			}
		}
	
	}
	return HAM_IGNORED
	
}

public ksun_physical_body(id, attacker, Float:damage, Float:direction[3], tracehandle, damagebits){
	if(!sh_is_active()) return HAM_IGNORED
	
	if(!is_user_alive(id)){

		return HAM_IGNORED;

	}
	if(!sh_user_has_hero(id,gHeroID) ){

		return HAM_IGNORED;

	}
	if(sh_clients_are_same_team(id,attacker)){

		return HAM_IGNORED
	}
	new hitgroup=get_tr2(tracehandle,TR_iHitgroup);
	switch(hitgroup){
		case HIT_STOMACH:{
			set_tr2(tracehandle,TR_iHitgroup,HIT_HEAD);
			SetHamParamTraceResult(5,tracehandle)
		}
		case HIT_CHEST:{
			return HAM_SUPERCEDE
		}
		case HIT_HEAD:{
			return HAM_SUPERCEDE
		}
	}
	return HAM_HANDLED;
}
public client_disconnected(id){
	
	spores_reset_user(id)
	ksun_unultimate_user(id,_,1)
	ksun_set_num_available_spores(id,0)
	
	
}

public sh_round_end(){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE
	for(new i=1;i< sh_maxplayers()+1;i++){
		if(!is_user_connected(i)){

			continue
		}
		if(!sh_user_has_hero(i,gHeroID) ){

			continue
		}
		arrayset(gWeaponPlayerKilledPlayerWith[i],0,SH_MAXSLOTS+1)
		
		ksun_unultimate_user(i,0,0)
	
	}
	
	if(ksun_get_when_reset_spores()&reset_on_new_round){
		arrayset(gMaxSporesUsable,0,SH_MAXSLOTS+1)
	}
	return PLUGIN_CONTINUE
}
public _ksun_set_num_available_spores(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gMaxSporesUsable[id]=value_to_set;
}
public _ksun_get_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	return gMaxSporesUsable[id]

}

public _ksun_multi_dec_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	new value= get_param(2)
	gMaxSporesUsable[id]-= (gMaxSporesUsable[id]>0)? value:0

}


public _ksun_get_when_reset_spores(iPlugin,iParams){

	return cvar_val(num, pcvar_ksun_when_reset_spores);

}
public _ksun_multi_inc_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	new value= get_param(2)
	gMaxSporesUsable[id]=((gMaxSporesUsable[id]+value)>=scanner_max_victims())? scanner_max_victims():gMaxSporesUsable[id]+value

}
public _ksun_dec_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	gMaxSporesUsable[id]-= (gMaxSporesUsable[id]>0)? 1:0

}
public _ksun_inc_num_available_spores(iPlugin,iParams){


	new id= get_param(1)
	gMaxSporesUsable[id]=(gMaxSporesUsable[id]>=scanner_max_victims())? scanner_max_victims():gMaxSporesUsable[id]+1

}
public _spores_ksun_hero_id(iPlugins, iParms){

	return gHeroID
}
public Float:_spores_cooldown(iPlugins, iParms){
	
	return cvar_val(float, pcvar_cooldown)
	
}
ksun_weapons(id)
{

if ( sh_is_active() && is_user_alive(id) && sh_user_has_hero(id,gHeroID) ) {
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
	if ( sh_user_has_hero(id,gHeroID) ) {
		ksun_weapons(id)
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
	}
	return
}
//----------------------------------------------------------------------------------------------
public ksun_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( sh_user_has_hero(id,gHeroID)  ){

		ksun_weapons(id)
		
	
	}
	else{
		sh_drop_weapon(id, KSUN_WEAPON_ID, true)
	}
	ksun_unultimate_user(id,_,1)
	spores_reset_user(id)
	ksun_set_num_available_spores(id,0)
	clean_ksun_spores_from_players(1,0,id);
}
//----------------------------------------------------------------------------------------------
public ksun_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ) return PLUGIN_HANDLED
	
	if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

	// Let them know they already used their ultimate if they have
	if ( sh_get_cooldown_flag(id)) {
		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID,"Spore launcher still in cooldown!");
		}
		return PLUGIN_HANDLED
	}
	else if(spores_busy(id)||ksun_player_is_in_ultimate(id)){
		
		if(!is_user_bot(id)){
			playSoundDenySelect(id)
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
		if(!ksun_get_num_available_spores(id)){
		
			
			if(!is_user_bot(id)){
				client_print(id,print_center,"%s",
					(cvar_val(num, pcvar_ksun_kill_type_broadness_level)<=1)?"[SH] ksun:^nKill someone with your M4A1 first":"[SH] ksun:^nKill someone first");
				playSoundDenySelect(id)
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
	
	ultimateTimer(id, cvar_val(float, pcvar_cooldown))
	return PLUGIN_HANDLED
}



//----------------------------------------------------------------------------------------------
public ksun_step_silent(id)
{
	if (! sh_is_active()) return
	for(new id=1; id<sh_maxplayers()+1;id++){

		if(is_user_alive(id)){
			if(sh_user_has_hero(id,gHeroID) ){
				new alive=0,dead=0
				sh_get_player_counts(id,1,alive,dead)
				if((alive<=0)) {
					set_pev(id, pev_flTimeStepSound, 999.0)
				}
			}
		}
	}
}
stock ksun_death_handler(id){
	if(!sh_is_active()) return
	
	if(is_user_connected(id)){
		if(sh_user_has_hero(id,gHeroID) ){
			ksun_unultimate_user(id,1,0)
			
			if(ksun_get_when_reset_spores()&reset_on_death){
				ksun_set_num_available_spores(id,0)
				clean_ksun_spores_from_players(1,0,id);
			}
		}
		
	}

}
public sh_client_death(id, killer, headshot, const wpnDescription[]){
	
	ksun_death_handler(id)
	if(is_user_alive(killer)&&is_user_connected(id)){
		if(sh_user_has_hero(killer,gHeroID) &&!ksun_player_is_in_ultimate(killer)){
			if(cvar_val(num, pcvar_ksun_kill_type_broadness_level)<=1){
				if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){
					sh_chat_message(killer,gHeroID,"Killed someone with your %s!",KSUN_WEAPON_NAME)
					sh_chat_message(killer,gHeroID,"You got %d spores for your kill!",
						cvar_val(num, pcvar_ksun_spores_per_kill))
					ksun_multi_inc_num_available_spores(killer,
						cvar_val(num, pcvar_ksun_spores_per_kill))
				}
			}
			else{
				sh_chat_message(killer,gHeroID,"Killed someone")
				sh_chat_message(killer,gHeroID,"You got %d spores for your kill!",
					cvar_val(num, pcvar_ksun_spores_per_kill))
				if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){
					sh_chat_message(killer,gHeroID,"You got %d extra spores for an %s kill!",
					((cvar_val(num, pcvar_ksun_spores_per_kill)*
							cvar_val(num, pcvar_ksun_spore_m4_mult))-
							cvar_val(num, pcvar_ksun_spores_per_kill)),KSUN_WEAPON_NAME)
					ksun_multi_inc_num_available_spores(killer,
					cvar_val(num, pcvar_ksun_spores_per_kill)*
					cvar_val(num, pcvar_ksun_spore_m4_mult))
				}
				else{
					ksun_multi_inc_num_available_spores(killer,
					cvar_val(num, pcvar_ksun_spores_per_kill))
				}
			}
		}
		gWeaponPlayerKilledPlayerWith[killer][id]=0;
	}
	
}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	if(sh_user_has_hero(victim,gHeroID) &&COVERT_ABUSE_ENABLED){

	
		covert_spike_damage(victim)

	}

	if((damage>0.0)&&OVERT_ABUSE_ENABLED){
		new Float:flDamage=float(damage)
		overt_spike_damage(attacker,flDamage,0)
		damage=floatround(flDamage)
	}
	

	
	return DMG_FWD_PASS
}
