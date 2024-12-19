#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_needle_funcs.inc"


#define PLUGIN "Superhero yakui mk2 needles"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new curr_needle_fx[SH_MAXSLOTS+1]
new needle_on[SH_MAXSLOTS+1]

new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(curr_needle_fx,0,SH_MAXSLOTS+1)
	arrayset(needle_on,0,SH_MAXSLOTS+1)
	RegisterHam(Ham_TakeDamage, "player", "Ham_Needle")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Needle_Swing",1)
	register_event("CurWeapon", "weaponChange", "be", "1=1")
}

public plugin_natives(){


	register_native( "gatling_set_needle","_gatling_set_needle",0)
	register_native( "gatling_get_needle","_gatling_get_needle",0)

}
public weaponChange(id)
{
	if ( !is_user_alive(id)||!gatling_get_has_yakui(id) ||!shModActive()) return PLUGIN_CONTINUE
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ((wpnid == CSW_KNIFE)&&gatling_get_needle(id)) {
		entity_set_string(id, EV_SZ_viewmodel, NEEDLE_V_MODEL)
		curr_needle_fx[id]=sh_gen_effect()
		notify_fx_user(id)
	}
	return PLUGIN_CONTINUE
	
}
notify_fx_user(id){

	new needle_color[4];
	new needle_name[128]
	sh_get_fx_color_name(curr_needle_fx[id],needle_color,needle_name);
	sh_screen_fade(id, 0.1, 0.9, needle_color[0], needle_color[1], needle_color[2], 50)
	playertrail(id,needle_color)
	sh_chat_message(id,gatling_get_hero_id(),"Effect switched! On next swing, you will inject: %s fluid",needle_name)

}
public Ham_Needle_Swing(weapon_ent)
{
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)

	if ( client_isnt_hitter(owner)||!gatling_get_needle(owner)) {
		return HAM_IGNORED
	}
	curr_needle_fx[owner]=sh_gen_effect()
	notify_fx_user(owner)
	return HAM_IGNORED
}
public Ham_Needle(id, idinflictor, attacker, Float:damage, damagebits)
{
	if ( !sh_is_active()) return HAM_IGNORED
	
	if ( client_isnt_hitter(attacker)) return HAM_IGNORED
	
	new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)
	
	new CsTeams:att_team=cs_get_user_team(attacker)
	if((cs_get_user_team(id)==att_team)) return HAM_IGNORED
	
	if((weapon==CSW_KNIFE)&&gatling_get_needle(attacker)){
		new button = pev(attacker, pev_button);
		new bool:slashing;
		new bool:stabbing;
		if(button & IN_ATTACK2){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
			slashing=false
		}
		if(button & IN_ATTACK){
			
			button &= ~IN_ATTACK;
			stabbing=false;
			slashing=true
		}
		damage=1.0
		SetHamParamFloat(4, damage);
		if(stabbing){
			make_effect_direct(id,attacker,curr_needle_fx[attacker],gatling_get_hero_id())
			
		}
		/*curr_needle_fx[attacker]=sh_gen_effect()
		notify_fx_user(attacker)*/
	}
	
	return HAM_IGNORED
}
public playertrail(pid, parm[])
{
	if (client_hittable(pid))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_KILLBEAM)	// TE_KILLBEAM
		write_short(pid)
		message_end()
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(pid) // entity
		write_short(m_trail)  // model
		write_byte( 10 )       // life
		write_byte( 5 )        // width
		write_byte(parm[0])			// r, g, b
		write_byte(parm[1])		// r, g, b
		write_byte(parm[2])			// r, g, b
		write_byte(parm[3]) // brightness

		message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
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

/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_hittable(vic_userid){

return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)

}

client_isnt_hitter(gatling_user){
	new bool:result=(!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)
	if(result) return true
	
	return !gatling_get_has_yakui(gatling_user)
	
}


public plugin_precache()
{
m_trail = precache_model("sprites/smoke.spr")

precache_model(NEEDLE_V_MODEL)

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
