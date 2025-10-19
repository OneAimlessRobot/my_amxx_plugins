
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "jetplane_inc/sh_jetplane_funcs.inc"
#include "jetplane_inc/sh_jetplane_engine_funcs.inc"
#include "jetplane_inc/sh_jetplane_bomb_funcs.inc"
#include "jetplane_inc/sh_jetplane_rocket_funcs.inc"
#include "jetplane_inc/sh_jetplane_radio_funcs.inc"
#include "jetplane_inc/sh_jetplane_mg_funcs.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_inc_pt2.inc"


#define PLUGIN "Superhero yandere jetty funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum



new g_jetplane_cooldown[SH_MAXSLOTS+1];
new g_jetplane_loaded[SH_MAXSLOTS+1];
new g_jetplane_deployed[SH_MAXSLOTS+1];
new g_jetplane[SH_MAXSLOTS+1];
new g_jetplane_sound_on[SH_MAXSLOTS+1];
new Float:g_jetplane_turn_data[SH_MAXSLOTS+1][4];
new Float:g_jetplane_telemetry_data[SH_MAXSLOTS+1][5];
new Float:g_jetplane_airspeed[SH_MAXSLOTS+1]
new camera[SH_MAXSLOTS+1]
new Float:jetplane_cooldown,
Float:jetplane_hp;
stock Float:jet_think_period
stock Float:jet_init_speed
stock jetplane_enable_gravity= 0;
stock jetplane_enable_air_drag= 1;
stock jetplane_enable_speed_limiter= 1;
new hud_sync_charge
new hud_sync_jetplane

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("yandere_jetplane_hp", "5")
	register_cvar("yandere_jetplane_cooldown", "5")
	register_cvar("yandere_jetplane_think_period", "5")
	register_cvar("yandere_jetplane_init_speed", "5")
	register_cvar("yandere_jetplane_enable_gravity", "0")
	register_cvar("yandere_jetplane_enable_air_drag", "1")
	register_cvar("yandere_jetplane_enable_speed_limiter", "1")
	arrayset(g_jetplane_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_jetplane_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_jetplane_deployed,0,SH_MAXSLOTS+1)
	arrayset(g_jetplane,-1,SH_MAXSLOTS+1)
	arrayset(g_jetplane_sound_on,0,SH_MAXSLOTS+1)
	hud_sync_charge=CreateHudSyncObj()
	hud_sync_jetplane=CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink")
	register_forward(FM_Think, "jet_think")
	RegisterHam(Ham_TakeDamage,"player","jet_Damage",_,true)
	
	
	new const szEntity[ ][ ] = {
		"worldspawn", "func_wall", "func_door",  "func_door_rotating",
		"func_wall_toggle", "func_breakable", "func_pushable", "func_train",
		"func_illusionary", "func_button", "func_rot_button", "func_rotating"
	}
	
	for( new i; i < sizeof szEntity; i++ ){
		register_touch( JETPLANE_FUSELAGE_CLASSNAME, szEntity[ i ], "FwdTouchWorld" );
	}
	
	RegisterHam(Ham_TakeDamage,"func_breakable","jet_itself_Damage",_,true)
	
}


public plugin_cfg(){
	
	loadCVARS();
}
public plugin_natives(){
	
	register_native("clear_jets","_clear_jets",0);
	register_native("reset_jet_user","_reset_jet_user",0);
	register_native("jet_get_user_jet_cooldown","_jet_get_user_jet_cooldown",0);
	register_native("jet_get_think_period","_jet_get_think_period",0);
	register_native("jet_uncharge_user","_jet_uncharge_user",0);
	register_native("jet_charge_user","_jet_charge_user",0);
	register_native("jet_loaded","_jet_loaded",0);
	register_native("jet_deployed","_jet_deployed",0);
	register_native("jet_destroy","_jet_destroy",0);
	register_native("jet_get_user_jet","_jet_get_user_jet",0);
	register_native("jet_hurt_user_jet","_jet_hurt_user_jet",0);

	
	
	
}
public loadCVARS(){
	jetplane_cooldown=get_cvar_float("yandere_jetplane_cooldown");
	jetplane_hp=get_cvar_float("yandere_jetplane_hp")
	jet_think_period=get_cvar_float("yandere_jetplane_think_period")
	jet_init_speed=get_cvar_float("yandere_jetplane_init_speed")
	jetplane_enable_gravity=get_cvar_num("yandere_jetplane_enable_gravity")
	jetplane_enable_air_drag=get_cvar_num("yandere_jetplane_enable_air_drag")
	jetplane_enable_speed_limiter=get_cvar_num("yandere_jetplane_enable_speed_limiter")
}
public plugin_precache(){
	
	
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	engfunc(EngFunc_PrecacheSound,JETPLANE_FLY_SOUND );
	engfunc(EngFunc_PrecacheSound,JETPLANE_BLOW_SOUND );
	engfunc(EngFunc_PrecacheSound,JETPLANE_IDLE_SOUND );
	precache_model(JETPLANE_MODEL)
	precache_model(JETPLANE_CAMERA_MODEL)
	precache_explosion_fx()
	
	
}
public _jet_get_user_jet(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane[id]
	
	
}
public _jet_hurt_user_jet(iPlugin,iParams){
	new id=get_param(1)
	new attacker=get_param(2)
	new damage_entity=get_param(3)
	new Float:damage_to_do=get_param_f(4)
	if(!sh_is_active()){
		return
	}
	if(pev_valid(damage_entity)!=2){
		return
	}
	if(!client_hittable(id)||!client_hittable(attacker)){
		return
	}
	if(!yandere_get_has_yandere(attacker)){
		return
	}
	if(pev_valid(jet_get_user_jet(id))!=2){
		return
	}
	if(!jet_deployed(id)){
		return
	}
	ExecuteHam(Ham_TakeDamage, jet_get_user_jet(id), damage_entity, attacker, damage_to_do, 0);
	
}
public Float:_jet_get_think_period(iPlugin,iParams){
	return jet_think_period
	
	
}
public _jet_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_loaded[id]
	
	
}
public _jet_deployed(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_deployed[id]
	
	
}
public _jet_get_user_jet_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jetplane_cooldown[id]
	
	
}
public _jet_charge_user(iPlugin, iParams){
	
	new id= get_param(1)
	if(!g_jetplane_loaded[id]){
		
		sh_chat_message(id,yandere_get_hero_id(),"Shield not loaded")
		return
	}
	g_jetplane_loaded[id]=0
	
	new material[128]
	new health[128]	
	g_jetplane[id] = create_entity( "func_breakable" );
	new NewEnt=g_jetplane[id]
	if(!is_valid_ent(g_jetplane[id])||(g_jetplane[id] <= 0)) {
		
		return
	}
	set_pev(NewEnt, pev_classname, JETPLANE_FUSELAGE_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, JETPLANE_MODEL)
	float_to_str(1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_mins,jetplane_min_dims)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_maxs,jetplane_max_dims)
	
	set_pev(NewEnt, pev_health, 0)
	set_pev(NewEnt, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	set_pev(NewEnt, pev_solid, SOLID_NOT)
	set_pev(NewEnt, pev_body, 3)
	set_pev(NewEnt, pev_sequence, 7)	// 7 = TRIPMINE_WORLD
	set_pev(NewEnt, pev_takedamage, DAMAGE_NO)
	set_pev(NewEnt,pev_rendermode,kRenderTransAlpha)
	set_pev(NewEnt,pev_renderfx,kRenderFxGlowShell)
	new alpha=100
	set_pev(NewEnt,pev_renderamt,float(alpha))
	set_pev(g_jetplane[id],pev_owner,id)
	new parm[2]
	parm[0]=id
	parm[1]=g_jetplane[id]
	set_task(jetplane_cooldown,"load_jet",id+JET_LOAD_TASKID,"", 0,  "a",1)
	set_task(JET_CHARGE_PERIOD,"charge_task",id+JET_CHARGE_TASKID,parm, 2,  "b")
	return
	
	
	
}
public jet_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!shModActive() || !is_user_connected(this)||!is_user_alive(this)||!yandere_get_has_yandere(this)) return HAM_IGNORED
	
	if(!g_jetplane_deployed[this]) return HAM_IGNORED
	
	damage=0.0;
	return HAM_SUPERCEDE
	
	
	
}
public jet_itself_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!sh_is_active()){
		return HAM_IGNORED
	}
	if(pev_valid(this)!=2){
		return HAM_IGNORED
	
	}
	
	
	if(pev_valid(idattacker)!=2){
		return HAM_IGNORED
	
	}
	if(!is_user_connected(idattacker)){
		return HAM_IGNORED
	
	}
	new attacker_name[128]
	get_user_name(idattacker,attacker_name,127);
	if(pev_valid(idinflictor)!=2){
		return HAM_IGNORED
	
	}
	static jet_classname[32]
	jet_classname[31]='^0'
	pev(this, pev_classname, jet_classname, charsmax(jet_classname))
	if(!equal(jet_classname, JETPLANE_FUSELAGE_CLASSNAME)){
		
		return HAM_IGNORED
		
	}
	static classname[32]
	classname[0] = '^0'
	pev(idinflictor, pev_classname, classname, charsmax(classname))
	
	new oid = entity_get_edict(this, EV_ENT_owner)
	
	console_print(oid,"[SH] (Selfless-Yandere_Pt2): Your jet has been damaged!!!^nYou received: %0.2f damage^nFrom entity of type: %s^nFrom attacker of id: %d (name %s)^n"
				,damage
				,classname
				,idattacker
				,attacker_name);
	
	return HAM_IGNORED;
}

public _jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)
	
	
}
uncharge_user(id){
	remove_task(id+JET_CHARGE_TASKID)
	g_jetplane_deployed[id]=0
	if(is_valid_ent(g_jetplane[id])){
		emit_sound(g_jetplane[id], CHAN_ITEM, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=0;
	}
	g_jetplane_loaded[id]=1
	return 0
	
	
	
}

public _reset_jet_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_jetplane_loaded[id]=true;
	g_jetplane_cooldown[id]=0;
	g_jetplane_deployed[id]=false;
	if(is_valid_ent(g_jetplane[id])){
		emit_sound(g_jetplane[id], CHAN_ITEM, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=0;
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
	
	
	
}

public jet_deploy_task(parm[],id){
	
	id-=JET_DEPLOY_TASKID
	
	new attacker=parm[0];
	new jetplane_id=parm[1];
	if(!is_valid_ent(jetplane_id)){
		
		return;
	}
	if(!client_hittable(attacker)){
		
		return
	}
	if(!yandere_get_has_yandere(attacker)){
		
		return
	}
	set_pev(jetplane_id, pev_takedamage, DAMAGE_YES)
	set_pev(jetplane_id, pev_movetype, jetplane_enable_gravity?MOVETYPE_BOUNCE:MOVETYPE_BOUNCEMISSILE) 
	set_pev(jetplane_id, pev_solid, SOLID_BBOX)
	if(get_user_gravity(attacker)>0.0){
		set_user_gravity(attacker,0.0)
	
	}
	set_pev(jet_get_user_jet(id),pev_gravity,jetplane_enable_gravity?JETPLANE_GRAVITY_MULT*0.15:0.0)
	new alpha=255
	set_pev(jetplane_id,pev_renderamt,float(alpha))
	set_pev(attacker, pev_takedamage, DAMAGE_NO)
	set_pev(attacker, pev_solid, SOLID_NOT)
	set_pev(attacker, pev_movetype, MOVETYPE_NONE) 
	reset_jet_fuel(jetplane_id)
	reset_jet_bombs(jetplane_id)
	reset_jet_shells(jetplane_id)
	reset_jet_rockets(jetplane_id)
	reset_jet_scans(jetplane_id)
	sh_chat_message(attacker,yandere_get_hero_id(),"jet armed!");
	camera[id] = create_entity("info_target")
	new Float:origin[3]
	new Float:init_speed[3]
	new Float:angles[3]
	new Float:v_angle[3]
		
	velocity_by_aim(id,floatround(get_jet_speed()),init_speed)
	pev(jetplane_id,pev_origin,origin)
	origin[2]+=jetplane_max_dims[2]+100.0
	set_pev(jetplane_id,pev_origin,origin)
	origin[0]+=jetplane_max_dims[0]
	entity_get_vector(id, EV_VEC_v_angle, v_angle)
	entity_get_vector(id, EV_VEC_angles, angles)
	entity_set_vector(jetplane_id, EV_VEC_angles, angles)
	entity_set_vector(jetplane_id, EV_VEC_v_angle, v_angle)
	v_angle[0] = - v_angle[0]
	if(camera[id] > 0)
	{
		entity_set_string(camera[id], EV_SZ_classname, "camera")
		entity_set_int(camera[id], EV_INT_solid, SOLID_NOT)
		entity_set_int(camera[id], EV_INT_movetype, MOVETYPE_NOCLIP)
		entity_set_size(camera[id], Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
		entity_set_model(camera[id], JETPLANE_CAMERA_MODEL)
		set_rendering(camera[id], kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		
		
		entity_set_origin(camera[id], origin)
		entity_set_vector(camera[id], EV_VEC_angles, v_angle)
		
		attach_view(id, camera[id])
	}
	set_pev(jetplane_id,pev_velocity,init_speed)
	g_jetplane_airspeed[id]=jet_init_speed
	spawn_jetplane_mg(attacker)
	spawn_jetplane_law(attacker)
	set_task(JET_HUD_PERIOD,"jet_hud_task",attacker+JET_HUD_TASKID,"",0,"b")
	arrayset(g_jetplane_telemetry_data[attacker],0.0,sizeof g_jetplane_telemetry_data[]);
	arrayset(g_jetplane_turn_data[attacker],0.0,sizeof g_jetplane_turn_data[]);
	set_task(JET_SOUND_PERIOD,"jet_sound_task",attacker+JET_SOUND_TASKID,"",0,"b")
	set_pev(jetplane_id, pev_nextthink, get_gametime() + jet_get_think_period())
}
public load_jet(id){
	id-=JET_LOAD_TASKID
	
	g_jetplane_loaded[id]=1;	
	sh_chat_message(id,yandere_get_hero_id(),"JET loaded");
	
	
}

public FwdTouchWorld( Ball, World ) {
	static Float:vVelocity[ 3 ];
	entity_get_vector( Ball, EV_VEC_velocity, vVelocity );
	
	if( floatround( vector_length( vVelocity ) ) > 10 ) {
		vVelocity[ 0 ] *= 0.15;
		vVelocity[ 1 ] *= 0.15;
		vVelocity[ 2 ] *= 0.15;
		
		entity_set_vector( Ball, EV_VEC_velocity, vVelocity );
		
	}
	
	return PLUGIN_CONTINUE;
}

//----------------------------------------------------------------------------------------------
public jet_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, JETPLANE_FUSELAGE_CLASSNAME) ) return FMRES_IGNORED
	
	static Float:gametime,Float:Pos[3]
	gametime = get_gametime()
	pev(ent, pev_origin, Pos)
	new owner=pev(ent,pev_owner)
	
	if(!client_hittable(owner)){

		return FMRES_IGNORED
	}
	if(!yandere_get_has_yandere(owner)||!g_jetplane_deployed[owner]){

		return FMRES_IGNORED
	}
		
	new Float:jet_health=float(pev(ent,pev_health))
	
	if ( (jet_health<1000.0)) {
		if(g_jetplane[owner]){
			jet_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet died!")
			uncharge_user(owner)
		}
		return FMRES_IGNORED
	}
	if(g_jetplane_deployed[owner]){
		
		new wpnid=get_user_weapon(owner)
		if(wpnid!=CSW_KNIFE){
			shSwitchWeaponID(owner,CSW_KNIFE)
		}
		
		new Float:vOrigin[3]
		new Float:v_angle[3]
		new Float:velocity[3]
		new Float:accel_thingie=0.0;
		new Float:brake_thingie=0.0;
		new Float:turn_thingie=0.0;
		new Float:updown_thingie=0.0;
		new Float:rolly_thingie=0.0;
		set_pev(owner,pev_velocity,NULL_VECTOR)
		Entvars_Get_Vector(jet_get_user_jet(owner), EV_VEC_origin, vOrigin)
		
		sh_set_rendering(owner,0,0,0,1,kRenderFxNone,kRenderTransAlpha);
		ENT_SetOrigin(owner, vOrigin)
		
		if(get_jet_upflapon(owner)||get_jet_downflapon(owner)){
			if(get_jet_upflapon(owner)){
		

				updown_thingie-=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
			if(get_jet_downflapon(owner)){

				

				updown_thingie+=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
		}
		else{
			
			updown_thingie-=((1.0/jet_get_stabilizer_mushyness())*1.0*g_jetplane_turn_data[owner][0])
		}
		g_jetplane_turn_data[owner][0]=floatclamp(g_jetplane_telemetry_data[owner][4]/(get_jet_speed()*JETPLANE_MAX_TURN_SPEED_THRESHOLD),JETPLANE_MIN_TURN_CONST,1.0)*floatclamp(g_jetplane_turn_data[owner][0]+updown_thingie,-jet_get_max_turn_const()*0.5,jet_get_max_turn_const()*0.5);
		if(get_jet_leftflapon(owner)||get_jet_rightflapon(owner)){
			if(get_jet_leftflapon(owner)){


				turn_thingie+=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
			if(get_jet_rightflapon(owner)){

				

				turn_thingie-=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
		}
		else{
			turn_thingie-=((1.0/jet_get_stabilizer_mushyness())*1.0*g_jetplane_turn_data[owner][1])
		}
		g_jetplane_turn_data[owner][1]=floatclamp(g_jetplane_telemetry_data[owner][4]/(get_jet_speed()*JETPLANE_MAX_TURN_SPEED_THRESHOLD),JETPLANE_MIN_TURN_CONST,1.0)*floatclamp(g_jetplane_turn_data[owner][1]+turn_thingie,-jet_get_max_turn_const()*0.5,jet_get_max_turn_const()*0.5);
		
		if(get_jet_left_rollflapon(owner)||get_jet_right_rollflapon(owner)){
			if(get_jet_left_rollflapon(owner)){


				rolly_thingie+=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
			if(get_jet_right_rollflapon(owner)){

				

				rolly_thingie-=jet_get_turn_inc_const()*jet_get_think_period()
				
			}
		}
		else{
	
			rolly_thingie-=((1.0/jet_get_stabilizer_mushyness())*1.0*g_jetplane_turn_data[owner][2]);
		}
		g_jetplane_turn_data[owner][2]=floatclamp(g_jetplane_telemetry_data[owner][4]/(get_jet_speed()*JETPLANE_MAX_TURN_SPEED_THRESHOLD),JETPLANE_MIN_TURN_CONST,1.0)*floatclamp(g_jetplane_turn_data[owner][2]+rolly_thingie,-jet_get_max_turn_const()*0.5,jet_get_max_turn_const()*0.5);

		new Float:angles[3]
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_angles, angles)
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_v_angle, v_angle)
		v_angle[1]+=g_jetplane_turn_data[owner][1]
		angles[1]+=g_jetplane_turn_data[owner][1]
		v_angle[0]=floatclamp(v_angle[0]+g_jetplane_turn_data[owner][0],-45.0,45.0)
		angles[0]=floatclamp(angles[0]-g_jetplane_turn_data[owner][0],-45.0,45.0)
		v_angle[2]=floatclamp(v_angle[2]-g_jetplane_turn_data[owner][2],-90.0,90.0)
		angles[2]=floatclamp(angles[2]-g_jetplane_turn_data[owner][2],-90.0,90.0)
		entity_set_vector(owner, EV_VEC_v_angle, v_angle)
		entity_set_vector(owner, EV_VEC_angles, angles)
		entity_set_vector(jet_get_user_jet(owner), EV_VEC_v_angle, v_angle)
		entity_set_vector(jet_get_user_jet(owner), EV_VEC_angles, angles)
		
		velocity_by_aim(jet_get_user_jet(owner),floatround(CAMERA_DIST),velocity)
		new Float:length=vector_length(velocity)
		if(pev_valid(camera[owner])==2){
			
			
			
			vOrigin[1]-=velocity[1]*(CAMERA_DIST/length)
			vOrigin[2]-=velocity[2]*(CAMERA_DIST/length)
			vOrigin[2]+=40.0
			vOrigin[0]-=velocity[0]*(CAMERA_DIST/length)
			entity_set_vector(camera[owner], EV_VEC_angles, v_angle)
			entity_set_vector(camera[owner], EV_VEC_origin, vOrigin)
			
			
		}
		
		if(get_jet_flying(owner)&&get_jet_throttle(owner)){


			accel_thingie=1.0
			
		}
		if(get_jet_airbrakes(owner)){


			brake_thingie+=floatclamp(g_jetplane_telemetry_data[owner][4]/(get_jet_speed()*JETPLANE_MAX_BRAKE_SPEED_THRESHOLD),JETPLANE_MIN_BRAKE_CONST,1.0)*1.0
			
		}
		
		new Float:raw_velocity[3];
		arrayset(raw_velocity,0,sizeof raw_velocity);
		new Float:accel_result=accel_thingie*get_jet_accelerate_const()*jet_get_think_period();
		new Float:brake_result=brake_thingie*get_jet_brake_const()*jet_get_think_period();
		
		new Float:thrust_vector[3];
		arrayset(thrust_vector,0,sizeof thrust_vector);
		if(get_jet_flying(owner)){
				velocity_by_aim(jet_get_user_jet(owner), floatround(accel_result), thrust_vector)
		}
		new Float:airbrake_vector[3];
		arrayset(airbrake_vector,0,sizeof airbrake_vector);
		if(get_jet_flying(owner)){
			velocity_by_aim(jet_get_user_jet(owner), -1*floatround(brake_result), airbrake_vector)
		}
		new Float:other_velocity[3]
		new Float:velocity_copy[3]

		entity_get_vector(jet_get_user_jet(owner),EV_VEC_velocity,other_velocity);
		multiply_3d_vector_by_scalar(other_velocity,1.0,velocity_copy);
		new Float:drag_vector[3];
		if(jetplane_enable_air_drag){
			arrayset(drag_vector,0,sizeof drag_vector);
			new Float:norm= VecLength(velocity_copy);
			velocity_by_aim(jet_get_user_jet(owner),floatround(norm),raw_velocity);
			new Float:gravity_const=get_cvar_float("sv_gravity")*JETPLANE_GRAVITY_MULT
			drag_vector[0]=-((JETPLANE_DRAG_CONST*norm*velocity_copy[0])/gravity_const)*jet_get_think_period();
			drag_vector[1]=-((JETPLANE_DRAG_CONST*norm*velocity_copy[1])/gravity_const)*jet_get_think_period();
			drag_vector[2]=-((JETPLANE_DRAG_CONST*norm*velocity_copy[2])/gravity_const)*jet_get_think_period();
		}
		raw_velocity[2]=velocity_copy[2]
		for(new i=0;i<3;i++){
			raw_velocity[i]+=thrust_vector[i]+(jetplane_enable_air_drag?drag_vector[i]:0.0)+airbrake_vector[i];
		}
		
		
		new Float:raw_speed=VecLength(raw_velocity);
		
		if(jetplane_enable_speed_limiter){
			new Float:speed_limit_thingie=(raw_speed>=get_jet_speed())?(raw_speed-get_jet_speed()+((1.0/JETPLANE_MAX_SPEED_BOUNCE_RATIO)*get_jet_speed() )):0.0
			if(speed_limit_thingie>0.0){
			
				vector_norm(raw_velocity, raw_velocity)
				new Float:new_speed=raw_speed-speed_limit_thingie;
				multiply_3d_vector_by_scalar(raw_velocity,new_speed,raw_velocity)
			}
		}
		
		set_pev(jet_get_user_jet(owner), pev_velocity, raw_velocity)
		set_pev(ent, pev_nextthink, gametime + jet_get_think_period())
	}
		
	return FMRES_IGNORED
}
public charge_task(parm[],id){
	id-=JET_CHARGE_TASKID
	
	
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])-40
	
	if(!is_valid_ent(g_jetplane[id])||(g_jetplane[id] == 0)) {
		return
	}
	ENT_SetOrigin(g_jetplane[id], vOrigin)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_angles, vAngles)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_jetplane[id], EV_VEC_velocity,  velocity)
	
	
	new hud_msg[128];
	set_pev(g_jetplane[id],pev_health,floatmin(jetplane_hp,floatadd(float(pev(g_jetplane[id],pev_health)),floatmul(JET_CHARGE_PERIOD,JET_CHARGE_RATE))))
	format(hud_msg,127,"[SH]: Curr build pct: %0.2f^n",float(pev(g_jetplane[id],pev_health)));
	set_hudmessage(jetplane_color[0], jetplane_color[1], jetplane_color[2], -1.0, -1.0, 1, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	new parm[2]
	parm[0]=id
	parm[1]=g_jetplane[id]
	
	emit_sound(g_jetplane[id], CHAN_ITEM,JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if((pev(g_jetplane[id],pev_health))>=floatround(jetplane_hp)){
		
		g_jetplane_deployed[id]=1;
		set_pev(g_jetplane[id],pev_health,1000.0+pev(g_jetplane[id],pev_health))
		jet_deploy_task(parm,id+JET_DEPLOY_TASKID)
		remove_task(id+JET_CHARGE_TASKID)
	}
	
	
	
	
	
	
}

public jet_sound_task(id){
	new owner=id-JET_SOUND_TASKID
	if(!client_hittable(owner)){
		
		remove_task(id)
		return
	}
	if(!yandere_get_has_yandere(owner)){
		
		remove_task(id)
		return
	}
	if(!jet_deployed(owner)){
		
		remove_task(id)
		return
	}
	if(get_jet_engine(owner)&&get_jet_throttle(owner)){
		g_jetplane_sound_on[owner]=1;
	}
	else{
		if(g_jetplane_sound_on[owner]){
		
			emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_IDLE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_BLOW_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, NULL_SOUND_FILENAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			g_jetplane_sound_on[owner]=0;
		
		}
	}
	if(g_jetplane_sound_on[owner]){
		if(g_jetplane_telemetry_data[owner][2]>get_cvar_float("yandere_jetplane_speed")*0.5){
			
			if(random(SoundRate) == (SoundRate-1)){ //make random chance to draw flame & play sound to reduce lag, send MSG_PVS instead of MSG_BROADCAST
				if(get_user_fuel_ammount(owner) > 160.0){
					emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_LOW+floatround(float(PITCH_HIGH-PITCH_LOW)*(g_jetplane_telemetry_data[owner][4]/get_cvar_float("yandere_jetplane_speed"))));
				}
				else{
					emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_BLOW_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_LOW+floatround(float(PITCH_HIGH-PITCH_LOW)*(g_jetplane_telemetry_data[owner][4]/get_cvar_float("yandere_jetplane_speed"))));
				}
			}
		}
		else{
			emit_sound(jet_get_user_jet(owner), CHAN_WEAPON, JETPLANE_IDLE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_LOW+floatround(float(PITCH_HIGH-PITCH_LOW)*(g_jetplane_telemetry_data[owner][4]/get_cvar_float("yandere_jetplane_speed"))));
			
		}	
		if(g_jetplane_telemetry_data[owner][2]>get_cvar_float("yandere_jetplane_speed")*0.5){
			if(random(FlameRate) == (FlameRate-1)) //make random chance to draw flame & play sound to reduce lag, send MSG_PVS instead of MSG_BROADCAST
			{
				trail(jet_get_user_jet(owner))
			}
		}
	}
}
public jet_hud_task(id){
	
	new owner=id-JET_HUD_TASKID
	if(!client_hittable(owner)){
		
		remove_task(id)
		return
	}
	if(!yandere_get_has_yandere(owner)){
		
		remove_task(id)
		return
	}
	if(!jet_deployed(owner)){
		
		remove_task(id)
		return
	}
	new Float:move_velocity[3]
	entity_get_vector(jet_get_user_jet(owner), EV_VEC_velocity, move_velocity)
	new Float:abs_velocity=vector_length(move_velocity)
	g_jetplane_telemetry_data[owner][4]=abs_velocity
	if(g_jetplane_telemetry_data[owner][0]>JET_AVG_SPEED_CALC_PERIOD){
		g_jetplane_telemetry_data[owner][2]=g_jetplane_telemetry_data[owner][1]/(g_jetplane_telemetry_data[owner][0]/JET_HUD_PERIOD)
		g_jetplane_telemetry_data[owner][0]=0.0
		g_jetplane_telemetry_data[owner][1]=0.0
		
	}
	new hud_msg[1024]
	format(hud_msg,1023,"Up flap on?: %s^nDown flap on?: %s^nLeft flap on?: %s^nRight flap on?: %s^nLeft roll flap on?: %s^nRight roll flap on?: %s^nThrottle on? %s^nAirbrake on? %s^njetplane hp: %0.2f^njetplane fuel: %0.2f^njetplane AVG SPEED (hu/s): %0.2f^nIs engine on? %s^nIs jetplane flying? %s^njetplane BOMBS: %d^njetplane JETGATLING hp: %0.2f^njetplane JETGATLING rounds: %d^njetplane LAW hp: %0.2f^njetplane roquetos: %d^nGround scans left: %d^n",
		get_jet_upflapon(owner)?"Yes":"No",
		get_jet_downflapon(owner)?"Yes":"No",
		get_jet_leftflapon(owner)?"Yes":"No",
		get_jet_rightflapon(owner)?"Yes":"No",
		get_jet_left_rollflapon(owner)?"Yes":"No",
		get_jet_right_rollflapon(owner)?"Yes":"No",
		get_jet_throttle(owner)?"Yes":"No",
		get_jet_airbrakes(owner)?"Yes":"No",
		float(pev(jet_get_user_jet(owner),pev_health))-1000.0,
		get_user_fuel_ammount(owner),
		g_jetplane_telemetry_data[owner][2],
		get_jet_engine(owner)?"Yes":"No",
		get_jet_flying(owner)?"Yes":"No",
		get_user_jet_bombs(owner),
		get_user_mg(owner)?(float(pev(get_user_mg(owner),pev_health))-1000.0):0.0,
		get_user_jet_shells(owner),
		get_user_law(owner)?(float(pev(get_user_law(owner),pev_health))-1000.0):0.0,
		get_user_jet_rockets(owner),
		get_user_jet_scans(owner));
	set_hudmessage(jetplane_color[0], jetplane_color[1], jetplane_color[2], 0.15, 1.9, 1, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(owner, hud_sync_jetplane, "%s", hud_msg)
	
	
	g_jetplane_telemetry_data[owner][0]+=JET_HUD_PERIOD
	g_jetplane_telemetry_data[owner][1]+=abs_velocity
	
}
public _jet_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	remove_task(id+JET_HUD_TASKID)
	emit_sound(jet_get_user_jet(id), CHAN_WEAPON, JETPLANE_IDLE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	emit_sound(jet_get_user_jet(id), CHAN_WEAPON, JETPLANE_FLY_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	emit_sound(jet_get_user_jet(id), CHAN_WEAPON, JETPLANE_BLOW_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	emit_sound(jet_get_user_jet(id), CHAN_WEAPON, NULL_SOUND_FILENAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	remove_task(id+JET_SOUND_TASKID)
	
	g_jetplane_loaded[id]=true;
	g_jetplane_cooldown[id]=0;
	g_jetplane_deployed[id]=false;
	if(is_valid_ent(g_jetplane[id])){
		if(client_hittable(id)){
			set_pev(id, pev_takedamage, DAMAGE_YES)
			set_pev(id, pev_solid, SOLID_SLIDEBOX)
			sh_set_rendering(id);
			new Float:origin[3],Float:plane_orig[3]
			pev(id,pev_origin,origin)
			pev(g_jetplane[id],pev_origin,plane_orig)
			origin[2]=plane_orig[2]+10.0
			set_pev(id,pev_origin,origin)
			
		}
		mg_destroy(id)
		law_destroy(id)
		draw_bbox(g_jetplane[id],1)
		remove_entity(g_jetplane[id]);
		g_jetplane[id]=-1;
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
}
public _clear_jets(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JETPLANE_FUSELAGE_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, JETPLANE_FUSELAGE_CLASSNAME)
	}
}
