#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "tranq_gun_inc/sh_tranq_funcs.inc"
#include <reapi>
#include "../my_include/weapons_const.inc"


#define PLUGIN "Superhero erica tranq funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new pPlayer
new bool:dart_loaded[SH_MAXSLOTS+1]
new Float:dart_launch_pos[MAX_ENTITIES][3];
new bool:dart_hurts[MAX_ENTITIES];
new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	for(new i=0;i<MAX_ENTITIES;i++){
		
		arrayset(dart_launch_pos[i],0.0,3);
		
	}
	arrayset(dart_loaded,true,SH_MAXSLOTS+1)
	arrayset(dart_hurts,false,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, STRN_ELITE, "fw_ItemDeployPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_WeaponPrimaryAttackPre")
	RegisterHam(Ham_Weapon_Reload,STRN_ELITE, "fw_WeaponReloadPre")
	
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

public fw_ItemDeployPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if(!tranq_get_has_erica(pPlayer)){
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, 0.9)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 0.9)
	return HAM_SUPERCEDE
}

public fw_WeaponReloadPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if(!tranq_get_has_erica(pPlayer)){
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Weapon_Reload, entity)
	set_member(pPlayer, m_flNextAttack, 2.23)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 2.23)
	return HAM_SUPERCEDE
}

public fw_WeaponPrimaryAttackPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if(!tranq_get_has_erica(pPlayer)){
		
		return HAM_IGNORED
	}
	if(get_member(entity, m_Weapon_iShotsFired)) return HAM_SUPERCEDE
	
	
	set_member(entity, m_Weapon_flTimeWeaponIdle, 1.033)
	set_member(entity, m_Weapon_flNextSecondaryAttack, 99999.0)
	return HAM_SUPERCEDE
}

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
	arrayset(dart_launch_pos[grenada],0.0,3);
	dart_hurts[grenada]=false;
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

if(tranq_get_is_max_points(id)){

	dart_hurts[Ent]=true;
	dart_launch_pos[Ent][0]=Origin[0]
	dart_launch_pos[Ent][1]=Origin[1]
	dart_launch_pos[Ent][2]=Origin[2]

}
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
if(!dart_hurts[pid]){
	write_byte(sleep_color[0])			// r, g, b
	write_byte(sleep_color[1])		// r, g, b
	write_byte(sleep_color[2])			// r, g, b
	write_byte(sleep_color[3]) // brightness
}
else {
	write_byte(rage_sleep_color[0])			// r, g, b
	write_byte(rage_sleep_color[1])		// r, g, b
	write_byte(rage_sleep_color[2])			// r, g, b
	write_byte(rage_sleep_color[3]) // brightness
}
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
		if(dart_hurts[pToucher]){
			new Float:vic_origin[3];
			entity_get_vector(pTouched,EV_VEC_origin,vic_origin);
			new Float:distance=vector_distance(vic_origin,dart_launch_pos[pToucher]);
			new Float:falloff_coeff= floatmin(1.0,distance/DART_DAMAGE_FALLOFF_DIST);
			sh_extra_damage(pTouched,oid,floatround(DART_DAMAGE-35.0*falloff_coeff),"Rage tranq");
			
		
		}
		sh_sleep_user(pTouched,oid,tranq_get_hero_id())
		
	}
	remove_entity(pToucher)
	arrayset(dart_launch_pos[pToucher],0.0,3);
	dart_hurts[pToucher]=false;
}
//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
if(pev(pTouched,pev_solid)==SOLID_BSP){
	
		emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(pToucher)	
		arrayset(dart_launch_pos[pToucher],0.0,3);
		dart_hurts[pToucher]=false;

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
