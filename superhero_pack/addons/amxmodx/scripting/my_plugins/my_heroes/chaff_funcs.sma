#include "../my_include/superheromod.inc"
#include "chaff_grenade_inc/sh_teliko_get_set.inc"
#include "chaff_grenade_inc/sh_chaff_funcs.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_inc_pt2.inc"


#define PLUGIN "Superhero teliko mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:chaff_loaded[SH_MAXSLOTS+1]

new bool:chaff_armed[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]

new Float:min_charge_time,Float:max_charge_time

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	arrayset(chaff_loaded,true,SH_MAXSLOTS+1)
	arrayset(chaff_armed,false,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	register_cvar("teliko_chaff_max_charge_time", "5.0")
	register_cvar("teliko_chaff_min_charge_time", "1.0")
}

public plugin_natives(){
	
	
	register_native( "clear_chaffs","_clear_chaffs",0)
	register_native( "chaff_get_chaff_loaded","_chaff_get_chaff_loaded",0)
	register_native( "chaff_uncharge_chaff","_chaff_uncharge_chaff",0)
	
	
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!client_hittable(id,teliko_get_has_teliko(id))) return FMRES_IGNORED;
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return FMRES_IGNORED
	}
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_smokegrenade", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_SMOKEGRENADE){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))||!chaff_loaded[id]) return FMRES_IGNORED
			if(teliko_get_num_chaffs(id) == 0)
			{
				client_print(id, print_center, "You are out of chaffs")
				sh_drop_weapon(id,CSW_SMOKEGRENADE,true)
				engclient_cmd(id, "weapon_knife")
				uncharge_user(id)
				return FMRES_IGNORED
			}
			if(!chaff_armed[id]){
				chaff_armed[id]=true
				curr_charge[id]=0.0
				charge_user(id)
				
			}
			else if((100.0*(curr_charge[id]/max_charge_time))>95.0){
				
				
				launch_chaff(id)
				client_print(id,print_center,"You have %d chaffs left",
				teliko_get_num_chaffs(id)
				);
				uncharge_user(id)
				return FMRES_IGNORED
			}
			
		}
		else if(chaff_armed[id]){
			if(curr_charge[id]>=min_charge_time){
				launch_chaff(id)
				client_print(id,print_center,"You have %d chaffs left",
				teliko_get_num_chaffs(id)
				);
			}
			else if(curr_charge[id]>0.0){
				sh_chat_message(id,teliko_get_hero_id(),"Chaff not charged! Not launched...");
				
			}
			uncharge_user(id)
			
		}
	}
	else
	{
		uncharge_user(id)
	}
	if(ent){
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE,teliko_get_num_chaffs(id));
		
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
	
	max_charge_time=get_cvar_float("teliko_chaff_max_charge_time")
	min_charge_time=get_cvar_float("teliko_chaff_min_charge_time")
}


public charge_task(id){
	id-=CHAFF_CHARGE_TASKID
	new hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],CHAFF_CHARGE_PERIOD)
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
	100.0*(curr_charge[id]/max_charge_time)
	);
	client_print(id,print_center,"%s",hud_msg)
	
	
	
	
	
	
}
charge_user(id){
	set_task(CHAFF_CHARGE_PERIOD,"charge_task",id+CHAFF_CHARGE_TASKID,"", 0,  "a",CHAFF_CHARGE_TIMES)
	set_task(floatmul(CHAFF_CHARGE_PERIOD,float(CHAFF_CHARGE_TIMES))+1.0,"uncharge_task",id+UNCHAFF_CHARGE_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
public _chaff_uncharge_chaff(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	
	
}
public uncharge_task(id){
	id-=UNCHAFF_CHARGE_TASKID
	remove_task(id+CHAFF_CHARGE_TASKID)
	chaff_armed[id]=false
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNCHAFF_CHARGE_TASKID)
	remove_task(id+CHAFF_CHARGE_TASKID)
	chaff_armed[id]=false
	return 0
	
	
	
}

public _clear_chaffs(iPlugin,iParams){

new grenada = find_ent_by_class(-1, CHAFF_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, CHAFF_CLASSNAME)
}
}
public _chaff_get_chaff_loaded(iPlugin,iParams){

new id=get_param(1)
return chaff_loaded[id]

}
launch_chaff(id)
{
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, CHAFF_CLASSNAME)
entity_set_model(Ent,"models/w_smokegrenade.mdl")

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

VelocityByAim(id, floatround(CHAFF_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

chaff_loaded[id] = false

teliko_dec_num_chaffs(id)

new parm[1]
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, CHAFF_THROW_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(0.01, "chafftrail",id,parm,1)
set_task(CHAFF_SHOOT_PERIOD, "blow_chaff_up",Ent+CHAFF_BLAST_TASKID,"",0)

return PLUGIN_CONTINUE
}

public chaff_reload(parm[])
{
if(!is_user_alive(parm[0])||!teliko_get_has_teliko(parm[0])||!is_user_connected(parm[0])) return
chaff_loaded[parm[0]] = true
new clip,ammo,wid=get_user_weapon(parm[0],clip,ammo)
if((wid==CSW_SMOKEGRENADE)&&teliko_get_num_chaffs(parm[0])){
entity_set_string(parm[0], EV_SZ_viewmodel, CHAFF_V_MODEL)
}
}
public chafftrail(parm[])
{
new pid = parm[0]
trail(pid,WHITE,10,5)
}
public blow_chaff_up(id_chaff){
id_chaff-=CHAFF_BLAST_TASKID

if ( !is_valid_ent(id_chaff) ) return

new szClassName[32]
Entvars_Get_String(id_chaff, EV_SZ_classname, szClassName, 31)

if(equal(szClassName, CHAFF_CLASSNAME)) {

new Float:fl_vExplodeAt[3]
Entvars_Get_Vector(id_chaff, EV_VEC_origin, fl_vExplodeAt)
new vExplodeAt[3]
vExplodeAt[0] = floatround(fl_vExplodeAt[0])
vExplodeAt[1] = floatround(fl_vExplodeAt[1])
vExplodeAt[2] = floatround(fl_vExplodeAt[2])
new id = Entvars_Get_Edict(id_chaff, EV_ENT_owner)
new origin[3],dist,i
make_shockwave(vExplodeAt,CHAFF_RADIUS,LineColorsWithAlpha[WHITE],1,5,8,4)
anime_kill_fx(vExplodeAt)
emit_sound(id_chaff, CHAN_WEAPON, CHAFF_EXPLODE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
for ( i = 1; i <= SH_MAXSLOTS; i++) {
	
	if( !client_hittable(i) ) continue
	get_user_origin(i,origin)
	dist = get_distance(origin,vExplodeAt)
	if (dist <= CHAFF_RADIUS) {
		
		sh_chaff_user(i,id,teliko_get_hero_id())
		
	}
}

new parm[1]
parm[0]=id
remove_chaff(parm,id_chaff+CHAFF_REM_TASKID)
}

}

public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return

new szClassName[32]
entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
if(equal(szClassName,CHAFF_CLASSNAME))
{
new Float:velocity[3]
entity_get_vector(pToucher, EV_VEC_velocity ,velocity)
if(pev(pTouched,pev_solid)==SOLID_BSP){
	emit_sound(pToucher, CHAN_WEAPON, CHAFF_BOUNCE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	velocity[0]*=0.5
	velocity[1]*=0.5
	velocity[2]*=0.5
	entity_set_vector(pToucher, EV_VEC_velocity ,velocity)
}

}
}

public remove_chaff(parm[],id_chaff){
id_chaff-=CHAFF_REM_TASKID
if(!is_valid_ent(id_chaff)) return
chaff_loaded[parm[0]]=true
remove_entity(id_chaff)


}
public plugin_precache()
{
precache_explosion_fx()
precache_sound("ambience/particle_suck2.wav")
precache_model("models/w_smokegrenade.mdl")
engfunc(EngFunc_PrecacheSound, CHAFF_BOUNCE_SFX)
engfunc(EngFunc_PrecacheSound,CHAFF_EXPLODE_SFX)

}
