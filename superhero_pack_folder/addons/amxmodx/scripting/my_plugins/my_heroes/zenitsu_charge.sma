#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS

#include "../my_include/superheromod.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "../my_include/my_author_header.inc"


#define PLUGIN "Zenitsu charge funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = -1

new g_zenitsu_has_touched_player_mask = 0
new g_zenitsu_is_charging_mask = 0
new g_zenitsu_was_charging_mask = 0
new g_zenitsu_is_glowing_mask = 0

new Float:g_zenitsu_curr_charge_look_direction[SH_MAXSLOTS+1][3]

public plugin_init(){
	

	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink")
	register_event("CurWeapon", "on_Knife_Weapon_Change", "be", "1=1")
	register_forward(FM_CmdStart, "zenitsu_charge")

	register_custom_touchable("player","zenitsu_ele_cuerte_de_la_spada",player_vector,1)


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

}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,FLIGHT_IGNITION );
	engfunc(EngFunc_PrecacheSound,SLICERISTA_HIT_MEAT_SFX)
}
public on_Knife_Weapon_Change(id)
{
	if ( !is_user_alive(id)||!sh_is_active()) return
	if(!sh_user_has_hero(id,gHeroID)) return
	if(Get_BitVar(g_zenitsu_is_charging_mask, id)&&!Get_BitVar(g_zenitsu_has_touched_player_mask, id)){
		engclient_cmd(id, "weapon_knife")
	}
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_user_has_hero(id,gHeroID)) {
	
		Assign_BitVar(g_zenitsu_has_touched_player_mask, id, false_for_macro);
		Assign_BitVar(g_zenitsu_is_charging_mask, id, false_for_macro);
		Assign_BitVar(g_zenitsu_was_charging_mask, id, false_for_macro);
	}
	return
}
remove_user_flight_fx(id){
	
	if(!sh_user_has_hero(id,gHeroID)||!is_user_connected(id)||!sh_is_active()) return
	
	trail(id,GREEN,0,0);
	Assign_BitVar(g_zenitsu_is_glowing_mask, id, false_for_macro);
	Assign_BitVar(g_zenitsu_is_charging_mask, id, false_for_macro);
	Assign_BitVar(g_zenitsu_was_charging_mask, id, false_for_macro);
	
	
}
public plugin_natives(){

	register_native("zenitsu_get_has_touched_player","_zenitsu_get_has_touched_player",0)
	
}
public _zenitsu_get_has_touched_player(iPlugin,iParams){
	
	new id= get_param(1)
	return Get_BitVar(g_zenitsu_has_touched_player_mask, id)

}
public zenitsu_charge(id, uc_handle, seed)
{	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)||!sh_user_has_hero(id,gHeroID)||Get_BitVar(g_zenitsu_has_touched_player_mask, id)||sh_get_stun(id)||!zenitsu_get_charge_mode_engaged(id)){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	static buttons

	
	Assign_BitVar(g_zenitsu_was_charging_mask, id, Get_BitVar(g_zenitsu_is_charging_mask,id));

	buttons = get_uc(uc_handle, UC_Buttons)

	Assign_BitVar(g_zenitsu_is_charging_mask, id, ((buttons & IN_DUCK)&&(buttons &IN_JUMP)))

	if(Get_BitVar(g_zenitsu_is_charging_mask, id))
	{
		if(!Get_BitVar(g_zenitsu_was_charging_mask, id)){

			engclient_cmd(id, "weapon_knife")
			trail(id,YELLOW,6,20)
			emit_sound(id, CHAN_AUTO, FLIGHT_IGNITION, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			get_uc(uc_handle,UC_ViewAngles,g_zenitsu_curr_charge_look_direction[id])
		}
		if(generate_int(0, FlameAndSoundRate) <3)
		{
			static Float:Velocity[3]
			velocity_by_aim(id, floatround(ZENITSU_CHARGE_SPEED), Velocity)
		
			entity_set_vector(id, EV_VEC_velocity, Velocity)
		
			if(!Get_BitVar(g_zenitsu_is_glowing_mask,id)){
				Assign_BitVar(g_zenitsu_is_glowing_mask,id, true_for_macro)
				
			}
		
        }
		return FMRES_SUPERCEDE;
    }
	else if(Get_BitVar(g_zenitsu_is_glowing_mask,id)){//avoids calling it too many times (heavy function)
		Assign_BitVar(g_zenitsu_is_glowing_mask,id, false_for_macro)
		remove_user_flight_fx(id)
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

	if (!sh_user_has_hero(pToucher,gHeroID)||!zenitsu_get_charge_mode_engaged(pToucher)||
						!Get_BitVar(g_zenitsu_is_charging_mask, pToucher)||
						Get_BitVar(g_zenitsu_has_touched_player_mask, pToucher)){

		return
	
	}
	if(!is_user_alive(pTouched)){
		
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
	sh_extra_damage(pTouched,pToucher,floatround(ZENITSU_DAMAGE),
				new_dmg_type_names[_:SH_NEW_DMG_IVE_STUDIED_THE_BLADE],
				MY_HIT_HEAD,
				_,_,_,_,
				SH_NEW_DMG_IVE_STUDIED_THE_BLADE,
				get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_IVE_STUDIED_THE_BLADE))

	if(!is_user_alive(pTouched)){
		new Float:vic_origin[3],Float:origin[3]
		entity_get_vector(pTouched,EV_VEC_origin,vic_origin)
		entity_get_vector(pToucher,EV_VEC_origin,origin)
		gross_kill_gibs_fx(pTouched,vic_origin,origin)

	}
	Assign_BitVar(g_zenitsu_has_touched_player_mask,pToucher, true_for_macro)
	zenitsu_set_charge_mode_engaged(pToucher,0)

}


public sh_client_death(id){
	
	if(is_user_connected(id)&&sh_is_active()){
		if(sh_user_has_hero(id,gHeroID)){

			zenitsu_set_charge_mode_engaged(id,0)
		}
	}
	
}
