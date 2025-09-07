#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "tranq_gun_inc/sh_tranq_funcs.inc"
#include <fakemeta_util>
#include <reapi>
#include "../my_include/weapons_const.inc"


#define PLUGIN "Superhero erica tranq funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new pPlayer
new Float:dart_launch_pos[MAX_ENTITIES][3];
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new g_Tranq_Clip[SH_MAXSLOTS+1]
new bool:dart_hurts[MAX_ENTITIES];
new bool:dart_loaded[SH_MAXSLOTS+1];
new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	for(new i=0;i<MAX_ENTITIES;i++){
		
		arrayset(dart_launch_pos[i],0.0,3);
		
	}
	arrayset(dart_hurts,false,MAX_ENTITIES)
	arrayset(dart_loaded,true,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, STRN_ELITE, "fw_ItemDeployPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_WeaponPrimaryAttackPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_Weapon_PrimaryAttack_Post", 1)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player")	
	RegisterHam(Ham_Item_PostFrame, STRN_ELITE, "fw_Item_PostFrame")	
	
	RegisterHam(Ham_Weapon_Reload,STRN_ELITE, "fw_WeaponReloadPre")
	RegisterHam(Ham_Weapon_Reload, STRN_ELITE, "fw_Weapon_Reload_Post", 1)	
	
	
	
}

public plugin_natives(){
	
	register_native( "clear_darts","_clear_darts",0)
	
	
}


public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!tranq_get_has_erica(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if(weapon==CSW_ELITE){
		if(button & IN_ATTACK)
		{
			if(!dart_loaded[id]){
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
			}
			
		}
	}
	
	return FMRES_IGNORED;
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != CSW_ELITE || !tranq_get_has_erica(Attacker))
		return HAM_IGNORED
		
	Damage=0.0;
	
	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(ent)
{
	static id; id = pev(ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return HAM_IGNORED;
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
	static bpammo; bpammo = cs_get_user_bpammo(id, CSW_ELITE)
	
	static iClip; iClip = get_pdata_int(ent, 51, 4)
	static fInReload; fInReload = get_pdata_int(ent, 54, 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, 51, iClip + temp1, 4)
		cs_set_user_bpammo(id, CSW_ELITE, bpammo - temp1)		
		
		set_pdata_int(ent, 54, 0, 4)
		
		fInReload = 0
	}		
	
	return HAM_IGNORED
}

public fw_WeaponReloadPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if(client_isnt_hitter(pPlayer)){
		
		return HAM_IGNORED
	}
	g_Tranq_Clip[pPlayer] = -1
		
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, CSW_ELITE)
	static iClip; iClip = get_pdata_int(entity, 51, 4)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_Tranq_Clip[pPlayer] = iClip		
	return HAM_HANDLED
}
public fw_Weapon_Reload_Post(ent)
{
	static id; id = pev(ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return HAM_IGNORED
	}
	if((get_pdata_int(ent, 54, 4) == 1))
	{ // Reload
		if(g_Tranq_Clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, 51, g_Tranq_Clip[id], 4)
	}
	
	
	return HAM_HANDLED
} 
public fw_ItemDeployPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if(!tranq_get_has_erica(pPlayer)){
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, DART_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flTimeWeaponIdle, DART_SHOOT_PERIOD)
	set_pdata_int(entity, 51,min(CLIP_SIZE,get_pdata_int(entity, 51, 4)), 4)
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	
	if ( client_isnt_hitter(pPlayer)||!hasRoundStarted()) return HAM_IGNORED;
	
	if(tranq_get_num_darts(pPlayer) == 0)
	{
		client_print(pPlayer, print_center, "You are out of darts")
		sh_drop_weapon(pPlayer, CSW_ELITE, true)
		return HAM_SUPERCEDE
	}
	launch_dart(pPlayer)
	dart_loaded[pPlayer]=false;
	g_Tranq_Clip[pPlayer]=get_pdata_int(entity, 51, 4)
	set_member(entity, m_Weapon_flTimeWeaponIdle, DART_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flNextSecondaryAttack, 99999.0)
	
	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	static id; id = pev(Ent, pev_owner)
	if(client_isnt_hitter(id)){
			return;
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	xs_vec_sub(Push, g_Recoil[id], Push)
	
	xs_vec_mul_scalar(Push, RECOIL, Push)
	xs_vec_add(Push, g_Recoil[id], Push)
	set_pev(id, pev_punchangle, Push)
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
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
entity_set_float(Ent,EV_FL_gravity, 2.0)
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
new parm2[1]

parm2[0]= id
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, SILENT_TRANQS_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_task(DART_SHOOT_PERIOD, "dart_reload",id,parm2,1,"a",1)
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
public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(client_isnt_hitter(player)){
		return
	}
	new clip, ammo, weapon = get_user_weapon(player, clip, ammo);
	if(weapon!=CSW_ELITE){
		return;
	}
	set_cd(cd, CD_flNextAttack, 99999.0)
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
