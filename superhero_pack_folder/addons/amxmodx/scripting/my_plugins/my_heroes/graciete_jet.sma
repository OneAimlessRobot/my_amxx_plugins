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

new Float:g_graciete_base_gravity[SH_MAXSLOTS+1];
new g_graciete_jetpack_loaded[SH_MAXSLOTS+1];
new bool:g_graciete_jetpack_on[SH_MAXSLOTS+1]
new Float:g_graciete_land_power[SH_MAXSLOTS+1];
new bool:g_graciete_power_landing[SH_MAXSLOTS+1];
new bool:g_graciete_leaped[SH_MAXSLOTS+1];
new jet_cooldown
new Float:land_explosion_radius
new Float:jet_velocity
new Float:jet_max_power
new Float:jet_stomp_grav_mult
new cmd_forward


stock GRACIETE_LOAD_TASKID,
		GRACIETE_CHARGE_TASKID


//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	arrayset(g_graciete_jetpack_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_graciete_land_power,0.0,SH_MAXSLOTS+1)
	arrayset(g_graciete_power_landing,false,SH_MAXSLOTS+1)
	arrayset(g_graciete_leaped,false,SH_MAXSLOTS+1)
	register_event("DeathMsg","death","a")

	cmd_forward=register_forward(FM_CmdStart, "CmdStart");
	GRACIETE_LOAD_TASKID=allocate_typed_task_id(player_task)
	GRACIETE_CHARGE_TASKID=allocate_typed_task_id(player_task)
	init_explosion_defaults()
}

public plugin_natives(){

	register_native("reset_graciete_user","_reset_graciete_user",0);
	register_native("jet_get_user_power_landing","_jet_get_user_power_landing",0)
	register_native("jet_uncharge_user","_jet_uncharge_user",0)

	

}
public _jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)
	sh_reset_min_gravity(id)


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
	g_graciete_land_power[id]=0.0;
	g_graciete_power_landing[id]=false;
	g_graciete_leaped[id]=false;
	remove_task(id+GRACIETE_CHARGE_TASKID)

	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	g_graciete_jetpack_on[id]=false;
	
	
}

public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound,  jp_jump)
	engfunc(EngFunc_PrecacheSound,  jp_fly)
	
	
	
}

public plugin_end(){
	
	
	unregister_forward(FM_CmdStart,cmd_forward);
	
}
charge_user(id){
	if(!client_hittable(id,sh_user_has_hero(id,graciete_get_hero_id()))) return 0
	
	g_graciete_base_gravity[id]=get_user_gravity(id)

	
	g_graciete_jetpack_on[id]= true
	
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	trail(id,RED,10,15)
	remove_task(id+GRACIETE_CHARGE_TASKID)
	set_task(GRACIETE_CHARGE_PERIOD,"charge_task",id+GRACIETE_CHARGE_TASKID,"", 0,  "b")
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+GRACIETE_CHARGE_TASKID)
	g_graciete_power_landing[id]=false
	if(g_graciete_jetpack_on[id]){
		g_graciete_jetpack_on[id]=false;
	}
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	return 0
	
	
	
}
public client_PostThink(id) {
	
	if( !client_hittable(id,sh_user_has_hero(id,graciete_get_hero_id()))) { 
		return
	}
	if(g_graciete_leaped[id]){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			g_graciete_leaped[id]=false
			if(g_graciete_power_landing[id]){
				
				explosion(graciete_get_hero_id(),id,land_explosion_radius,g_graciete_land_power[id],default_explode_knock_force_magnitude,1)
				g_graciete_land_power[id]=0.0
				
			}
			uncharge_user(id)
			sh_reset_min_gravity(id)
		
		}
	}
}
public CmdStart(id, uc_handle)
{
	if (!client_hittable(id,sh_user_has_hero(id,graciete_get_hero_id()))||!hasRoundStarted()){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	new flags = pev(id, pev_flags)
	if((flags  & FL_INGROUND2)){
		if((button & IN_DUCK)&&(button&IN_JUMP))
		{
			if(g_graciete_jetpack_loaded[id]){
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
	set_task(float(jet_cooldown),"load_jetpack",id+GRACIETE_LOAD_TASKID,"",0,"a",1);
	
}
public load_jetpack(id){
	id-=GRACIETE_LOAD_TASKID
	
	g_graciete_jetpack_loaded[id]=true;	
	
	
}
public charge_task(id){
	id-=GRACIETE_CHARGE_TASKID
	if(!client_hittable(id)){
		
		remove_task(id+GRACIETE_CHARGE_TASKID)
		return
	}
	if(!sh_user_has_hero(id,graciete_get_hero_id())){
		

		remove_task(id+GRACIETE_CHARGE_TASKID)
		return
	}
	
	
	set_user_gravity(id,g_graciete_base_gravity[id]*jet_stomp_grav_mult);
	
	new hud_msg[128];
	g_graciete_land_power[id]=floatmin(jet_max_power,floatadd(g_graciete_land_power[id],GRACIETE_CHARGE_RATE))
	formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",(g_graciete_land_power[id])
	);
	client_print(id,print_center,"%s",hud_msg)
	
	
	
	
	
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
	if(!is_user_connected(id)||!sh_is_active()||!sh_user_has_hero(id,graciete_get_hero_id())) return
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	
}
