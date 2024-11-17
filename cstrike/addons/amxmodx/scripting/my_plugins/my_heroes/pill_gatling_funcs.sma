#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"


#define PLUGIN "Superhero yakui pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
//handle when player presses attack2

arrayset(pill_loaded,true,SH_MAXSLOTS+1)
arrayset(gCurrFX,0,SH_MAXSLOTS+1)
arrayset(pill_fx,0,MAX_ENTITIES)
register_forward(FM_PlayerPreThink, "player_prethink_gatling")
RegisterHam(Ham_TakeDamage, "player", "Pillgatling_damage");
}

public plugin_natives(){


	register_native("gatling_set_num_pills","_gatling_set_num_pills",0);
	register_native("gatling_get_num_pills","_gatling_get_num_pills",0);
	register_native("gatling_dec_num_pills","_gatling_dec_num_pills",0);
	
	register_native("gatling_set_fx_num","_gatling_set_fx_num",0);
	register_native("gatling_get_fx_num","_gatling_get_fx_num",0);
	
	register_native("gatling_set_pill_fx_num","_gatling_set_pill_fx_num",0);
	register_native("gatling_get_pill_fx_num","_gatling_get_pill_fx_num",0);
	
	register_native("gatling_set_hero_id","_gatling_set_hero_id",0);
	register_native("gatling_get_hero_id","_gatling_get_hero_id",0);
	
	register_native("gatling_set_has_yakui","_gatling_set_has_yakui",0);
	register_native("gatling_get_has_yakui","_gatling_get_has_yakui",0);
	
	register_native("gatling_set_pillgatling","_gatling_set_pillgatling",0);
	register_native("gatling_get_pillgatling","_gatling_get_pillgatling",0);
	register_native("client_isnt_hitter","_client_isnt_hitter",0);
	register_native( "launch_pill","_launch_pill",0);
	register_native( "uneffect_user_handler","_uneffect_user_handler",0)
	register_native( "make_effect","_make_effect",0)
	register_native( "clear_pills","_clear_pills",0)
	register_native( "make_effect_direct","_make_effect_direct",0)
	


}

public Pillgatling_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if(client_isnt_hitter(attacker)) return HAM_IGNORED

new clip, ammo, wpnid = get_user_weapon(attacker,clip,ammo)
if(gPillGatlingEngaged[attacker]){
	
	if(wpnid==CSW_M249){
		
		damage=0.0
		return HAM_SUPERCEDE;
			
	}
	
}
return HAM_IGNORED
}


public _make_effect(iPlugin,iParams){

	new vic= get_param(1)
	new attacker= get_param(2)

	sh_uneffect_user(vic,gCurrFX[vic],gHeroID)
	new fx_num=sh_effect_user(vic,attacker,gHeroID)
	gCurrFX[vic]=fx_num;

}
public _make_effect_direct(iPlugin,iParams){

	new vic= get_param(1)
	new attacker= get_param(2)
	new fx_num= get_param(3)

	sh_uneffect_user(vic,gCurrFX[vic],gHeroID)
	sh_effect_user_direct(vic,attacker,gHeroID,fx_num)
	gCurrFX[vic]=fx_num;

}
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

public _gatling_get_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	return pill_fx[pillid]

}

public _gatling_set_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	new value_to_set= get_param(2)
	pill_fx[pillid]=value_to_set

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

public _uneffect_user_handler(iPlugin,iParams){

	new user=get_param(1)
	sh_uneffect_user(user,gatling_get_fx_num(user),gatling_get_hero_id())
	gCurrFX[user]=0;

}
//----------------------------------------------------------------------------------------------
public player_prethink_gatling(id)
{
	if(client_isnt_hitter(id)) return FMRES_IGNORED
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	/*client_print(id, print_center, "Shot a pill 0!!!!! Atacas? %s Equipped? %s Yakui? %s",
					(entity_get_int(id, EV_INT_button) & IN_ATTACK)?"Sim":"Nao",
					(wpnid == CSW_M249) ?"Sim":"Nao",
					gHasYakui[id]?"Sim":"Nao"
					)
	*/
	if ( (wpnid == CSW_M249) && gHasYakui[id]&&gPillGatlingEngaged[id] )
	{
		if((entity_get_int(id, EV_INT_button) & IN_ATTACK2)){
		
			launch_pill(id)
			return FMRES_IGNORED
		}
		
	}
	return FMRES_IGNORED
}
/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_hittable(vic_userid){

return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)

}
public _client_isnt_hitter(iPlugin,iParams){

new gatling_user=get_param(1)

return (!shModActive()||!gHasYakui[gatling_user]||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_pills(iPlugin,iParams){

	arrayset(pill_fx,0,MAX_ENTITIES)
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
public _launch_pill(iPlugin,iParams)
{
	new id= get_param(1)
	if( !gHasYakui[id] || !(is_user_alive(id))||!pill_loaded[id]) return PLUGIN_CONTINUE
	//if(!(is_user_alive(id))) return PLUGIN_CONTINUE

	if(gNumPills[id] == 0)
	{
		client_print(id, print_center, "You are out of pills")
		return PLUGIN_CONTINUE
	}
	shooting_aura(id)
	entity_set_int(id, EV_INT_weaponanim, 3)

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	Origin[2] =floatadd( Origin[2] , 50.0)

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
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, floatround(PILL_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	pill_loaded[id] = false

	gNumPills[id]--

	new parm[6]
	new fx_num=sh_gen_effect()
	pill_fx[Ent]=fx_num
	new color[4]
	sh_get_pill_color(Ent,id,color)
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
	new attacker = parm[1]
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
		new damradius = floatround(PILL_RADIUS)

		new Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new origin[3],dist,i

		for ( i = 1; i <= 32; i++)
		{
			if(client_hittable(i))
			{
				get_user_origin(i,origin)
				dist = get_distance(origin,vExplodeAt)
				if (dist <= damradius)
				{
					make_effect_direct(i,oid,pill_fx[pToucher])

				}
			}
		}
		emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		pill_fx[pToucher]=0;
		remove_entity(pToucher)

	}
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
