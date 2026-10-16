#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_needle_funcs.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"


#define PLUGIN "Superhero yakui mk2 needles"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = -1

new fx_id:curr_needle_fx[SH_MAXSLOTS+1]
new needle_on_mask = 0


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_Needle",_,true)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Needle_Swing",1,true)
	register_event("CurWeapon", "weaponChange", "be", "1=1")
}

public plugin_natives(){


	register_native( "gatling_set_needle","_gatling_set_needle")
	register_native( "gatling_get_needle","_gatling_get_needle")
	register_native( "gatling_get_needle_fx","_gatling_get_needle_fx")
	register_native( "gatling_needle_cycle_fx","_gatling_needle_cycle_fx")

}
public weaponChange(id)
{
	if (!sh_get_user_has_hero(id,gHeroID) ||!sh_is_active()) return PLUGIN_CONTINUE
	
	new wpnid = read_data(2)
	if ((wpnid == CSW_KNIFE)&&gatling_get_needle(id)) {
		entity_set_string(id, EV_SZ_viewmodel, NEEDLE_V_MODEL)
		if(!sh_get_id_bit(id, SH_IS_SLEEPING)){
			gatling_needle_cycle_fx(id)
		}
	}
	return PLUGIN_CONTINUE
	
}
notify_fx_user(id){

	static needle_color[3];
	static needle_name[128]
	sh_get_fx_color_name(curr_needle_fx[id],needle_color,needle_name);
	sh_screen_fade(id, 0.1, 0.9, needle_color[0], needle_color[1], needle_color[2], 50)
	trail(id,RED,0,0)
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
	if(!gatling_get_needle(owner)){

		return HAM_IGNORED
	}
	curr_needle_fx[owner]=sh_gen_effect()
	notify_fx_user(owner)
	return HAM_IGNORED
}
public Ham_Needle(id, idinflictor, attacker, Float:damage, damagebits)
{
	if ( !sh_is_active()) return HAM_IGNORED
	
	if ( !is_user_alive(attacker)) {
		return HAM_IGNORED
	}
	if(!sh_get_user_has_hero(attacker,gHeroID) ){

		return HAM_IGNORED
	}
	if(!gatling_get_needle(attacker)){

		return HAM_IGNORED
	}
	new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	if((cs_get_user_team(id)==att_team)) return HAM_IGNORED
	
	if((weapon==CSW_KNIFE)&&gatling_get_needle(attacker)){
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

			make_effect(id,attacker,gHeroID,curr_needle_fx[attacker],false)
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
	gHeroID = gatling_get_hero_id()
	
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
	if(!gatling_get_needle(id)){

		return
	}

	curr_needle_fx[id]=sh_gen_effect()
	notify_fx_user(id)
}
public _gatling_set_needle(iPlugin,iParams){
	new id=get_param(1)
	new value_to_set=get_param(2)
	if(value_to_set){
		weaponChange(id)
	
	}
	else if (is_user_alive(id))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_KILLBEAM)	// TE_KILLBEAM
		write_short(id)
		message_end()
	}
	Assign_BitVar(needle_on_mask, id, value_to_set);


}


public plugin_precache()
{
engfunc(EngFunc_PrecacheModel,NEEDLE_V_MODEL)

}
