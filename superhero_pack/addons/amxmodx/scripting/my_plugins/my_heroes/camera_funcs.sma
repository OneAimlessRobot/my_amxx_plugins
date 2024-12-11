
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "camera_inc/sh_camman_get_set.inc"
#include "camera_inc/sh_camera_funcs.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"

#define PLUGIN "Superhero camman mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum
const m_iFOV = 363;
new camera_loaded[SH_MAXSLOTS+1]

new camera_armed[SH_MAXSLOTS+1]
new looking_with_camera[SH_MAXSLOTS+1]
new disarmer_on[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]
new Float:curr_disarm_charge[SH_MAXSLOTS+1]
new Float:min_charge_time
new user_cameras[SH_MAXSLOTS+1][MAX_CAMERAS]
new user_curr_camera[SH_MAXSLOTS+1]
new Float:camera_charge[SH_MAXSLOTS+1]
new Float:camera_hp
new hud_sync_charge
new camman_camera_maxalpha
new camman_camera_minalpha
new Float:max_camera_charge
new gSpriteBeam
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(camera_loaded,true,SH_MAXSLOTS+1)
	arrayset(looking_with_camera,0,SH_MAXSLOTS+1)
	arrayset(camera_armed,0,SH_MAXSLOTS+1)
	arrayset(camera_charge,0.0,SH_MAXSLOTS+1)
	arrayset(user_curr_camera,0,SH_MAXSLOTS+1)
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		arrayset(user_cameras[i],0,MAX_CAMERAS)
	}
	arrayset(disarmer_on,0,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	arrayset(curr_disarm_charge,0.0,SH_MAXSLOTS+1)
	register_cvar("camman_camera_min_charge_time", "1.0")
	register_cvar("camman_camera_health", "100.0")
	register_cvar("camman_camera_charge", "1000.0")
	register_cvar("camman_camera_maxalpha", "100.0")
	register_cvar("camman_camera_minalpha", "1000.0")
	register_event("DeathMsg","death","a")
	hud_sync_charge=CreateHudSyncObj()
	register_forward(FM_Think, "camera_think")
	register_forward(FM_CmdStart, "camera_controls")
}
public plugin_natives(){
	
	
	register_native( "clear_cameras","_clear_cameras",0)
	register_native( "camera_get_camera_loaded","_camera_get_camera_loaded",0)
	register_native( "user_can_plant_camera","_user_can_plant_camera",0)
	register_native( "camera_get_curr_camera","_camera_get_curr_camera",0)
	register_native( "camera_clear_user_cameras","_camera_clear_user_cameras",0)
	register_native( "toggle_camera_view","_toggle_camera_view",0)
	register_native( "camera_get_camera_armed","_camera_get_camera_armed",0)
	register_native( "camera_get_camera_planted","_camera_get_camera_planted",0)
	register_native( "camera_set_camera_armed","_camera_set_camera_armed",0)
	register_native( "camera_uncharge_camera","_camera_uncharge_camera",0)
	register_native( "camera_charge_camera","_camera_charge_camera",0)
	register_native( "camera_disarm_camera","_camera_disarm_camera",0)
	register_native( "camera_undisarm_camera","_camera_undisarm_camera",0)
	register_native( "camera_get_camera_charging","_camera_get_camera_charging",0)
	register_native( "camera_get_camera_disarming","_camera_get_camera_disarming",0)
	register_native( "camera_get_camera_disarmer_on","_camera_get_camera_disarmer_on",0)
	register_native( "camera_set_camera_disarmer_on","_camera_set_camera_disarmer_on",0)
	register_native( "plant_camera","_plant_camera",0)
	
	
}
//----------------------------------------------------------------------------------------------
public camera_controls(id, uc_handle)
{
	if ( !is_user_alive(id)||!camman_get_has_camman(id)||!hasRoundStarted()||!camman_get_num_cameras(id)||!looking_with_camera[id]) return FMRES_IGNORED;
	
	new Float:zoom;
	pev(id,pev_fov,zoom)
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	if(button & IN_ATTACK)
	{
		button &= ~IN_ATTACK;
		set_uc(uc_handle, UC_Buttons, button);
		
		
		//set_pev(id,pev_fov,floatmin(MAX_ZOOM,zoom+ZOOM_INC))
		set_pev(id,pev_fov,floatmin( MAX_ZOOM ,zoom+ZOOM_INC))
		set_pdata_int(id, m_iFOV, floatround(floatmin(MAX_ZOOM,zoom+ZOOM_INC)));
		
		
	}
	else if(button & IN_ATTACK2)
	{
		button &= ~IN_ATTACK2;
		set_uc(uc_handle, UC_Buttons, button);
		
		set_pev(id,pev_fov,floatmin(MIN_ZOOM,zoom-ZOOM_INC))
		set_pdata_int(id, m_iFOV,floatround(floatmax(MIN_ZOOM,zoom-ZOOM_INC)));
		
	}
	return FMRES_SUPERCEDE;
}
public _camera_get_curr_camera(iPlugins,iParams){
	
	new id=get_param(1)
	return user_curr_camera[id]
	
	
	
	
}
public _camera_clear_user_cameras(iPlugins,iParams){
	
	new id=get_param(1)
	for(new i=0;i<camman_get_max_cameras();i++){
		new parm[3]
		parm[2]=i
		parm[0]=id
		parm[1]=user_cameras[id][i]
		remove_camera(parm);
		
	}
	user_curr_camera[id]=0;
	
	
	
	
}
public _camera_get_camera_charging(iPlugins,iParams){
	
	new id=get_param(1);
	return curr_charge[id]<min_charge_time;
	
	
}
public _camera_get_camera_disarming(iPlugins,iParams){
	
	new id=get_param(1);
	return curr_disarm_charge[id]<min_charge_time;
	
	
}
public _camera_get_camera_armed(iPlugins,iParams){
	
	new id=get_param(1);
	return camera_armed[id]
	
	
}
public _camera_get_camera_planted(iPlugins,iParams){
	
	new id=get_param(1);
	return camman_get_num_cameras(id)
	
	
}
public _camera_set_camera_armed(iPlugins,iParams){
	
	new id=get_param(1);
	new value_to_set=get_param(2)
	camera_armed[id]=value_to_set
	
	
}
public _camera_get_camera_disarmer_on(iPlugins,iParams){
	
	new id=get_param(1);
	return disarmer_on[id]
	
	
}
public _camera_set_camera_disarmer_on(iPlugins,iParams){
	
	new id=get_param(1);
	new value_to_set=get_param(2)
	disarmer_on[id]=value_to_set
	
	
}
public _camera_get_camera_loaded(iPlugins,iParams){
	
	new id=get_param(1);
	return camera_loaded[id]
	
	
}
public _toggle_camera_view(iPlugins,iParams){
	new id=get_param(1);
	
	if(!looking_with_camera[id]&&camman_get_num_cameras(id)){
		new camera_id
		new i=user_curr_camera[id]
		new count=0
		for(;(count<camman_get_max_cameras())&&(!camera_id||!pev(camera_id, pev_iuser1));count++,i=(i+1)%(camman_get_max_cameras())){
			camera_id=user_cameras[id][(i)%(camman_get_max_cameras())]
			user_curr_camera[id]=(i)%(camman_get_max_cameras())
		}
		if(!camera_id){
			
			sh_chat_message(id,camman_get_hero_id(),"No available cameras!");
			looking_with_camera[id]=0;
			return
			
		}
		else if(!pev_valid(camera_id)){
			
			sh_chat_message(id,camman_get_hero_id(),"No available cameras!");
			looking_with_camera[id]=0;
			return
			
		}
		else if(!pev(camera_id, pev_iuser1)){
			
			sh_chat_message(id,camman_get_hero_id(),"No available cameras!");
			looking_with_camera[id]=0;
			return
			
		}
		
		
		new owner_name[128];
		get_user_name(pev(camera_id, pev_iuser2),owner_name,127)
		new Float: battery_pct=camera_charge[id]*(100.0/max_camera_charge)
		if(battery_pct<25.0){
			
			
			
			sh_chat_message(id,camman_get_hero_id(),"Not enough charge (%0.2f)! Replant your camera,%s!",battery_pct,owner_name);
			return
		}
		new Float: cam_health;
		pev(camera_id,pev_health,cam_health)
		looking_with_camera[id]=1
		attach_view(id,camera_id)
		sh_chat_message(id,camman_get_hero_id(),"Looking with camera %d^n",camera_get_curr_camera(id))
		sh_chat_message(id,camman_get_hero_id(),"Your camera currently has %0.2f HP And %0.2f pct. charge!It belongs to %s!",cam_health,battery_pct,owner_name);
		user_curr_camera[id]=(user_curr_camera[id]+1)%(camman_get_max_cameras())
		return
		
	}
	else {
		
		looking_with_camera[id]=0;
		set_pev(id,pev_fov,90.0)
		set_pdata_int(id, m_iFOV,90);
		attach_view(id,id)
		
	}
	
	
}
public _plant_camera(iPlugins,iParams)
{
	new id= get_param(1)
	
	if(!camman_get_has_camman(id)) return PLUGIN_HANDLED
	
	new material[128]
	new health[128]	
	new NewEnt = create_entity( "func_breakable" );
	if ( !NewEnt ) return PLUGIN_HANDLED
	
	set_pev(NewEnt, pev_classname, CAMERA_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, CAMERA_WORLD_MDL)
	float_to_str(camera_hp+1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	
	set_pev(NewEnt, pev_health, camera_hp+1000.0)
	engfunc(EngFunc_SetSize, NewEnt, Float:{-8.0, -8.0, -8.0}, Float:{8.0, 8.0, 8.0})
	set_pev(NewEnt, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	set_pev(NewEnt, pev_solid, SOLID_NOT)
	set_pev(NewEnt, pev_body, 3)
	set_pev(NewEnt, pev_sequence, 7)	// 7 = TRIPMINE_WORLD
	set_pev(NewEnt, pev_takedamage, DAMAGE_NO)
	set_pev(NewEnt, pev_iuser1, 0)		//0 Will be for inactive.
	
	
	set_camera_aiming(id,NewEnt)
	set_pev(NewEnt, pev_iuser2, id)
	user_cameras[id][camman_get_num_cameras(id)]=NewEnt
	camman_inc_num_cameras(id);
	
	new parm[2];
	parm[0]=id;
	parm[1]=NewEnt
	
	camera_charge[id]=max_camera_charge
	set_task(CAMERA_ARMING_TIME,"camera_arm_task",NewEnt+CAMERA_ARMING_TASKID, parm, 2, "a",1)
	set_pev(NewEnt, pev_nextthink, get_gametime() + CAMERA_ARMING_TIME+1.0)
	return PLUGIN_HANDLED
}
set_camera_aiming(other_ent,cam_id){
	
	
	new Float:vOrigin[3]
	pev(other_ent, pev_origin, vOrigin)
	
	new Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vTraceResult[3], Float:vNormal[3]
	
	velocity_by_aim(other_ent, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]
	
	new Float:fraction, tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, 0, other_ent, tr)
	get_tr2(tr, TR_vecEndPos, vTraceResult)
	get_tr2(tr, TR_vecPlaneNormal, vNormal)
	get_tr2(tr, TR_flFraction, fraction)
	//0 Will be for inactive.
	
	
	new Float:vNewOrigin[3], Float:vEntAngles[3]
	vNewOrigin[0] = vTraceResult[0] + (vNormal[0] * 8.0)
	vNewOrigin[1] = vTraceResult[1] + (vNormal[1] * 8.0)
	vNewOrigin[2] = vTraceResult[2] + (vNormal[2] * 8.0)
	engfunc(EngFunc_SetOrigin, cam_id, vNewOrigin)
	
	
	vector_to_angle(vNormal, vEntAngles)
	set_pev(cam_id, pev_angles, vEntAngles)
	
	new Float:vBeamEnd[3], Float:vTracedBeamEnd[3]
	vBeamEnd[0] = vNewOrigin[0] + (vNormal[0] * 8192.0)
	vBeamEnd[1] = vNewOrigin[1] + (vNormal[1] * 8192.0)
	vBeamEnd[2] = vNewOrigin[2] + (vNormal[2] * 8192.0)
	
	tr = 0
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, 1, -1, tr)
	get_tr2(tr, TR_vecEndPos, vTracedBeamEnd)
	set_pev(cam_id, pev_vuser1, vTracedBeamEnd)
}

update_camera_aiming(other_ent,cam_id){
	
	new Float:vOrigin[3],Float:other_orig[3],Float: aim_orig[3];
	
	pev(cam_id,pev_origin,vOrigin);
	pev(other_ent,pev_origin,other_orig);
	
	
	fm_get_aim_origin(other_ent, aim_orig)
	new Float:aim_vec[3];
	for(new i=0;i<sizeof(aim_vec);i++){
		aim_vec[i]=aim_orig[i]-other_orig[i]
		
	}
	new Float:aimlen=vector_length(aim_vec);
	
	
	for(new i=0;i<sizeof(aim_vec);i++){
		aim_vec[i]*=((1.0)/aimlen)
		
	}
	
	new Float:angles[3];
	
	entity_get_vector(other_ent, EV_VEC_v_angle, angles)
	angles[0] = - angles[0]
	entity_set_vector(cam_id, EV_VEC_v_angle, angles)
	entity_get_vector(other_ent, EV_VEC_angles, angles)
	angles[0] = - angles[0]
	entity_set_vector(cam_id, EV_VEC_angles, angles)
	
	new Float:vBeamEnd[3],Float:vTracedBeamEnd[3]
	
	vBeamEnd[0] = vOrigin[0] + (aim_vec[0] * 8192.0)
	vBeamEnd[1] = vOrigin[1] + (aim_vec[1] * 8192.0)
	vBeamEnd[2] = vOrigin[2] + (aim_vec[2] * 8192.0)
	new tr = 0
	
	engfunc(EngFunc_TraceLine, vOrigin, vBeamEnd, 0, -1, tr)
	get_tr2(tr, TR_vecEndPos, vTracedBeamEnd)
	set_pev(cam_id, pev_vuser1, vTracedBeamEnd)
	
	
}
public laser_on_player_think(ent){
	
	if ( !ent||!pev_valid(ent)) return
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, CAMERA_CLASSNAME) ) return
	new owner=pev(ent,pev_iuser2)
	if(client_isnt_hitter(owner)||!looking_with_camera[owner]) return
	
	static Float:vTrace[3], iHit, tr
	static Float:vOrigin[3],Float:vEnd[3]
	pev(ent, pev_vuser1, vEnd)
	pev(ent, pev_origin, vOrigin)
	tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, ent, tr)
	get_tr2(tr, TR_vecEndPos, vTrace)
	iHit = get_tr2(tr, TR_pHit)
	laser_line(ent,vOrigin,vEnd,true)
	if ( is_user_alive(iHit) ) {
	
		sh_effect_user_direct(owner,iHit,camman_get_hero_id(),GLOW)
		sh_chat_message(owner,camman_get_hero_id(),"Player detetado!");
	
	}
	return
}
//----------------------------------------------------------------------------------------------
public camera_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, CAMERA_CLASSNAME) ) return FMRES_IGNORED
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_iuser2)
	new Float:cameraHealth=float(pev(ent,pev_health))
	new parm[3]
	parm[1]=ent
	parm[0]=owner
	new i=0
	
	if ( (cameraHealth<1000.0)) {
		for(;(user_cameras[owner][i]!=ent)&&(i<camman_get_max_cameras());i++){}
		
		if(i<camman_get_max_cameras()){
			parm[2]=i
			remove_camera(parm);
			camman_dec_num_cameras(owner)
		}
		return FMRES_IGNORED
	}
	static Float:beamtime
	pev(ent, pev_fuser1, beamtime)
	if ( beamtime <= gametime ) {
		//Should get called every second
		set_pev(ent, pev_fuser1, gametime + (1.0/CAMERA_FRAMERATE))
	}
	camera_charge[owner]=camera_charge[owner]-(1.0/CAMERA_FRAMERATE)
	if(looking_with_camera[owner]){
		
		//client_print(owner,print_center,"Battery charge: %0.2f seconds left!",camera_charge[owner])
		laser_on_player_think(ent)
		update_camera_aiming(owner,ent)
	}
	set_pev(ent, pev_nextthink, gametime + (1.0/CAMERA_FRAMERATE))
	return FMRES_IGNORED
}
public camera_arm_task(parm[],camera_taskid){
	
	
	new attacker=parm[0];
	new camera_id=parm[1];
	if(!is_valid_ent(camera_id)){
		
		return;
	}
	set_pev(camera_id, pev_iuser1, 1)
	set_pev(camera_id, pev_takedamage, DAMAGE_YES)
	set_pev(camera_id, pev_solid, SOLID_BBOX)
	emit_sound(camera_id, CHAN_VOICE, CAMERA_CLICK_SFX, 1.0, 0.0, 0, PITCH_NORM)
	emit_sound(camera_id,CHAN_VOICE, CAMERA_BOOTED_SFX, 1.0, 0.0, 0, PITCH_NORM)
	set_pev(camera_id,pev_rendermode,kRenderTransAlpha)
	set_pev(camera_id,pev_renderfx,kRenderFxGlowShell)
	new alpha=camman_camera_minalpha
	set_pev(camera_id,pev_renderamt,float(alpha))
	set_task(CAMERA_WAIT_TIME,"camera_wait_task",camera_id+CAMERA_WAIT_TASKID, parm, 2, "b")
	sh_chat_message(attacker,camman_get_hero_id(),"The camera is armed!");
}
public camera_wait_task(parm[],camera_taskid){
	new camera_id=parm[1];
	if(!is_valid_ent(camera_id)){
		
		return;
	}
	new alpha=pev(camera_id,pev_renderamt)
	alpha=min(alpha+ALPHA_INC,camman_camera_maxalpha)
	set_pev(camera_id,pev_renderamt,float(alpha))
	
	
}
//----------------------------------------------------------------------------------------------
laser_line(cam_id,Float:Pos[3], Float:vEnd[3], bool:killbeam)
{
	if ( !pev_valid(cam_id) ) return
	
	static  colors[3]
	
	switch ( cs_get_user_team(pev(cam_id, pev_iuser2)) )
	{
		case CS_TEAM_T: colors = LineColors[RED]
			case CS_TEAM_CT: colors = LineColors[BLUE]
				default: colors = LineColors[CUSTOM]
	}
	//This is a little cleaner but not much
	if ( killbeam ) {
		//Kill the Beam
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
		write_byte(TE_KILLBEAM)
		write_short(cam_id) // entity
		message_end()
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord_f(Pos[0])
	write_coord_f(Pos[1])
	write_coord_f(Pos[2])		// start entity
	write_coord_f(vEnd[0])	// end position
	write_coord_f( vEnd[1])
	write_coord_f(vEnd[2])
	write_short(gSpriteBeam)// sprite index
	write_byte(0)		// starting frame
	write_byte(0)		// frame rate in 0.1's
	write_byte(1)		// life in 0.1's
	write_byte(5)		// line width in 0.1's
	write_byte(0)		// noise amplitude in 0.01's
	write_byte(colors[0])	// Red
	write_byte(colors[1])	// Green
	write_byte(colors[2])	// Blue
	write_byte(pev(cam_id,pev_renderamt))	// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()
}
public remove_camera(parm[3]){
	
	if(!is_valid_ent(parm[1])) return
	
	remove_task(parm[1]+CAMERA_ARMING_TASKID);
	remove_task(parm[1]+CAMERA_WAIT_TASKID);
	camera_loaded[parm[0]]=true
	remove_entity(parm[1])
	if(parm[2]>=0){
		user_cameras[parm[0]][parm[2]]=0
	}
	
}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	
	min_charge_time=get_cvar_float("camman_camera_min_charge_time")
	camera_hp=get_cvar_float("camman_camera_health")
	max_camera_charge=get_cvar_float("camman_camera_charge")
	camman_camera_maxalpha=get_cvar_num("camman_camera_maxalpha")
	camman_camera_minalpha=get_cvar_num("camman_camera_minalpha")
}


public disarm_task(param[],id){
	id-=CAMERA_DISARM_TASKID
	new hud_msg[128];
	curr_disarm_charge[id]=floatadd(curr_disarm_charge[id],CAMERA_DISARM_PERIOD)
	format(hud_msg,127,"[SH]: DISARMING CAMERA: %0.2f^n",
	100.0*(curr_disarm_charge[id]/min_charge_time)
	);
	set_hudmessage(camera_color[0], camera_color[1], camera_color[2], -1.0, -1.0, 0, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	camman_update_disarming(id)
	if(!camera_get_camera_disarming(id)){
		new parm[3];
		parm[2]=param[1];
		parm[1]=param[0];
		parm[0]=id;
		camman_set_num_cameras(id,camman_get_num_cameras(id)-1)
		remove_camera(parm);
		client_print(id,print_center,"You retrieved and disarmed 1 camera! %d cameras left now!",camman_get_num_cameras(id));
	}
	
	
	
	
	
	
}
public _camera_undisarm_camera(iPlugin,iParams){
	new id=get_param(1)
	undisarm_user(id)
	
	
}
public undisarm_task(id){
	id-=UNCAMERA_DISARM_TASKID
	remove_task(id+CAMERA_DISARM_TASKID)
	disarmer_on[id]=0
	return 0
	
	
	
}

undisarm_user(id){
	remove_task(id+UNCAMERA_DISARM_TASKID)
	remove_task(id+CAMERA_DISARM_TASKID)
	disarmer_on[id]=0
	return 0
	
	
}
public _camera_disarm_camera(iPlugins,iParams){
	
	new id=get_param(1);
	new camera_id=get_param(2)
	new cam_it=get_param(3)
	new param[2];
	param[0]=camera_id
	param[1]=cam_it
	curr_disarm_charge[id]=0.0
	user_curr_camera[id]=0;
	set_task(CAMERA_DISARM_PERIOD,"disarm_task",id+CAMERA_DISARM_TASKID,param, 2,  "a",CAMERA_DISARM_TIMES)
	set_task(floatmul(CAMERA_DISARM_PERIOD,float(CAMERA_DISARM_TIMES))+1.0,"undisarm_task",id+UNCAMERA_DISARM_TASKID,"", 0,  "a",1)
	return 0
	
	
	
	
}
public _user_can_plant_camera(iPlugins,iParams){
	
	new id= get_param(1)
	new Float:vOrigin[3]
	pev(id, pev_origin, vOrigin)
	
	new Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vTraceResult[3], Float:vNormal[3]
	
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]
	
	new Float:fraction, tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, 0, id, tr)
	get_tr2(tr, TR_vecEndPos, vTraceResult)
	get_tr2(tr, TR_vecPlaneNormal, vNormal)
	get_tr2(tr, TR_flFraction, fraction)
	
	if ( fraction >= 1.0 ) {
		return 0
	}
	return 1
}
public _camera_charge_camera(iPlugins,iParams){
	
	new id=get_param(1);
	
	if(!camman_get_has_camman(id)) return PLUGIN_HANDLED
	
	curr_charge[id]=0.0
	emit_sound(id, CHAN_AUTO, CAMERA_BOOTING_SFX, 1.0, 0.0, 0, PITCH_NORM)
	set_task(CAMERA_CHARGE_PERIOD,"charge_task",id+CAMERA_CHARGE_TASKID,"", 0,  "a",CAMERA_CHARGE_TIMES)
	set_task(floatmul(CAMERA_CHARGE_PERIOD,float(CAMERA_CHARGE_TIMES))+1.0,"uncharge_task",id+UNCAMERA_CHARGE_TASKID,"", 0,  "a",1)
	return PLUGIN_HANDLED
	
	
	
	
}

camman_update_planting(id){
	new butnprs
	if(!user_can_plant_camera(id)){
		
		sh_chat_message(id,camman_get_hero_id(),"You looked away from a wall while planting, so your action was canceled");
		camera_uncharge_camera(id)
		
	}
	butnprs = Entvars_Get_Int(id, EV_INT_button)
	
	if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD||butnprs&IN_USE){
		
		sh_chat_message(id,camman_get_hero_id(),"You moved while planting, so your action was canceled");
		camera_uncharge_camera(id)
	}
	if (butnprs&IN_JUMP){
		
		
		sh_chat_message(id,camman_get_hero_id(),"You moved while planting, so your action was canceled");
		camera_uncharge_camera(id)
		
	}
	if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
		sh_chat_message(id,camman_get_hero_id(),"You moved while planting, so your action was canceled");
		camera_uncharge_camera(id)
		
		
	}
	if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
		sh_chat_message(id,camman_get_hero_id(),"You moved while planting, so your action was canceled");
		camera_uncharge_camera(id)
	}
	
	
	
}
camman_update_disarming(id){
	new butnprs
	
	if(!user_can_plant_camera(id)){
		
		sh_chat_message(id,camman_get_hero_id(),"You looked away from a wall while disarming, so your action was canceled");
		camera_undisarm_camera(id)
		
	}
	butnprs = Entvars_Get_Int(id, EV_INT_button)
	
	if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD){
		
		sh_chat_message(id,camman_get_hero_id(),"You werent ducked while planting, so your action was canceled");
		camera_undisarm_camera(id)
	}
	if (butnprs&IN_JUMP){
		
		
		sh_chat_message(id,camman_get_hero_id(),"You werent ducked while planting, so your action was canceled");
		camera_undisarm_camera(id)
		
	}
	if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
		sh_chat_message(id,camman_get_hero_id(),"You werent ducked while planting, so your action was canceled");
		camera_undisarm_camera(id)
		
		
	}
	if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
		sh_chat_message(id,camman_get_hero_id(),"You werent ducked while planting, so your action was canceled");
		camera_undisarm_camera(id)
	}
	
	
	
}
public charge_task(id){
	id-=CAMERA_CHARGE_TASKID
	new hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],CAMERA_CHARGE_PERIOD)
	format(hud_msg,127,"[SH]: Curr camera charge: %0.2f^n",
	100.0*(curr_charge[id]/min_charge_time)
	);
	set_hudmessage(camera_color[0], camera_color[1], camera_color[2], -1.0, -1.0, 0, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	camman_update_planting(id)
	if(!camera_get_camera_charging(id)){
		plant_camera(id)
		client_print(id,print_center,"You have %d cameras left",
		camman_get_num_cameras(id));
	}
	
	
	
	
	
	
}
public _camera_uncharge_camera(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	
	
}
public uncharge_task(id){
	id-=UNCAMERA_CHARGE_TASKID
	remove_task(id+CAMERA_CHARGE_TASKID)
	camera_armed[id]=0
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNCAMERA_CHARGE_TASKID)
	remove_task(id+CAMERA_CHARGE_TASKID)
	camera_armed[id]=0
	return 0
	
	
}
client_hittable(vic_userid){
	
	return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)
	
}
public _clear_cameras(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, CAMERA_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, CAMERA_CLASSNAME)
	}
}
public plugin_precache()
{
	
	precache_model( CAMERA_WORLD_MDL );
	engfunc(EngFunc_PrecacheSound, CAMERA_BOOTING_SFX) 
	engfunc(EngFunc_PrecacheSound, CAMERA_CLICK_SFX) 
	engfunc(EngFunc_PrecacheSound, CAMERA_BOOTED_SFX)
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	gSpriteBeam = precache_model("sprites/laserbeam.spr")
}
public death()
{	
	new id=read_data(2)
	if(camman_get_has_camman(id)&&!client_isnt_hitter(id)){
		
		
		looking_with_camera[id]=0;
		set_pev(id,pev_fov,90.0)
		set_pdata_int(id, m_iFOV,90);
		attach_view(id,id)
		
	}
}