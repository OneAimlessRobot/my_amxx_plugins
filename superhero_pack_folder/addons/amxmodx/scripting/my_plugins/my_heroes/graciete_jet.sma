#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_PDATA_ALIASES
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "q_barrel_inc/sh_graciete_get_set.inc"
#include "q_barrel_inc/sh_q_barrel.inc"
#include "q_barrel_inc/sh_graciete_rocket.inc"




#define PLUGIN "Superhero graciete jetty funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new g_graciete_jetpack_loaded_mask = 0;
new g_graciete_jetpack_on_mask = 0;
new g_graciete_power_landing_mask = 0;
new g_graciete_leaped_mask = 0;

new pcvar_jet_max_cooldown, pcvar_jet_min_cooldown
new pcvar_land_explosion_radius
new pcvar_jet_max_velocity
new pcvar_jet_velocity_pct_inc
new pcvar_jet_max_power
new pcvar_jet_stomp_grav_mult
new pcvar_min_jet_start_launch_speed
new pcvar_min_launch_height

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
	pcvar_jet_max_velocity = create_cvar("graciete_jet_max_velocity", "8")
	pcvar_jet_velocity_pct_inc = create_cvar("graciete_jet_velocity_pct_inc", "8") //pct of remaining speed rel. to maximum to add
	pcvar_jet_max_cooldown = create_cvar("graciete_jet_max_cooldown", "8")
	pcvar_jet_min_cooldown = create_cvar("graciete_jet_min_cooldown", "8")
	pcvar_jet_max_power = create_cvar("graciete_jet_max_power", "8")
	pcvar_min_jet_start_launch_speed = create_cvar("graciete_min_jet_start_launch_speed", "8")
	pcvar_min_launch_height = create_cvar("graciete_min_launch_height","8")
	pcvar_jet_stomp_grav_mult = create_cvar("graciete_jet_stomp_grav_mult", "8")
	pcvar_land_explosion_radius = create_cvar("graciete_land_explosion_radius", "8")
	
	RegisterHam(Ham_Player_PostThink,"player","Ham_Think_Post",_,true)
	cmd_forward=register_forward(FM_CmdStart, "CmdStart");
	GRACIETE_LOAD_TASKID=allocate_typed_task_id(player_task)
	GRACIETE_CHARGE_TASKID=allocate_typed_task_id(player_task)
}

public plugin_natives(){

	register_native("reset_graciete_user","_reset_graciete_user");
	register_native("jet_get_user_power_landing","_jet_get_user_power_landing")
	register_native("graciete_jet_uncharge_user","_graciete_jet_uncharge_user")

	

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
	emit_sound(id, CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
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
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)) return

	if(task_exists(id+GRACIETE_CHARGE_TASKID)){
		return
	}
	g_graciete_base_gravity[id]=get_user_gravity(id)

	
	Set_BitVar(g_graciete_jetpack_on_mask,id);
	
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	trail(id,RED,10,15)
	charge_task(id+GRACIETE_CHARGE_TASKID)
	
	
	
}

uncharge_user(id){
	UnSet_BitVar(g_graciete_power_landing_mask,id);
	if(Get_BitVar(g_graciete_jetpack_on_mask,id)){
		UnSet_BitVar(g_graciete_jetpack_on_mask,id);
	}
	trail(id,RED,0,0)
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	
	
}
public Ham_Think_Post(id) {
	
	if(!sh_is_active()) return HAM_IGNORED
	
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)) return HAM_IGNORED

	if(Get_BitVar(g_graciete_leaped_mask, id)){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			UnSet_BitVar(g_graciete_leaped_mask, id)
			if(Get_BitVar(g_graciete_power_landing_mask,id)){
				
				explosion(gHeroID,id,
						cvar_val(float,pcvar_land_explosion_radius),g_graciete_land_power[id],_,1)
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

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED


	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)) return FMRES_IGNORED

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


			if(sh_get_player_has_hero_prop(id,SH_ANTI_FALL_DAMAGE_HERO)||
							sh_get_player_has_hero_prop(id,SH_ETHEREAL_HERO)){
								
				return FMRES_IGNORED
			
			}
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
	static Float:velocity_vec[3], Float:velocity_magnitude = 0.0, Float:speed_to_add = 0.0, Float:speed_to_set = 0.0
	static Float:speed_frac = 0.0
	static Float:the_cooldown = 0.0
	velocity_magnitude= 0.0
	speed_to_add = 0.0
	speed_to_set = 0.0
	speed_frac = 0.0
	the_cooldown = 0.0

	get_user_velocity(id,velocity_vec)



	velocity_magnitude = vector_length(velocity_vec)
	


	speed_to_add = ((cvar_val(float, pcvar_jet_max_velocity) - velocity_magnitude)  * cvar_val(float, pcvar_jet_velocity_pct_inc))

	speed_to_set = max_macro(max_macro(0.0, cvar_val(float, pcvar_min_jet_start_launch_speed)), min_macro(cvar_val(float, pcvar_jet_max_velocity), speed_to_add + velocity_magnitude))

	speed_frac = clamp_macro( speed_to_set/cvar_val(float, pcvar_jet_max_velocity), 0.1, 0.99)

	the_cooldown = cvar_val(float, pcvar_jet_min_cooldown)
	
				+ 
	
		speed_frac

				*
	
	(cvar_val(float, pcvar_jet_max_cooldown) - cvar_val(float, pcvar_jet_min_cooldown))

	JetpackJump(id, floatround(speed_to_set));
	set_task(the_cooldown,"load_jetpack",id+GRACIETE_LOAD_TASKID);
	
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
	if(!sh_get_user_has_hero(id,gHeroID)){

		return
	}
	if(!Get_BitVar(g_graciete_power_landing_mask, id)){
		return
	}	
	set_user_gravity(id,g_graciete_base_gravity[id]*
			cvar_val(float, pcvar_jet_stomp_grav_mult));
	
	static hud_msg[128];
	g_graciete_land_power[id]=min_macro(cvar_val(float, pcvar_jet_max_power),floatadd(g_graciete_land_power[id],GRACIETE_CHARGE_RATE))
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
	velocity[2]=max_macro(max_macro(0.0,cvar_val(float, pcvar_min_launch_height)),floatabs(velocity[2]));
	set_pev(id, pev_velocity, velocity);
}


public sh_client_death(id)
{
	if(!is_user_connected(id)||!sh_is_active()){
		return
	}
	uncharge_user(id)
	
}
