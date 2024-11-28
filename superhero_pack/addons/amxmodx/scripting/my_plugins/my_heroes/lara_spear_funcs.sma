#include "../my_include/superheromod.inc"
#include "lara_spear_inc/sh_lara_get_set.inc"
#include "lara_spear_inc/sh_spear_funcs.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"


#define PLUGIN "Superhero lara mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:spear_loaded[SH_MAXSLOTS+1]

new bool:spear_armed[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]

new bool:spear_pickable[MAX_ENTITIES]

new Float:min_charge_time,Float:max_charge_time

new m_trail
new hud_sync_charge
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
//handle when player presses attack2

arrayset(spear_loaded,true,SH_MAXSLOTS+1)
arrayset(spear_armed,false,SH_MAXSLOTS+1)
arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
arrayset(spear_pickable,false,MAX_ENTITIES)
register_forward(FM_CmdStart, "CmdStart");
register_cvar("lara_spear_max_charge_time", "5.0")
register_cvar("lara_spear_min_charge_time", "1.0")
hud_sync_charge=CreateHudSyncObj()
RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Weapon_Stab")
}

public plugin_natives(){

	
	register_native( "clear_spears","_clear_spears",0)
	register_native( "spear_get_spear_loaded","_spear_get_spear_loaded",0)
	register_native( "spear_uncharge_spear","_spear_uncharge_spear",0)


}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!spear_get_has_lara(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_KNIFE){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))||!spear_loaded[id]) return FMRES_IGNORED
			if(spear_get_num_spears(id) == 0)
			{
				client_print(id, print_center, "You are out of spears")
				return FMRES_IGNORED
			}
			if(!spear_armed[id]){
				spear_armed[id]=true
				curr_charge[id]=0.0
				charge_user(id)
				
			}
			
		}
		else if(spear_armed[id]){
			if(curr_charge[id]>=min_charge_time){
				launch_spear(id)
				client_print(id,print_center,"You have %d spears left",
					spear_get_num_spears(id)
					);
			}
			else if(curr_charge[id]>0.0){
				sh_chat_message(id,spear_get_hero_id(),"Spear not charged! Spear not launched...");
			
			}
			uncharge_user(id)
		
		}
	}
	else{
	
		uncharge_user(id)
	}
	
	return FMRES_IGNORED;
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	max_charge_time=get_cvar_float("lara_spear_max_charge_time")
	min_charge_time=get_cvar_float("lara_spear_min_charge_time")
}


public charge_task(id){
	id-=SPEAR_CHARGE_TASKID
	new hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],SPEAR_CHARGE_PERIOD)
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
					100.0*(curr_charge[id]/max_charge_time)
					);
	set_hudmessage(redline_color[0], redline_color[1], redline_color[2], -1.0, -1.0, redline_color[3], 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
					
	

	


}
charge_user(id){
	set_task(SPEAR_CHARGE_PERIOD,"charge_task",id+SPEAR_CHARGE_TASKID,"", 0,  "a",SPEAR_CHARGE_TIMES)
	set_task(floatmul(SPEAR_CHARGE_PERIOD,float(SPEAR_CHARGE_TIMES))+1.0,"uncharge_task",id+UNSPEAR_CHARGE_TASKID,"", 0,  "a",1)
	return 0



}
public _spear_uncharge_spear(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	spear_loaded[id]=true


}
public uncharge_task(id){
	id-=UNSPEAR_CHARGE_TASKID
	remove_task(id+SPEAR_CHARGE_TASKID)
	spear_armed[id]=false
	return 0



}

uncharge_user(id){
	remove_task(id+UNSPEAR_CHARGE_TASKID)
	remove_task(id+SPEAR_CHARGE_TASKID)
	spear_armed[id]=false
	return 0



}

public Ham_Weapon_Stab(weapon_ent)
{
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)

	if ( (!spear_loaded[owner]||!spear_get_num_spears(owner))&&spear_get_has_lara(owner)) {
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}
public lara_charge_task(id){
	id-=SPEAR_CHARGE_TASKID
	
	


}
/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_hittable(vic_userid){

return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)

}
client_isnt_hitter(gatling_user){


return (!spear_get_has_lara(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_spears(iPlugin,iParams){

	new grenada = find_ent_by_class(-1, SPEAR_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, SPEAR_CLASSNAME)
	}
}
public _spear_get_spear_loaded(iPlugin,iParams){

	new id=get_param(1)
	return spear_loaded[id]
	
}
launch_spear(id)
{
	entity_set_int(id, EV_INT_weaponanim, 3)

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, SPEAR_CLASSNAME)
	entity_set_model(Ent, SPEAR_W_MODEL)

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	
	Origin[2]+=50.0
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, floatround(SPEAR_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)
	//VelocityByAim(id, floatround(SPEAR_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	spear_loaded[id] = false

	spear_dec_num_spears(id)

	new parm[1]
	parm[0] = Ent
	emit_sound(id, CHAN_WEAPON, SPEAR_THROW_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	//if(get_cvar_num("veronika_m203trail"))
	set_task(0.01, "speartrail",id,parm,1)

	parm[0] = id
	entity_set_string(id, EV_SZ_viewmodel, NOSPEAR_V_MODEL)
	set_task(SPEAR_SHOOT_PERIOD, "spear_reload",id+SPEAR_RELOAD_TASKID,parm,1)

	return PLUGIN_CONTINUE
}

public spear_reload(parm[])
{
	if(!is_user_alive(parm[0])||!spear_get_has_lara(parm[0])||!is_user_connected(parm[0])) return
	spear_loaded[parm[0]] = true
	new clip,ammo,wid=get_user_weapon(parm[0],clip,ammo)
	if((wid==CSW_KNIFE)&&spear_get_num_spears(parm[0])){
		entity_set_string(parm[0], EV_SZ_viewmodel, SPEAR_V_MODEL)
	}
}
/////////////////////
//Thantik's he-conc functions
stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

	// Velocity = Distance / Time

	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}


// Sets velocity of an entity (ent) away from origin with speed (speed)

stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
	new Float:fVelocity[3];
	get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

	entity_set_vector( ent, EV_VEC_velocity, fVelocity );

	return ( 1 );
}

public speartrail(parm[])
{
	new pid = parm[0]
	if (pid)
	{
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(pid) // entity
		write_short(m_trail)  // model
		write_byte( 10 )       // life
		write_byte( 5 )        // width
		write_byte(255)			// r, g, b
		write_byte(255)		// r, g, b
		write_byte(255)			// r, g, b
		write_byte(255) // brightness

		message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
	}
}


public vexd_pfntouch(pToucher, pTouched)
{
	
	if (pToucher <= 0) return
	if (!is_valid_ent(pToucher)) return
	
	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, SPEAR_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		//new Float:origin[3],dist
		
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			
			if(client_hittable(pTouched))
			{
				
				if(spear_get_has_lara(pTouched)&&(pTouched==oid)&&spear_pickable[pToucher] && SPEAR_RETRIEVE){
				
					spear_set_num_spears(oid,spear_get_num_spears(oid)+1)
					sh_chat_message(oid,spear_get_hero_id(),"Youve picked up your spear back! You now have %d",spear_get_num_spears(oid))
					spear_pickable[pToucher]=false
					remove_entity(pToucher);
				
				}
				else if(pTouched!=oid){
					sh_extra_damage(pTouched,oid,SPEAR_DAMAGE,"Hunter Spear",0,SH_DMG_NORM)
					sh_bleed_user(pTouched,oid,gHeroID)
					emit_sound(pToucher, CHAN_WEAPON, SPEAR_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					spear_pickable[pToucher]=true
					set_task(SPEAR_REM_TIME,"remove_spear",pToucher+SPEAR_REM_TASKID,"",0)
				}
			}
		}
		//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
		if(pev(pTouched,pev_solid)==SOLID_BSP){
			emit_sound(pToucher, CHAN_WEAPON, SPEAR_HIT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			entity_set_vector(pToucher, EV_VEC_velocity ,NULL_VECTOR)
			spear_pickable[pToucher]=true
			set_task(SPEAR_REM_TIME,"remove_spear",pToucher+SPEAR_REM_TASKID,"",0)
		}

	}
}
public remove_spear(id_spear){
	id_spear-=SPEAR_REM_TASKID
	if(!is_valid_ent(id_spear)) return
	spear_pickable[id_spear]=false
	remove_entity(id_spear)


}
public plugin_precache()
{
	m_trail = precache_model("sprites/smoke.spr")

	precache_model(SPEAR_W_MODEL)
	engfunc(EngFunc_PrecacheSound, SPEAR_HIT_SFX)
	engfunc(EngFunc_PrecacheSound, SPEAR_THROW_SFX)
	engfunc(EngFunc_PrecacheSound, SPEAR_WOUND_SFX)
	
}
/*

public _gatling_set_num_pills(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumPills[id]=value_to_set;
}
public _gatling_set_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set= get_param(2)
	gHasYakui[id]=value_to_set;
}
public _gatling_get_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	return gHasYakui[id]
}

public _gatling_get_num_pills(iPlugin,iParams){


	new id= get_param(1)
	return gNumPills[id]

}

public _gatling_dec_num_pills(iPlugin,iParams){


	new id= get_param(1)
	gNumPills[id]-= (gNumPills[id]>0)? 1:0

}
public _gatling_get_fx_num(iPlugin,iParams){


	new id= get_param(1)
	return gCurrFX[id]

}

public _gatling_set_fx_num(iPlugin,iParams){


	new id= get_param(1)
	new value_to_set= get_param(2)
	gCurrFX[id]=value_to_set

}


public _gatling_get_hero_id(iPlugin,iParams){

	return gHeroID

}

public _gatling_set_hero_id(iPlugin,iParams){


	new value_to_set= get_param(1)
	gHeroID=value_to_set

}

public _gatling_get_pillgatling(iPlugin,iParams){
	new id=get_param(1)
	return gPillGatlingEngaged[id]
	
}
public _gatling_set_pillgatling(iPlugin,iParams){
	
	new id= get_param(1)
	new value_to_set= get_param(2)
	gPillGatlingEngaged[id]=value_to_set;
}
*/
