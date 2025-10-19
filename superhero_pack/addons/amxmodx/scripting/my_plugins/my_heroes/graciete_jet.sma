
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "q_barrel_inc/sh_graciete_get_set.inc"
#include "q_barrel_inc/sh_q_barrel.inc"
#include "q_barrel_inc/sh_graciete_rocket.inc"


#define PLUGIN "Superhero graciete jetty funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new g_graciete_jetpack_cooldown[SH_MAXSLOTS+1];
new Float:g_graciete_base_gravity[SH_MAXSLOTS+1];
new g_graciete_jetpack_loaded[SH_MAXSLOTS+1];
new g_graciete_jetpack[SH_MAXSLOTS+1];
new Float:g_graciete_land_power[SH_MAXSLOTS+1];
new bool:g_graciete_power_landing[SH_MAXSLOTS+1];
new bool:g_graciete_leaped[SH_MAXSLOTS+1];
//const FL_INGROUND2 = (FL_CONVEYOR|FL_ONGROUND|FL_PARTIALGROUND|FL_INWATER|FL_FLOAT)
const FL_INGROUND2=TOUCHING_GROUND
new jet_cooldown
//new Float:berserk_m3_mult
new Float:land_explosion_radius
new Float:jet_velocity
new Float:jet_max_power
new Float:jet_stomp_grav_mult
new cmd_forward
new hud_sync_charge
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	arrayset(g_graciete_jetpack_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_graciete_jetpack_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_graciete_jetpack,0,SH_MAXSLOTS+1)
	arrayset(g_graciete_land_power,0.0,SH_MAXSLOTS+1)
	arrayset(g_graciete_power_landing,false,SH_MAXSLOTS+1)
	arrayset(g_graciete_leaped,false,SH_MAXSLOTS+1)
	register_event("DeathMsg","death","a")

	cmd_forward=register_forward(FM_CmdStart, "CmdStart");
	
	g_msgFade = get_user_msgid("ScreenFade");
	hud_sync_charge=CreateHudSyncObj()
	
	// Add your code here...
}

public plugin_natives(){

	register_native("clear_jps","_clear_jps",0);
	register_native("reset_graciete_user","_reset_graciete_user",0);
	register_native("jet_get_user_jet_cooldown","_jet_get_user_jet_cooldown",0)
	register_native("jet_get_user_power_landing","_jet_get_user_power_landing",0)
	register_native("jet_uncharge_user","_jet_uncharge_user",0)

	

}
public _jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)
	sh_reset_min_gravity(id)


}
public _jet_get_user_jet_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_graciete_jetpack_cooldown[id]


}
public _jet_get_user_power_landing(iPlugin,iParams){
	new id=get_param(1)
	
	return g_graciete_power_landing[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	jet_cooldown=get_cvar_num("graciete_jet_cooldown");
	land_explosion_radius=get_cvar_float("graciete_land_explosion_radius");
	jet_velocity=get_cvar_float("graciete_jet_velocity");
	jet_max_power=get_cvar_float("graciete_jet_max_power")
	jet_stomp_grav_mult=get_cvar_float("graciete_jet_stomp_grav_mult")
}

public _reset_graciete_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_graciete_jetpack_loaded[id]=true;
	g_graciete_jetpack_cooldown[id]=0;
	g_graciete_land_power[id]=0.0;
	g_graciete_power_landing[id]=false;
	g_graciete_leaped[id]=false;
	remove_task(id+GRACIETE_CHARGE_TASKID)
	if(is_valid_ent(g_graciete_jetpack[id])){
		emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_graciete_jetpack[id]);
		g_graciete_jetpack[id]=0;
	}
	
	
}

public plugin_precache(){
	
	precache_model(jp_mdl)
	engfunc(EngFunc_PrecacheSound,  jp_jump)
	engfunc(EngFunc_PrecacheSound,  jp_fly)
	precache_explosion_fx()
	
	
}

public plugin_end(){
	
	
	unregister_forward(FM_CmdStart,cmd_forward);
	
}
public graciete_cooldown_loop(id){
	id-=GRACIETE_COOLDOWN_TASKID;
	if(!client_hittable(id,graciete_get_has_graciete(id))){
		return PLUGIN_HANDLED
		
	}
	if(g_graciete_jetpack_cooldown[id]){
		
		g_graciete_jetpack_cooldown[id]-=1;
		
	}
	return PLUGIN_HANDLED
	
}
charge_user(id){
	if(!client_hittable(id,graciete_get_has_graciete(id))) return 0
	
	g_graciete_base_gravity[id]=get_user_gravity(id)
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	
	g_graciete_jetpack[id]= CreateEntity("info_target")
	
	if(!is_valid_ent(g_graciete_jetpack[id])||(g_graciete_jetpack[id] == 0)) {
		return PLUGIN_HANDLED
	}
	Entvars_Set_String(g_graciete_jetpack[id], EV_SZ_classname, JP_CLASSNAME)
	ENT_SetModel(g_graciete_jetpack[id], jp_mdl)
	
	
	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}
	
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_mins,fl_vecminsx)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_maxs,fl_vecmaxsx)
	
	ENT_SetOrigin(g_graciete_jetpack[id], vOrigin)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_angles, vAngles)
	Entvars_Set_Int(g_graciete_jetpack[id], EV_INT_effects, 64)
	Entvars_Set_Int(g_graciete_jetpack[id], EV_INT_solid, 0)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_velocity,  velocity)
	
	Entvars_Set_Edict(g_graciete_jetpack[id], EV_ENT_owner, id)
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	rockettrail(g_graciete_jetpack[id]+GRACIETE_TRAIL_TASKID)
	set_task(GRACIETE_CHARGE_PERIOD,"charge_task",id+GRACIETE_CHARGE_TASKID,"", 0,  "b")
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+GRACIETE_CHARGE_TASKID)
	g_graciete_power_landing[id]=false
	if(is_valid_ent(g_graciete_jetpack[id])){
		remove_entity(g_graciete_jetpack[id]);
		g_graciete_jetpack[id]=0;
	}
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	return 0
	
	
	
}
public client_PostThink(id) {
	
	if( !client_hittable(id,graciete_get_has_graciete(id))) { 
		return
	}
	if(g_graciete_leaped[id]){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			g_graciete_leaped[id]=false
			if(g_graciete_power_landing[id]){
				
				explosion_player(graciete_get_hero_id(),id,land_explosion_radius,g_graciete_land_power[id])
				g_graciete_land_power[id]=0.0
				
			}
			uncharge_user(id)
			sh_reset_min_gravity(id)
		
		}
	}
}
public CmdStart(id, uc_handle)
{
	if (!client_hittable(id,graciete_get_has_graciete(id))||!hasRoundStarted()) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	new flags = pev(id, pev_flags)
	if((flags  & FL_INGROUND2)){
		if((button & IN_DUCK)&&(button&IN_JUMP))
		{
			if(!g_graciete_jetpack_loaded[id]){
				
				client_print(id,print_center,"Cant jump yet! %d seconds left!",g_graciete_jetpack_cooldown[id]);
			}
			else{
				graciete_jump(id)
			}
		}
		return FMRES_IGNORED
	}
	if(g_graciete_leaped[id]){
		
			if((weapon==CSW_KNIFE)&&(button & IN_ATTACK2)&&(button & IN_DUCK)){
				if(!g_graciete_power_landing[id]){
					g_graciete_power_landing[id]=true
					charge_user(id)
					return FMRES_IGNORED
				}
			}
	}
	return FMRES_IGNORED;
}
public graciete_jump(id){
	
	emit_sound(id, CHAN_WEAPON, jp_jump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	g_graciete_jetpack_loaded[id]=false;
	g_graciete_leaped[id]=true;	
	JetpackJump(id, floatround(jet_velocity));
	g_graciete_jetpack_cooldown[id]=jet_cooldown
	set_task(1.0,"graciete_cooldown_loop",id+GRACIETE_COOLDOWN_TASKID,"",0,"a",jet_cooldown);
	set_task(float(jet_cooldown),"load_jetpack",id+GRACIETE_LOAD_TASKID,"",0,"a",1);
	
}
public load_jetpack(id){
	id-=GRACIETE_LOAD_TASKID
	
	g_graciete_jetpack_loaded[id]=true;	
	
	
}
public rockettrail(id)
{
	id-=GRACIETE_TRAIL_TASKID
	
	
	trail(id,LTGREEN,10,15)
	// move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
public charge_task(id){
	id-=GRACIETE_CHARGE_TASKID
	if(!client_hittable(id,graciete_get_has_graciete(id))) return
	
	
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	
	
	if(!is_valid_ent(g_graciete_jetpack[id])||(g_graciete_jetpack[id] == 0)) {
		return
	}
	ENT_SetOrigin(g_graciete_jetpack[id], vOrigin)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_angles, vAngles)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_velocity,  velocity)
	
	set_user_gravity(id,g_graciete_base_gravity[id]*jet_stomp_grav_mult);
	
	new hud_msg[128];
	g_graciete_land_power[id]=floatmin(jet_max_power,floatadd(g_graciete_land_power[id],GRACIETE_CHARGE_RATE))
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",(g_graciete_land_power[id])
	);
	set_hudmessage(graciete_color[0], graciete_color[1], graciete_color[2], -1.0, -1.0, graciete_color[3], 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	
	
	
	
	
	
}
public _clear_jps(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JP_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada,  JP_CLASSNAME)
	}
}

public JetpackJump( id,intensity){
	
	new Float:velocity[3];
	VelocityByAim(id, intensity, velocity);
	new Float:vector_len=vector_length(velocity);
	velocity[0]=velocity[0]/vector_len;
	velocity[1]=velocity[1]/vector_len;
	velocity[2]=velocity[2]/vector_len;
	
	velocity[0]=velocity[0]*float(intensity);
	velocity[1]=velocity[1]*float(intensity);
	velocity[2]=velocity[2]*float(intensity);
	velocity[2]=floatabs(velocity[2])+250;
	set_pev(id, pev_velocity, velocity);
}


public death()
{
	new id = read_data(2)
	if(!is_user_connected(id)||!sh_is_active()||!graciete_get_has_graciete(id)) return
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
}
