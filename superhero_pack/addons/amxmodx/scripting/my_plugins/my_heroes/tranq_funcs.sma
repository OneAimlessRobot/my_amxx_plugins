#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "tranq_gun_inc/sh_tranq_funcs.inc"


#define PLUGIN "Superhero erica tranq funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:dart_loaded[SH_MAXSLOTS+1]

new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(dart_loaded,true,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	
}

public plugin_natives(){
	
	register_native( "clear_darts","_clear_darts",0)
	
	
}
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!tranq_get_has_erica(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_elite", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_ELITE){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if(!(is_user_alive(id))||!dart_loaded[id]) return FMRES_IGNORED
			if(tranq_get_num_darts(id) == 0)
			{
				client_print(id, print_center, "You are out of darts")
				return FMRES_IGNORED
			}
			launch_dart(id)
			dart_loaded[id]=false
			
		}
		else
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if(ent){
				set_pdata_float(ent, 48, 0.5+DART_SHOOT_PERIOD, 4);
			}
			dart_loaded[id]=true
		}
	}
	if(ent)
	{
		cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, CSW_ELITE,tranq_get_num_darts(id));
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


return (!tranq_get_has_erica(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_darts(iPlugin,iParams){

new grenada = find_ent_by_class(-1, DART_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, DART_CLASSNAME)
}
}

launch_dart(id)
{

entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, DART_CLASSNAME)
entity_set_model(Ent, "models/shell.mdl")

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_effects, 2)
entity_set_int(Ent, EV_INT_solid, 2)
entity_set_int(Ent, EV_INT_movetype, 5)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(DART_SPEED) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

tranq_dec_num_darts(id)

new parm[1]

parm[0] = Ent
emit_sound(id, CHAN_WEAPON, SILENT_TRANQS_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_task(0.01, "darttrail",id,parm,1)

return PLUGIN_CONTINUE
}

public dart_reload(parm[])
{

dart_loaded[parm[0]] = true
}
public darttrail(parm[])
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
write_byte(sleep_color[0])			// r, g, b
write_byte(sleep_color[1])		// r, g, b
write_byte(sleep_color[2])			// r, g, b
write_byte(sleep_color[3]) // brightness

message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
}


public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return

new szClassName[32]
entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
if(equal(szClassName, DART_CLASSNAME))
{
new oid = entity_get_edict(pToucher, EV_ENT_owner)
//new Float:origin[3],dist

if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
	if(client_hittable(pTouched))
	{
		sh_sleep_user(pTouched,oid,tranq_get_hero_id())
		
	}
	remove_entity(pToucher)
}
//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
if(pev(pTouched,pev_solid)==SOLID_BSP){
	
		emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(pToucher)
		}

	}
}
public remove_dart(id_dart){
	id_dart-=DART_REM_TASKID

	remove_entity(id_dart)


}
public plugin_precache()
{
m_trail = precache_model("sprites/smoke.spr")

precache_model("models/shell.mdl")
engfunc(EngFunc_PrecacheSound, EFFECT_SHOT_SFX)
engfunc(EngFunc_PrecacheSound, SILENT_TRANQS_SFX)

}
