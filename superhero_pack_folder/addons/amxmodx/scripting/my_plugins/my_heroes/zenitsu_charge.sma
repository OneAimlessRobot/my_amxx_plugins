#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "../my_include/my_author_header.inc"


#define PLUGIN "Zenitsu charge funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_zenitsu_has_touched_player[SH_MAXSLOTS+1]
new g_zenitsu_is_charging[SH_MAXSLOTS+1]
new g_zenitsu_was_charging[SH_MAXSLOTS+1]
new Float:g_zenitsu_curr_charge_look_direction[SH_MAXSLOTS+1][3]
new g_zenitsu_is_glowing[SH_MAXSLOTS+1]

public plugin_init(){
	

	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("DeathMsg","on_death_cleanup","a")
	register_event("ResetHUD","zenitsu_newRound","b")
	register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink")
	register_event("CurWeapon", "on_Knife_Weapon_Change", "be", "1=1")
	register_forward(FM_CmdStart, "zenitsu_charge")

}
public Fwd_PlayerPreThink(id)
{
	if(!client_hittable(id)){
		return FMRES_IGNORED
	}

	if(!g_zenitsu_is_charging[id]){
		return FMRES_IGNORED
	}
	entity_set_vector( id, EV_VEC_angles, g_zenitsu_curr_charge_look_direction[id] )
	entity_set_int( id, EV_INT_fixangle, 1 )
	return FMRES_IGNORED
}

public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,FLIGHT_IGNITION );
	engfunc(EngFunc_PrecacheSound,SLICERISTA_HIT_MEAT_SFX)
}
public on_Knife_Weapon_Change(id)
{
	if ( !client_hittable(id)||!shModActive()) return
	if(!sh_user_has_hero(id,zenitsu_get_hero_id())) return
	if(g_zenitsu_is_charging[id]&&!g_zenitsu_has_touched_player[id]){
		engclient_cmd(id, "weapon_knife")
	}
}

//----------------------------------------------------------------------------------------------
public zenitsu_newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}

	if ( sh_user_has_hero(id,zenitsu_get_hero_id())) {
		
		g_zenitsu_has_touched_player[id]=0
		g_zenitsu_was_charging[id]=g_zenitsu_is_charging[id]=0
	}
	return PLUGIN_CONTINUE
}
remove_user_flight_fx(id){
	
	if(!sh_user_has_hero(id,zenitsu_get_hero_id())||!is_user_connected(id)||!sh_is_active()) return
	
	trail(id,GREEN,0,0)
	g_zenitsu_is_glowing[id]=0;
	g_zenitsu_was_charging[id]=g_zenitsu_is_charging[id]=0
	
	
}
public plugin_natives(){

	register_native("zenitsu_get_has_touched_player","_zenitsu_get_has_touched_player",0)
	
}
public _zenitsu_get_has_touched_player(iPlugin,iParams){
	
	new id= get_param(1)
	return g_zenitsu_has_touched_player[id]

}
public zenitsu_charge(id, uc_handle, seed)
{
	if(!sh_user_has_hero(id,zenitsu_get_hero_id())||!client_hittable(id)||g_zenitsu_has_touched_player[id]||sh_get_stun(id)||!zenitsu_get_charge_mode_engaged(id)){
			return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	static buttons

	g_zenitsu_was_charging[id]=g_zenitsu_is_charging[id]
	buttons = get_uc(uc_handle, UC_Buttons)
	g_zenitsu_is_charging[id]=((buttons & IN_DUCK)&&(buttons &IN_JUMP))
	
	if(g_zenitsu_is_charging[id])
	{
		if(!g_zenitsu_was_charging[id]){

			engclient_cmd(id, "weapon_knife")
			trail(id,YELLOW,1,10)
			emit_sound(id, CHAN_AUTO, FLIGHT_IGNITION, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			get_uc(uc_handle,UC_ViewAngles,g_zenitsu_curr_charge_look_direction[id])
		}
		if(generate_int(0, FlameAndSoundRate) <3)
		{
			static Float:Velocity[3]
			velocity_by_aim(id, floatround(ZENITSU_CHARGE_SPEED), Velocity)
		
			entity_set_vector(id, EV_VEC_velocity, Velocity)
		
			if(!g_zenitsu_is_glowing[id]){
				g_zenitsu_is_glowing[id]=1
				
			}
		
        }
		return FMRES_SUPERCEDE;
    }
	else if(g_zenitsu_is_glowing[id]){//avoids calling it too many times (heavy function)
		g_zenitsu_is_glowing[id]=0;
		remove_user_flight_fx(id)
	}
	return FMRES_IGNORED;
}


public vexd_pfntouch(pToucher, pTouched) {


	if (pev_valid(pToucher)!=2){
		
		return
	}
	if (!client_hittable(pToucher)){

		return
	}
	if (!sh_user_has_hero(pToucher,zenitsu_get_hero_id())||!zenitsu_get_charge_mode_engaged(pToucher)||!g_zenitsu_is_charging[pToucher]||g_zenitsu_has_touched_player[pToucher]){

		return
	
	}
	if(!client_hittable(pTouched)){
		
		return
	}
	if(pTouched==pToucher){

		return
	}
	if(sh_clients_are_same_team(pToucher,pTouched)){

		return
	}

	remove_user_flight_fx(pToucher)

	new opp_health=get_user_health(pTouched);

	emit_sound(pToucher, CHAN_WEAPON, SLICERISTA_HIT_MEAT_SFX, 1.0, 0.0, 0, PITCH_NORM)
	
	sh_extra_damage(pTouched,pToucher,floatround(ZENITSU_DAMAGE),new_dmg_type_names[_:SH_NEW_DMG_IVE_STUDIED_THE_BLADE],1,_,_,_,_,_,
				SH_NEW_DMG_IVE_STUDIED_THE_BLADE,
				get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_IVE_STUDIED_THE_BLADE))

	if((floatround(ZENITSU_DAMAGE)>=opp_health)&&!is_user_alive(pTouched)){
		new Float:vic_origin[3],Float:origin[3]
		entity_get_vector(pTouched,EV_VEC_origin,vic_origin)
		entity_get_vector(pToucher,EV_VEC_origin,origin)
		gross_kill_gibs_fx(pTouched,vic_origin,origin)

	}
	g_zenitsu_has_touched_player[pToucher]=1
	zenitsu_set_charge_mode_engaged(pToucher,0)

}


public on_death_cleanup()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		if(sh_user_has_hero(id,zenitsu_get_hero_id())){

			zenitsu_set_charge_mode_engaged(id,0)
		}
	}
	
}
