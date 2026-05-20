#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "shinobu_knife/shinobu_usp_funcs.inc"

new gHeroID = 0
#define AMMO_TYPE_45ACP 6
#define START_MAX_AMMO 0

#define MAX_AMMO 16

#define PLUGIN "Shinobu usp funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new g_shinobu_curr_ammo[SH_MAXSLOTS+1]


new dmg_source_name_short_shinobu_pistol[SAFE_BUFFER_SIZE+1]="shinobu_usp"
new dmg_source_name_long_shinobu_pistol[SAFE_BUFFER_SIZE+1]="shinobu_usp"
new custom_weapon_shinobu_pistol

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_CmdStart,"fw_Shut_Shinobu_Usp_Up")
	RegisterHam(Ham_TraceAttack,"player","trace_shinobu_usp",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[SHINOBU_WEAPON_CLASSID], "track_shinobu_usp_ammo",_,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	register_event("CurWeapon", "on_Usp_Weapon_Change", "be", "1=1")
	
    
	
}
public plugin_cfg(){

	gHeroID = shinobu_get_hero_id()

	custom_weapon_shinobu_pistol=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_shinobu_pistol,
								dmg_source_name_long_shinobu_pistol,
								0)
}
public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	
	if(!is_user_alive(player)){
		return FMRES_IGNORED
	}

	if(!sh_user_has_hero(player,gHeroID)){

		return FMRES_IGNORED
	}
	new weapon = get_user_weapon(player);
	if(weapon!=SHINOBU_WEAPON_CLASSID){
		return FMRES_IGNORED
	}
	
	new pEntity = get_pdata_cbase(player, m_pActiveItem, OFFSET_LINUX_PLAYER)
	if(is_valid_ent(pEntity)){

		new is_silenced=cs_get_weapon_silen(pEntity)
		if(!is_silenced){
			set_cd(cd, CD_flNextAttack, get_gametime()+9999.0)
			return FMRES_HANDLED
		}
	}	
	return FMRES_IGNORED
}
public plugin_natives(){


	register_native("shinobu_unweapons","_shinobu_unweapons",0)
	register_native("shinobu_weapons","_shinobu_weapons",0)
}

public client_disconnected(id){

	g_shinobu_curr_ammo[id]=0

}
public _shinobu_weapons(iPlugins, iParam){

	new id=get_param(1)

	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}
	if(sh_user_has_hero(id,gHeroID)){

		if(!user_has_weapon(id,SHINOBU_WEAPON_CLASSID)){
			sh_give_weapon(id,SHINOBU_WEAPON_CLASSID,true)
		}
		g_shinobu_curr_ammo[id]=START_MAX_AMMO
	}
	

}
public _shinobu_unweapons(iPlugins, iParam){

	new id=get_param(1)
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}
	if((cs_get_user_team(id)!=CS_TEAM_CT)&&user_has_weapon(id,SHINOBU_WEAPON_CLASSID)){

		sh_drop_weapon(id,SHINOBU_WEAPON_CLASSID,true)
	}
}


public on_Usp_Weapon_Change(id)
{
	if ( !is_user_alive(id)||!sh_is_active()) return
	if(!sh_user_has_hero(id,gHeroID)) return

	new  wpnid = get_user_weapon(id)

	if(wpnid==SHINOBU_WEAPON_CLASSID){
		if(cs_get_user_bpammo(id,SHINOBU_WEAPON_CLASSID)>g_shinobu_curr_ammo[id]){
			cs_set_user_bpammo(id,SHINOBU_WEAPON_CLASSID,g_shinobu_curr_ammo[id])
		}
	}

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	shinobu_weapons(id)
}
public track_shinobu_usp_ammo(ent)
{
	if(!is_valid_ent(ent)) return HAM_IGNORED

	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}

	if( !sh_user_has_hero(id,gHeroID) ) return HAM_IGNORED

	g_shinobu_curr_ammo[id] = -1
		
	static BPAmmo; BPAmmo = cs_get_user_bpammo(id, SHINOBU_WEAPON_CLASSID)
		
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}

	g_shinobu_curr_ammo[id] = BPAmmo
	
	return HAM_HANDLED
}

public trace_shinobu_usp(this, idattacker, Float:damage, Float:direction[3], traceresult, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}
	if ( !sh_is_active()) return HAM_IGNORED
	
	if ( !is_user_alive(idattacker)) {
		return HAM_IGNORED
	}
	if(!sh_user_has_hero(idattacker,gHeroID)){

		return HAM_IGNORED
	}
	new CsTeams:att_team=cs_get_user_team(idattacker)
	if((cs_get_user_team(this)==att_team)) return HAM_IGNORED
	new ammo,weapon=get_user_weapon(idattacker,_,ammo)
	if(weapon==SHINOBU_WEAPON_CLASSID){
		static Float:speed,Float:stun_time;
		new hitzone=get_tr2(traceresult,TR_Hitgroup)
		new is_headshot=(hitzone==HIT_HEAD)
		new target_is_marked_by_weapon_owner=(shinobu_get_user_tagged_player(idattacker)==this)
		if(target_is_marked_by_weapon_owner){
			
			stun_time=(is_headshot?3.0:1.0)
			speed=(is_headshot?40.0:220.0)
			sh_set_stun(this,stun_time,speed)
			
			damage*=(is_headshot?2.5:1.5)
			ammo+=(is_headshot?3:1)
			g_shinobu_curr_ammo[idattacker] = ammo
			g_shinobu_curr_ammo[idattacker] = min(g_shinobu_curr_ammo[idattacker],MAX_AMMO)
			cs_set_user_bpammo(idattacker,SHINOBU_WEAPON_CLASSID,g_shinobu_curr_ammo[idattacker])
			
			sh_extra_damage( this, idattacker, floatround(damage), dmg_source_name_long_shinobu_pistol,
								my_hitpoint_enum:hitzone,
								_,_,_,_,
								SH_NEW_DMG_SUPER_BULLET,
								custom_weapon_shinobu_pistol)
			
		}
		else{
			damage=0.0
			SetHamParamFloat(3,damage)
		}
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_Shut_Shinobu_Usp_Up(id, uc_handle)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if (!is_user_alive(id)){
		return FMRES_IGNORED
	}
	if(get_user_weapon(id) != SHINOBU_WEAPON_CLASSID){
		return FMRES_IGNORED
	}
	if(!sh_user_has_hero(id,gHeroID)){

		return FMRES_IGNORED
	}
	new button = get_uc(uc_handle, UC_Buttons);
	if(button & IN_ATTACK)
	{
		new weapon_ent = get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER)
		new is_silenced=cs_get_weapon_silen(weapon_ent)
		if(!is_silenced){
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			return FMRES_SUPERCEDE
		}
		
	}
	return FMRES_IGNORED
}
