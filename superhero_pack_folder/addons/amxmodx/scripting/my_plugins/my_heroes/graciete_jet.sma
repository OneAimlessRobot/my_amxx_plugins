#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "q_barrel_inc/sh_graciete_get_set.inc"
#include "q_barrel_inc/sh_q_barrel.inc"
#include "q_barrel_inc/sh_graciete_rocket.inc"




#define PLUGIN "Superhero graciete jetty funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new gHeroID = 0
new g_graciete_jetpack_loaded_mask = 0;
new g_graciete_jetpack_on_mask = 0;
new g_graciete_power_landing_mask = 0;
new g_graciete_leaped_mask = 0;

new pcvar_jet_cooldown
new pcvar_land_explosion_radius
new pcvar_jet_velocity
new pcvar_jet_max_power
new pcvar_jet_stomp_grav_mult

new Float:g_graciete_base_gravity[SH_MAXSLOTS+1];
new Float:g_graciete_land_power[SH_MAXSLOTS+1];
new cmd_forward


stock GRACIETE_LOAD_TASKID,
		GRACIETE_CHARGE_TASKID


//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("DeathMsg","death","a")
	pcvar_jet_velocity = register_cvar("graciete_jet_velocity", "8")
	pcvar_jet_cooldown = register_cvar("graciete_jet_cooldown", "8")
	pcvar_jet_max_power = register_cvar("graciete_jet_max_power", "8")
	pcvar_jet_stomp_grav_mult = register_cvar("graciete_jet_stomp_grav_mult", "8")
	pcvar_land_explosion_radius = register_cvar("graciete_land_explosion_radius", "8")
	
	RegisterHam(Ham_Player_PostThink,"player","Ham_Think_Post",_,true)
	cmd_forward=register_forward(FM_CmdStart, "CmdStart");
	GRACIETE_LOAD_TASKID=allocate_typed_task_id(player_task)
	GRACIETE_CHARGE_TASKID=allocate_typed_task_id(player_task)
	init_explosion_defaults()
}

public plugin_natives(){

	register_native("reset_graciete_user","_reset_graciete_user",0);
	register_native("jet_get_user_power_landing","_jet_get_user_power_landing",0)
	register_native("graciete_jet_uncharge_user","_graciete_jet_uncharge_user",0)

	

}
public plugin_cfg(){

	gHeroID = graciete_get_hero_id()
}
public _graciete_jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)
	sh_reset_min_gravity(id)


}
public _jet_get_user_power_landing(iPlugin,iParams){
	new id=get_param(1)
	
	return Get_BitVar(g_graciete_power_landing_mask, id)


}
public _reset_graciete_user(iPlugin,iParams){
	
	new id= get_param(1)
	Set_BitVar(g_graciete_jetpack_loaded_mask,id);
	UnSet_BitVar(g_graciete_power_landing_mask,id);
	UnSet_BitVar(g_graciete_leaped_mask,id);
	UnSet_BitVar(g_graciete_jetpack_on_mask,id);
	g_graciete_land_power[id]=0.0;
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
	
}

public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound,  jp_jump)
	engfunc(EngFunc_PrecacheSound,  jp_fly)
	
	
	
}

public plugin_end(){
	
	
	unregister_forward(FM_CmdStart,cmd_forward);
	
}
charge_user(id){
	if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)) return
	
	g_graciete_base_gravity[id]=get_user_gravity(id)

	
	Set_BitVar(g_graciete_jetpack_on_mask,id);
	
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	trail(id,RED,10,15)
	set_task(GRACIETE_CHARGE_PERIOD,"charge_task",id+GRACIETE_CHARGE_TASKID)
	
	
	
}

uncharge_user(id){
	UnSet_BitVar(g_graciete_power_landing_mask,id);
	if(Get_BitVar(g_graciete_jetpack_on_mask,id)){
		UnSet_BitVar(g_graciete_jetpack_on_mask,id);
	}
	trail(id,RED,0,0)
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
	
	
}
public Ham_Think_Post(id) {
	
	if(!sh_is_active()) return HAM_IGNORED
	
	if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)) return HAM_IGNORED

	if(Get_BitVar(g_graciete_leaped_mask, id)){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			UnSet_BitVar(g_graciete_leaped_mask, id)
			if(Get_BitVar(g_graciete_power_landing_mask,id)){
				
				emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
				explosion(gHeroID,id,
						cvar_val(float,pcvar_land_explosion_radius),g_graciete_land_power[id],default_explode_knock_force_magnitude,1)
				UnSet_BitVar(g_graciete_power_landing_mask,id);
				g_graciete_land_power[id]=0.0
				
				
			}
			uncharge_user(id)
			sh_reset_min_gravity(id)
		
		}
	}
	return HAM_IGNORED
}
public CmdStart(id, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()) return FMRES_IGNORED;

	if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	new flags = pev(id, pev_flags)
	if((flags  & FL_INGROUND2)){
		if((button & IN_DUCK)&&(button&IN_JUMP))
		{
			if(Get_BitVar(g_graciete_jetpack_loaded_mask, id)){
				graciete_jump(id)
			}
		}
		return FMRES_IGNORED
	}
	if(Get_BitVar(g_graciete_leaped_mask, id)){
	
		if((weapon==CSW_KNIFE)&&(button & IN_ATTACK2)&&(button & IN_DUCK)){
			if(!Get_BitVar(g_graciete_power_landing_mask, id)){
				Set_BitVar(g_graciete_power_landing_mask, id);
				charge_user(id)
				return FMRES_IGNORED
			}
		}
	}
	return FMRES_IGNORED;
}
public graciete_jump(id){
	
	emit_sound(id, CHAN_WEAPON, jp_jump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	UnSet_BitVar(g_graciete_jetpack_loaded_mask, id);
	Set_BitVar(g_graciete_leaped_mask, id);
	JetpackJump(id, floatround(cvar_val(float, pcvar_jet_velocity)));
	set_task(float(cvar_val(num, pcvar_jet_cooldown)),"load_jetpack",id+GRACIETE_LOAD_TASKID);
	
}
public load_jetpack(id){
	id-=GRACIETE_LOAD_TASKID;
	
	Set_BitVar(g_graciete_jetpack_loaded_mask, id);	
	
	
}
public charge_task(id){
	id-=GRACIETE_CHARGE_TASKID
	if(!is_user_alive(id)){
		
		return
	}
	if(!sh_user_has_hero(id,gHeroID)){

		return
	}
	if(!Get_BitVar(g_graciete_power_landing_mask, id)){
		return
	}	
	set_user_gravity(id,g_graciete_base_gravity[id]*
			cvar_val(float, pcvar_jet_stomp_grav_mult));
	
	static hud_msg[128];
	g_graciete_land_power[id]=floatmin(
				cvar_val(float, pcvar_jet_max_power),floatadd(g_graciete_land_power[id],GRACIETE_CHARGE_RATE))
	formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",(g_graciete_land_power[id])
	);
	client_print(id,print_center,"%s",hud_msg)
	if(Get_BitVar(g_graciete_power_landing_mask, id)){
		set_task(GRACIETE_CHARGE_PERIOD,"charge_task",id+GRACIETE_CHARGE_TASKID)
	}
	
	
	
	
}
public JetpackJump( id,intensity){
	
	new Float:velocity[3];
	velocity_by_aim(id, intensity, velocity);
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
	if(!is_user_connected(id)||!sh_is_active()||!sh_user_has_hero(id,gHeroID)) return
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
}
