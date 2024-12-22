
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "jetplane_inc/sh_jetplane_funcs.inc"
#include "jetplane_inc/sh_jetplane_mg_funcs.inc"
#include "jetplane_inc/sh_jetplane_rocket_funcs.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"


#define PLUGIN "Superhero yandere JETGATLING funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new Float:jetplane_mg_dmg,
Float:jetplane_mg_bulletspeed;
new shell_loaded[SH_MAXSLOTS+1]
new jetplane_mg_ammo;
new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	arrayset(shell_loaded,true,SH_MAXSLOTS+1)
	register_cvar("yandere_jetplane_mg_ammo", "5")
	register_cvar("yandere_jetplane_mg_dmg", "5")
	register_cvar("yandere_jetplane_mg_bulletspeed", "5")
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_Think, "mg_think")
	
}
public plugin_cfg(){
	
	loadCVARS()
}
public loadCVARS(){
	jetplane_mg_dmg=get_cvar_float("yandere_jetplane_mg_dmg");
	jetplane_mg_bulletspeed=get_cvar_float("yandere_jetplane_mg_bulletspeed");
	jetplane_mg_ammo=get_cvar_num("yandere_jetplane_mg_ammo");
}
public plugin_natives(){
	
	register_native("get_jet_shells","_get_jet_shells",0);
	register_native("clear_shells","_clear_shells",0);
	register_native("clear_mgs","_clear_mgs",0);
	register_native("mg_destroy","_mg_destroy",0);
	register_native("spawn_jetplane_mg","_spawn_jetplane_mg",0);
	register_native("set_jet_shells","_set_jet_shells",0);
	register_native("get_user_jet_shells","_get_user_jet_shells",0);
	register_native("set_user_jet_shells","_set_user_jet_shells",0);
	register_native("reset_jet_shells","_reset_jet_shells",0);
	register_native("reset_user_jet_shells","_reset_user_jet_shells",0);
	register_native("get_user_mg","_get_user_mg",0);
	
}
public _get_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	
	new num_shells=pev(jet_id,pev_iuser2)
	return num_shells;
	
}
public _set_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	new the_shells=get_param(2)
	
	set_pev(jet_id,pev_iuser2,the_shells)
}
public _reset_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	
	set_pev(jet_id,pev_iuser2,jetplane_mg_ammo)
}
public _get_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	return get_jet_shells(jet_get_user_jet(id))
	
}
public _set_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	new the_shells=get_param(2)
	return set_jet_shells(jet_get_user_jet(id),the_shells)
	
}
public _reset_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	return reset_jet_shells(jet_get_user_jet(id))
	
}
public _get_user_mg(iPlugins,iParams){
	new id=get_param(1)
	new result=is_user_connected(id)
	if(result){
	new result2=pev_valid(jet_get_user_jet(id))
		if(result2){
			
		
			return pev(jet_get_user_jet(id),pev_iuser3)
		}
		else{
			return 0
		
		}
	}
	return 0

}
public _spawn_jetplane_mg(iPlugins,iParams){

	new id=get_param(1)
	new jetplane_id=jet_get_user_jet(id)
	
	
	new material[128]
	new health[128]	
	new Float:jetplane_orig[3]
	pev(jetplane_id,pev_origin,jetplane_orig)
	new mg_id = create_entity( "func_breakable" );
	if(!is_valid_ent(mg_id)||(mg_id == 0)) {
		
		sh_chat_message(id,yandere_get_hero_id(),"Mg failed to spawn")
		return
	}
	set_pev(jetplane_id, pev_iuser3,mg_id)
	set_pev(mg_id,pev_owner,id)
	set_pev(mg_id, pev_takedamage, DAMAGE_YES)
	set_pev(mg_id, pev_solid, SOLID_BBOX)
	set_pev(mg_id , pev_classname, JETPLANE_MG_CLASSNAME)
	engfunc(EngFunc_SetModel, mg_id , P_MACHINEGUN_MODEL)
	float_to_str(1250.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue(  mg_id , "material", material );
	DispatchKeyValue(  mg_id , "health", health );
	set_pev(mg_id,pev_rendermode,kRenderTransAlpha)
	set_pev(mg_id,pev_renderfx,kRenderFxGlowShell)
	new alpha=190;
	set_pev(mg_id,pev_renderamt,float(alpha))
	Entvars_Set_Vector(mg_id, EV_VEC_mins,jetplane_mg_min_dims)
	Entvars_Set_Vector(mg_id, EV_VEC_maxs,jetplane_mg_max_dims)
	jetplane_orig[0]+=jetplane_origin_mg_offsets[0]
	jetplane_orig[1]+=jetplane_origin_mg_offsets[1]
	jetplane_orig[2]+=jetplane_origin_mg_offsets[2]
	set_pev(mg_id,pev_origin,jetplane_orig)
	set_pev(mg_id, pev_nextthink, get_gametime() + JET_THINK_PERIOD*2)
}
client_hittable(vic_userid){
	
	return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)
	
}
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!yandere_get_has_yandere(id)||!hasRoundStarted()||!client_hittable(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if((weapon==CSW_KNIFE)&&jet_deployed(id)){
		if(get_user_mg(id)){
			if(button & IN_ATTACK)
			{
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
				if(!(is_user_alive(id))||!shell_loaded[id]) return FMRES_IGNORED
				if(!get_user_jet_shells(id))
				{
					client_print(id, print_center, "You are out of shells")
					return FMRES_IGNORED
				}
				client_print(id, print_center, "Shell fired!")
				launch_shell(id)
				
			}
		}
		else{
		
			client_print(id, print_center, "Mg is unnavailable. Please try again later.")
		
		}
	}
	
	return FMRES_IGNORED;
}

public _clear_shells(iPlugin,iParams){

new grenada = find_ent_by_class(-1, JETPLANE_SHELL_CLASSNAME)
while(grenada) {
	
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, JETPLANE_SHELL_CLASSNAME)
}
}

//----------------------------------------------------------------------------------------------
public mg_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, JETPLANE_MG_CLASSNAME) ) return FMRES_IGNORED
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	if ( !jet_deployed(owner)) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet mg died cuz of plane dying!!")
		}
		return FMRES_IGNORED
	}
	new Float:mg_health=float(pev(ent,pev_health))
	
	if ( (mg_health<1000.0)) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet mg died!")
		}
		return FMRES_IGNORED
	}
	if(jet_deployed(owner)){
		
		new Float:vOrigin[3]
		Entvars_Get_Vector(jet_get_user_jet(owner), EV_VEC_origin, vOrigin)
		vOrigin[0]+=jetplane_origin_mg_offsets[0]
		vOrigin[1]+=jetplane_origin_mg_offsets[1]
		vOrigin[2]+=jetplane_origin_mg_offsets[2]
		ENT_SetOrigin(ent, vOrigin)
		
		new Float:angles[3]
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_v_angle, angles)
		entity_set_vector(ent, EV_VEC_v_angle, angles)
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_angles, angles)
		entity_set_vector(ent, EV_VEC_angles, angles)
		
		
		draw_bbox(ent,0)
		set_pev(ent, pev_nextthink, gametime + (JET_THINK_PERIOD))
	}
	return FMRES_IGNORED
}

launch_shell(id)
{

entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent
if(!pev_valid(get_user_mg(id))) return PLUGIN_HANDLED
entity_get_vector(get_user_mg(id), EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)

Origin[2]+=(jetplane_mg_max_dims[2]+10.0)

Ent = create_entity("info_target")

if (!Ent){
	sh_chat_message(id,yandere_get_hero_id(),"shell failed!");
	return PLUGIN_HANDLED
}
entity_set_string(Ent, EV_SZ_classname, JETPLANE_SHELL_CLASSNAME)
entity_set_model(Ent, GUN_SHELL)

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

//Origin[0]+=jetplane_max_dims[0]

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_solid, 2)
entity_set_int(Ent, EV_INT_movetype, 5)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(jetplane_mg_bulletspeed) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

new parm[1]
set_user_jet_shells(id,get_user_jet_shells(id)-1)
shell_loaded[id]=false
parm[0]=id
set_task(MG_SHELL_PERIOD,"shell_reload",id+MG_SHELL_RELOAD_TASKID,parm,1,"a",1)


new parm1[1]
parm1[0] = Ent
emit_sound(id, CHAN_WEAPON, MACHINE_GUN_SOUND , VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(0.01, "shelltrail",id,parm1,1)

return PLUGIN_CONTINUE
}

public shell_reload(parm[],id)
{
id-=MG_SHELL_RELOAD_TASKID
shell_loaded[parm[0]] = true
}
public shelltrail(parm[])
{
new pid = parm[0]
if (pid)
{
message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
write_byte( TE_BEAMFOLLOW )
write_short(pid) // entity
write_short(m_trail)  // model
write_byte( 10 )       // life
write_byte( 2 )        // width
write_byte(love_color[0])			// r, g, b
write_byte(love_color[1])		// r, g, b
write_byte(love_color[2])			// r, g, b
write_byte(love_color[3]) // brightness
message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
}


public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return
new szClassName[32]
Entvars_Get_String(pToucher, EV_SZ_classname, szClassName, 31)

new oid = entity_get_edict(pToucher, EV_ENT_owner)
//&&((pTouched==oid)||(pTouched==jet_get_user_jet(oid))||(pTouched!=get_user_mg(oid)))
if(equal(szClassName, JETPLANE_SHELL_CLASSNAME)) {
if((pTouched==get_user_law(oid))||(pTouched==get_user_mg(oid))||(pTouched==jet_get_user_jet(oid))) return
if(client_hittable(pTouched))
{
	
	sh_extra_damage(pTouched,oid,floatround(jetplane_mg_dmg),"Rage jet gatling cannon");
	
	
}
remove_entity(pToucher)
}
}
public plugin_precache()
{
m_trail = precache_model("sprites/smoke.spr")

precache_model( "models/metalgibs.mdl" );
engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
precache_model(GUN_SHELL)
precache_model(P_MACHINEGUN_MODEL)
engfunc(EngFunc_PrecacheSound, MACHINE_GUN_SOUND)

}

public _mg_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	
	if(is_valid_ent(get_user_mg(id))&&get_user_mg(id)){
		draw_bbox(get_user_mg(id),true)
		remove_entity(get_user_mg(id));
		set_pev(jet_get_user_jet(id),pev_iuser3,0)
	}
}
public _clear_mgs(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JETPLANE_MG_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, JETPLANE_MG_CLASSNAME)
	}
}
