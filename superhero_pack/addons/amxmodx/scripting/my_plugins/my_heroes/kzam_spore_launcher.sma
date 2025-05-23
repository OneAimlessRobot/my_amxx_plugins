



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
	Float:kzam_follow_time;
new kzam_max_victims
new hud_sync_enemies
new bool:g_spore_used[SH_MAXSLOTS+1]
new bool:g_spore_busy[SH_MAXSLOTS+1]
new bool:g_spore_ready[SH_MAXSLOTS+1]
new g_player_num_victims[SH_MAXSLOTS+1]
new g_player_tracks_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
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
	
	register_touch(SPORE_CLASSNAME, "player", "touch_event")
	register_event("ResetHUD","newRound","b")
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	hud_sync_enemies = CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "spore_launch_check")
	register_forward(FM_Think, "spore_think")
}
public plugin_natives(){
	
	
	
	register_native("spores_launch","_spores_launch",0)
	register_native("spores_reset_user","_spores_reset_user",0)
	register_native("spores_clear","_spores_clear",0)
	register_native("spores_busy","_spores_busy",0)
	register_native("spores_ready","_spores_ready",0)
	register_native("spores_used","_spores_used",0)
	register_native("spores_max_victims","_spores_max_victims",0)
	register_native("spores_gather_targets","_spores_gather_targets",0)
	
	
	
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
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	
	if ( spores_has_kzam(id) && sh_is_active() ) {
		
		spores_reset_user(id)
	}
	return PLUGIN_HANDLED
}
public _spores_clear(iPlugins, iParms){
	
	new spore = find_ent_by_class(-1, SPORE_CLASSNAME)
	while(spore) {
		remove_entity(spore)
		spore = find_ent_by_class(spore, SPORE_CLASSNAME)
	}
	
}
public _spores_max_victims(iPlugins, iParms){
	
	return kzam_max_victims
	
}
public _spores_reset_user(iPlugins, iParms){
	
	new id= get_param(1)
	
	if ( spores_has_kzam(id) && sh_is_active() ) {
		arrayset(g_player_tracks_player[id],false,SH_MAXSLOTS+1)
		g_player_num_victims[id]=0
		g_spore_used[id]=false
		g_spore_busy[id]=false
		g_spore_ready[id]=true
	}
	return PLUGIN_HANDLED
	
}
public bool:_spores_ready(iPlugins, iParms){
	
	new id= get_param(1)
	return g_spore_ready[id]
	
}
public bool:_spores_used(iPlugins, iParms){
	
	new id= get_param(1)
	return g_spore_used[id]
	
}
public bool:_spores_busy(iPlugins, iParms){
	
	new id= get_param(1)
	return g_spore_busy[id]
	
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
	
	
	if(!pev_valid(ent)){
		
		return
		
	}
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	

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
		g_player_tracks_player[id][pid]=true
		g_player_num_victims[id]++
	
}
show_targets(id)
}
public _spores_launch(iPlugin,iParms){
	
	new id= get_param(1)
	for(new i=0;i<=SH_MAXSLOTS;i++){
		
			if(i!=id){
				if(g_player_tracks_player[id][i]&&client_hittable(i)&&is_user_connected(i)){
					
					spore_launch(id,i)
				}
			}
	}
	
}
//----------------------------------------------------------------------------------------------
public spore_launch(id,target)
{
new spore = create_entity("info_target")

if ( (spore == 0) || !pev_valid(spore)) {
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


aimvec[0]=originplayer[0]
aimvec[1]=originplayer[1]
aimvec[2]=originplayer[2]+UNITS_ABOVE

b_orig[0] = float(aimvec[0]);
b_orig[1] = float(aimvec[1]);
b_orig[2] = float(aimvec[2]);

entity_set_string(spore, EV_SZ_classname, SPORE_CLASSNAME)


entity_set_model(spore, KZAM_SPORE_MDL)

entity_set_origin(spore, b_orig)
//entity_set_float(spore,EV_FL_health,500.0)
//entity_set_float(spore, EV_FL_takedamage, 1.0)

new Float:MinBox[3]
new Float:MaxBox[3]
MinBox[0] = -SPORE_SIZE
MinBox[1] = -SPORE_SIZE
MinBox[2] = -SPORE_SIZE
MaxBox[0] = SPORE_SIZE
MaxBox[1] = SPORE_SIZE
MaxBox[2] = SPORE_SIZE
entity_set_vector(spore,EV_VEC_mins, MinBox)
entity_set_vector(spore,EV_VEC_maxs, MaxBox)


//Sets who the owner of the entity is
entity_set_edict(spore, EV_ENT_owner, id)

entity_set_int(spore, EV_INT_solid, SOLID_TRIGGER)
entity_set_int(spore,EV_INT_movetype, MOVETYPE_NOCLIP)

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
parms[2]=target
sporetrack(parms)
}
public sporetrack(parms[]){
new spore=parms[0]
emit_sound(parms[1], CHAN_WEAPON, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(floatsub(floatmul(FOLLOW_LOOP_PERIOD,float(FOLLOW_LOOP_TIMES)),0.1),"untrack_spore_task",spore+UNFOLLOW_LOOP_TASKID,parms, 3,  "a",1)
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

if ( is_user_alive(spore_target)) {
	entity_set_follow(spore, spore_target)
	sporetrail(spore)
}
else{
	
	untrack_spore(spore)
	g_player_tracks_player[spore_owner][spore_target]=false
	g_player_num_victims[spore_owner]--
}
}
//----------------------------------------------------------------------------------------------
untrack_spore(spore){
	remove_task(spore+UNFOLLOW_LOOP_TASKID)
	remove_task(spore+FOLLOW_LOOP_TASKID)
	remove_entity(spore)
	return 0

}
//----------------------------------------------------------------------------------------------
public untrack_spore_task(spore){
	spore-=UNFOLLOW_LOOP_TASKID
	remove_task(spore+FOLLOW_LOOP_TASKID)
	remove_entity(spore)
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

new killer = entity_get_edict(pToucher, EV_ENT_owner)
new victim = pTouched
new ffOn = get_cvar_num("mp_friendlyfire")
if ( (get_user_team(victim) != get_user_team(killer)) || ffOn )
{
	sh_extra_damage(victim, killer, floatround(kzam_spore_damage), "kzam spore")
	heal(killer,kzam_spore_damage)
	g_player_tracks_player[killer][victim]=false
	untrack_spore(pToucher)
	g_player_num_victims[killer]--
}

}

//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model(KZAM_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	precache_explosion_fx()
}