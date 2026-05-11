#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "../my_include/my_author_header.inc"

new gHeroID = 0 

new pcvar_ksun_hold_time,
	pcvar_ksun_launcher_base_health;



new g_launcher_phase[SH_MAXSLOTS+1]
new g_player_launcher[SH_MAXSLOTS+1]
new Float:g_launcher_timer[SH_MAXSLOTS+1]





//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun spore launcher","1.1",AUTHOR)
	
	gHeroID = spores_ksun_hero_id()

	pcvar_ksun_hold_time = register_cvar("ksun_hold_time", "5.0")
	pcvar_ksun_launcher_base_health = register_cvar("ksun_launcher_health", "100.0" )
	
	register_event("DeathMsg","death","a")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	register_think(LAUNCHER_CLASSNAME, "launcher_think")
}



public plugin_natives(){
	
	
	
	register_native("spores_launch","_spores_launch",0)
	register_native("launcher_deploy","_launcher_deploy",0)
	register_native("spores_reset_user","_spores_reset_user",0)
	register_native("spores_busy","_spores_busy",0)
	register_native("get_player_launcher_phase","_get_player_launcher_phase",0)
	register_native("get_player_launcher","_get_player_launcher",0)
	
	
	
	
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
	
	remove_entity_name(LAUNCHER_CLASSNAME)
	return PLUGIN_CONTINUE
	
}
public _spores_reset_user(iPlugins, iParms){
	
	new id= get_param(1)

	set_player_num_victims(id,0)
	destroy_player_launcher(id)
	destroy_player_scanner(id)
	return PLUGIN_HANDLED
	
}
public bool:_spores_busy(iPlugins, iParms){
	
	new id= get_param(1)
	return (get_player_num_victims(id)>0)
	
}
public launcher_think(ent){
	
	if ( pev_valid(ent)!=2) return FMRES_IGNORED
	
	
	new Float:launcher_hp=float(pev(ent,pev_health))
	new launcher_owner= entity_get_edict(ent,EV_ENT_euser1)
	
	
	if ( (launcher_hp<LAUNCHER_DEAD_HP) || !is_valid_ent(launcher_owner) ){
	
		destroy_player_launcher(launcher_owner)
		return FMRES_IGNORED
		
	}
	new Float: think_time
	switch(g_launcher_phase[launcher_owner]){
		case PHASE_IDLE:{
			
			g_launcher_timer[launcher_owner]=floatadd(g_launcher_timer[launcher_owner],LAUNCHER_THINK_PERIOD)
			if(g_launcher_timer[launcher_owner]>cvar_val(float, pcvar_ksun_hold_time)){
				
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
			if(g_launcher_timer[launcher_owner]>cvar_val(float, pcvar_ksun_hold_time)){
				
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
		
	
			destroy_player_launcher(launcher_owner)
			return FMRES_IGNORED;
		}
		
	}
	
	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,think_time));
	
	return FMRES_IGNORED
}
public _spores_launch(iPlugin,iParms){
	
	new id= get_param(1)
	if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)){
		
		return
	}
	spores_reset_user(id)
	spawn_scanner(id)
	
	
}


//----------------------------------------------------------------------------------------------
public _launcher_deploy(iPlugin,iParams)
{

new id= get_param(1)
if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)){
	
	return
}
new material[128]
new health[128]	
new launcher = create_entity( "func_breakable" );

if ( (launcher == 0) || !pev_valid(launcher)||!is_valid_ent(launcher)) {
	
	if(!is_user_bot(id)){
		client_print(id, print_chat, "[SH](ksun) Launcher Creation Failure")
	}
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

float_to_str(LAUNCHER_DEAD_HP+ cvar_val(float, pcvar_ksun_launcher_base_health),health,127)
num_to_str(2,material,127)
DispatchKeyValue( launcher, "material", material );
DispatchKeyValue( launcher, "health", health );


set_pev(launcher, pev_health, LAUNCHER_DEAD_HP + cvar_val(float, pcvar_ksun_launcher_base_health))
engfunc(EngFunc_SetSize, launcher, Float:{-LAUNCHER_SIZE, -LAUNCHER_SIZE,-LAUNCHER_SIZE}, Float:{LAUNCHER_SIZE, LAUNCHER_SIZE, LAUNCHER_SIZE})


set_pev(launcher, pev_takedamage, DAMAGE_YES)
set_pev(launcher, pev_solid, SOLID_BBOX)
set_pev(launcher, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides
entity_set_origin(launcher, b_orig)

//Sets who the owner of the entity is
entity_set_edict(launcher, EV_ENT_euser1,id)
entity_set_edict(launcher, EV_ENT_owner,id)


if(!is_user_bot(id)){
	client_print(id, print_console, "[SH](ksun) Launcher deployed! Launcher id is: %d(%d)^n Launcher phase is: %d^n Launcher timer is: %0.2f^n",launcher,g_player_launcher[id],g_launcher_phase[id],g_launcher_timer[id])
}
g_launcher_phase[id]=PHASE_DEPLOY
entity_set_float( launcher, EV_FL_nextthink, floatadd(get_gametime( ) ,LAUNCHER_THINK_PERIOD));

}


public destroy_player_launcher(id){
	
	if(!is_user_connected(id)||! sh_is_active() ) return PLUGIN_HANDLED
	
	if(sh_user_has_hero(id,gHeroID)){
		reset_player_targets(id)
		set_player_num_deployed_spores(id,0);
		set_player_num_launched_spores(id,0);
		g_launcher_phase[id]=0;
		g_launcher_timer[id]=0.0;
		
		if(is_valid_ent(g_player_launcher[id])){
			
			
			emit_sound(id, CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			remove_entity(g_player_launcher[id])
			g_player_launcher[id]=0
		
		
		}
	}
	return PLUGIN_HANDLED
	
	

}

public death()
{
	new id = read_data(2)
	
	if(sh_user_has_hero(id,gHeroID)){
	
		if(ksun_get_when_reset_spores()&reset_on_death){
			spores_reset_user(id)
		}
		
	}
	
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,KSUN_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, LAUNCHER_SCAN_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_READY_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_TRAVEL_SFX)
	
}