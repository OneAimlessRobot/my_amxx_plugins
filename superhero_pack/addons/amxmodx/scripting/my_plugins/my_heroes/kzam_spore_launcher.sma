



#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "kzam_inc/kzam_global.inc"
#include "kzam_inc/kzam_particle.inc"
#include "kzam_inc/kzam_spore_launcher.inc"

new Float:kzam_track_radius, 
	Float:kzam_spore_damage, 
	Float:kzam_spore_speed, 
	Float:kzam_track_time,
	Float:kzam_heal_coeff,
	Float:kzam_spore_base_health,
	Float:kzam_follow_time;
new kzam_max_victims
new hud_sync_enemies
new hud_sync_stats
new num_launched_spores[SH_MAXSLOTS+1]
new g_player_num_victims[SH_MAXSLOTS+1]
new bool:g_player_tracks_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new g_player_targets[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new Float:g_player_cooldown_remaining[SH_MAXSLOTS+1]
new g_spore_phase[MAX_ENTITIES]
new Float:g_spore_timer[MAX_ENTITIES]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO kzam","1.1","MilkChanThaGOAT")
	
	register_cvar("kzam_track_radius", "2000.0")
	register_cvar("kzam_spore_damage", "100.0" )
	register_cvar("kzam_spore_speed", "900.0" )
	register_cvar("kzam_track_time", "5.0" )
	register_cvar("kzam_follow_time", "5.0")
	register_cvar("kzam_heal_coeff", "0.5" )
	register_cvar("kzam_max_victims", "4" )
	register_cvar("kzam_spore_health", "100.0" )
	
	register_touch(SPORE_CLASSNAME, "player", "touch_event")
	register_event("DeathMsg","death","a")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	hud_sync_enemies = CreateHudSyncObj()
	hud_sync_stats = CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "spore_launch_check")
	register_forward(FM_Think, "spore_think")
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
	new hud_msg[300];
	format(hud_msg,200,"[SH] kzam:^nNumber of launched spores %d^nCurrent number of victims gathered: %d^n",
					num_launched_spores[id],
					g_player_num_victims[id]);
	if(g_player_cooldown_remaining[id]>0){
	format(hud_msg,299,"%s^nCooldown_remaining_value: %0.2f^n",hud_msg,
					g_player_cooldown_remaining[id]);
	}
	else{
	
	
	format(hud_msg,299,"%s^n%Mrs. Kzam? The launcher is ready.^n",hud_msg)
	
		
		
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
	
	arrayset(g_spore_phase,0,MAX_ENTITIES)
	arrayset(g_spore_timer,0.0,MAX_ENTITIES)
	
}
public _spores_max_victims(iPlugins, iParms){
	
	return kzam_max_victims
	
}
public _spores_reset_user(iPlugins, iParms){
	
	new id= get_param(1)
	
	if ( spores_has_kzam(id) && sh_is_active() ) {
		arrayset(g_player_tracks_player[id],false,SH_MAXSLOTS+1)
		arrayset(g_player_targets[id],0,SH_MAXSLOTS+1)
		g_player_num_victims[id]=0
		g_player_cooldown_remaining[id]=0.0
		num_launched_spores[id]=0;
	}
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
	kzam_track_time= get_cvar_float("kzam_track_time")
	kzam_follow_time= get_cvar_float("kzam_follow_time")
	kzam_heal_coeff=get_cvar_float("kzam_heal_coeff")
	kzam_spore_base_health=get_cvar_float("kzam_spore_health")
	kzam_max_victims= get_cvar_num("kzam_max_victims")
}
show_targets(id){

	new hud_msg[500];
	new client_name[128];
	get_user_name(id,client_name,127)
	format(hud_msg,500,"[SH] kzam:^nTHE FOLLOWING PLAYERS WILL BE TARGETED BY AN INCOMMING SPORE ATTACK FROM %s!!!!^n^n",client_name)
	for(new i=1;i<=SH_MAXSLOTS;i++){
		if(g_player_tracks_player[id][i]&&client_hittable(i)){
			get_user_name(i,client_name,127)
			format(hud_msg,500,"%s%s.^n",hud_msg,client_name);
		}
	} 
	set_hudmessage(LineColors[PURPLE][0],LineColors[PURPLE][1],LineColors[PURPLE][2], -1.0, -1.0,      0,       0.0,       4.0,       0.0,     0.0,      1)
	ShowSyncHudMsg(0, hud_sync_enemies, "%s", hud_msg)

}
public spore_think(ent){
	
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, SPORE_CLASSNAME) ) return FMRES_IGNORED
	
	new Float:spore_hp=float(pev(ent,pev_health))
	
	
	if ( (spore_hp<SPORE_DEAD_HP) ||( g_spore_timer[ent]>kzam_track_time)){
		
		untrack_spore(ent)
		return FMRES_IGNORED
		
	}
	floatadd(g_spore_timer[ent],SPORE_THINK_PERIOD)
	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,SPORE_THINK_PERIOD));
	
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public _spores_gather_targets(iPlugin, iParms)
{
new id= get_param(1)
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
for( new i= 0;i< numfound;i++){
	
	
				
		new pid = entlist[i];
		if(!client_hittable(pid)){
			continue
		
		}
		
		if(g_player_num_victims[id]>=kzam_max_victims){
			return
		
		}
		if((cs_get_user_team(pid)==idTeam)){
				continue
		}
		if(!g_player_tracks_player[id][pid]){
			g_player_tracks_player[id][pid]=true
			g_player_num_victims[id]++
		}
	
}
show_targets(id)
}
public _spores_launch(iPlugin,iParms){
	
	new id= get_param(1)
	
	for(new i=0;i<=SH_MAXSLOTS;i++){
		
			if(i!=id){
				if(g_player_tracks_player[id][i]&&client_hittable(i)&&is_user_connected(i)){
					g_player_targets[id][num_launched_spores[id]++]=i;
					
				}
			}
	}
	set_task(SHOOT_LOOP_PERIOD, "spore_launch", id+SHOOT_LOOP_TASKID, "", 0, "a",num_launched_spores[id])
	g_player_cooldown_remaining[id]=spores_cooldown()
}
//----------------------------------------------------------------------------------------------
public spore_launch(id)
{
id-= SHOOT_LOOP_TASKID
if(!spores_has_kzam(id)||!client_hittable(id)){
	
	return
}
new material[128]
new health[128]	
new spore = create_entity( "func_breakable" );

if ( (spore == 0) || !pev_valid(spore)||!is_valid_ent(spore)) {
	client_print(id, print_chat, "[SH](Kzam) Spore Creation Failure")
	return
}

g_spore_phase[spore]=0
g_spore_timer[spore]=0.0

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


set_pev(spore, pev_takedamage, DAMAGE_YES)
set_pev(spore, pev_solid, SOLID_TRIGGER)
entity_set_int(spore,EV_INT_movetype, MOVETYPE_NOCLIP)
entity_set_origin(spore, b_orig)

//Sets who the owner of the entity is
entity_set_edict(spore, EV_ENT_euser1,id)

new velocity[3]
new Float:fVelocity[3]
//This will set the velocity of the entity
velocity_by_aim(id, floatround(kzam_spore_speed), fVelocity)
FVecIVec(fVelocity, velocity) //converts a floating vector to an integer vector

//This will set the entity in motion
entity_set_vector(spore, EV_VEC_velocity, fVelocity)
new parms[3];
parms[0]=spore
parms[1]=id
parms[2]=(g_player_targets[id][num_launched_spores[id]-1])
new user_name[128]
get_user_name(g_player_targets[id][num_launched_spores[id]-1],user_name,127)
client_print(id, print_console, "[SH](Kzam) Spore sent! spore id is: %d^nLaunched at target number: %d^nThe name if said target is: %s^n",spore,num_launched_spores[id],user_name)
num_launched_spores[id]--
sporetrack(parms)
}
public sporetrack(parms[]){
new spore=parms[0]
emit_sound(parms[1], CHAN_WEAPON, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(floatsub(floatmul(FOLLOW_LOOP_PERIOD,float(FOLLOW_LOOP_TIMES)),0.1),"untrack_spore_task",spore+UNFOLLOW_LOOP_TASKID,"",0,  "a",1)
set_task(FOLLOW_LOOP_PERIOD, "track_spore", spore+FOLLOW_LOOP_TASKID, parms, 3, "a",FOLLOW_LOOP_TIMES)
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

if ( is_user_alive(spore_target)&&is_user_alive(spore_owner)) {
	entity_set_follow(spore, spore_target)
	sporetrail(spore)
}
else{
	
	untrack_spore(spore)
	g_player_tracks_player[spore_owner][spore_target]=false
}
}
//----------------------------------------------------------------------------------------------
untrack_spore(spore){
	remove_task(spore+UNFOLLOW_LOOP_TASKID)
	remove_task(spore+FOLLOW_LOOP_TASKID)
	if(pev_valid(spore)){
		new spore_owner = entity_get_edict(spore, EV_ENT_euser1)
		g_player_num_victims[spore_owner]--
		g_spore_phase[spore]=0
		g_spore_timer[spore]=0.0
		remove_entity(spore)
	}
	return 0

}
//----------------------------------------------------------------------------------------------
public untrack_spore_task(spore){
	spore-=UNFOLLOW_LOOP_TASKID
	remove_task(spore+FOLLOW_LOOP_TASKID)
	if(pev_valid(spore)){
		new spore_owner = entity_get_edict(spore, EV_ENT_euser1)
		g_player_num_victims[spore_owner]--
		g_spore_phase[spore]=0
		g_spore_timer[spore]=0.0
		remove_entity(spore)
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

new killer = entity_get_edict(pToucher, EV_ENT_euser1)
new victim = pTouched
new ffOn = get_cvar_num("mp_friendlyfire")
if ( (get_user_team(victim) != get_user_team(killer)) || ffOn )
{
	sh_extra_damage(victim, killer, floatround(kzam_spore_damage), "kzam spore")
	emit_sound(victim, CHAN_WEAPON, SPORE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	heal(killer,kzam_spore_damage)
	g_player_tracks_player[killer][victim]=false
	untrack_spore(pToucher)
}

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
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_WOUND_SFX)
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_explosion_fx()
}