#include "../my_include/superheromod.inc"
#include <reapi>
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_needle_funcs.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"


#define PLUGIN "Superhero yakui mk2 needles"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new curr_needle_fx[SH_MAXSLOTS+1]
new needle_on[SH_MAXSLOTS+1]


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(curr_needle_fx,0,SH_MAXSLOTS+1)
	arrayset(needle_on,0,SH_MAXSLOTS+1)
	RegisterHam(Ham_TakeDamage, "player", "Ham_Needle",_,true)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Needle_Swing",1,true)
	register_event("CurWeapon", "weaponChange", "be", "1=1")
}

public plugin_natives(){


	register_native( "gatling_set_needle","_gatling_set_needle",0)
	register_native( "gatling_get_needle","_gatling_get_needle",0)
	register_native( "gatling_get_needle_fx","_gatling_get_needle_fx",0)
	register_native( "gatling_needle_cycle_fx","_gatling_needle_cycle_fx",0)

}
public weaponChange(id)
{
	if ( !is_user_alive(id)||!sh_user_has_hero(id,gatling_get_hero_id()) ||!shModActive()) return PLUGIN_CONTINUE
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ((wpnid == CSW_KNIFE)&&gatling_get_needle(id)) {
		entity_set_string(id, EV_SZ_viewmodel, NEEDLE_V_MODEL)
		if(!sh_get_user_is_asleep(id)){
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
		sh_chat_message(id,gatling_get_hero_id(),"Effect switched! On next swing, you will inject: %s fluid",needle_name)
	}
}
public Ham_Needle_Swing(weapon_ent)
{
	if(pev_valid(weapon_ent)!=2){

		server_print("Yakui needle hook to weapon faulty???");
		return HAM_IGNORED
	}

	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_member(weapon_ent, m_pPlayer)

	if ( !client_hittable(owner)) {
		return HAM_IGNORED
	}
	if(!sh_user_has_hero(owner,gatling_get_hero_id()) ){

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
	
	if ( !client_hittable(attacker)) {
		return HAM_IGNORED
	}
	if(!sh_user_has_hero(attacker,gatling_get_hero_id()) ){

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

			make_effect(id,attacker,gatling_get_hero_id(),curr_needle_fx[attacker],false)
		}
	}
	
	return HAM_IGNORED
}
public playertrail(pid)
{
	if (client_hittable(pid))
	{
		trail(pid,FX_COLOR_OFFSET+curr_needle_fx[pid],10,5,40)
	}
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
}
public _gatling_get_needle(iPlugin,iParams){
	new id=get_param(1)
	
	return needle_on[id];


}
public _gatling_get_needle_fx(iPlugin,iParams){
	new id=get_param(1)
	
	return curr_needle_fx[id]


}
public _gatling_needle_cycle_fx(iPlugin,iParams){
	new id=get_param(1)

	if ( !client_hittable(id)) {
		return
	}
	if(!sh_user_has_hero(id,gatling_get_hero_id()) ){

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
	else if (client_hittable(id))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_KILLBEAM)	// TE_KILLBEAM
		write_short(id)
		message_end()
	}
	needle_on[id]=value_to_set


}


public plugin_precache()
{
engfunc(EngFunc_PrecacheModel,NEEDLE_V_MODEL)

}
