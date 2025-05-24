



#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "kzam_inc/kzam_global.inc"
#include "kzam_inc/kzam_particle.inc"
#include "kzam_inc/kzam_spore_launcher.inc"

new Float:kzam_track_radius, 
	Float:kzam_spore_damage, 
	Float:kzam_spore_speed,
	Float:kzam_hold_time,
	Float:kzam_heal_coeff,
	Float:kzam_spore_base_health,
	Float:kzam_launcher_base_health,
	Float:kzam_follow_time;
new kzam_max_victims
new hud_sync_stats
new num_launched_spores[SH_MAXSLOTS+1]
new num_deployed_spores[SH_MAXSLOTS+1]
new g_player_num_victims[SH_MAXSLOTS+1]
new bool:g_player_tracks_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new g_player_spores[SH_MAXSLOTS+1][SH_MAXSLOTS+2]
new g_player_targets[SH_MAXSLOTS+1][SH_MAXSLOTS+2]
new Float:g_player_cooldown_remaining[SH_MAXSLOTS+1]
new g_launcher_phase[SH_MAXSLOTS+1]
new g_player_launcher[SH_MAXSLOTS+1]
new Float:g_launcher_timer[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO kzam","1.1","MilkChanThaGOAT")
	
	register_cvar("kzam_track_radius", "2000.0")
	register_cvar("kzam_spore_damage", "100.0" )
	register_cvar("kzam_spore_speed", "900.0" )
	register_cvar("kzam_follow_time", "5.0")
	register_cvar("kzam_hold_time", "5.0")
	register_cvar("kzam_heal_coeff", "0.5" )
	register_cvar("kzam_max_victims", "4" )
	register_cvar("kzam_spore_health", "100.0" )
	register_cvar("kzam_launcher_health", "100.0" )
	
	register_touch(SPORE_CLASSNAME, "player", "touch_event")
	register_event("DeathMsg","death","a")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	hud_sync_stats = CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "spore_launch_check")
	register_forward(FM_Think, "spore_think")
	register_forward(FM_Think, "launcher_think")
}
#define STATUS_UPDATE_TASKID 7812713
#define STATUS_UPDATE_PERIOD 0.5



public plugin_natives(){
	
	
	
	register_native("spores_launch","_spores_launch",0)
	register_native("spores_reset_user","_spores_reset_user",0)
	register_native("spores_clear","_spores_clear",0)
	register_native("spores_busy","_spores_busy",0)
	register_native("spores_max_victims","_spores_max_victims",0)
	register_native("spores_gather_targets","_spores_gather_targets",0)
	register_native("delete_hud_tasks","_delete_hud_tasks",0)
	register_native("init_hud_tasks","_init_hud_tasks",0)
	register_native("delete_cooldown_update_tasks","_delete_cooldown_update_tasks",0)
	register_native("init_cooldown_update_tasks","_init_cooldown_update_tasks",0)
	
	
	
}
public ev_SendAudio(){
	
	spores_clear()
			
		
}
bool:heal(id,Float:damage){
	
	new Float:mate_health=float(get_user_health(id))
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	damage*=kzam_heal_coeff
	new Float: new_health=floatadd(mate_health,damage)
	set_user_health(id,min(sh_get_max_hp(id),floatround(new_health)))
	setScreenFlash(id,LineColors[PURPLE][0],LineColors[PURPLE][1],LineColors[PURPLE][2],3,100)
	return true

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
public status_hud(id){
	id-=STATUS_UPDATE_TASKID
	if(!client_hittable(id)||(client_hittable(id)&&!spores_has_kzam(id))){
				
		delete_hud_tasks(id)
		return
		
	}
	new hud_msg[200];
	format(hud_msg,150,"[SH] kzam:^nNumber of launched spores %d^nNumber of deployed spores: %d^nCurrent number of victims gathered: %d^nCurrent phase: %d^nCurrent hold time: %0.2f^n",
					num_launched_spores[id],
					num_deployed_spores[id],
					g_player_num_victims[id],
					g_launcher_phase[id],
					g_launcher_timer[id]);
	if(g_player_cooldown_remaining[id]>0){
	format(hud_msg,199,"%s^nCooldown_remaining_value: %0.2f^n",hud_msg,
					g_player_cooldown_remaining[id]);
	}
	else{
	
	
	format(hud_msg,199,"%s^n%Mrs. Kzam? The launcher is ready.^n",hud_msg)
	
		
		
	}
	
	set_hudmessage(255, 255, 255,1.0, 0.3, 0, 0.0, 2.0,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_stats, "%s", hud_msg)
	
	
}

public launcher_recharge_loop(id){
	
	id-=COOLDOWN_UPDATE_TASKID;
	
	if(!client_hittable(id)||(client_hittable(id)&&!spores_has_kzam(id))){
				
		delete_hud_tasks(id)
		return
		
	}
	if(g_player_cooldown_remaining[id]>0.0){
		
		g_player_cooldown_remaining[id]=floatsub(g_player_cooldown_remaining[id],COOLDOWN_UPDATE_PERIOD);
		
		
	}
	
	
}
public _spores_clear(iPlugins, iParms){
	
	new spore = find_ent_by_class(-1, SPORE_CLASSNAME)
	while(spore) {
		remove_entity(spore)
		spore = find_ent_by_class(spore, SPORE_CLASSNAME)
	}
	new launcher = find_ent_by_class(-1, LAUNCHER_CLASSNAME)
	while(launcher) {
		remove_entity(launcher)
		launcher = find_ent_by_class(launcher, LAUNCHER_CLASSNAME)
	}
	
	
}
public _spores_max_victims(iPlugins, iParms){
	
	return kzam_max_victims
	
}
public _spores_reset_user(iPlugins, iParms){
	
	new id= get_param(1)
	destroy_player_launcher(id+UNDEPLOY_LOOP_TASKID)
	return PLUGIN_HANDLED
	
}
public bool:_spores_busy(iPlugins, iParms){
	
	new id= get_param(1)
	return (g_player_num_victims[id]>0)
	
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	kzam_track_radius= get_cvar_float("kzam_track_radius")
	kzam_spore_damage= get_cvar_float("kzam_spore_damage")
	kzam_spore_speed= get_cvar_float("kzam_spore_speed")
	kzam_hold_time= get_cvar_float("kzam_hold_time")
	kzam_follow_time= get_cvar_float("kzam_follow_time")
	kzam_heal_coeff= get_cvar_float("kzam_heal_coeff")
	kzam_spore_base_health= get_cvar_float("kzam_spore_health")
	kzam_launcher_base_health= get_cvar_float("kzam_launcher_health")
	kzam_max_victims= get_cvar_num("kzam_max_victims")
}
show_targets(id){

	if(!client_hittable(id)||!spores_has_kzam(id)){
		
		return
	}
	emit_sound(id, CHAN_STATIC, LAUNCHER_SCAN_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	new hud_msg[500];
	new client_name[128];
	get_user_name(id,client_name,127)
	if(g_player_num_victims[id]<=0){
		
		client_print(id,print_center,"[SH] kzam:^nNo victims were gathered...")
	}
	else{
		format(hud_msg,500,"[SH] kzam:^nTargets:^n")
		for(new i=1;i<=SH_MAXSLOTS;i++){
			if(g_player_tracks_player[id][i]&&client_hittable(i)){
				get_user_name(i,client_name,127)
				format(hud_msg,500,"%s%s.^n",hud_msg,client_name);
			}
		} 
		client_print(id,print_center, "%s", hud_msg)
	}
}
public spore_think(ent){
	
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, SPORE_CLASSNAME) ) return FMRES_IGNORED
	
	new Float:spore_hp=float(pev(ent,pev_health))
	
	
	if ( (spore_hp<SPORE_DEAD_HP)){
		
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
public launcher_think(ent){
	
	if ( !pev_valid(ent)) return FMRES_IGNORED
	
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, LAUNCHER_CLASSNAME) ) return FMRES_IGNORED
	
	new Float:launcher_hp=float(pev(ent,pev_health))
	new launcher_owner= entity_get_edict(ent,EV_ENT_euser1)
	
	
	if ( (launcher_hp<LAUNCHER_DEAD_HP)  ){
		
		draw_bbox(ent,1)
		destroy_player_launcher(launcher_owner+UNDEPLOY_LOOP_TASKID)
		return FMRES_IGNORED
		
	}
	new Float: think_time
	switch(g_launcher_phase[launcher_owner]){
		case PHASE_IDLE:{
			
			g_launcher_timer[launcher_owner]=floatadd(g_launcher_timer[launcher_owner],LAUNCHER_THINK_PERIOD)
			if(g_launcher_timer[launcher_owner]>kzam_hold_time){
				
				g_launcher_phase[launcher_owner]=PHASE_SEND
				set_pev(ent, pev_takedamage, DAMAGE_YES)
				set_pev(ent, pev_solid, SOLID_BBOX)
				set_pev(ent, pev_movetype, MOVETYPE_FLY)
				
			}
		
			think_time=LAUNCHER_THINK_PERIOD
			
			
		}
		case PHASE_DEPLOY:{
		
			if(num_deployed_spores[launcher_owner]<=0){
				
				g_launcher_phase[launcher_owner]=PHASE_HOLD
				
			}
			else{
				spore_launch(launcher_owner+FIRE_LOOP_TASKID)
				num_deployed_spores[launcher_owner]--
			}
			think_time=DEPLOY_LOOP_PERIOD
		}
		case PHASE_HOLD:{
			g_launcher_timer[launcher_owner]=floatadd(g_launcher_timer[launcher_owner],LAUNCHER_THINK_PERIOD)
			if(g_launcher_timer[launcher_owner]>kzam_hold_time){
				
				client_print(0,print_console,"Chegamos à parte de mudar para send^n")
				g_launcher_phase[launcher_owner]=PHASE_SEND
				emit_sound(g_player_launcher[launcher_owner], CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
			}
		
			think_time=LAUNCHER_THINK_PERIOD
		}
		case PHASE_SEND:{
		
			if(num_launched_spores[launcher_owner]<=0){
			
				g_launcher_phase[launcher_owner]=PHASE_DONE
			
			}
			else{
				//set_task(FIRE_DELAY,"spore_launch",launcher_owner+FIRE_LOOP_TASKID)
				spore_launch(launcher_owner+FIRE_LOOP_TASKID)
				num_launched_spores[launcher_owner]--
			}
			think_time=SHOOT_LOOP_PERIOD
		}
		case PHASE_DONE:{
		
	
			set_task(kzam_follow_time,"destroy_player_launcher",launcher_owner+UNDEPLOY_LOOP_TASKID)
			return FMRES_IGNORED;
		}
		
	}
	
	draw_bbox(ent,0)
	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,think_time));
	
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public _spores_gather_targets(iPlugin, iParms)
{
new id= get_param(1)
if(!client_hittable(id)||!spores_has_kzam(id)){
	
		return
}
spores_reset_user(id)
new Float:fOrigin[3];
entity_get_vector( id, EV_VEC_origin, fOrigin);

new iOrigin[3];
for(new i=0;i<3;i++){
	iOrigin[i] = floatround(fOrigin[i]);
}
make_shockwave(iOrigin,kzam_track_radius,{255, 0, 255,125})
new entlist[33];
new numfound = find_sphere_class(id,"player", kzam_track_radius ,entlist, 32);
new CsTeams:idTeam = cs_get_user_team(id)
for( new i= 0;(g_player_num_victims[id]<=(kzam_max_victims))&&(i< numfound);i++){
	
	
				
		new pid = entlist[i];
		if(!client_hittable(pid)){
			continue
		
		}
		
		if((cs_get_user_team(pid)==idTeam)){
				continue
		}
		if(!g_player_tracks_player[id][pid]){
			g_player_tracks_player[id][pid]=true
			num_deployed_spores[id]++
			num_launched_spores[id]++
			g_player_targets[id][num_launched_spores[id]]=pid;
			g_player_num_victims[id]++
		}
	
}
show_targets(id)
}
public _spores_launch(iPlugin,iParms){
	
	new id= get_param(1)
	if(g_player_num_victims[id]>0){
		
		launcher_deploy(id)
	}
	g_player_cooldown_remaining[id]=spores_cooldown()
	
}
//----------------------------------------------------------------------------------------------
public spore_launch(id)
{
id-=FIRE_LOOP_TASKID
if(!spores_has_kzam(id)||!client_hittable(id)){
	
	return
}
switch(g_launcher_phase[id]){
	case PHASE_DEPLOY:{
		new material[128]
		new health[128]	
		new spore = create_entity( "func_breakable" );

		if ( (spore == 0) || !pev_valid(spore)||!is_valid_ent(spore)) {
			client_print(id, print_chat, "[SH](Kzam) Spore Creation Failure")
			return
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


		entity_set_model(spore, KZAM_SPORE_MDL)

		float_to_str(SPORE_DEAD_HP+kzam_spore_base_health,health,127)
		num_to_str(2,material,127)
		DispatchKeyValue( spore, "material", material );
		DispatchKeyValue( spore, "health", health );


		set_pev(spore, pev_health, SPORE_DEAD_HP+kzam_spore_base_health)
		engfunc(EngFunc_SetSize, spore, Float:{-SPORE_SIZE, -SPORE_SIZE,-SPORE_SIZE}, Float:{SPORE_SIZE, SPORE_SIZE, SPORE_SIZE})

		entity_set_float( spore, EV_FL_fuser1, 0.0);

		set_pev(spore, pev_takedamage, DAMAGE_YES)
		set_pev(spore, pev_solid, SOLID_BBOX)
		entity_set_int(spore,EV_INT_movetype, MOVETYPE_NOCLIP)
		entity_set_origin(spore, b_orig)

		//Sets who the owner of the entity is
		entity_set_edict(spore, EV_ENT_euser1,id)
		entity_set_edict(spore, EV_ENT_owner,g_player_launcher[id])

		new parms[3];
		g_player_spores[id][num_deployed_spores[id]]=spore
		parms[0]=g_player_spores[id][num_deployed_spores[id]]
		parms[1]=id
		parms[2]=g_player_launcher[id]
		client_print(id, print_console, "[SH](Kzam) Spore prepared! spore id is: %d^nSpore number is: %d^n",spore,num_deployed_spores[id])
		sporeprepare(parms)
		}
	case PHASE_SEND:{
		
		
		new parms[3];
		parms[0]=g_player_spores[id][num_launched_spores[id]]
		parms[1]=id
		parms[2]=g_player_targets[id][num_launched_spores[id]]
		new user_name[128]
		emit_sound(parms[0], CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		get_user_name(parms[2],user_name,127)
		client_print(id, print_console, "[SH](Kzam) Spore sent! spore id is: %d^nSpore number is: %d^nLaunched at target number: %d^nThe name of said target is: %s^n",parms[0],num_launched_spores[id],parms[2],user_name)
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
//----------------------------------------------------------------------------------------------
public launcher_deploy(id)
{

if(!spores_has_kzam(id)||!client_hittable(id)){
	
	return
}
new material[128]
new health[128]	
new launcher = create_entity( "func_breakable" );

if ( (launcher == 0) || !pev_valid(launcher)||!is_valid_ent(launcher)) {
	client_print(id, print_chat, "[SH](Kzam) Launcher Creation Failure")
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


entity_set_model(launcher, KZAM_SPORE_MDL)

float_to_str(LAUNCHER_DEAD_HP+kzam_launcher_base_health,health,127)
num_to_str(2,material,127)
DispatchKeyValue( launcher, "material", material );
DispatchKeyValue( launcher, "health", health );


set_pev(launcher, pev_health, LAUNCHER_DEAD_HP+kzam_launcher_base_health)
engfunc(EngFunc_SetSize, launcher, Float:{-LAUNCHER_SIZE, -LAUNCHER_SIZE,-LAUNCHER_SIZE}, Float:{LAUNCHER_SIZE, LAUNCHER_SIZE, LAUNCHER_SIZE})


set_pev(launcher, pev_takedamage, DAMAGE_YES)
set_pev(launcher, pev_solid, SOLID_BBOX)
set_pev(launcher, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides
entity_set_origin(launcher, b_orig)

//Sets who the owner of the entity is
entity_set_edict(launcher, EV_ENT_euser1,id)
entity_set_edict(launcher, EV_ENT_owner,id)

client_print(id, print_console, "[SH](Kzam) Launcher deployed! Launcher id is: %d(%d)^n Launcher phase is: %d^n Launcher timer is: %0.2f^n",launcher,g_player_launcher[id],g_launcher_phase[id],g_launcher_timer[id])

g_launcher_phase[id]=PHASE_DEPLOY
entity_set_float( launcher, EV_FL_nextthink, floatadd(get_gametime( ) ,LAUNCHER_THINK_PERIOD));

}
//----------------------------------------------------------------------------------------------
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
if(g_launcher_phase[spore_owner]<=PHASE_DEPLOY){
			if(client_hittable(spore_owner)){
				if ( is_valid_ent(g_player_launcher[spore_owner])) {
					entity_set_follow(spore, g_player_launcher[spore_owner])
					sporetrail(spore)
				}
			}
}
else{
			client_print(0,print_console,"Chegamos ao switch de send^n")
			if ( client_hittable(spore_target)&&client_hittable(spore_owner)) {
				entity_set_follow(spore, spore_target)
				sporetrail(spore)
			}
			else{
				
				client_print(spore_owner,print_console,"Spore untrack function about to be called in tracking function!!!!!^nSpore owner id: %d^nSpore target id: %d^n",spore_owner, spore_target)
				untrack_spore(spore)
				g_player_tracks_player[spore_owner][spore_target]=false
			}
		}
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
		g_player_num_victims[spore_owner]--
	}
	return 0

}
//----------------------------------------------------------------------------------------------
public untrack_spore_task(spore){
	spore-=UNFOLLOW_LOOP_TASKID
	remove_task(spore+FOLLOW_LOOP_TASKID)
	if(pev_valid(spore)){
		new spore_owner= entity_get_edict(spore,EV_ENT_euser1)
		client_print(spore_owner,print_console,"Spore untrack task called!!!!!^n")
		entity_set_float( spore, EV_FL_fuser1, 0.0);
		remove_entity(spore)
		g_player_num_victims[spore_owner]--
	}
	return 0

}

//----------------------------------------------------------------------------------------------
sporetrail(entid){
	trailing_beam(20,entid,{255, 0, 255,125}) 	
}
//----------------------------------------------------------------------------------------------
stock entity_set_follow(entity, target)
{
if ( !is_valid_ent(entity) || !client_hittable(target) ) return 0

new Float:fl_Origin[3], Float:fl_EntOrigin[3]
entity_get_vector(target, EV_VEC_origin, fl_Origin)
entity_get_vector(entity, EV_VEC_origin, fl_EntOrigin)

new Float:fl_InvTime = (kzam_spore_speed / vector_distance(fl_Origin, fl_EntOrigin))

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
	sh_extra_damage(victim, killer, floatround(kzam_spore_damage), "kzam spore")
	sh_bleed_user(victim,killer,spores_kzam_hero_id())
	heal(killer,kzam_spore_damage)
	emit_sound(victim, CHAN_STATIC, SPORE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	g_player_tracks_player[killer][victim]=false
	sh_chat_message(killer,spores_kzam_hero_id(),"You just spored %s!^n",vic_name)
	sh_chat_message(victim,spores_kzam_hero_id(),"You got spored by %s!^n",tger_name)
	untrack_spore(pToucher)
}

}
public destroy_player_launcher(id){
	
	id-=UNDEPLOY_LOOP_TASKID
	if(!client_hittable(id)||! sh_is_active() ) return PLUGIN_HANDLED
	remove_task(id+FIRE_LOOP_TASKID)
	
	if ( spores_has_kzam(id)) {
		arrayset(g_player_tracks_player[id],false,SH_MAXSLOTS+1)
		arrayset(g_player_targets[id],0,SH_MAXSLOTS+1)
		arrayset(g_player_spores[id],0,SH_MAXSLOTS+1)
		g_player_num_victims[id]=0
		g_player_cooldown_remaining[id]=0.0
		num_deployed_spores[id]=0;
		num_launched_spores[id]=0;
		g_launcher_phase[id]=0;
		g_launcher_timer[id]=0.0;
		
		if(is_valid_ent(g_player_launcher[id])){
			
			
			emit_sound(g_player_launcher[id], CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			draw_bbox(g_player_launcher[id],1)
			remove_entity(g_player_launcher[id])
		
		
		}
	}
	return PLUGIN_HANDLED
	
	

}
public death()
{
	new id = read_data(2)
	
	if(spores_has_kzam(id)){
		
		spores_reset_user(id)
		delete_hud_tasks(id)
		
	}
	
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model(KZAM_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, LAUNCHER_SCAN_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_READY_SFX)
	precache_sound(SPORE_WOUND_SFX)
	precache_sound(SPORE_TRAVEL_SFX)
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_explosion_fx()
}