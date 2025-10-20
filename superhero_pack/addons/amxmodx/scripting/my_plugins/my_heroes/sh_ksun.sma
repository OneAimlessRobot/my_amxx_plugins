// KSUN
/* CVARS - copy and paste to shconfig.cfg

//
ksun_level 12
ksun_track_radius 2000.0
ksun_spore_damage 100.0
ksun_spore_speed 900.0
ksun_follow_time 5.0
ksun_teamglow_on 1
ksun_hold_time 5.0
ksun_max_victims 4
ksun_heal_coeff 0.5
ksun_cooldown 10.0
ksun_spore_health 100.0
ksun_launcher_health 500.0
*/


#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "ksun_inc/sh_sleep_grenade_funcs.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"

// GLOBAL VARIABLES
new gHeroName[]="ksun"
new bool:gHasksun[SH_MAXSLOTS+1]
new gmorphed[SH_MAXSLOTS+1]
new gNumSleepNades[SH_MAXSLOTS+1]
new gMaxSporesUsable[SH_MAXSLOTS+1]
new gWeaponPlayerKilledPlayerWith[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new Float:cooldown
new ksun_kill_type_broadness_level
new ksun_spores_per_kill
new ksun_spore_m4_mult
new num_sleep_nades
new teamglow_on
new gHeroID
stock ksun_when_reset_spores=never_reset;
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun","1.1","MilkChanThaGOAT")
	
	register_cvar("ksun_level", "12" )
	register_cvar("ksun_teamglow_on", "1")
	register_cvar("ksun_cooldown", "10.0" )
	register_cvar("ksun_num_of_sleep_nades","6")
	register_cvar("ksun_kill_type_broadness_level","0")
	register_cvar("ksun_spores_per_kill","0")
	register_cvar("ksun_spore_m4_mult","0")
	register_cvar("ksun_when_reset_spores","0")
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Spore Launcher", "Launch spores that follow enemies!", true, "ksun_level" )
	register_event("ResetHUD","newRound","b")
	RegisterHam(Ham_TakeDamage, "player", "ksun_damage_debt",_,true)
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	// INIT
	register_srvcmd("ksun_init", "ksun_init")
	shRegHeroInit(gHeroName, "ksun_init")
	
	register_srvcmd("ksun_kd", "ksun_kd")
	shRegKeyDown(gHeroName, "ksun_kd")
	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
	register_forward(FM_PlayerPreThink, "ksun_prethink")
}
public plugin_natives(){
	
	
	register_native("ksun_dec_num_sleep_nades","_ksun_dec_num_sleep_nades",0);
	register_native("ksun_get_num_sleep_nades","_ksun_get_num_sleep_nades",0);
	register_native("ksun_set_num_sleep_nades","_ksun_set_num_sleep_nades",0);
	
	
	register_native("ksun_get_num_available_spores","_ksun_get_num_available_spores",0);
	register_native("ksun_set_num_available_spores","_ksun_set_num_available_spores",0);
	register_native("ksun_dec_num_available_spores","_ksun_dec_num_available_spores",0);
	register_native("ksun_inc_num_available_spores","_ksun_inc_num_available_spores",0);
	
	register_native("ksun_multi_inc_num_available_spores","_ksun_multi_inc_num_available_spores",0);
	register_native("ksun_multi_dec_num_available_spores","_ksun_multi_dec_num_available_spores",0);
	
	
	
	register_native("ksun_get_when_reset_spores","_ksun_get_when_reset_spores",0);
	
	
	
	
	
	register_native("spores_has_ksun","_spores_has_ksun",0)
	register_native("spores_cooldown","_spores_cooldown",0)
	register_native("spores_ksun_hero_id","_spores_ksun_hero_id",0)
	
	
	
}

stock covert_spike_damage(id){
	for(new payer=0;payer<SH_MAXSLOTS+1;payer++){

			if(!client_hittable(payer)){
				
				
				continue
			}
			new CsTeams:payer_team=cs_get_user_team(payer)
			if(cs_get_user_team(id)==payer_team){
				
				continue
			}
			new times_spiked_by_me=get_times_player_spiked_by_player(payer,id)
			if((times_spiked_by_me>0)){
				new tger_name[128], vic_name[128]
				get_user_name(payer,vic_name,127)
				get_user_name(id,tger_name,127)
				new Float: pctHealthLost=get_spike_base_damage_debt()*float(times_spiked_by_me)
				new Float: healthXtracted=1.0+(float(get_user_health(payer))*pctHealthLost)
				new Ent = create_entity("info_target")

				if (pev_valid(Ent)!=2){
					continue
				}
				entity_set_string(Ent, EV_SZ_classname, "ksun debt")
				sh_chat_message(id,spores_ksun_hero_id(),"health of target named %s before: %d",vic_name,get_user_health(payer))
				ExecuteHam(Ham_TakeDamage,payer,Ent,id,healthXtracted,DMG_GENERIC);
				sh_chat_message(id,spores_ksun_hero_id(),"health of target named %s now: %d",vic_name,get_user_health(payer))
				remove_entity(Ent)
				heal(id,healthXtracted)
				new violence_to_use
				if(get_cvar_num("ksun_violence_level")<0){
					
					violence_to_use=random_num(1,MAX_VIOLENCE)
				}
				else{
					
					violence_to_use=clamp(1,get_cvar_num("ksun_violence_level"),MAX_VIOLENCE)
				}
				sh_chat_message(id,spores_ksun_hero_id(),"(Expected and obligated) %s%s! they %0.2f health points were due today",CENSORSHIP_SENTENCES[violence_to_use][0],vic_name,healthXtracted)
				sh_chat_message(payer,spores_ksun_hero_id(),"(Expected and obligated) %s by%s! %0.2f health points were due today",CENSORSHIP_SENTENCES[violence_to_use][1],tger_name,healthXtracted)
			}
		}
			

}

stock overt_spike_damage(attacker,&Float:damage,is_in_ham_hook=1){
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	for(new collector=0;collector<SH_MAXSLOTS+1;collector++){

		if(!client_hittable(collector)){
			
			
			continue
		}
		
		new CsTeams:collector_team=cs_get_user_team(collector)
		if(att_team==collector_team){
			
			continue
		}
		new times_spiked_by_them=get_times_player_spiked_player(collector,attacker)
		if((times_spiked_by_them>0)){
			
			new tger_name[128], vic_name[128]
			get_user_name(attacker,vic_name,127)
			get_user_name(collector,tger_name,127)
			
			new Float: pctDmgLost=get_spike_base_damage_debt()*float(times_spiked_by_them)
			new Float: dmgSnatched=1.0+(damage*pctDmgLost)
		
			heal(collector,dmgSnatched)
			new violence_to_use
			if(get_cvar_num("ksun_violence_level")<0){
				
				violence_to_use=random_num(1,MAX_VIOLENCE)
			}
			else{
				
				violence_to_use=clamp(1,get_cvar_num("ksun_violence_level"),MAX_VIOLENCE)
			}
			sh_chat_message(collector,spores_ksun_hero_id(),"(kind and generosly) %s%s! %0.2f of privileges were due today",CENSORSHIP_SENTENCES[violence_to_use][0],vic_name,dmgSnatched)
			sh_chat_message(attacker,spores_ksun_hero_id(),"(kindly and generosly) %s by%s! %0.2f of privileges were due today",CENSORSHIP_SENTENCES[violence_to_use][1],tger_name,dmgSnatched)
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
	if ( !sh_is_active() || !client_hittable(id) || !client_hittable(attacker)) return HAM_IGNORED

	new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)

	if (idinflictor != attacker)
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = CSW_HEGRENADE;
	}
	else
	{
		gWeaponPlayerKilledPlayerWith[attacker][id] = weapon;
	}
	if(spores_has_ksun(id)&&COVERT_ABUSE_ENABLED){

	
		covert_spike_damage(id)

	}

	if((damage>0.0)&&OVERT_ABUSE_ENABLED){
		overt_spike_damage(attacker,damage,1)
	}

	if(spores_has_ksun(attacker)){
		if(weapon==KSUN_WEAPON_ID){
			if(sh_get_user_is_asleep(id)){
			
				new tger_name[128], vic_name[128]
				get_user_name(attacker,vic_name,127)
				get_user_name(id,tger_name,127)
				heal(attacker,damage)
				new CsTeams:payer_team=cs_get_user_team(id)
				new CsTeams:att_team=cs_get_user_team(attacker)
				if(att_team!=payer_team){
					ksun_inc_player_supply_points(attacker,floatround(damage))
					if(spores_has_ksun(id)){
						ksun_dec_player_supply_points(id,floatround(damage))
						sh_chat_message(attacker,spores_ksun_hero_id(),"You stol-- took back %d supply points rom %s! They now have %d supply points!",floatround(damage),tger_name,ksun_get_player_supply_points(id))
					}
				}
				else{
					
					if(spores_has_ksun(id)){
						ksun_inc_player_supply_points(attacker,floatround(damage))
						ksun_dec_player_supply_points(id,floatround(damage))
						sh_chat_message(attacker,spores_ksun_hero_id(),"You stol-- took back %d supply points rom %s! They now have %d supply points!",floatround(damage),tger_name,ksun_get_player_supply_points(id))
					}
					
					
				}
			}
		}
	
	}
	return HAM_IGNORED
	
}


public client_disconnected(id){
	
	spores_reset_user(id)
	ksun_unultimate_user(id)
	ksun_set_num_available_spores(id,0)
	
	
}

public ev_SendAudio(){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		
		arrayset(gWeaponPlayerKilledPlayerWith[i],0,SH_MAXSLOTS+1)
		
		ksun_unultimate_user(i)
	
	}
	
	if(ksun_get_when_reset_spores()&reset_on_new_round){
		arrayset(gMaxSporesUsable,0,SH_MAXSLOTS+1)
	}
	return PLUGIN_HANDLED
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

	return ksun_when_reset_spores;

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
public _ksun_set_num_sleep_nades(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumSleepNades[id]=value_to_set;
}
public _ksun_get_num_sleep_nades(iPlugin,iParams){


	new id= get_param(1)
	return gNumSleepNades[id]

}

public _ksun_dec_num_sleep_nades(iPlugin,iParams){


	new id= get_param(1)
	gNumSleepNades[id]-= (gNumSleepNades[id]>0)? 1:0

}
public _spores_ksun_hero_id(iPlugins, iParms){

	return gHeroID
}
public _spores_has_ksun(iPlugins, iParms){
	
	new id= get_param(1)
	return gHasksun[id]
	
}public Float:_spores_cooldown(iPlugins, iParms){
	
	return cooldown
	
}
ksun_weapons(id)
{

if ( sh_is_active() && client_hittable(id) && spores_has_ksun(id)) {
	cs_set_user_bpammo(id, CSW_HEGRENADE,num_sleep_nades);
	sh_give_weapon(id,CSW_FLASHBANG,false)
	sh_give_weapon(id, KSUN_WEAPON_ID)
}
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	spores_reset_user(id)
	ksun_unultimate_user(id)
	if ( spores_has_ksun(id)) {
		ksun_weapons(id)
		gNumSleepNades[id]=num_sleep_nades
		ksun_morph(id+KSUN_MORPH_TASKID)
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
		init_hud_tasks(id)
	}
	return PLUGIN_HANDLED
}
public sh_round_end(){

	clear_sleep_nades()

}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	cooldown= get_cvar_float("ksun_cooldown")
	teamglow_on=get_cvar_num("ksun_teamglow_on")
	num_sleep_nades=get_cvar_num("ksun_num_of_sleep_nades")
	//<=1: Only m4 kills (Normal m4 damage) count for spores
	//>=2: Any kills count for spores
	ksun_kill_type_broadness_level=get_cvar_num("ksun_kill_type_broadness_level")
	ksun_spores_per_kill=get_cvar_num("ksun_spores_per_kill")
	ksun_spore_m4_mult=get_cvar_num("ksun_spore_m4_mult")
	ksun_when_reset_spores=clamp(get_cvar_num("ksun_when_reset_spores"),never_reset,always_reset)
	
}
//----------------------------------------------------------------------------------------------
public ksun_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	
	gHasksun[id] = (hasPowers!=0)
	if ( gHasksun[id] )
	{
		spores_reset_user(id)
		ksun_unultimate_user(id)
		ksun_morph(id+KSUN_MORPH_TASKID)
		gNumSleepNades[id]=num_sleep_nades
		ksun_weapons(id)
		init_cooldown_update_tasks(id)
		ksun_set_num_available_spores(id,0)
		init_hud_tasks(id)
	}
	else{
		spores_reset_user(id)
		ksun_unultimate_user(id)
		delete_cooldown_update_tasks(id)
		delete_hud_tasks(id)
		ksun_unmorph(id+KSUN_MORPH_TASKID)
		sh_drop_weapon(id, KSUN_WEAPON_ID, true)
		ksun_set_num_available_spores(id,0)
	}
}
//----------------------------------------------------------------------------------------------
public ksun_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !client_hittable(id) ) return PLUGIN_HANDLED
	
	if(!spores_has_ksun(id)) return PLUGIN_HANDLED
	
	// Let them know they already used their ultimate if they have
	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		sh_chat_message(id,gHeroID,"Spore launcher still in cooldown!");
		return PLUGIN_HANDLED
	}
	else if(spores_busy(id)||ksun_player_is_in_ultimate(id)){
		
		playSoundDenySelect(id)
		if(!ksun_player_is_in_ultimate(id)){
			sh_chat_message(id,gHeroID,"Some launched spores still busy!");
		}
		else if(!spores_busy(id)){
			
			
			sh_chat_message(id,gHeroID,"Already in ultimate! Ignoring!");
				
			
		}
		return PLUGIN_HANDLED
		
		
	}
	
	if(!ksun_player_is_ultimate_ready(id)){
		if(!ksun_get_num_available_spores(id)){
		
			client_print(id,print_center,"%s",(ksun_kill_type_broadness_level<=1)?"[SH] ksun:^nKill someone with your M4A1 first":"[SH] ksun:^nKill someone first");
			playSoundDenySelect(id)
			return PLUGIN_HANDLED
		
		}
	
		new message[128]
		format(message, 127, SEARCH_MSG )
		set_hudmessage(255,0,255,-1.0,0.3,0,0.25,1.0,0.0,0.0,4)
		show_hudmessage(id, message)
		spores_launch(id)
	}
	else{
		new owner_name[128]
		get_user_name(id,owner_name,127)
		client_print(0,print_chat,"[SH](ksun): %s is glistening",owner_name)
		
		spores_reset_user(id)
		ksun_player_engage_ultimate(id)
	}
	
	ultimateTimer(id, cooldown)
	return PLUGIN_HANDLED
}

public plugin_precache()
{
	precache_model(KSUN_PLAYER_MODEL)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_READY_SOUND)

}
public get_ksun_num(id,want_alive,want_all){

new players[SH_MAXSLOTS]
new team_name[32]
new player_count;
get_user_team(id,team_name,32)
if(want_all){
	if(!want_alive){
		get_players(players,player_count,"b")
	}
	else{
		get_players(players,player_count,"a")
		player_count--
	}
}
else{
	if(!want_alive){
		get_players(players,player_count,"eb",team_name)
	}
	else{
		get_players(players,player_count,"ea",team_name)
		player_count--
	}
}
return player_count;


}
//----------------------------------------------------------------------------------------------
public ksun_prethink(id)
{
	if ( sh_is_active()){
		if(client_hittable(id)){
			if(spores_has_ksun(id)){
				if((get_ksun_num(id,1,0)<=0)) {
					set_pev(id, pev_flTimeStepSound, 999)
					}
				}
			}
	}
}
//----------------------------------------------------------------------------------------------
public ksun_model(id)
{
	if ( !is_user_alive(id)||!spores_has_ksun(id) ) return
	
	set_task(1.0, "ksun_morph", id+KSUN_MORPH_TASKID)
	if( teamglow_on){
		set_task(1.0, "ksun_glow", id+KSUN_MORPH_TASKID, "", 0, "b" )
	}

}
//----------------------------------------------------------------------------------------------
public ksun_morph(id)
{
	id-=KSUN_MORPH_TASKID
	if ( gmorphed[id] || !is_user_alive(id)||!spores_has_ksun(id) ) return
	
	// Message
	/*set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "ksun: '...'")*/
	cs_set_user_model(id,"ksun")

	gmorphed[id] = true
	
}
//----------------------------------------------------------------------------------------------
public ksun_unmorph(id)
{
	id-=KSUN_MORPH_TASKID
	if(!is_user_connected(id) ) return
	if ( gmorphed[id] ) {

		cs_reset_user_model(id)

		gmorphed[id] = false

		if ( teamglow_on ) {
			remove_task(id+KSUN_MORPH_TASKID)
			set_user_rendering(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public ksun_glow(id)
{
	id -= KSUN_MORPH_TASKID

	if ( !is_user_connected(id) ) {
		//Don't want any left over residuals
		remove_task(id+KSUN_MORPH_TASKID)
		return
	}

	if ( spores_has_ksun(id) && is_user_alive(id)) {
		if ( get_user_team(id) == 1 ) {
			shGlow(id, 255, 0, 255)
		}
		else {
			shGlow(id, 0, 255, 255)
		}
	}
}

public death()
{
	if(!sh_is_active()) return
	
	new id = read_data(2)
	new killer= read_data(1)
	
	
	if(is_user_connected(id)){
		if(spores_has_ksun(id)){
			if(sleep_nade_get_sleep_nade_loaded(id)){
		
				sleep_nade_uncharge_sleep_nade(id)
			}
			
			ksun_unmorph(id+KSUN_MORPH_TASKID)
			if(ksun_get_when_reset_spores()&reset_on_death){
				ksun_set_num_available_spores(id,0)
				clean_ksun_spores_from_players(1,0,id);
			}
		}
		
	}
	if(is_user_connected(killer)&&spores_has_ksun(killer)){
		if(ksun_kill_type_broadness_level>=3){
			
				ksun_multi_inc_num_available_spores(killer,ksun_spores_per_kill)
			
		}
	}
		
}
public sh_client_death(id, killer, headshot, const wpnDescription[]){
	
	if(is_user_connected(id)){
		if(spores_has_ksun(id)){
			if(sleep_nade_get_sleep_nade_loaded(id)){
		
				sleep_nade_uncharge_sleep_nade(id)
			}
			
			ksun_unmorph(id+KSUN_MORPH_TASKID)
			if(ksun_get_when_reset_spores()&reset_on_death){
				ksun_set_num_available_spores(id,0)
				clean_ksun_spores_from_players(1,0,id);
			}
		}
		
	}
	if(client_hittable(killer)&&is_user_connected(id)){
		if(spores_has_ksun(killer)&&!ksun_player_is_in_ultimate(killer)){
			if(ksun_kill_type_broadness_level<=1){
				if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){
					sh_chat_message(killer,spores_ksun_hero_id(),"Killed someone with your %s!",KSUN_WEAPON_NAME)
					sh_chat_message(killer,spores_ksun_hero_id(),"You got %d spores for your kill!",ksun_spores_per_kill)
					ksun_multi_inc_num_available_spores(killer,ksun_spores_per_kill)
				}
			}
			else{
				sh_chat_message(killer,spores_ksun_hero_id(),"Killed someone")
				sh_chat_message(killer,spores_ksun_hero_id(),"You got %d spores for your kill!",ksun_spores_per_kill)
				if(gWeaponPlayerKilledPlayerWith[killer][id]==KSUN_WEAPON_ID){
					sh_chat_message(killer,spores_ksun_hero_id(),"You got %d extra spores for an %s kill!",((ksun_spores_per_kill*ksun_spore_m4_mult)-ksun_spores_per_kill),KSUN_WEAPON_NAME)
					ksun_multi_inc_num_available_spores(killer,ksun_spores_per_kill*ksun_spore_m4_mult)
				}
				else{
					ksun_multi_inc_num_available_spores(killer,ksun_spores_per_kill)
				}
			}
		}
		gWeaponPlayerKilledPlayerWith[killer][id]=0;
	}
	
}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32], &headshot, &dmgMode, &bool:dmgStun,&bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type){
	
	if ( !sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)){
	
		return DMG_FWD_PASS
	}
	if(spores_has_ksun(victim)&&COVERT_ABUSE_ENABLED){

	
		covert_spike_damage(victim)

	}

	if((damage>0.0)&&OVERT_ABUSE_ENABLED){
		new Float:flDamage=float(damage)
		overt_spike_damage(attacker,flDamage,0)
		damage=floatround(flDamage)
	}
	

	
	return DMG_FWD_PASS
}
