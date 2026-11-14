#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS

#include "../my_include/superheromod.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"


#define PLUGIN "Zenitsu charge funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_zenitsu_is_charging_mask = 0
new g_zenitsu_is_glowing_mask = 0

new generic_super_emo = -1

new Float:g_zenitsu_curr_charge_look_direction[SH_MAXSLOTS+1][3]

new Float:g_zenitsu_charge_ammount[SH_MAXSLOTS+1]

new const allow_self_charge = 1
new const allow_self_deplete = 1
new const DEBUG = 0

new ZENITSU_DEBUG_HUD_TASKID
// ints


//floats
new pcvar_zenitsu_pct_electrostatic_dmg_fill_battery,
	pcvar_zenitsu_speed_to_dmg_ratio,
	pcvar_zenitsu_base_speed,
	pcvar_zenitsu_max_speed,
	pcvar_zenitsu_max_battery,
	pcvar_zenitsu_min_battery,
	pcvar_zenitsu_init_battery,
	pcvar_zenitsu_min_electrostatic_dmg_mult,
	pcvar_zenitsu_max_electrostatic_dmg_mult,
	pcvar_zenitsu_emboldened_inside

new zenitsu_hud_msg_sync

public plugin_init(){
	

	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink")
	register_event("CurWeapon", "on_Knife_Weapon_Change", "be", "1=1")
	pcvar_zenitsu_min_battery = create_cvar("zenitsu_min_battery","1000.0")
	pcvar_zenitsu_init_battery = create_cvar("zenitsu_init_battery","2000.0")
	pcvar_zenitsu_max_battery = create_cvar("zenitsu_max_battery","5000.0")
	pcvar_zenitsu_base_speed = create_cvar("zenitsu_base_speed","1000.0")
	pcvar_zenitsu_max_speed = create_cvar("zenitsu_max_speed","5000.0")
	pcvar_zenitsu_pct_electrostatic_dmg_fill_battery = create_cvar("zenitsu_pct_electrostatic_dmg_fill_battery","0.5")
	pcvar_zenitsu_speed_to_dmg_ratio = create_cvar("zenitsu_speed_to_dmg_ratio","0.5")
	pcvar_zenitsu_min_electrostatic_dmg_mult = create_cvar("zenitsu_min_electrostatic_dmg_mult","1.1")
	pcvar_zenitsu_max_electrostatic_dmg_mult = create_cvar("zenitsu_max_electrostatic_dmg_mult","3.0")
	pcvar_zenitsu_emboldened_inside = create_cvar("zenitsu_emboldened_inside", "0")

	register_forward(FM_CmdStart, "zenitsu_charge")

	register_custom_touchable("player","zenitsu_ele_cuerte_de_la_spada",player_vector,1)

	zenitsu_hud_msg_sync = CreateHudSyncObj()
	if(DEBUG){
		ZENITSU_DEBUG_HUD_TASKID = allocate_typed_task_id(generic_task)
		set_task(1.0,"zenitsu_debug_hud_task",ZENITSU_DEBUG_HUD_TASKID,_,_,"b")
	}

}
public zenitsu_debug_hud_task(task_id){

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]
		
		if(!is_user_alive(id)) continue

		if(!sh_get_user_has_hero(id,gHeroID)) continue
		

		show_points_to_player(id)



	}


}

show_points_to_player(id){

	if ( !sh_is_active() || !is_user_alive(id) ||!sh_get_user_has_hero(id,gHeroID)){
		return
	}
	if(!DEBUG){

		if(!sh_get_id_bit(id, SH_ZENITSU_CHARGE_IS_ON)){

			return
		}
	}

	static hud_msg_buff[512]

	bzero(hud_msg_buff)
	if(DEBUG){
		formatex(hud_msg_buff, charsmax(hud_msg_buff), "[SH Zenitsu Agatsuma] You now have %0.2f points!^nStruck someone with power? %s^nIs the power on? %s^nAre you charging? %s^nAre you flying with some power? %s^n",
							g_zenitsu_charge_ammount[id],
							sh_get_id_bit(id,SH_ZENITSU_HAS_STRUCK)?"Yes!":"No...",
							sh_get_id_bit(id,SH_ZENITSU_CHARGE_IS_ON)?"Yes!":"No...",
							Get_BitVar(g_zenitsu_is_charging_mask,id)?"Yes!":"No...",
							sh_get_id_bit(id,SH_USER_IS_FLYING)?"Yes!":"No..."
							)

	}
	else{

		formatex(hud_msg_buff, charsmax(hud_msg_buff), "[SH Zenitsu Agatsuma] You now have %0.2f points!",
							g_zenitsu_charge_ammount[id])

	
	}
	set_hudmessage(LineColors[YELLOW][0],LineColors[YELLOW][1],LineColors[YELLOW][2], 0.39, 0.20 ,0,0.0,2.0,0.1,0.1,_,120)

	ShowSyncHudMsg(id, zenitsu_hud_msg_sync,"%s",hud_msg_buff)
}


Float:get_zenitsu_charge_speed(id){
		
	return (cvar_val(float, pcvar_zenitsu_base_speed)

								+
				((cvar_val(float,pcvar_zenitsu_max_speed)-cvar_val(float, pcvar_zenitsu_base_speed))
								*
						get_zenitsu_battery_ratio(id)))

}

Float:get_zenitsu_impact_damage(id){
		
	return get_entity_velocity(id)*cvar_val(float, pcvar_zenitsu_speed_to_dmg_ratio)

}
Float:get_zenitsu_battery_ratio(id){

	return clamp_macro(g_zenitsu_charge_ammount[id]/cvar_val(float,pcvar_zenitsu_max_battery),0.1,1.0)


}

Float:get_zenitsu_electrostatic_damage_mult(id){


	return (cvar_val(float, pcvar_zenitsu_min_electrostatic_dmg_mult)

								+
				((cvar_val(float,pcvar_zenitsu_max_electrostatic_dmg_mult)-cvar_val(float, pcvar_zenitsu_min_electrostatic_dmg_mult))
								*
						get_zenitsu_battery_ratio(id)))


}
public Fwd_PlayerPreThink(id)
{
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}

	if(!Get_BitVar(g_zenitsu_is_charging_mask, id)){
		return FMRES_IGNORED
	}
	entity_set_vector( id, EV_VEC_angles, g_zenitsu_curr_charge_look_direction[id] )
	entity_set_vector( id, EV_VEC_v_angle, g_zenitsu_curr_charge_look_direction[id] )
	entity_set_int( id, EV_INT_fixangle, 1 )
	return FMRES_IGNORED
}
public plugin_cfg(){

	gHeroID = zenitsu_get_hero_id()
	generic_super_emo = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_ENERGY_BLADE)
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,FLIGHT_IGNITION );
	engfunc(EngFunc_PrecacheSound,SLICERISTA_HIT_MEAT_SFX)
}
public on_Knife_Weapon_Change(id)
{
	if ( !sh_is_active()) return
	if(!sh_get_user_has_hero(id,gHeroID)) return
	if(Get_BitVar(g_zenitsu_is_charging_mask, id)&&!sh_get_id_bit(id, SH_ZENITSU_HAS_STRUCK)){
		engclient_cmd(id, "weapon_knife")
	}
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_get_user_has_hero(id,gHeroID)) {
	
		sh_assign_id_bit(id, SH_ZENITSU_HAS_STRUCK, false)
		sh_assign_id_bit(id, SH_ZENITSU_CHARGE_IS_ON, false)
		sh_assign_id_bit(id, SH_ZENITSU_HAS_BEEN_SLEEP_TRIGGERED, false)
		g_zenitsu_charge_ammount[id] = 0.0;
		Assign_BitVar(g_zenitsu_is_charging_mask, id, false_for_macro);
	}
	return
}
remove_user_flight_fx(id){
	
	if(!sh_get_user_has_hero(id,gHeroID)||!is_user_connected(id)||!sh_is_active()) return
	
	trail(id,GREEN,0,0);
	Assign_BitVar(g_zenitsu_is_glowing_mask, id, false_for_macro);
	Assign_BitVar(g_zenitsu_is_charging_mask, id, false_for_macro);
	sh_assign_id_bit(id,SH_USER_IS_FLYING, false)
	
	
}
public plugin_natives(){

	register_native("zenitsu_init_battery","_zenitsu_init_battery")
	
}
public _zenitsu_init_battery(iPlugin,iParams){
	
	new id= get_param(1)
	sh_sleep_user(id,id,5.0,gHeroID)


}
public sh_on_sleep_end_fwd(id,attacker,Float:the_time,heroID){
	if(!is_user_alive(id)){
		return
	}
	if(!sh_get_user_has_hero(id,gHeroID)){
		return
	}
	new bool:self_started_sleep = (heroID==gHeroID)

	zenitsu_init_battery_aux(id,self_started_sleep)


}
bool:zenitsu_init_battery_aux(id, bool:self_triggered = false){
	
	static Float:fl_Origin[3]
	
	static Float:fl_TraceEnd[3], Float:fl_EndPos[3]
	pev(id, pev_origin, fl_Origin)
	fl_Origin[2] -= (pev(id, pev_flags) & FL_DUCKING) ? 36.0 : 18.0

	fl_TraceEnd[0] = fl_Origin[0] + 1500.0
	fl_TraceEnd[1] = fl_Origin[1] + 1500.0
	fl_TraceEnd[2] = fl_Origin[2] + 8000.0

	if ( get_pcvar_num(pcvar_zenitsu_emboldened_inside) <=0 ) {
		new ptr = create_tr2()
		engfunc(EngFunc_TraceLine, fl_Origin, fl_TraceEnd, IGNORE_MONSTERS, id, ptr)
		get_tr2(ptr, TR_vecEndPos, fl_EndPos)
		free_tr2(ptr)
		
		// Check if the victim is under the sky or not
		if ( engfunc(EngFunc_PointContents, fl_EndPos) == CONTENTS_SKY ){
			thunder_effects(fl_Origin)
		}
	}
	else{

		thunder_effects(fl_Origin)
	}
	

	g_zenitsu_charge_ammount[id] = max_macro(g_zenitsu_charge_ammount[id],cvar_val(float,pcvar_zenitsu_init_battery))
	if(!self_triggered){
		static user_name[128]
		get_user_name(id,user_name, charsmax(user_name))
		sh_chat_message(0, gHeroID,"The thunder warrior has been emboldened. %s is free from their shackles of despondency!",user_name)

	
	}
	sh_assign_id_bit(id, SH_ZENITSU_CHARGE_IS_ON, true)

}
public zenitsu_charge(id, uc_handle, seed)
{	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||sh_get_id_bit(id, SH_ZENITSU_HAS_STRUCK)||!sh_get_id_bit(id, SH_ZENITSU_CHARGE_IS_ON)){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)||sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||((sh_get_id_bit(id,SH_USER_IS_FLYING))&&!Get_BitVar(g_zenitsu_is_charging_mask,id))){
		if(Get_BitVar(g_zenitsu_is_charging_mask,id)){
			remove_user_flight_fx(id)
			
		}
		return FMRES_IGNORED
	}
	if(g_zenitsu_charge_ammount[id]<= cvar_val(float,pcvar_zenitsu_min_battery)){
		if(Get_BitVar(g_zenitsu_is_charging_mask,id)){
			remove_user_flight_fx(id)
			
		}
		return FMRES_IGNORED
	}
	static buttons,oldbuttons; 
	buttons = get_uc(uc_handle, UC_Buttons)
	
	oldbuttons = pev(id, pev_oldbuttons)


	if((buttons & IN_DUCK)&&(buttons &IN_JUMP))
	{ 
		if(!(oldbuttons & IN_DUCK)||!(oldbuttons &IN_JUMP)){

				engclient_cmd(id, "weapon_knife")
				trail(id,YELLOW,6,20)
				emit_sound(id, CHAN_AUTO, FLIGHT_IGNITION, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				get_uc(uc_handle,UC_ViewAngles,g_zenitsu_curr_charge_look_direction[id])
				
				if(!Get_BitVar(g_zenitsu_is_charging_mask,id)){
					Set_BitVar(g_zenitsu_is_charging_mask,id);
					sh_assign_id_bit(id,SH_USER_IS_FLYING, true)
					
				}
			
		}
		if(generate_int(0, 5,8) <3)
		{
			static Float:Velocity[3]
			velocity_by_aim(id, floatround(get_zenitsu_charge_speed(id)), Velocity)
		
			entity_set_vector(id, EV_VEC_velocity, Velocity)
		
		
		}
	}
	else{
		if(Get_BitVar(g_zenitsu_is_charging_mask,id)){
			remove_user_flight_fx(id)
			
		}
		
		
	}
	return FMRES_IGNORED;
}


public zenitsu_ele_cuerte_de_la_spada(pToucher, pTouched) {


	if (pev_valid(pToucher)!=2){
		
		return
	}
	if (!is_user_alive(pToucher)){

		return
	}

	if (pev_valid(pTouched)<1){
		
		return
	}

	if (!sh_get_user_has_hero(pToucher,gHeroID)||!sh_get_id_bit(pToucher, SH_ZENITSU_CHARGE_IS_ON)||
						!Get_BitVar(g_zenitsu_is_charging_mask, pToucher)||
						sh_get_id_bit(pToucher, SH_ZENITSU_HAS_STRUCK)){

		return
	
	}
	if(!is_user_alive(pTouched)){
		
		return
	}
	if(sh_get_id_bit(pTouched, SH_CONTROLLING_VEHICLE)){

		return
	}
	if(pTouched==pToucher){

		return
	}
	if(sh_clients_are_same_team(pToucher,pTouched)){

		return
	}

	remove_user_flight_fx(pToucher)


	emit_sound(pToucher, CHAN_WEAPON, SLICERISTA_HIT_MEAT_SFX, 1.0, 0.0, 0, PITCH_NORM)
	
	set_user_godmode(pTouched,0)

	new Float:damage_to_do = min_macro(g_zenitsu_charge_ammount[pToucher],get_zenitsu_impact_damage(pToucher))
	

	if(g_zenitsu_charge_ammount[pToucher]>0.0){
		g_zenitsu_charge_ammount[pToucher] = max_macro(0.0, g_zenitsu_charge_ammount[pToucher]-damage_to_do)

		if(!DEBUG){
			show_points_to_player(pToucher)
		}
	}

	sh_extra_damage(pTouched,pToucher,floatround(damage_to_do),
				MY_HIT_HEAD,
				_,_,_,_,
				SH_NEW_DMG_ENERGY_BLADE,
				generic_super_emo)

	if(!is_user_alive(pTouched)){
		new Float:vic_origin[3],Float:origin[3]
		entity_get_vector(pTouched,EV_VEC_origin,vic_origin)
		entity_get_vector(pToucher,EV_VEC_origin,origin)
		gross_kill_gibs_fx(pTouched,vic_origin,origin)

	}
	sh_assign_id_bit(pToucher, SH_ZENITSU_HAS_STRUCK, true)
	sh_assign_id_bit(pToucher, SH_ZENITSU_CHARGE_IS_ON, false)
	sh_assign_id_bit(pToucher, SH_ZENITSU_HAS_BEEN_SLEEP_TRIGGERED, false)
	g_zenitsu_charge_ammount[pToucher] = 0.0 


}


public sh_client_death(id){
	
	if(is_user_connected(id)&&sh_is_active()){
		if(sh_get_user_has_hero(id,gHeroID)){

			sh_assign_id_bit(id, SH_ZENITSU_CHARGE_IS_ON, false)
			sh_assign_id_bit(id, SH_ZENITSU_HAS_BEEN_SLEEP_TRIGGERED, false)
			g_zenitsu_charge_ammount[id] = 0.0 
		}
	}
	
}


public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage,  &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	
	new dmg_fwd_ret_id:result= DMG_FWD_PASS
	new bool:self_attack = (victim==attacker)

	if(CUSTOM_DMG_TYPE_IS_ELECTROSTATIC(new_dmg_type)){
		if(!sh_get_id_bit(victim, SH_ZENITSU_HAS_STRUCK) && sh_get_user_has_hero(victim,gHeroID) ){
			if(!self_attack||(allow_self_charge)){
				if((g_zenitsu_charge_ammount[victim]<cvar_val(float, pcvar_zenitsu_max_battery))){
					new Float:battery_left = max_macro(0.0,(cvar_val(float, pcvar_zenitsu_max_battery)-g_zenitsu_charge_ammount[victim]))
					
					new blocked_damage = floatround(min_macro(battery_left,(float(damage) * cvar_val(float, pcvar_zenitsu_pct_electrostatic_dmg_fill_battery))))
					
					new before_block_damage = damage

					damage -= min_macro(damage,blocked_damage)

					if(DEBUG){
						new Float:last_battery = g_zenitsu_charge_ammount[victim] 
						sh_chat_message(victim,gHeroID,"Battery left calculated: %0.2f Last battery: %0.2f Damage to be absorbed: %d Damage before block: %d Damage after block: %d", battery_left,last_battery,blocked_damage,before_block_damage, damage)
					
					}
					g_zenitsu_charge_ammount[victim] += float(blocked_damage)
					if(!DEBUG){
						show_points_to_player(victim)
					}
					

					if(!sh_get_id_bit(victim, SH_IS_SLEEPING)&&!sh_get_id_bit(victim, SH_ZENITSU_HAS_BEEN_SLEEP_TRIGGERED)&&!sh_get_id_bit(victim, SH_ZENITSU_HAS_STRUCK)&&!sh_get_id_bit(victim, SH_ZENITSU_CHARGE_IS_ON)&&(g_zenitsu_charge_ammount[victim]>cvar_val(float, pcvar_zenitsu_init_battery))){
						
						sh_assign_id_bit(victim, SH_ZENITSU_HAS_BEEN_SLEEP_TRIGGERED, true)
						sh_sleep_user(victim,attacker,5.0,-1)

					}
					result = DMG_FWD_HANDLED

				}
			}
		}
		if(sh_get_id_bit(attacker, SH_ZENITSU_CHARGE_IS_ON) && sh_get_user_has_hero(attacker,gHeroID)){
			
			if(!self_attack||allow_self_deplete){
				if(g_zenitsu_charge_ammount[attacker]>0.0){

					new Float:extra_damage_to_do = min_macro(g_zenitsu_charge_ammount[attacker],((float(damage) * get_zenitsu_electrostatic_damage_mult(attacker)) - float(damage)))
		
					damage += floatround(extra_damage_to_do)
					g_zenitsu_charge_ammount[attacker] -= extra_damage_to_do
					if(!DEBUG){
						show_points_to_player(attacker)
					}
					result = DMG_FWD_HANDLED
				}
			}
		
		}
	}
	return result
}

