



#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"

new Float:ksun_hold_time,
	Float:ksun_launcher_base_health,
	Float:ksun_follow_time;
new hud_sync_stats



new Float:g_player_cooldown_remaining[SH_MAXSLOTS+1]
new g_launcher_phase[SH_MAXSLOTS+1]
new g_player_launcher[SH_MAXSLOTS+1]
new Float:g_launcher_timer[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun spore launcher","1.1","MilkChanThaGOAT")
	
	register_cvar("ksun_follow_time", "5.0")
	register_cvar("ksun_hold_time", "5.0")
	register_cvar("ksun_heal_coeff", "0.5" )
	register_cvar("ksun_violence_level", "3" )
	register_cvar("ksun_spore_health", "100.0" )
	register_cvar("ksun_launcher_health", "100.0" )
	
	register_touch(SPORE_CLASSNAME, "player", "touch_event")
	register_event("DeathMsg","death","a")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	hud_sync_stats = CreateHudSyncObj()
	register_forward(FM_Think, "launcher_think")
}



public plugin_natives(){
	
	
	
	register_native("spores_launch","_spores_launch",0)
	register_native("launcher_deploy","_launcher_deploy",0)
	register_native("spores_reset_user","_spores_reset_user",0)
	register_native("launchers_clear","_launchers_clear",0)
	register_native("spores_busy","_spores_busy",0)
	register_native("get_player_launcher_phase","_get_player_launcher_phase",0)
	register_native("get_player_launcher","_get_player_launcher",0)
	
	
	register_native("get_follow_time","_get_follow_time",0)
	
	
	register_native("init_hud_tasks","_init_hud_tasks",0)
	register_native("delete_hud_tasks","_delete_hud_tasks",0)
	register_native("delete_cooldown_update_tasks","_delete_cooldown_update_tasks",0)
	register_native("init_cooldown_update_tasks","_init_cooldown_update_tasks",0)
	
	
	
}
public Float:_get_follow_time(iPlugins,iParms){
	
	return ksun_follow_time;

}

public _get_player_launcher_phase(iPlugins, iParms){ 
	
	new id= get_param(1)
	return g_launcher_phase[id]
	
}
public _get_player_launcher(iPlugins, iParms){ 
	
	new id= get_param(1)
	return g_player_launcher[id]
	
}
public ev_SendAudio(){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE
	
	launchers_clear()
	return PLUGIN_CONTINUE
	
}
public _delete_hud_tasks(iPlugins, iParms){
	
	new id= get_param(1)
	remove_task(id+STATUS_UPDATE_TASKID)
	
	
	
}

public _init_hud_tasks(iPlugins, iParms){
	
	new id= get_param(1)
	set_task(STATUS_UPDATE_PERIOD,"status_hud",id+STATUS_UPDATE_TASKID,"",0,"b")
	
	
}
public _delete_cooldown_update_tasks(iPlugins, iParms){
	
	new id= get_param(1)
	remove_task(id+COOLDOWN_UPDATE_TASKID)
	
	
	
}

public _init_cooldown_update_tasks(iPlugins, iParms){
	
	new id= get_param(1)
	set_task(COOLDOWN_UPDATE_PERIOD,"launcher_recharge_loop",id+COOLDOWN_UPDATE_TASKID,"",0,"b")
	
	
}
public remove_glow_task(id){

id-=KSUN_UNGLOW_TASKID
if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)) return

set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)

}
public status_hud(id){
	id-=STATUS_UPDATE_TASKID
	if(!client_hittable(id)||(client_hittable(id)&&!spores_has_ksun(id))){
				
		delete_hud_tasks(id)
		return
		
	}
	new hud_msg[301];
	format(hud_msg,300,"[SH] ksun:^nScanner: %s^nCurrent scanner time: %0.1f^nCurrent scanner radius: %0.1f^nCurrent number of sleep grenades: %d^nCurrent number of victims gathered: %d^nCurrent number of kills with M4A1 as ksun: %d^nCurrent hold time: %0.2f^n",
					is_valid_ent(get_player_scanner(id))&&(get_player_scanner(id)>0)? "ON":"OFF",
					is_valid_ent(get_player_scanner(id))? entity_get_float(get_player_scanner(id),EV_FL_fuser1):0.0,
					is_valid_ent(get_player_scanner(id))? entity_get_float(get_player_scanner(id),EV_FL_fuser2):0.0,
					ksun_get_num_sleep_nades(id),
					get_player_num_victims(id),
					ksun_get_num_available_spores(id),
					g_launcher_timer[id]);
	if(g_player_cooldown_remaining[id]>0){
	format(hud_msg,300,"%s^nCooldown_remaining_value: %0.2f^n",hud_msg,
					g_player_cooldown_remaining[id]);
	}
	else{
	
	
	format(hud_msg,300,"%s^n%Mrs. ksun? The launcher is ready.^n",hud_msg)
	
		
		
	}
	
	set_hudmessage(255, 255, 255,1.0, 0.3, 0, 0.0, 2.0,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_stats, "%s", hud_msg)
	
	
}

public launcher_recharge_loop(id){
	
	id-=COOLDOWN_UPDATE_TASKID;
	
	if(!client_hittable(id)||(client_hittable(id)&&!spores_has_ksun(id))){
				
		delete_hud_tasks(id)
		return
		
	}
	if(g_player_cooldown_remaining[id]>0.0){
		
		g_player_cooldown_remaining[id]=floatsub(g_player_cooldown_remaining[id],COOLDOWN_UPDATE_PERIOD);
		
		
	}
	
	
}
public _launchers_clear(iPlugins, iParms){
	
	new launcher = find_ent_by_class(-1, LAUNCHER_CLASSNAME)
	while(launcher) {
		remove_entity(launcher)
		launcher = find_ent_by_class(launcher, LAUNCHER_CLASSNAME)
	}
	
}
public _spores_reset_user(iPlugins, iParms){
	
	new id= get_param(1)
	destroy_player_launcher(id+UNDEPLOY_LOOP_TASKID)
	destroy_player_scanner(id)
	return PLUGIN_HANDLED
	
}
public bool:_spores_busy(iPlugins, iParms){
	
	new id= get_param(1)
	return (get_player_num_victims(id)>0)
	
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	ksun_hold_time= get_cvar_float("ksun_hold_time")
	ksun_follow_time= get_cvar_float("ksun_follow_time")
	ksun_launcher_base_health= get_cvar_float("ksun_launcher_health")
}
public launcher_think(ent){
	
	if ( !pev_valid(ent)) return FMRES_IGNORED
	
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, LAUNCHER_CLASSNAME) ) return FMRES_IGNORED
	
	new Float:launcher_hp=float(pev(ent,pev_health))
	new launcher_owner= entity_get_edict(ent,EV_ENT_euser1)
	
	
	if ( (launcher_hp<LAUNCHER_DEAD_HP) || !is_valid_ent(launcher_owner) ){
		
		draw_bbox(ent,1)
		destroy_player_launcher(launcher_owner+UNDEPLOY_LOOP_TASKID)
		return FMRES_IGNORED
		
	}
	new Float: think_time
	switch(g_launcher_phase[launcher_owner]){
		case PHASE_IDLE:{
			
			g_launcher_timer[launcher_owner]=floatadd(g_launcher_timer[launcher_owner],LAUNCHER_THINK_PERIOD)
			if(g_launcher_timer[launcher_owner]>ksun_hold_time){
				
				g_launcher_phase[launcher_owner]=PHASE_SEND
				set_pev(ent, pev_takedamage, DAMAGE_YES)
				set_pev(ent, pev_solid, SOLID_BBOX)
				set_pev(ent, pev_movetype, MOVETYPE_FLY)
				
			}
		
			think_time=LAUNCHER_THINK_PERIOD
			
			
		}
		case PHASE_DEPLOY:{
		
			if(get_player_num_deployed_spores(launcher_owner)<=0){
				
				g_launcher_phase[launcher_owner]=PHASE_HOLD
				
			}
			else{
				spore_launch(launcher_owner)
				dec_player_num_deployed_spores(launcher_owner)
			}
			think_time=DEPLOY_LOOP_PERIOD
		}
		case PHASE_HOLD:{
			g_launcher_timer[launcher_owner]=floatadd(g_launcher_timer[launcher_owner],LAUNCHER_THINK_PERIOD)
			if(g_launcher_timer[launcher_owner]>ksun_hold_time){
				
				g_launcher_phase[launcher_owner]=PHASE_SEND
				emit_sound(g_player_launcher[launcher_owner], CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
			}
		
			think_time=LAUNCHER_THINK_PERIOD
		}
		case PHASE_SEND:{
		
			if(get_player_num_launched_spores(launcher_owner)<=0){
			
				g_launcher_phase[launcher_owner]=PHASE_DONE
			
			}
			else{
				spore_launch(launcher_owner)
				dec_player_num_launched_spores(launcher_owner)
			}
			think_time=SHOOT_LOOP_PERIOD
		}
		case PHASE_DONE:{
		
	
			set_task(ksun_follow_time,"destroy_player_launcher",launcher_owner+UNDEPLOY_LOOP_TASKID)
			return FMRES_IGNORED;
		}
		
	}
	
	draw_bbox(ent,0)
	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,think_time));
	
	return FMRES_IGNORED
}
public _spores_launch(iPlugin,iParms){
	
	new id= get_param(1)
	if(!spores_has_ksun(id)||!client_hittable(id)){
		
		return
	}
	spores_reset_user(id)
	g_player_cooldown_remaining[id]=floatadd(spores_cooldown(),get_scanner_traverse_time())
	spawn_scanner(id)
	
	
}


//----------------------------------------------------------------------------------------------
public _launcher_deploy(iPlugin,iParams)
{

new id= get_param(1)
if(!spores_has_ksun(id)||!client_hittable(id)){
	
	return
}
new material[128]
new health[128]	
new launcher = create_entity( "func_breakable" );

if ( (launcher == 0) || !pev_valid(launcher)||!is_valid_ent(launcher)) {
	client_print(id, print_chat, "[SH](ksun) Launcher Creation Failure")
	return
}

g_player_launcher[id]=launcher

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

entity_set_string(launcher, EV_SZ_classname, LAUNCHER_CLASSNAME)


entity_set_model(launcher, KSUN_SPORE_MDL)

float_to_str(LAUNCHER_DEAD_HP+ksun_launcher_base_health,health,127)
num_to_str(2,material,127)
DispatchKeyValue( launcher, "material", material );
DispatchKeyValue( launcher, "health", health );


set_pev(launcher, pev_health, LAUNCHER_DEAD_HP+ksun_launcher_base_health)
engfunc(EngFunc_SetSize, launcher, Float:{-LAUNCHER_SIZE, -LAUNCHER_SIZE,-LAUNCHER_SIZE}, Float:{LAUNCHER_SIZE, LAUNCHER_SIZE, LAUNCHER_SIZE})


set_pev(launcher, pev_takedamage, DAMAGE_YES)
set_pev(launcher, pev_solid, SOLID_BBOX)
set_pev(launcher, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides
entity_set_origin(launcher, b_orig)

//Sets who the owner of the entity is
entity_set_edict(launcher, EV_ENT_euser1,id)
entity_set_edict(launcher, EV_ENT_owner,id)

client_print(id, print_console, "[SH](ksun) Launcher deployed! Launcher id is: %d(%d)^n Launcher phase is: %d^n Launcher timer is: %0.2f^n",launcher,g_player_launcher[id],g_launcher_phase[id],g_launcher_timer[id])

g_launcher_phase[id]=PHASE_DEPLOY
entity_set_float( launcher, EV_FL_nextthink, floatadd(get_gametime( ) ,LAUNCHER_THINK_PERIOD));

}


public destroy_player_launcher(id){
	
	id-=UNDEPLOY_LOOP_TASKID
	if(!is_user_connected(id)||! sh_is_active() ) return PLUGIN_HANDLED
	
	if ( spores_has_ksun(id)) {
		reset_player_targets(id)
		set_player_num_victims(id,0)
		g_player_cooldown_remaining[id]=0.0
		set_player_num_deployed_spores(id,0);
		set_player_num_launched_spores(id,0);
		g_launcher_phase[id]=0;
		g_launcher_timer[id]=0.0;
		
		if(is_valid_ent(g_player_launcher[id])){
			
			
			emit_sound(id, CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			draw_bbox(g_player_launcher[id],1)
			remove_entity(g_player_launcher[id])
			g_player_launcher[id]=0
		
		
		}
	}
	return PLUGIN_HANDLED
	
	

}

public death()
{
	new id = read_data(2)
	
	if(spores_has_ksun(id)){
	
		spores_reset_user(id)
		delete_hud_tasks(id)
		
	}
	
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model(KSUN_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, LAUNCHER_SCAN_SFX)
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