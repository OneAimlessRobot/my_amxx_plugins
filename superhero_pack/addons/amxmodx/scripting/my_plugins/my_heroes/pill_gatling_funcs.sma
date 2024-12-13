#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"


#define PLUGIN "Superhero yakui mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:pill_loaded[SH_MAXSLOTS+1]

new gPillGatlingEngaged[SH_MAXSLOTS+1]

new pill_fx[MAX_ENTITIES]
new m_trail
new const gunsound[] = "shmod/yakui/m249-1.wav";
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
//handle when player presses attack2

arrayset(pill_fx,0,sh_max_entities())
arrayset(pill_loaded,true,SH_MAXSLOTS+1)
register_forward(FM_CmdStart, "CmdStart");
}

public plugin_natives(){

	
	register_native("gatling_set_pill_fx_num","_gatling_set_pill_fx_num",0);
	register_native("gatling_get_pill_fx_num","_gatling_get_pill_fx_num",0);
	register_native("gatling_set_pillgatling","_gatling_set_pillgatling",0);
	register_native("gatling_get_pillgatling","_gatling_get_pillgatling",0);
	register_native( "clear_pills","_clear_pills",0)


}
public _gatling_get_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	return pill_fx[pillid]

}

public _gatling_set_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	new value_to_set= get_param(2)
	pill_fx[pillid]=value_to_set

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
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!gatling_get_has_yakui(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_m249", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_M249){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !gatling_get_pillgatling(id) || !(is_user_alive(id))||!pill_loaded[id]) return FMRES_IGNORED
			if(gatling_get_num_pills(id) == 0)
			{
				client_print(id, print_center, "You are out of pills")
				return FMRES_IGNORED
			}
			launch_pill(id)
			
		}
	}
	if(ent)
	{
		cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, CSW_M249, gatling_get_num_pills(id));
	}
	
	return FMRES_IGNORED;
}
/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_hittable(vic_userid){

return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)

}
client_isnt_hitter(gatling_user){


return (!gatling_get_has_yakui(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_pills(iPlugin,iParams){

	arrayset(pill_fx,0,sh_max_entities())
	new grenada = find_ent_by_class(-1, PILL_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, PILL_CLASSNAME)
	}
}
shooting_aura(id){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(random_num(0,255))			// r, g, b
	write_byte(random_num(0,255))		// r, g, b
	write_byte(random_num(0,255))			// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()

}
launch_pill(id)
{
	shooting_aura(id)
	entity_set_int(id, EV_INT_weaponanim, 3)

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, PILL_CLASSNAME)
	entity_set_model(Ent, "models/shell.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 2)
	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, floatround(PILL_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	pill_loaded[id] = false

	gatling_dec_num_pills(id)

	new parm[6]
	new fx_num=sh_gen_effect()
	pill_fx[Ent]=fx_num
	new color[4]
	sh_get_pill_color(fx_num,id,color)
	parm[0] = Ent
	parm[1] =id
	parm[2]=color[0]
	parm[3]=color[1]
	parm[4]=color[2]
	parm[5]=color[3]
	emit_sound(id, CHAN_WEAPON, gunsound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	//if(get_cvar_num("veronika_m203trail"))
	set_task(0.01, "pilltrail",id,parm,6)

	parm[0] = id
	set_task(PILL_SHOOT_PERIOD, "pill_reload",id+PILL_RELOAD_TASKID,parm,1)

	return PLUGIN_CONTINUE
}

public pill_reload(parm[])
{
	pill_loaded[parm[0]] = true
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

public pilltrail(parm[])
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
		write_byte(parm[2])			// r, g, b
		write_byte(parm[3])		// r, g, b
		write_byte(parm[4])			// r, g, b
		write_byte(parm[5]) // brightness

		message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
	}
}


public vexd_pfntouch(pToucher, pTouched)
{
	
	if (pToucher <= 0) return
	if (!is_valid_ent(pToucher)) return
	
	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, PILL_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		//new Float:origin[3],dist
		
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{
				make_effect_direct(pTouched,oid,pill_fx[pToucher],gHeroID)
				remove_entity(pToucher)
			}
		}
		//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
		if(pev(pTouched,pev_solid)==SOLID_BSP){
			
			emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(pToucher)
		}

	}
}
public remove_pill(id_pill){
	id_pill-=PILL_REM_TASKID

	remove_entity(id_pill)


}
public plugin_precache()
{
	m_trail = precache_model("sprites/smoke.spr")

	precache_model("models/shell.mdl")
	precache_model(GATLING_P_MODEL)
	precache_model(GATLING_V_MODEL)
	engfunc(EngFunc_PrecacheSound, EFFECT_SHOT_SFX)
	engfunc(EngFunc_PrecacheSound, gunsound)
	
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
