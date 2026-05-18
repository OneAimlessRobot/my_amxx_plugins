#define I_WANT_CONSTANTS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "camera_inc/sh_camman_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "camera_inc/sh_camera_funcs.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"

#define PLUGIN "Superhero camman mk2 pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
const m_iFOV = 363;
new camera_loaded_mask = 0xFFFF
new camera_planting_mask = 0
new camera_armed_mask = 0
new looking_with_camera_mask = 0
new disarmer_on_mask = 0

new Float:curr_charge[SH_MAXSLOTS+1]
new Float:curr_disarm_charge[SH_MAXSLOTS+1]
new user_camera[SH_MAXSLOTS+1]
new Float:camera_charge[SH_MAXSLOTS+1]
stock ham_is_here=0
stock ham_is_on=0
stock HamHook:the_damage_ham_hook;

new pcvar_min_charge_time
new pcvar_camman_camera_maxalpha
new pcvar_camman_camera_minalpha
new pcvar_max_camera_charge
new pcvar_camera_hp

stock CAMERA_CHARGE_TASKID,
		CAMERA_DISARM_TASKID

new gHeroID = 0
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	pcvar_min_charge_time = register_cvar("camman_camera_min_charge_time", "1.0")
	pcvar_camera_hp = register_cvar("camman_camera_health", "100.0")
	pcvar_max_camera_charge = register_cvar("camman_camera_charge", "1000.0")
	pcvar_camman_camera_maxalpha = register_cvar("camman_camera_maxalpha", "100.0")
	pcvar_camman_camera_minalpha = register_cvar("camman_camera_minalpha", "1000.0")

	register_think(CAMERA_CLASSNAME, "camera_think")
	register_forward(FM_CmdStart, "camera_controls")
	CAMERA_CHARGE_TASKID=allocate_typed_task_id(player_task)
	CAMERA_DISARM_TASKID=allocate_typed_task_id(player_task)

}
public plugin_natives(){
	
	
	register_native( "clear_cameras","_clear_cameras",0)
	register_native( "camera_get_camera_loaded","_camera_get_camera_loaded",0)
	register_native( "user_can_plant_camera","_user_can_plant_camera",0)
	register_native( "camera_clear_user_camera","_camera_clear_user_camera",0)
	register_native( "toggle_camera_view","_toggle_camera_view",0)
	register_native( "camera_get_camera_armed","_camera_get_camera_armed",0)
	register_native( "camera_get_camera_planted","_camera_get_camera_planted",0)
	register_native( "camera_charge_camera","_camera_charge_camera",0)
	register_native( "camera_disarm_camera","_camera_disarm_camera",0)
	register_native( "camera_get_camera_charging","_camera_get_camera_charging",0)
	register_native( "camera_get_camera_disarming","_camera_get_camera_disarming",0)
	register_native( "camera_get_camera_disarmer_on","_camera_get_camera_disarmer_on",0)
	register_native( "camera_set_camera_disarmer_on","_camera_set_camera_disarmer_on",0)
	register_native( "camera_set_camera_planting", "_camera_set_camera_planting",0)
	register_native( "camera_get_camera_planting", "_camera_get_camera_planting",0)
	
	
}
public plugin_cfg(){


	gHeroID=camman_get_hero_id()

}
public Camera_Damage(this, idinflictor, attacker, Float:damage, damagebits)
{
	if(!sh_is_active()){
		return HAM_IGNORED
	}
	if(pev_valid(this)!=2){
		return HAM_IGNORED
	
	}
	
	
	if(pev_valid(attacker)!=2){
		return HAM_IGNORED
	
	}
	if(!is_user_connected(attacker)){
		return HAM_IGNORED
	
	}
	if(pev_valid(idinflictor)!=2){
		return HAM_IGNORED
	
	}
	set_pev(this, pev_nextthink, get_gametime() + (1.0/CAMERA_FRAMERATE))
	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public camera_controls(id, uc_handle)
{	
	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if ( !is_user_alive(id)){
		return FMRES_IGNORED;
	}

	if(!sh_user_has_hero(id,gHeroID)) return FMRES_IGNORED

	if(!camman_get_has_camera(id)) return FMRES_IGNORED
	
	if(sh_get_stun(id)) return FMRES_IGNORED

	if(!Get_BitVar(looking_with_camera_mask, id)) return FMRES_IGNORED
	
	new Float:zoom;
	pev(id,pev_fov,zoom)
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	if(button & IN_ATTACK)
	{
		button &= ~IN_ATTACK;
		set_uc(uc_handle, UC_Buttons, button);

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
	return user_camera[id]
	
	
	
	
}
public _camera_clear_user_camera(iPlugins,iParams){
	
	new id=get_param(1)
	remove_camera(id)
	
	
	
	
}
public _camera_get_camera_charging(iPlugins,iParams){
	
	new id=get_param(1);
	return curr_charge[id]<cvar_val(float, pcvar_min_charge_time);
	
	
}
public _camera_get_camera_disarming(iPlugins,iParams){
	
	new id=get_param(1);
	return curr_disarm_charge[id]<cvar_val(float, pcvar_min_charge_time);
	
	
}
public _camera_get_camera_armed(iPlugins,iParams){
	
	new id=get_param(1);
	return Get_BitVar(camera_armed_mask,id)
	
	
}
public _camera_set_camera_planting(iPlugins,iParams){
	
	new id=get_param(1);
	new value_to_set=get_param(2)
	if(value_to_set){

		Set_BitVar(camera_planting_mask,id)
	}
	else{

		UnSet_BitVar(camera_planting_mask,id)
	}
	
	
}
public _camera_get_camera_planting(iPlugins,iParams){
	
	new id=get_param(1);

	return Get_BitVar(camera_planting_mask,id)

	
	
}
public _camera_get_camera_planted(iPlugins,iParams){
	
	new id=get_param(1);
	return camman_get_has_camera(id)
	
	
}
public _camera_get_camera_disarmer_on(iPlugins,iParams){
	
	new id=get_param(1);
	return Get_BitVar(disarmer_on_mask,id)
	
	
}
public _camera_set_camera_disarmer_on(iPlugins,iParams){
	
	new id=get_param(1);
	new value_to_set=get_param(2)
	if(value_to_set){

		Set_BitVar(disarmer_on_mask,id)
	}
	else{

		UnSet_BitVar(disarmer_on_mask,id)
	}
	
	
}
public _camera_get_camera_loaded(iPlugins,iParams){
	
	new id=get_param(1);
	
	return Get_BitVar(camera_loaded_mask,id)
	
	
}
public _toggle_camera_view(iPlugins,iParams){
	new id=get_param(1);
	
	if(!Get_BitVar(looking_with_camera_mask, id)){
		new camera_id=user_camera[id]
		
		if(!pev_valid(camera_id)){
			
			sh_chat_message(id,gHeroID,"No available cameras!");
			UnSet_BitVar(looking_with_camera_mask, id)
			return
			
		}
		else if(!pev(camera_id, pev_iuser1)){
			
			sh_chat_message(id,gHeroID,"No available cameras!");
			UnSet_BitVar(looking_with_camera_mask, id)
			return
			
		}
		
		new Float: battery_pct=camera_charge[id]*(100.0/cvar_val(float, pcvar_max_camera_charge))
		if(battery_pct<25.0){
			
			
			
			sh_chat_message(id,gHeroID,"Not enough charge (%0.2f)! Replant your camera!",battery_pct);
			UnSet_BitVar(looking_with_camera_mask, id)
			return
		}
		new Float: cam_health;
		pev(camera_id,pev_health,cam_health)
		Set_BitVar(looking_with_camera_mask, id)
		attach_view(id,camera_id)
		set_pev(camera_id, pev_nextthink, get_gametime() + (1.0/CAMERA_FRAMERATE))
		sh_chat_message(id,gHeroID,"Health: %0.2f Charge: %0.2f",cam_health,battery_pct);
		return
		
	}
	else {
		
		UnSet_BitVar(looking_with_camera_mask, id)
		set_pev(id,pev_fov,90.0)
		set_pdata_int(id, m_iFOV,90);
		attach_view(id,id)
		
	}
	
	
}
public plant_camera(id)
{
	if(!sh_user_has_hero(id,gHeroID)) return PLUGIN_HANDLED
	
	static material[128]
	static health[128]	
	new NewEnt = create_entity( "func_breakable" );
	if ( !NewEnt ) return PLUGIN_HANDLED
	
	set_pev(NewEnt, pev_classname, CAMERA_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, CAMERA_WORLD_MDL)
	float_to_str(cvar_val(float, pcvar_camera_hp)+1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	
	set_pev(NewEnt, pev_health, cvar_val(float, pcvar_camera_hp)+1000.0)
	engfunc(EngFunc_SetSize, NewEnt, Float:{-HALF_CAMERA_SIZE, -HALF_CAMERA_SIZE, -HALF_CAMERA_SIZE},
									Float:{HALF_CAMERA_SIZE, HALF_CAMERA_SIZE, HALF_CAMERA_SIZE})
	set_pev(NewEnt, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	set_pev(NewEnt, pev_solid, SOLID_NOT)
	set_pev(NewEnt, pev_body, 3)
	set_pev(NewEnt, pev_sequence, 7)	// 7 = TRIPMINE_WORLD
	set_pev(NewEnt, pev_takedamage, DAMAGE_NO)
	set_pev(NewEnt, pev_iuser1, 0)		//0 Will be for inactive.
	
	//set phase status
	set_pev(NewEnt,pev_iuser2,0)
	set_camera_aiming(id,NewEnt)
	set_pev(NewEnt, pev_euser1, id)
	camman_set_has_camera(id,1)
	UnSet_BitVar(camera_planting_mask,id);
	UnSet_BitVar(disarmer_on_mask,id)
	user_camera[id]=NewEnt
	
	new parm[2];
	parm[0]=id;
	parm[1]=NewEnt
	
	camera_charge[id]=cvar_val(float, pcvar_max_camera_charge)
	set_pev(NewEnt, pev_nextthink, get_gametime() + CAMERA_ARMING_TIME)
	return PLUGIN_HANDLED
}
set_camera_aiming(other_ent,cam_id){
	
	
	static Float:vOrigin[3]
	pev(other_ent, pev_origin, vOrigin)
	
	static Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vTraceResult[3], Float:vNormal[3]
	
	velocity_by_aim(other_ent, 9999, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]
	
	new Float:fraction, tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, 0, other_ent, tr)
	get_tr2(tr, TR_vecEndPos, vTraceResult)
	get_tr2(tr, TR_vecPlaneNormal, vNormal)
	get_tr2(tr, TR_flFraction, fraction)

	free_tr2(tr)
	
	static Float:vNewOrigin[3], Float:vEntAngles[3]
	//distance that the camera will be placed away from the wall
	new Float:walldist=HALF_CAMERA_SIZE
	vNewOrigin[0] = vTraceResult[0] + (vNormal[0] * walldist)
	vNewOrigin[1] = vTraceResult[1] + (vNormal[1] * walldist)
	vNewOrigin[2] = vTraceResult[2] + (vNormal[2] * walldist)
	engfunc(EngFunc_SetOrigin, cam_id, vNewOrigin)
	
	
	vector_to_angle(vNormal, vEntAngles)
	set_pev(cam_id, pev_angles, vEntAngles)
	
	static Float:vBeamEnd[3], Float:vTracedBeamEnd[3]
	vBeamEnd[0] = vNewOrigin[0] + (vNormal[0] * 8192.0)
	vBeamEnd[1] = vNewOrigin[1] + (vNormal[1] * 8192.0)
	vBeamEnd[2] = vNewOrigin[2] + (vNormal[2] * 8192.0)
	
	tr = 0
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, 1, -1, tr)
	get_tr2(tr, TR_vecEndPos, vTracedBeamEnd)

	free_tr2(tr)

	set_pev(cam_id, pev_vuser1, vTracedBeamEnd)
	
}

update_camera_aiming(other_ent,cam_id){
	
	static Float:angles[3];
	
	entity_get_vector(cam_id, EV_VEC_v_angle, angles)
	angles[0] = - angles[0]
	entity_set_vector(cam_id, EV_VEC_v_angle, angles)

	static Float:vOrigin[3],Float: aim_orig[3];
	
	pev(cam_id,pev_origin,vOrigin);
	fm_get_aim_origin(cam_id,aim_orig)

	static Float:vector_direction_result[3]
	
	xs_vec_sub(aim_orig,vOrigin,vector_direction_result)

	xs_vec_normalize(vector_direction_result,vector_direction_result)

	xs_vec_mul_scalar(vector_direction_result,MAX_MAP_DIST_POSSIBLE,vector_direction_result)
	
	xs_vec_add(vOrigin,vector_direction_result,aim_orig)

	set_pev(cam_id, pev_vuser1, aim_orig)

	entity_get_vector(other_ent, EV_VEC_v_angle, angles)
	angles[0] = - angles[0]
	entity_set_vector(cam_id, EV_VEC_v_angle, angles)
	entity_get_vector(other_ent, EV_VEC_angles, angles)
	angles[0] = - angles[0]
	entity_set_vector(cam_id, EV_VEC_angles, angles)

	
	
}
public laser_on_player_think(ent){
	
	if ( !ent||!pev_valid(ent)) return
	
	new owner=pev(ent,pev_euser1)
	
	static Float:vTrace[3], iHit, tr
	static Float:vOrigin[3],Float:vEnd[3]
	pev(ent, pev_vuser1, vEnd)
	pev(ent, pev_origin, vOrigin)
	tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, ent, tr)
	get_tr2(tr, TR_vecEndPos, vTrace)
	iHit = get_tr2(tr, TR_pHit)
	free_tr2(tr)
	laser_line(ent,vOrigin,vTrace,true)

	if ( is_user_alive(iHit) ) {
		
		if(!sh_clients_are_same_team(owner,iHit)&&(iHit!=owner)){
			make_effect(iHit,owner,gHeroID,GLOW,false)

				
		}
	}
}
//----------------------------------------------------------------------------------------------
public camera_think(ent)
{
	if ( !pev_valid(ent) ) return PLUGIN_CONTINUE
	
	//get phase
	new phase=pev(ent,pev_iuser2)


	new owner=pev(ent,pev_euser1)
	static Float:gametime
	gametime = get_gametime()
	switch(phase){
		case 0:{
			set_pev(ent, pev_iuser1, 1)
			set_pev(ent, pev_takedamage, DAMAGE_YES)
			set_pev(ent, pev_solid, SOLID_BBOX)
			emit_sound(ent, CHAN_VOICE, CAMERA_CLICK_SFX, 1.0, 0.0, 0, PITCH_NORM)
			emit_sound(ent,CHAN_VOICE, CAMERA_BOOTED_SFX, 1.0, 0.0, 0, PITCH_NORM)
			set_pev(ent,pev_rendermode,kRenderTransAlpha)
			set_pev(ent,pev_renderfx,kRenderFxGlowShell)
			new alpha=cvar_val(num, pcvar_camman_camera_maxalpha)
			set_pev(ent,pev_renderamt,float(alpha))
			if(!ham_is_here){
				the_damage_ham_hook=RegisterHam(Ham_TakeDamage,"func_breakable","Camera_Damage",_,true)
				ham_is_here=1;
			}
			if(!ham_is_on){
				EnableHamForward(the_damage_ham_hook)
				ham_is_on=1;
			}
			if(!is_user_bot(owner)){
				sh_chat_message(owner,gHeroID,"The camera is armed!");
			}
			set_pev(ent,pev_iuser2,1)

			set_pev(ent, pev_nextthink, gametime + 1.0)
		}
		case 1:{

			new alpha=pev(ent,pev_renderamt)
			alpha=max(alpha-ALPHA_INC,cvar_val(num, pcvar_camman_camera_minalpha))
			set_pev(ent,pev_renderamt,float(alpha))
			if(alpha==cvar_val(num, pcvar_camman_camera_minalpha)){
				
				set_pev(ent,pev_iuser2,2)
			}
			set_pev(ent, pev_nextthink, gametime + 1.0)
		}
		case 2:{
			static Float:vEnd[3], Float:Pos[3]
			pev(ent, pev_origin, Pos)
			pev(ent, pev_vuser1, vEnd)
			new Float:cameraHealth=float(pev(ent,pev_health))
			new parm[3]
			parm[1]=ent
			parm[0]=owner
			if ( (cameraHealth<1000.0)) {
				
				remove_camera(owner);
				return PLUGIN_CONTINUE
			}
			if(Get_BitVar(looking_with_camera_mask,owner)){
				camera_charge[owner]=camera_charge[owner]-(1.0/CAMERA_FRAMERATE)
				laser_on_player_think(ent)
				update_camera_aiming(owner,ent)
				set_pev(ent, pev_nextthink, gametime + (1.0/CAMERA_FRAMERATE))
			}
		}
	}
	
	return PLUGIN_CONTINUE
}
public remove_camera(pid){
	if(!is_user_connected(pid)) return
	camman_set_has_camera(pid,0)
	if(pev_valid(user_camera[pid])!=2) return
	
	remove_entity(user_camera[pid])

	UnSet_BitVar(looking_with_camera_mask,pid);
	UnSet_BitVar(camera_armed_mask,pid);
	UnSet_BitVar(camera_planting_mask,pid);
	Set_BitVar(camera_loaded_mask,pid)
	user_camera[pid]=-1
}


public disarm_task(id){
	id-=CAMERA_DISARM_TASKID
	if(!camman_get_has_camera(id)){
		return;

	}
	if(!Get_BitVar(disarmer_on_mask,id)){
		return;

	}
	static hud_msg[128];
	if(!is_user_bot(id)){
		curr_disarm_charge[id]=floatadd(curr_disarm_charge[id],CAMERA_DISARM_PERIOD)
		formatex(hud_msg,127,"[SH]: DISARMING CAMERA: %0.2f^n",
		100.0*(curr_disarm_charge[id]/cvar_val(float, pcvar_min_charge_time))
		);
		client_print(id,print_center,"%s",hud_msg)
	}
	new bool:result=camman_update_disarming(id)
	if(!camera_get_camera_disarming(id)){
		
		if(!is_user_bot(id)){
			client_print(id,print_center,"You retrieved and disarmed your camera! The camera id is %d",user_camera[id]);
		}

		remove_camera(id);
	}
	else if(result){

		set_task(CAMERA_DISARM_PERIOD,"disarm_task",id+CAMERA_DISARM_TASKID)
	}
	
	
	
	
	
	
}

public _camera_disarm_camera(iPlugins,iParams){
	
	new id=get_param(1);
	Set_BitVar(disarmer_on_mask,id)
	curr_disarm_charge[id]=0.0
	set_task(CAMERA_DISARM_PERIOD,"disarm_task",id+CAMERA_DISARM_TASKID)
	
	
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
	return !Get_BitVar(looking_with_camera_mask,id)
}
public _camera_charge_camera(iPlugins,iParams){
	
	new id=get_param(1);
	
	if(!sh_user_has_hero(id,gHeroID)) return PLUGIN_HANDLED;
	
	Set_BitVar(camera_planting_mask,id);
	Set_BitVar(camera_armed_mask,id);
	curr_charge[id]=0.0
	emit_sound(id, CHAN_AUTO, CAMERA_BOOTING_SFX, 1.0, 0.0, 0, PITCH_NORM)
	set_task(CAMERA_CHARGE_PERIOD,"charge_task",id+CAMERA_CHARGE_TASKID)
	
	return PLUGIN_HANDLED
	
	
	
	
}

bool:camman_update_planting(id){
	new butnprs
	if(!user_can_plant_camera(id)){
		
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You looked away from a wall while planting, so your action was canceled");
		}
		return false
		
	}
	butnprs = entity_get_int(id, EV_INT_button)
	
	if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD||butnprs&IN_USE){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You moved while planting, so your action was canceled");
		}
		return false
	}
	if (butnprs&IN_JUMP){
		
		
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You moved while planting, so your action was canceled");
		}
		return false
		
	}
	if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You moved while planting, so your action was canceled");
		}
		return false
		
		
	}
	if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You moved while planting, so your action was canceled");
		}
		return false
	}
	return true
	
	
}
bool:camman_update_disarming(id){
	new butnprs
	
	if(!user_can_plant_camera(id)){
		
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You looked away from a wall while disarming, so your action was canceled");
		}
		return false
		
	}
	butnprs = entity_get_int(id, EV_INT_button)
	
	if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD){
		
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You werent ducked while disarming, so your action was canceled");
		}
		return false
	}
	if (butnprs&IN_JUMP){
		
		
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You werent ducked while disarming, so your action was canceled");
		}
		return false
		
	}
	if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You werent ducked while disarming, so your action was canceled");
		}
		return false
		
		
	}
	if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT){
		
		if(!is_user_bot(id)){
			sh_chat_message(id,gHeroID,"You werent ducked while disarming, so your action was canceled");
		}
		return false
	}
	return true
	
	
}
public charge_task(id){
	id-=CAMERA_CHARGE_TASKID
	if(!hasRoundStarted()){
		UnSet_BitVar(camera_armed_mask, id)
		return
	
	}
	if(!is_user_alive(id)){
		UnSet_BitVar(camera_armed_mask, id)
		return
	
	}
	if(!sh_user_has_hero(id,gHeroID)){
		UnSet_BitVar(camera_armed_mask, id)
		return
	
	}
	if(!Get_BitVar(camera_planting_mask,id)){
		
		UnSet_BitVar(camera_armed_mask, id)
		return
	}
	curr_charge[id]=floatadd(curr_charge[id],CAMERA_CHARGE_PERIOD)

	if(!is_user_bot(id)){
		static hud_msg[128];
		formatex(hud_msg,127,"[SH]: Curr camera charge: %0.2f^n",
		100.0*(curr_charge[id]/cvar_val(float, pcvar_min_charge_time))
		);
		client_print(id,print_center,"%s",hud_msg)
	}
	new bool:result=camman_update_planting(id)
	if(!result){
		UnSet_BitVar(camera_armed_mask, id)
		return	
		
	}
	if(!camera_get_camera_charging(id)){
		plant_camera(id)
		return
	}
	set_task(CAMERA_CHARGE_PERIOD,"charge_task",id+CAMERA_CHARGE_TASKID)
	
	
	
	
	
	
}
public _clear_cameras(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, CAMERA_CLASSNAME)
	while(grenada) {

		new owner=entity_get_edict(grenada,EV_ENT_owner)
		remove_camera(owner)
		grenada = find_ent_by_class(grenada, CAMERA_CLASSNAME)
	}

	if(ham_is_on){
		DisableHamForward(the_damage_ham_hook)
		ham_is_on=0;
	}
}
public plugin_precache()
{
	
	engfunc(EngFunc_PrecacheModel,CAMERA_WORLD_MDL );
	engfunc(EngFunc_PrecacheSound, CAMERA_BOOTING_SFX) 
	engfunc(EngFunc_PrecacheSound, CAMERA_CLICK_SFX) 
	engfunc(EngFunc_PrecacheSound, CAMERA_BOOTED_SFX)
	
}
public sh_client_death(id)
{
	if(sh_user_has_hero(id,gHeroID)&&is_user_connected(id)){
		
		
		UnSet_BitVar(looking_with_camera_mask, id)
		set_pev(id,pev_fov,90.0)
		set_pdata_int(id, m_iFOV,90);
		attach_view(id,id)
		
	}
}
