#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_funcs.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include <fakemeta_util>


#define PLUGIN "Superhero teliko mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:molly_loaded[SH_MAXSLOTS+1]

new bool:molly_armed[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]

new Float:min_charge_time,Float:max_charge_time
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(molly_loaded,true,SH_MAXSLOTS+1)
	arrayset(molly_armed,false,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	register_cvar("erica_molly_max_charge_time", "5.0")
	register_cvar("erica_molly_min_charge_time", "1.0")
}

public plugin_natives(){
	
	
	register_native( "clear_mollies","_clear_mollies",0)
	register_native( "molly_get_molly_loaded","_molly_get_molly_loaded",0)
	register_native( "molly_uncharge_molly","_molly_uncharge_molly",0)
	
	
}
stock ground_z(iOrigin[3], ent, skip = 0, iRecursion = 0) {

	iOrigin[2] += random_num(5, 80);

	if (!pev_valid(ent)) {
		return iOrigin[2];
	}

	new Float:fOrigin[3];
	IVecFVec(iOrigin, fOrigin);
	set_pev(ent, pev_origin, fOrigin);
	engfunc(EngFunc_DropToFloor, ent);

	if (!skip && !engfunc(EngFunc_EntIsOnFloor, ent)) {
		if (iRecursion >= ANTI_LAGG) {
			skip = 1;
		}

		return ground_z(iOrigin, ent, skip, ++iRecursion);
	}

	pev(ent, pev_origin, fOrigin);

	return floatround(fOrigin[2]);
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!tranq_get_has_erica(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_hegrenade", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_HEGRENADE){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))||!molly_loaded[id]) return FMRES_IGNORED
			if(erica_get_num_mollies(id) == 0)
			{
				client_print(id, print_center, "You are out of mollies sis!!!")
				sh_drop_weapon(id,CSW_HEGRENADE,true)
				uncharge_user(id)
				return FMRES_IGNORED
			}
			if(!molly_armed[id]){
				molly_armed[id]=true
				curr_charge[id]=0.0
				charge_user(id)
				
			}
			
		}
		else if(molly_armed[id]){
			if(curr_charge[id]>=min_charge_time){
				launch_molly(id)
				client_print(id,print_center,"You have %d mollies left siss!!!! %d left!!!!!",
				erica_get_num_mollies(id),erica_get_num_mollies(id)
				);
			}
			else if(curr_charge[id]>0.0){
				sh_chat_message(id,tranq_get_hero_id(),"Chaff not charged! Not launched...");
				
			}
			uncharge_user(id)
			
		}
	}
	else
	{
		uncharge_user(id)
	}
	if(ent){
		cs_set_user_bpammo(id, CSW_HEGRENADE,erica_get_num_mollies(id));
		
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
	
	max_charge_time=get_cvar_float("erica_molly_max_charge_time")
	min_charge_time=get_cvar_float("erica_molly_min_charge_time")
}


public charge_task(id){
	id-=MOLLY_CHARGE_TASKID
	new hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],MOLLY_CHARGE_PERIOD)
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
	100.0*(curr_charge[id]/max_charge_time)
	);
	
	client_print(id,print_center,"%s",hud_msg)
	
	
	
	
	
	
}
charge_user(id){
	set_task(MOLLY_CHARGE_PERIOD,"charge_task",id+MOLLY_CHARGE_TASKID,"", 0,  "a",MOLLY_CHARGE_TIMES)
	set_task(floatmul(MOLLY_CHARGE_PERIOD,float(MOLLY_CHARGE_TIMES))+1.0,"uncharge_task",id+UNMOLLY_CHARGE_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
public _molly_uncharge_molly(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	
	
}
public uncharge_task(id){
	id-=UNMOLLY_CHARGE_TASKID
	remove_task(id+MOLLY_CHARGE_TASKID)
	molly_armed[id]=false
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNMOLLY_CHARGE_TASKID)
	remove_task(id+MOLLY_CHARGE_TASKID)
	molly_armed[id]=false
	return 0
	
	
	
}
/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_isnt_hitter(gatling_user){


return (!tranq_get_has_erica(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_mollies(iPlugin,iParams){

new grenada = find_ent_by_class(-1, MOLLY_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, MOLLY_CLASSNAME)
}
}
public _molly_get_molly_loaded(iPlugin,iParams){

new id=get_param(1)
return molly_loaded[id]

}
launch_molly(id)
{
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, MOLLY_CLASSNAME)
entity_set_model(Ent,MOLLY_W_MODEL)

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

VelocityByAim(id, floatround(MOLLY_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

molly_loaded[id] = false

erica_dec_num_mollies(id)

new parm[1]
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, MOLLY_THROW_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(0.01, "mollytrail",id,parm,1)
//set_task(MOLLY_SHOOT_PERIOD, "blow_molly_up",Ent+MOLLY_BLAST_TASKID,"",0)

return PLUGIN_CONTINUE
}

public molly_reload(parm[])
{
if(!is_user_alive(parm[0])||!tranq_get_has_erica(parm[0])||!is_user_connected(parm[0])) return
molly_loaded[parm[0]] = true
new clip,ammo,wid=get_user_weapon(parm[0],clip,ammo)
if((wid==CSW_HEGRENADE)&&erica_get_num_mollies(parm[0])){
entity_set_string(parm[0], EV_SZ_viewmodel, MOLLY_V_MODEL)
}
}
public mollytrail(parm[])
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


public blow_molly_up(id_molly){
id_molly-=MOLLY_BLAST_TASKID

if ( !is_valid_ent(id_molly) ) return

new szClassName[32]
Entvars_Get_String(id_molly, EV_SZ_classname, szClassName, 31)

if(equal(szClassName, MOLLY_CLASSNAME)) {

new Float:fl_vExplodeAt[3]
Entvars_Get_Vector(id_molly, EV_VEC_origin, fl_vExplodeAt)
new vExplodeAt[3]
vExplodeAt[0] = floatround(fl_vExplodeAt[0])
vExplodeAt[1] = floatround(fl_vExplodeAt[1])
vExplodeAt[2] = floatround(fl_vExplodeAt[2])
new id = Entvars_Get_Edict(id_molly, EV_ENT_owner)
new origin[3],dist,i
make_shockwave(vExplodeAt, MOLLY_RADIUS, molly_color)
random_fire(vExplodeAt, id_molly, MOLLY_RADIUS);
emit_sound(id_molly, CHAN_WEAPON, MOLLY_BURST_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

for ( i = 1; i <= SH_MAXSLOTS; i++) {
	
	if( !client_hittable(i) ) continue
	get_user_origin(i,origin)
	dist = get_distance(origin,vExplodeAt)
	if (dist <= MOLLY_RADIUS) {
		
		sh_molly_user(i,id,tranq_get_hero_id())
		
	}
}

new parm[1]
parm[0]=id
remove_molly(parm,id_molly+MOLLY_REM_TASKID)
}

}

public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return

new szClassName[32]
entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
if(equal(szClassName,MOLLY_CLASSNAME))
{
	if(pev(pTouched,pev_solid)==SOLID_BSP){
		emit_sound(pToucher, CHAN_WEAPON, MOLLY_BURST_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		blow_molly_up(pToucher+MOLLY_BLAST_TASKID)
	}

}
}


public remove_molly(parm[],id_molly){
id_molly-=MOLLY_REM_TASKID
if(!is_valid_ent(id_molly)) return
molly_loaded[parm[0]]=true
remove_entity(id_molly)


}
public plugin_precache()
{
	precache_explosion_fx()

	precache_model(MOLLY_V_MODEL);
	precache_model(MOLLY_W_MODEL);
	precache_model(MOLLY_P_MODEL);

	engfunc(EngFunc_PrecacheSound, MOLLY_BURST_SFX)
	engfunc(EngFunc_PrecacheSound, MOLLY_FIRE_SFX)



}
