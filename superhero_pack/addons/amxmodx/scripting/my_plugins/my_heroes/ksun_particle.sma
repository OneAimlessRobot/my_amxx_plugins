
#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"



new Float:ksun_spore_damage, 
	Float:ksun_spore_speed,
	Float:ksun_heal_coeff,
	Float:ksun_dmg_paycut,
	Float:ksun_spore_base_health;
new violence_level

new g_times_player_spiked_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new g_times_player_spiked_by_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun spores","1.1","MilkChanThaGOAT")
	
	register_cvar("ksun_spore_damage", "100.0" )
	register_cvar("ksun_spore_speed", "900.0" )
	register_cvar("ksun_follow_time", "5.0")
	register_cvar("ksun_hold_time", "5.0")
	register_cvar("ksun_heal_coeff", "0.5" )
	register_cvar("ksun_dmg_paycut", "0.05" )
	register_cvar("ksun_violence_level", "3" )
	register_cvar("ksun_spore_health", "100.0" )
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	register_touch(SPORE_CLASSNAME, "player", "touch_event")
	
	register_forward(FM_Think, "spore_think")
}

public plugin_natives(){
	
	
	
	register_native("spore_launch","_spore_launch",0)
	register_native("spores_clear","_spores_clear",0)
	register_native("get_times_player_spiked_player","_get_times_player_spiked_player",0)
	register_native("inc_times_player_spiked_player","_inc_times_player_spiked_player",0)
	register_native("dec_times_player_spiked_player","_dec_times_player_spiked_player",0)
	
	register_native("get_times_player_spiked_by_player","_get_times_player_spiked_by_player",0)
	register_native("inc_times_player_spiked_by_player","_inc_times_player_spiked_by_player",0)
	register_native("dec_times_player_spiked_by_player","_dec_times_player_spiked_by_player",0)
	register_native("get_spike_base_damage_debt","_get_spike_base_damage_debt",0)
	register_native("heal","_heal",0)
	
	
	
}
public Float:_get_spike_base_damage_debt(iPlugins, iParms){
	
	return ksun_dmg_paycut
}
	
//----------------------------------------------------------------------------------------------
untrack_spore(spore){
	remove_task(spore+UNFOLLOW_LOOP_TASKID)
	remove_task(spore+FOLLOW_LOOP_TASKID)
	if(pev_valid(spore)){
		new spore_owner= entity_get_edict(spore,EV_ENT_euser1)
		emit_sound(spore, CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(spore, CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		//client_print(spore_owner,print_console,"Spore untrack function called!!!!!^n")
		entity_set_float( spore, EV_FL_fuser1, 0.0);
		remove_entity(spore)
		dec_player_num_victims(spore_owner)
	}
	return 0

}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	ksun_spore_damage= get_cvar_float("ksun_spore_damage")
	ksun_spore_speed= get_cvar_float("ksun_spore_speed")
	violence_level= get_cvar_num("ksun_violence_level")
	ksun_heal_coeff= get_cvar_float("ksun_heal_coeff")
	ksun_spore_base_health= get_cvar_float("ksun_spore_health")
	ksun_dmg_paycut=get_cvar_float("ksun_dmg_paycut")
}
public bool:_heal(iPlugins, iParms){
	new id= get_param(1)
	new Float:damage=get_param_f(2)
	
	new Float: mate_health=float(get_user_health(id))
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	damage*=ksun_heal_coeff
	new Float: new_health=floatadd(mate_health,damage)
	set_user_health(id,min(sh_get_max_hp(id),floatround(new_health)))
	setScreenFlash(id,LineColors[PURPLE][0],LineColors[PURPLE][1],LineColors[PURPLE][2],3,100)
	sh_set_rendering(id, LineColors[PURPLE][0],LineColors[PURPLE][1],LineColors[PURPLE][2],180,kRenderFxGlowShell, kRenderTransAlpha)
	set_task(KSUN_HEAL_GLOW_TIME,"remove_glow_task",id+KSUN_UNGLOW_TASKID,"", 0,  "a",1)
	emit_sound(id, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	return true

}
public _spores_clear(iPlugins, iParms){
	
	new spore = find_ent_by_class(-1, SPORE_CLASSNAME)
	while(spore) {
		remove_entity(spore)
		spore = find_ent_by_class(spore, SPORE_CLASSNAME)
	}
	
}
public ev_SendAudio(){
	
	spores_clear()
	if(!sh_is_active()) return PLUGIN_CONTINUE
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		arrayset(g_times_player_spiked_player[i],0,SH_MAXSLOTS+1)
		arrayset(g_times_player_spiked_by_player[i],0,SH_MAXSLOTS+1)
	}
	return PLUGIN_HANDLED
}
public spawn_spore(id){
	if(!spores_has_ksun(id)||!client_hittable(id)){
	
		return 0
	}
	new material[128]
	new health[128]	
	new spore = create_entity( "func_breakable" );

	if ( (spore == 0) || !pev_valid(spore)||!is_valid_ent(spore)) {
		client_print(id, print_chat, "[SH](ksun) Spore Creation Failure")
		return 0
	}

	new Float:b_orig[3]

	new originplayer[3], originlook[3], aimvec[3]

	get_user_origin(id, originplayer)
	get_user_origin(id, originlook, 2)


	new distance[2]

	distance[0] = originlook[0]-originplayer[0]
	distance[1] = originlook[1]-originplayer[1]


	new unitsinfront = 80

	aimvec[0]=originplayer[0]+(unitsinfront*distance[0])/sqrt(distance[0]*distance[0]+distance[1]*distance[1])
	aimvec[1]=originplayer[1]+(unitsinfront*distance[1])/sqrt(distance[0]*distance[0]+distance[1]*distance[1])
	aimvec[2]=originplayer[2]+UNITS_ABOVE

	b_orig[0] = float(aimvec[0]);
	b_orig[1] = float(aimvec[1]);
	b_orig[2] = float(aimvec[2]);

	entity_set_string(spore, EV_SZ_classname, SPORE_CLASSNAME)


	entity_set_model(spore, KSUN_SPORE_MDL)

	float_to_str(SPORE_DEAD_HP+ksun_spore_base_health,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( spore, "material", material );
	DispatchKeyValue( spore, "health", health );


	set_pev(spore, pev_health, SPORE_DEAD_HP+ksun_spore_base_health)
	engfunc(EngFunc_SetSize, spore, Float:{-SPORE_SIZE, -SPORE_SIZE,-SPORE_SIZE}, Float:{SPORE_SIZE, SPORE_SIZE, SPORE_SIZE})

	entity_set_float( spore, EV_FL_fuser1, 0.0);

	set_pev(spore, pev_takedamage, DAMAGE_YES)
	set_pev(spore, pev_solid, SOLID_BBOX)
	entity_set_int(spore,EV_INT_movetype, MOVETYPE_NOCLIP)
	entity_set_origin(spore, b_orig)

	//Sets who the owner of the entity is
	entity_set_edict(spore, EV_ENT_euser1,id)
	entity_set_edict(spore, EV_ENT_owner,get_player_launcher(id))

	return spore
}
//----------------------------------------------------------------------------------------------
public _get_times_player_spiked_player(iPlugin,iParms){
	
		new killer= get_param(1)
		new victim= get_param(2)
		
		return g_times_player_spiked_player[killer][victim]
	
	
}
public _inc_times_player_spiked_player(iPlugin,iParms){

		new killer= get_param(1)
		new victim= get_param(2)

		g_times_player_spiked_player[killer][victim]++
}
public _dec_times_player_spiked_player(iPlugin,iParms){

		new killer= get_param(1)
		new victim= get_param(2)

		g_times_player_spiked_player[killer][victim]= (g_times_player_spiked_player[killer][victim]>0)? (g_times_player_spiked_player[killer][victim]-1):0
		
}
//----------------------------------------------------------------------------------------------
public _get_times_player_spiked_by_player(iPlugin,iParms){
	
		
		new victim= get_param(1)
		new killer= get_param(2)
		
		return g_times_player_spiked_by_player[victim][killer]
	
	
}
public _inc_times_player_spiked_by_player(iPlugin,iParms){

		new victim= get_param(1)
		new killer= get_param(2)

		g_times_player_spiked_by_player[victim][killer]++
}

public _dec_times_player_spiked_by_player(iPlugin,iParms){

		new victim= get_param(1)
		new killer= get_param(2)

		g_times_player_spiked_by_player[victim][killer]= (g_times_player_spiked_by_player[victim][killer]>0)? (g_times_player_spiked_by_player[victim][killer]-1):0
		
}
//----------------------------------------------------------------------------------------------
public _spore_launch(iPlugins,iParms)
{
new id= get_param(1)
if(!spores_has_ksun(id)||!client_hittable(id)){
	
	return
}
switch(get_player_launcher_phase(id)){
	case PHASE_DEPLOY:{
		new spore= spawn_spore(id)
		if(!spore){
			
			return
		}
		new parms[3];
		set_spore_at_player_spores(id,get_player_num_deployed_spores(id),spore)
		parms[0]=spore
		parms[1]=id
		parms[2]=get_player_launcher(id)
		client_print(id, print_console, "[SH](ksun) Spore prepared! spore id is: %d^nSpore number is: %d^n",spore,get_player_num_deployed_spores(id))
		sporeprepare(parms)
		}
	case PHASE_SEND:{
		
		
		new parms[3];
		parms[0]=get_spore_from_player_spores(id,get_player_num_launched_spores(id))
		parms[1]=id
		parms[2]=get_target_from_player_targets(id,get_player_num_launched_spores(id))
		new user_name[128]
		emit_sound(parms[0], CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		get_user_name(parms[2],user_name,127)
		client_print(id, print_console, "[SH](ksun) Spore sent! spore id is: %d^nSpore number is: %d^nLaunched at target number: %d^nThe name of said target is: %s^n",parms[0],get_player_num_launched_spores(id),parms[2],user_name)
		sporetrack(parms)
	}
}
}
public sporetrack(parms[]){
new spore=parms[0]
emit_sound(parms[1], CHAN_STATIC, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(floatsub(floatmul(FOLLOW_LOOP_PERIOD,float(FOLLOW_LOOP_TIMES)),0.1),"untrack_spore_task",spore+UNFOLLOW_LOOP_TASKID,"",0,  "a",1)
set_task(FOLLOW_LOOP_PERIOD, "track_spore", spore+FOLLOW_LOOP_TASKID, parms, 3, "a",FOLLOW_LOOP_TIMES)
}
public sporeprepare(parms[]){
new spore=parms[0]
emit_sound(parms[1], CHAN_WEAPON, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
entity_set_float( spore, EV_FL_nextthink, floatadd(get_gametime( ) ,SPORE_THINK_PERIOD));
}

public track_spore(parms[])
{


new spore = parms[0]
new spore_owner = parms[1]
new spore_target = parms[2]
if ( !is_valid_ent(spore) ) {
	remove_task(spore+FOLLOW_LOOP_TASKID)
	remove_task(spore+UNFOLLOW_LOOP_TASKID)
	return
}
emit_sound(spore, CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
if(get_player_launcher_phase(spore_owner)<=PHASE_DEPLOY){
			if(client_hittable(spore_owner)){
				if ( is_valid_ent(get_player_launcher_phase(spore_owner))) {
					entity_set_follow(spore, get_player_launcher_phase(spore_owner))
					sporetrail(spore)
				}
			}
}
else{
			if ( client_hittable(spore_target)&&client_hittable(spore_owner)) {
				entity_set_follow(spore, spore_target)
				sporetrail(spore)
			}
			else{
				
				untrack_spore(spore)
				set_scanner_player_tracks_player(spore_owner,spore_target,0)
			}
		}
}
//----------------------------------------------------------------------------------------------
public untrack_spore_task(spore){
	spore-=UNFOLLOW_LOOP_TASKID
	remove_task(spore+FOLLOW_LOOP_TASKID)
	if(pev_valid(spore)){
		new spore_owner= entity_get_edict(spore,EV_ENT_euser1)
		emit_sound(spore, CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(spore, CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		//client_print(spore_owner,print_console,"Spore untrack task called!!!!!^n")
		entity_set_float( spore, EV_FL_fuser1, 0.0);
		remove_entity(spore)
		dec_player_num_victims(spore_owner)
	}
	return 0

}

//----------------------------------------------------------------------------------------------
sporetrail(entid){
	trailing_beam(20,entid,{255, 0, 255,125}) 	
}

public spore_think(ent){
	
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, SPORE_CLASSNAME) ) return FMRES_IGNORED
	
	new Float:spore_hp=float(pev(ent,pev_health))
	
	
	if ( (spore_hp<SPORE_DEAD_HP)|| !client_hittable(entity_get_edict(ent,EV_ENT_euser1)) || !is_valid_ent(entity_get_edict(ent,EV_ENT_euser1))|| !is_valid_ent(entity_get_edict(ent,EV_ENT_owner))){
		
		client_print(entity_get_edict(ent,EV_ENT_euser1),print_console,"Spore untrack function about to be called in spore thinking function!!!!!^nCurrent hp of this spore: %0.2f^n",spore_hp)
		//draw_bbox(ent,1)
		untrack_spore(ent)
		return FMRES_IGNORED
		
	}
	//draw_bbox(ent,0)
	entity_set_float( ent, EV_FL_fuser1, floatadd(entity_get_float(ent, EV_FL_fuser1) ,SPORE_THINK_PERIOD));
	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,SPORE_THINK_PERIOD));
	
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
stock entity_set_follow(entity, target)
{
if ( !is_valid_ent(entity) || !client_hittable(target) ) return 0

new Float:fl_Origin[3], Float:fl_EntOrigin[3]
entity_get_vector(target, EV_VEC_origin, fl_Origin)
entity_get_vector(entity, EV_VEC_origin, fl_EntOrigin)

new Float:fl_InvTime = (ksun_spore_speed / vector_distance(fl_Origin, fl_EntOrigin))

new Float:fl_Distance[3]
fl_Distance[0] = fl_Origin[0] - fl_EntOrigin[0]
fl_Distance[1] = fl_Origin[1] - fl_EntOrigin[1]
fl_Distance[2] = fl_Origin[2] - fl_EntOrigin[2]

new Float:fl_Velocity[3]
fl_Velocity[0] = fl_Distance[0] * fl_InvTime
fl_Velocity[1] = fl_Distance[1] * fl_InvTime
fl_Velocity[2] = fl_Distance[2] * fl_InvTime

entity_set_vector(entity, EV_VEC_velocity, fl_Velocity)

new Float:fl_NewAngle[3]
vector_to_angle(fl_Velocity, fl_NewAngle)
entity_set_vector(entity, EV_VEC_angles, fl_NewAngle)

return 1
}
//----------------------------------------------------------------------------------------------
public touch_event(pToucher, pTouched)  //This is triggered when two entites touch
{
if(!is_valid_ent(pToucher)) return

if(!client_hittable(pTouched)) return

static classname[32]
classname[0] = '^0'
pev(pToucher, pev_classname, classname, charsmax(classname))
	
if ( !equal(classname, SPORE_CLASSNAME) ) return

new killer = entity_get_edict(pToucher, EV_ENT_euser1)

if(!client_hittable(killer)) return

new victim = pTouched
new ffOn = get_cvar_num("mp_friendlyfire")
if ( (get_user_team(victim) != get_user_team(killer)) || ffOn )
{
	//client_print(killer,print_console,"Spore untrack function about to be called in touch hook!!!!!^n")
	new tger_name[128], vic_name[128]
	get_user_name(victim,vic_name,127)
	get_user_name(killer,tger_name,127)
	sh_extra_damage(victim, killer, floatround(ksun_spore_damage), "ksun spore")
	sh_bleed_user(victim,killer,spores_ksun_hero_id())
	heal(killer,ksun_spore_damage)
	emit_sound(victim, CHAN_STATIC, SPORE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_scanner_player_tracks_player(killer,victim,0)
	g_times_player_spiked_player[killer][victim]++
	g_times_player_spiked_by_player[victim][killer]++
	new violence_to_use
	if(violence_level<0){
		
		violence_to_use=random_num(1,MAX_VIOLENCE)
	}
	else{
		
		violence_to_use=clamp(violence_level,1,MAX_VIOLENCE)
	}
	sh_chat_message(killer,spores_ksun_hero_id(),"%s%s!",CENSORSHIP_SENTENCES[violence_to_use][0],vic_name)
	sh_chat_message(victim,spores_ksun_hero_id(),"%s by%s!",CENSORSHIP_SENTENCES[violence_to_use][1],tger_name)
	untrack_spore(pToucher)
}
}

public remove_glow_task(id){

id-=KSUN_UNGLOW_TASKID
if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)) return

set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)

}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model(KSUN_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_READY_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_WOUND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_TRAVEL_SFX)
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_explosion_fx()
}