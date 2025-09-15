#include "../my_include/superheromod.inc"
#include <xs>
#include "chaff_grenade_inc/sh_teliko_get_set.inc"
#include "chaff_grenade_inc/sh_slitter_funcs.inc"
#include "chaff_grenade_inc/sh_chaff_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero teliko slitter"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new slitter_on[SH_MAXSLOTS+1]

new g_dragging_who[SH_MAXSLOTS+1][2]
new g_slit_kills[SH_MAXSLOTS+1]

new Float:slitter_distance
new Float:slitter_drag_time
new slitter_level_difference
new max_slitter_kills_per_life
new Float:slitter_drag_speed
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		if(client_hittable(i)){
			g_dragging_who[i][0]=-1;
			g_dragging_who[i][1]=0
		}
	
	}
	arrayset(slitter_on,0,SH_MAXSLOTS+1)
	arrayset(g_slit_kills,0,SH_MAXSLOTS+1)
	register_cvar("slitter_distance", "2.0")
	register_cvar("max_slits_per_life", "2.0")
	register_cvar("slitter_drag_speed", "2.0")
	register_cvar("slitter_level_difference", "10")
	register_cvar("slitter_drag_time", "3")
	RegisterHam(Ham_TakeDamage,"player","Teliko_ham_damage",_,true)
	register_forward(FM_CmdStart, "CmdStart");
	register_event("DeathMsg","death","a")
	register_event("ResetHUD","newRound","b")
	register_event("CurWeapon", "weaponChange", "be", "1=1")
}

public weaponChange(id)
{
	if ( !is_user_alive(id)||!teliko_get_has_teliko(id) ||!shModActive()) return PLUGIN_CONTINUE
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ((wpnid == CSW_KNIFE)&&slitter_get_slit_kills(id)) {
		entity_set_string(id, EV_SZ_viewmodel, SLITTER_V_MODEL)
	}
	return PLUGIN_CONTINUE
	
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
if ( teliko_get_has_teliko(id)&&is_user_alive(id) && shModActive() &&!hasRoundStarted() ) {
	
	stop_dragging(id)
	g_slit_kills[id]=max_slitter_kills_per_life;
}
return PLUGIN_HANDLED

}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	slitter_distance=get_cvar_float("slitter_distance")
	slitter_level_difference=get_cvar_num("slitter_level_difference")
	slitter_drag_time=get_cvar_float("slitter_drag_time")
	slitter_drag_speed=get_cvar_float("slitter_drag_speed")
	max_slitter_kills_per_life=get_cvar_num("max_slits_per_life")
}
public plugin_natives(){
	
	
	register_native( "slitter_set_slitter","_slitter_set_slitter",0)
	register_native( "slitter_get_slitter","_slitter_get_slitter",0)
	register_native( "slitter_get_dragging_who","_slitter_get_dragging_who",0)
	register_native( "slitter_get_slit_kills","_slitter_get_slit_kills",0)
	
}
stop_dragging(id){
	
		remove_task(id+SLITTER_TASKID)
		if((g_dragging_who[id][0]>=0)){
			if(client_hittable( g_dragging_who[id][0])){
				entity_set_int( g_dragging_who[id][0], EV_INT_fixangle, 0 );
			}
			sh_reset_max_speed(id)
			
		}
		g_dragging_who[id][1]=0
		g_dragging_who[id][0]=-1

}

//----------------------------------------------------------------------------------------------
public slitter_think(id)
{
	id-=SLITTER_TASKID
	if (!client_hittable(id)){
	
		remove_task(id+SLITTER_TASKID)
		return FMRES_IGNORED
	
	}
	if (!teliko_get_has_teliko(id)){
	
		remove_task(id+SLITTER_TASKID)
		return FMRES_IGNORED
	
	}
	if(g_dragging_who[id][0]<0){
		
	
	
		remove_task(id+SLITTER_TASKID)
		return FMRES_IGNORED
	}
	if(!(g_dragging_who[id][1])){
		
		stop_dragging(id)
	
		return FMRES_IGNORED
	
	
	}
	new ammo, clip, wpnid=get_user_weapon(id,ammo,clip)
	if(wpnid!=CSW_KNIFE){
		shSwitchWeaponID(id,CSW_KNIFE)
	}
	static Float:aimvec[3],Float:vAngle[3],Float:vAngles[3],Float:eOrigin[3],Float:vOrigin[3]
	pev(id,pev_origin,vOrigin)
	pev(g_dragging_who[id][0],pev_origin,eOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	entity_get_vector(id, EV_VEC_angles, vAngles)
	new Float:direction[3],Float:fl_Velocity[3], Float:length
	VelocityByAim(id,9999,aimvec)
	
	static Float:vTrace[3], tr
	static Float:vEnd[3],Float:newVec[3]
	for(new i=0;i<3;i++){
		vEnd[i]=vOrigin[i]+aimvec[i]
	}
	tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, id, tr)
	get_tr2(tr, TR_vecEndPos, vTrace)
	
	direction[0] = vTrace[0]-vOrigin[0]
	direction[1] = vTrace[1]-vOrigin[1]
	direction[2] = vTrace[2]-vOrigin[2]

	length = vector_distance(aimvec, vOrigin)
	if (length==0.0) length = 1.0        // avoid division by 0

	newVec[0] = vOrigin[0]+direction[0]*slitter_distance/length
	newVec[1] = vOrigin[1]+direction[1]*slitter_distance/length

	fl_Velocity[0] = (newVec[0]-eOrigin[0])*DRAG_FORCE
	fl_Velocity[1] = (newVec[1]-eOrigin[1])*DRAG_FORCE
	fl_Velocity[2] = -DRAG_FORCE

	entity_set_vector(g_dragging_who[id][0], EV_VEC_velocity, fl_Velocity)
	
	orient_user(g_dragging_who[id][0],vAngles,vAngle)
	sh_set_stun(g_dragging_who[id][0],2.0,0.1)
	set_user_maxspeed(id,slitter_drag_speed)
	
	set_pev(g_dragging_who[id][0],pev_renderamt,255.0)
	g_dragging_who[id][1]--;
	return FMRES_IGNORED
}

public orient_user(id,Float:angles[3],Float:v_angle[3])
{
	
	entity_set_int( id, EV_INT_fixangle, 0 );
	entity_set_vector(id, EV_VEC_v_angle,v_angle)
	entity_set_vector(id, EV_VEC_angles,angles)
	entity_set_int( id, EV_INT_fixangle, 1 );
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public CmdStart(attacker, uc_handle)
{
	if ( !hasRoundStarted()||!client_hittable(attacker)) return FMRES_IGNORED;
	if ( !teliko_get_has_teliko(attacker)||!slitter_get_slitter(attacker)||!slitter_get_slit_kills(attacker)) return FMRES_IGNORED;
	
	static button
	button= get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(attacker, clip, ammo);
	
	if((weapon==CSW_KNIFE)){
		if((button & IN_DUCK)){
			button&= ~IN_DUCK
			set_pev(attacker, pev_flTimeStepSound, 999)
		
		}
		if((button & IN_RELOAD))
		{
			if((g_dragging_who[attacker][0]<0)){
				button &= ~IN_RELOAD;
				set_uc(uc_handle, UC_Buttons, button);
				
				new Float: vec2LOS[2];
				new Float: vecForward[3];
				new Float: vecForward2D[2];
				
				velocity_by_aim( attacker, floatround(slitter_distance), vecForward );
				
				xs_vec_make2d( vecForward, vec2LOS );
				xs_vec_normalize( vec2LOS, vec2LOS );
				
				static Float:vTrace[3], id, tr
				static Float:vOrigin[3],Float:vEnd[3]
				pev(attacker, pev_origin, vOrigin)
				vEnd[0]=vOrigin[0]+vecForward[0]
				vEnd[1]=vOrigin[1]+vecForward[1]
				vEnd[2]=vOrigin[2]+vecForward[2]
				tr = 0
				engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, attacker, tr)
				get_tr2(tr, TR_vecEndPos, vTrace)
				id = get_tr2(tr, TR_pHit)
				if (!is_user_alive(id) ){
					return FMRES_IGNORED
				
				}
				if(cs_get_user_team(id)==cs_get_user_team(attacker)){
					return FMRES_IGNORED
				}
				velocity_by_aim(id, floatround(slitter_distance), vecForward ); 
				
				xs_vec_make2d( vecForward, vecForward2D );
				new att_name[128],vic_name[128];
				if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.8) )
				{
					if((sh_get_user_lvl(attacker)-sh_get_user_lvl(id))>slitter_level_difference){
						
						g_dragging_who[attacker][0]=id
						g_dragging_who[attacker][1]=floatround(SLITTER_DRAG_THINK_TIMES)
						new Float:velocity[3]={1.0,1.0,1.0}
						entity_set_vector(id, EV_VEC_velocity, velocity)
						set_task((SLITTER_DRAG_THINK_PERIOD),"slitter_think",attacker+SLITTER_TASKID,"",0,"b")
						get_user_name(attacker,att_name,127)
						get_user_name(id,vic_name,127)
						sh_chat_message(attacker,teliko_get_hero_id(),"Snuck up on %s!",vic_name);
						sh_chat_message(id,teliko_get_hero_id(),"You got snuck up on by %s!",att_name);
					}
					else{
						sh_chat_message(attacker,teliko_get_hero_id(),"Level difference is too small! Cannot drag opponent!");
						
					}
				}
			}
		}
		else {
		
		
			g_dragging_who[attacker][0]=-1
		
		}
		
	}
	return FMRES_IGNORED;
}
public Teliko_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !shModActive() || !is_user_alive(id) || !is_user_connected(id)||!is_user_alive(attacker) ||!is_user_connected(attacker) ||!(attacker>=1 && attacker <=SH_MAXSLOTS)) return HAM_IGNORED

new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)

new CsTeams:att_team=cs_get_user_team(attacker)
if(teliko_get_has_teliko(attacker)&&!(cs_get_user_team(id)==att_team)){
	
	if(weapon==CSW_KNIFE){
		new button = pev(attacker, pev_button);
		new bool:slashing;
		if((button & IN_ATTACK)&&(button & IN_DUCK)){
			
			button &= ~IN_ATTACK;
			button &= ~IN_DUCK;
			slashing=true;
		}
		new Float: vec2LOS[2];
		new Float: vecForward[3];
		new Float: vecForward2D[2];
		
		velocity_by_aim( attacker, 1, vecForward );
		
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
		
		velocity_by_aim(id, 1, vecForward ); 
		
		xs_vec_make2d( vecForward, vecForward2D );
		new att_name[128],vic_name[128];
		
		
		if(slashing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.8) )
			{
				if(g_dragging_who[attacker][0]==id){
						
					if(slitter_get_slit_kills(attacker)){
						get_user_name(attacker,att_name,127)
						get_user_name(id,vic_name,127)
						g_dragging_who[attacker][0]=-1;
						g_dragging_who[attacker][1]=0;
						if(get_user_godmode(id)){
						
							
							sh_chat_message(attacker,teliko_get_hero_id(),"You removed %s's godmode!!",vic_name);
							set_user_godmode(id,0)
						}
						else{
							damage=get_user_health(id)*3.0
							SetHamParamFloat(4, damage);
							sh_extra_damage(id,attacker,floatround(damage),"Slit throat",1)
							sh_chat_message(attacker,teliko_get_hero_id(),"You slit %s's throat!",vic_name);
						}
						g_slit_kills[attacker]--;
						if(slitter_get_slit_kills(attacker)){							
							
							sh_chat_message(attacker,teliko_get_hero_id(),"You got %d slit strikes left",slitter_get_slit_kills(attacker));
						
						}
					}
					else{
					
						sh_chat_message(attacker,teliko_get_hero_id(),"Already hit %d slit kills this life!",max_slitter_kills_per_life);
				
					}
				}
			}	
		}
	}
}

return HAM_IGNORED

}
public _slitter_get_slitter(iPlugin,iParams){
new id=get_param(1)

return slitter_on[id];


}
public _slitter_set_slitter(iPlugin,iParams){
new id=get_param(1)
new value_to_set=get_param(2)
new prev_value=slitter_on[id]
if(!prev_value&&value_to_set){
	g_slit_kills[id]=0;
}
slitter_on[id]=value_to_set

}
public _slitter_get_dragging_who(iPlugin,iParams){
new id=get_param(1)

return g_dragging_who[id][0]


}

public _slitter_get_slit_kills(iPlugin,iParams){
new id=get_param(1)

return g_slit_kills[id]


}



public plugin_precache()
{
	precache_model(SLITTER_V_MODEL)
	for(new i=0;i<sizeof(teliko_slitter_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,teliko_slitter_sounds[i] );
	
	}

}

public death()
{	
	new id = read_data(2)
	if(teliko_get_has_teliko(id)){
		
		stop_dragging(id)
	
	}
	
}
