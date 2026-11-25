#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_RESOURCE_ALIASES
#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_needle_funcs.inc"


#define PLUGIN "Superhero yakui mk2 needles"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new fx_id:curr_needle_fx[SH_MAXSLOTS+1]
new needle_on_mask = 0


new mode_change_button_pressed_mask = 0;

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_Needle",_,true)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Needle_Swing",1,true)
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	register_forward(FM_CmdStart, "player_prethink_yakui_weapon");
}

public plugin_natives(){


	register_native( "gatling_set_needle","_gatling_set_needle")
	register_native( "gatling_get_needle","_gatling_get_needle")
	register_native( "gatling_get_needle_fx","_gatling_get_needle_fx")
	register_native( "gatling_needle_cycle_fx","_gatling_needle_cycle_fx")

}//----------------------------------------------------------------------------------------------
public player_prethink_yakui_weapon(id, uc_handle)
{


	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if ( !is_user_alive(id) ||!sh_get_user_has_hero(id, gHeroID) ) return FMRES_IGNORED;

	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id, SH_USER_IS_FLYING)) return FMRES_IGNORED

	static button;
	button= get_uc(uc_handle, UC_Buttons);

	static prev_button;
	prev_button = entity_get_int(id, EV_INT_oldbuttons)


	if((button & IN_ALT1)&&!(prev_button & IN_ALT1)){

		if(!Get_BitVar(mode_change_button_pressed_mask, id)){
			new wpnid=get_user_weapon(id)
			if(wpnid==CSW_KNIFE){
				Set_BitVar(mode_change_button_pressed_mask, id);
				sh_chat_message(id,gHeroID,"Mode changed")
				Assign_BitVar(needle_on_mask,id,!Get_BitVar(needle_on_mask,id))
			}
		}
	}
	else{

		UnSet_BitVar(mode_change_button_pressed_mask, id);
	}
	return FMRES_IGNORED;
}
public weaponChange(id)
{
	if (!sh_get_user_has_hero(id,gHeroID) ||!sh_is_active()) return PLUGIN_CONTINUE
	
	new wpnid = read_data(2)
	if ((wpnid == CSW_KNIFE)&&Get_BitVar(needle_on_mask, id)) {
		entity_set_string(id, EV_SZ_viewmodel, NEEDLE_V_MODEL)
		if(!sh_get_id_bit(id, SH_IS_SLEEPING)){
			curr_needle_fx[id]=sh_gen_effect()
			notify_fx_user(id)
		}
	}
	else if(Get_BitVar(needle_on_mask, id)){
		kill_trails_on_user(id)
	}
	return PLUGIN_CONTINUE
	
}
notify_fx_user(id){

	static needle_color[3];
	static needle_name[128]
	sh_get_fx_color_name(curr_needle_fx[id],needle_color,needle_name);
	sh_screen_fade(id, 0.1, 0.9, needle_color[0], needle_color[1], needle_color[2], 50)
	kill_trails_on_user(id)
	playertrail(id)
	if(!is_user_bot(id)){
		sh_chat_message(id,gHeroID,"Effect switched! On next swing, you will inject: %s fluid",needle_name)
	}
}
public Ham_Needle_Swing(weapon_ent)
{
	if(pev_valid(weapon_ent)!=2){

		server_print("Yakui needle hook to weapon faulty???");
		return HAM_IGNORED
	}

	if ( !sh_is_active() ) return HAM_IGNORED

	static owner; owner = get_pdata_cbase(weapon_ent, m_pPlayer,XO_WEAPON)

	if ( !is_user_alive(owner)) {
		return HAM_IGNORED
	}
	if(!sh_get_user_has_hero(owner,gHeroID) ){

		return HAM_IGNORED
	}
	if(!Get_BitVar(needle_on_mask, owner)){

		return HAM_IGNORED
	}
	curr_needle_fx[owner]=sh_gen_effect()
	notify_fx_user(owner)
	return HAM_IGNORED
}
public Ham_Needle(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}

	if(attacker == id) return HAM_IGNORED 
	
	if ( !sh_is_active()) return HAM_IGNORED
	
	if ( !is_user_alive(attacker)) {
		return HAM_IGNORED
	}
	if(!sh_get_user_has_hero(attacker,gHeroID) ){

		return HAM_IGNORED
	}
	if(!Get_BitVar(needle_on_mask, attacker)){

		return HAM_IGNORED
	}
	new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	if((cs_get_user_team(id)==att_team)) return HAM_IGNORED
	
	if((weapon==CSW_KNIFE)&&Get_BitVar(needle_on_mask, attacker)){
		new button = pev(attacker, pev_button);
		new bool:stabbing;
		if(button & IN_ATTACK2){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
		}
		if(button & IN_ATTACK){
			
			button &= ~IN_ATTACK;
			stabbing=false;
		}
		damage=1.0
		SetHamParamFloat(4, damage);
		if(stabbing){

			make_effect(id,attacker,5.0,gHeroID,curr_needle_fx[attacker],false)
		}
	}
	
	return HAM_IGNORED
}
public playertrail(pid)
{
	if (is_user_alive(pid))
	{
		trail(pid,FX_COLOR_OFFSET(curr_needle_fx[pid]),10,5,40)
	}
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	gHeroID = yakui_get_hero_id()
	
}
public _gatling_get_needle(iPlugin,iParams){
	new id=get_param(1)
	
	return Get_BitVar(needle_on_mask, id);


}
public fx_id:_gatling_get_needle_fx(iPlugin,iParams){
	new id=get_param(1)
	
	return curr_needle_fx[id]


}
public _gatling_needle_cycle_fx(iPlugin,iParams){
	new id=get_param(1)

	if ( !is_user_alive(id)) {
		return
	}
	if(!sh_get_user_has_hero(id,gHeroID) ){

		return
	}
	if(!Get_BitVar(needle_on_mask, id)){

		return
	}

}
public _gatling_set_needle(iPlugin,iParams){
	new id=get_param(1)
	new value_to_set=get_param(2)
	if(value_to_set){
		weaponChange(id)
	
	}
	else if (is_user_alive(id))
	{
		kill_trails_on_user(id)
	}
	Assign_BitVar(needle_on_mask, id, value_to_set);


}

public sh_client_spawn(id){

	UnSet_BitVar(mode_change_button_pressed_mask, id);
}
public plugin_precache()
{
engfunc(EngFunc_PrecacheModel,NEEDLE_V_MODEL)

}
