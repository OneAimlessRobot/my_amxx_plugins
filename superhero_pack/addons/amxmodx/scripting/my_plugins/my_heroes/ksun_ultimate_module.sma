
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_ultimate.inc"



new Float:ksun_health_to_supply_ratio,
	ksun_supply_capacity;
	
new Float:ksun_dmg_absorption_index

new Float:ksun_ultimate_fire_rate_mult
new Float:ksun_ultimate_reload_rate_mult

new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]


new g_player_supply_amount[SH_MAXSLOTS+1]

new g_player_in_ultimate[SH_MAXSLOTS+1]


new m_spriteTexture
new hud_sync_ultimate

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun supply","1.1","MilkChanThaGOAT")
	
	register_cvar("ksun_ultimate_fire_rate_mult", "3.0" )
	register_cvar("ksun_ultimate_reload_rate_mult", "3.0" )
	register_cvar("ksun_health_to_supply_ratio", "1.0" )
	register_cvar("ksun_dmg_absorption_index", "1.0" )
	register_cvar("ksun_supply_capacity", "1000" )
	RegisterHam(Ham_TakeDamage, "player", "ksun_ultimate_damage_hook",_,true)
	register_event("DeathMsg","death","a")
	register_event("CurWeapon", "ksun_rifle_laser", "be", "1=1", "3>0")
	
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	register_logevent("ev_SendAudio", 2, "1=Round_End")
	register_logevent("ev_SendAudio", 2, "1&Restart_Round_")
	hud_sync_ultimate=CreateHudSyncObj()
	
	new wpnName[32]
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{
		if ( !(FAST_RELOAD_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
		{
			RegisterHam(Ham_Item_PostFrame, wpnName, "Item_PostFrame_Post", 1,true)
		}
	}
	
}

public plugin_natives(){
	
	
	
	
	register_native("ksun_set_player_supply_points","_ksun_set_player_supply_points",0)
	register_native("ksun_get_player_supply_points","_ksun_get_player_supply_points",0)
	
	register_native("ksun_dec_player_supply_points","_ksun_dec_player_supply_points",0)
	register_native("ksun_inc_player_supply_points","_ksun_inc_player_supply_points",0)
	
	register_native("ksun_player_is_in_ultimate","_ksun_player_is_in_ultimate",0)
	
	
	register_native("ksun_player_is_ultimate_ready","_ksun_player_is_ultimate_ready",0)
	
	
	register_native("ksun_player_engage_ultimate","_ksun_player_engage_ultimate",0)
	
	register_native("ksun_unultimate_user","_ksun_unultimate_user",0)
	
}

public Item_PostFrame_Post(iEnt)
{    
	if(pev_valid(iEnt)!=2){
		return HAM_IGNORED
	}
	new id = entity_get_edict(iEnt, EV_ENT_owner);
	if(!client_hittable(id)){
		return HAM_IGNORED
	}
	if (!sh_is_active()||!spores_has_ksun(id)||!ksun_player_is_in_ultimate(id)){
		return HAM_IGNORED
	}
	if( get_pdata_int(iEnt, m_fInReload, 4) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_pdata_int(iEnt, m_iId, 4)], ksun_ultimate_reload_rate_mult)
		set_pdata_float(get_pdata_cbase(iEnt, m_pPlayer, 4), m_flNextAttack, fDelay, 5)
		set_pdata_float(iEnt, m_flTimeWeaponIdle, fDelay + 0.5, 4)
	}
	return HAM_IGNORED
}
public ksun_ultimate_damage_hook(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !sh_is_active() || !client_hittable(id) || !client_hittable(attacker)) return HAM_IGNORED

if(!spores_has_ksun(id)&&!spores_has_ksun(attacker)) return HAM_IGNORED



new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)


if(spores_has_ksun(id)&&ksun_player_is_in_ultimate(id)){

	new Float:dmgSnatched= damage*ksun_dmg_absorption_index
	
	new Float:newDamage=damage- dmgSnatched
	SetHamParamFloat(4, newDamage);
	sh_chat_message(id,spores_ksun_hero_id(),"You are in ultimate. You absorbed %0.2f damage from this attack.",dmgSnatched)
		

}
if(spores_has_ksun(attacker)&&ksun_player_is_in_ultimate(attacker)){

	
	if(weapon==CSW_M4A1){
		new Float:dmgAdded= damage*ksun_dmg_absorption_index
		new Float:newDamage=damage+ dmgAdded
		SetHamParamFloat(4, newDamage);
		sh_chat_message(attacker,spores_ksun_hero_id(),"You are in ultimate. You dealt %0.2f more damage from your rifle!",dmgAdded)
	}
}
return HAM_IGNORED

}	

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	ksun_health_to_supply_ratio= get_cvar_float("ksun_health_to_supply_ratio")
	ksun_dmg_absorption_index= get_cvar_float("ksun_dmg_absorption_index")
	ksun_supply_capacity= get_cvar_num("ksun_supply_capacity")
	ksun_ultimate_fire_rate_mult=get_cvar_float("ksun_ultimate_fire_rate_mult")
	ksun_ultimate_reload_rate_mult=get_cvar_float("ksun_ultimate_reload_rate_mult")
	
}
calculate_untaxed_health_to_filtered_supply(supply_parcel){

	return max(0,floatround(floatmul(float(supply_parcel),ksun_health_to_supply_ratio)))
	
}
public ev_SendAudio(){
	
	spores_clear()
	if(!sh_is_active()) return PLUGIN_CONTINUE
	
	// Reset the cooldown on round end, to start fresh for a new round
	for (new id = 1; id <= SH_MAXSLOTS; id++) {
		if(is_user_connected(id)){
			unultimate_user(id,(ksun_get_when_reset_spores()&reset_on_new_round))
			
		}
	}
	return PLUGIN_HANDLED
}
public _ksun_set_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	g_player_supply_amount[id]= max(0,min(ksun_supply_capacity,value))
	
}
public _ksun_dec_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	g_player_supply_amount[id]= max(0,g_player_supply_amount[id]-value)
	
}
public _ksun_inc_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	new value=get_param(2)
	
	g_player_supply_amount[id]= max(0,
									min(ksun_supply_capacity,g_player_supply_amount[id]+
									calculate_untaxed_health_to_filtered_supply(value)))
	
}
public _ksun_get_player_supply_points(iPlugins, iParams){
	
	new id= get_param(1)
	
	return g_player_supply_amount[id]
	
}
public _ksun_player_is_in_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	
	return g_player_in_ultimate[id]
	
	
}

public _ksun_player_engage_ultimate(iPlugins, iParams){
	
	new id= get_param(1)
	
	if(!client_hittable(id)) return
	if(!spores_has_ksun(id)) return
	
	g_player_in_ultimate[id]=1
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(KSUN_ULTIMATE_LOOP_PERIOD,"ultimate_task",id+KSUN_ULTIMATE_TASKID,"", 0,  "a",KSUN_ULTIMATE_LOOP_TIMES)
	set_task(floatmul(KSUN_ULTIMATE_LOOP_PERIOD,float(KSUN_ULTIMATE_LOOP_TIMES))+1.0,"unultimate_task",id+UNKSUN_ULTIMATE_TASKID,"", 0,  "a",1)
	
	
	
}


public ultimate_task(id){
	id-=KSUN_ULTIMATE_TASKID
	if(!client_hittable(id)) return
	if(!ksun_player_is_in_ultimate(id)||!spores_has_ksun(id)) return
	new hud_msg[128];
	new origin[3]
	get_user_origin(id,origin,0)
	ksun_dec_player_supply_points(id,KSUN_ULTIMATE_LOOP_DEC)
	ksun_glisten(id)
	make_shockwave(origin,200.0,LineColorsWithAlpha[PURPLE])
	
	format(hud_msg,127,"[SH](ksun): Curr charge: %0.2f^n",
	100.0*(floatdiv(float(g_player_supply_amount[id]),float(ksun_supply_capacity)))
	);
	set_hudmessage(LineColors[PURPLE][0], LineColors[PURPLE][1],LineColors[PURPLE][2], -1.0, -1.0,125, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_ultimate, "%s", hud_msg)
	
	
	
	
	
	
}
public _ksun_unultimate_user(iPlugin,iParams){
	new id=get_param(1)
	unultimate_user(id)
	
	
}
public unultimate_task(id){
	id-=UNKSUN_ULTIMATE_TASKID
	remove_task(id+KSUN_ULTIMATE_TASKID)
	emit_sound(id, CHAN_STATIC, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, KSUN_ULTIMATE_DRONE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_AUTO, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	g_player_in_ultimate[id]=0
	g_player_supply_amount[id]=0
	
	
	
}

unultimate_user(id,take_away_supply=1){
	remove_task(id+UNKSUN_ULTIMATE_TASKID)
	remove_task(id+KSUN_ULTIMATE_TASKID)
	emit_sound(id, CHAN_STATIC, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, KSUN_ULTIMATE_DRONE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(id, CHAN_AUTO, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_AUTO, KSUN_ULTIMATE_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	g_player_in_ultimate[id]=0
	g_player_supply_amount[id]=take_away_supply?0:g_player_supply_amount[id]
	
	
	
}
public _ksun_player_is_ultimate_ready(iPlugins, iParams){
	
	new id=get_param(1)
	
	
	return g_player_supply_amount[id]>=ksun_supply_capacity
	
}

public ksun_rifle_laser(id)
{

if(!client_hittable(id)) return PLUGIN_CONTINUE 
if ( !spores_has_ksun(id)) return PLUGIN_CONTINUE 
new wpnid = read_data(2)		// id of the weapon 
new ammo = read_data(3)		// ammo left in clip 

if ( (wpnid ==CSW_M4A1)&&(ksun_player_is_in_ultimate(id)))
{
	if (gLastWeapon[id] == 0){
		gLastWeapon[id] = wpnid
	}
	if ((gLastClipCount[id] > ammo)&&(gLastWeapon[id] == wpnid)) 
	{
		new vec1[3], vec2[3]
		get_user_origin(id, vec1, 1) // origin; your camera point.
		get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
		
		
		//BEAMENTPOINTS
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (0)     //TE_BEAMENTPOINTS 0
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_coord(vec2[0])
		write_coord(vec2[1])
		write_coord(vec2[2])
		write_short( m_spriteTexture )
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(2) // life
		write_byte(10) // width
		write_byte(0) // noise
		write_byte( LineColors[PURPLE][0] )     // r, g, b
		write_byte( LineColors[PURPLE][1] )       // r, g, b
		write_byte( LineColors[PURPLE][2] )
		write_byte(255) // brightness
		write_byte(150) // speed
		message_end()
		static Float:N_Speed
		N_Speed =ksun_ultimate_fire_rate_mult
		if(N_Speed != 1.0)
		{
			static weapon[32],Ent
			get_weaponname(wpnid,weapon,31)
			Ent = fm_find_ent_by_owner(-1,weapon,id)
			if(Ent)
			{
				static Float:Delay,Float:M_Delay
				Delay =floatdiv(get_pdata_float( Ent, 46, 4) ,N_Speed)
				M_Delay =floatdiv(get_pdata_float( Ent, 47, 4) ,N_Speed)
				if (Delay > 0.0)
				{
					set_pdata_float( Ent, 46, Delay, 4)
					set_pdata_float( Ent, 47, M_Delay, 4)
				}
			}
		}
		
	}
	gLastClipCount[id] = ammo
	gLastWeapon[id]=wpnid;
}
return PLUGIN_CONTINUE 

}

public plugin_precache(){
	
	m_spriteTexture = precache_model("sprites/dot.spr")
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_DRONE_SOUND)
	engfunc(EngFunc_PrecacheSound, KSUN_ULTIMATE_SOUND)
}
public death()
{
	new id = read_data(2)
	if(is_user_connected(id)&&spores_has_ksun(id)){
		
		unultimate_user(id)

	}
}