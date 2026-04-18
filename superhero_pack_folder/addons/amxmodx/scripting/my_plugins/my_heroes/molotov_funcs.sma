#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_funcs.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "../my_include/stripweapons.inc"


#define PLUGIN "Superhero molotov funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new bool:molly_loaded[SH_MAXSLOTS+1]

new bool:molly_armed[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]


new Float:min_charge_time,Float:max_charge_time


stock MOLLY_CHARGE_TASKID,
		UNMOLLY_CHARGE_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(molly_loaded,true,SH_MAXSLOTS+1)
	arrayset(molly_armed,false,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	register_think(MOLLY_CLASSNAME,"molly_think")

	register_cvar("erica_molly_max_charge_time", "5.0")
	register_cvar("erica_molly_min_charge_time", "1.0")


	register_entity_as_wall_touchable(MOLLY_CLASSNAME,"molly_burner_um_burner")
	register_custom_touchable(MOLLY_CLASSNAME,"molly_burner_um_burner",player_vector,1)

	MOLLY_CHARGE_TASKID=allocate_typed_task_id(player_task)
	UNMOLLY_CHARGE_TASKID=allocate_typed_task_id(player_task)
}

public plugin_natives(){

	register_native( "molly_get_molly_loaded","_molly_get_molly_loaded",0)
	register_native( "molly_uncharge_molly","_molly_uncharge_molly",0)
	
	
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!client_hittable(id,sh_user_has_hero(id,tranq_get_hero_id()))) return FMRES_IGNORED;
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return FMRES_IGNORED
	}
	
	if(sh_get_stun(id)) return FMRES_IGNORED

	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, MOLLY_WEAPON_NAME, id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==MOLLY_CLASSID){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))||!molly_loaded[id]) return FMRES_IGNORED
			if(!molly_armed[id]){
				molly_armed[id]=true
				curr_charge[id]=0.0
				charge_user(id)
				
			}
			else if((100.0*(curr_charge[id]/max_charge_time))>95.0){
				
				launch_molly(id)
				
				if(!is_user_bot(id)){
					client_print(id,print_center,"You have %d mollies left siss!!!! %d left!!!!!",
					erica_get_num_mollies(id),erica_get_num_mollies(id)
					);
				}
				uncharge_user(id)
			}
			
		}
		else if(molly_armed[id]){
			if(curr_charge[id]>=min_charge_time){
				launch_molly(id)
				if(!is_user_bot(id)){
					client_print(id,print_center,"You have %d mollies left siss!!!! %d left!!!!!",
					erica_get_num_mollies(id),erica_get_num_mollies(id)
					);
				}
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
		cs_set_user_bpammo(id, MOLLY_CLASSID,erica_get_num_mollies(id));
		strip_weapon_for_my_grenade_heroes(id,"You are out of mollies sis!!!",MOLLY_CLASSID,!erica_get_num_mollies(id))
	
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
	formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
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
public _molly_get_molly_loaded(iPlugin,iParams){

new id=get_param(1)
return molly_loaded[id]

}
launch_molly(id)
{
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

velocity_by_aim(id, floatround(MOLLY_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

molly_loaded[id] = false

erica_dec_num_mollies(id)
if(erica_get_num_mollies(id) == 0)
{
	client_print(id, print_center, "You are out of %s s, sis!",MOLLY_WEAPON_NAME)
	sh_drop_weapon(id,MOLLY_CLASSID,true)
	engclient_cmd(id, "weapon_knife")
}
emit_sound(id, CHAN_WEAPON, THROWABLE_LAUNCH_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
trail(Ent,PINK,10,5)
entity_set_float(Ent,EV_FL_nextthink,get_gametime()+MOLLY_SHOOT_PERIOD)
return PLUGIN_CONTINUE
}

public molly_think(id_molly){


if ( !is_valid_ent(id_molly) ) return

new Float:fl_vExplodeAt[3]
entity_get_vector(id_molly, EV_VEC_origin, fl_vExplodeAt)
new vExplodeAt[3]
vExplodeAt[0] = floatround(fl_vExplodeAt[0])
vExplodeAt[1] = floatround(fl_vExplodeAt[1])
vExplodeAt[2] = floatround(fl_vExplodeAt[2])
new id = entity_get_edict(id_molly, EV_ENT_owner)
make_shockwave(vExplodeAt, MOLLY_RADIUS, LineColors[PINK],_,_,_,_,200)
anime_kill_fx(vExplodeAt)
random_fire(vExplodeAt, id_molly, MOLLY_RADIUS);
emit_sound(id_molly, CHAN_WEAPON, GLASS_VIAL_BREAK, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
static entlist[33];
new numfound = find_sphere_class(id_molly,"player", MOLLY_RADIUS ,entlist, 32);

for( new i= 0;(i< numfound);i++){

	new pid = entlist[i];
	if( !client_hittable(pid) ) continue
	
	sh_molly_user(pid,id,tranq_get_hero_id())
	
}

remove_molly(id,id_molly)

}

public molly_burner_um_burner(pToucher, pTouched)
{

	new Float:velocity[3]
	entity_get_vector(pToucher, EV_VEC_velocity ,velocity)
	emit_sound(pToucher, CHAN_WEAPON, CUSTOM_GRENADE_BOUNCE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	velocity[0]*=0.5
	velocity[1]*=0.5
	velocity[2]*=0.5
	entity_set_vector(pToucher, EV_VEC_velocity ,velocity)

}


public remove_molly(id,id_molly){
if(!is_valid_ent(id_molly)) return
molly_loaded[id]=true
remove_entity(id_molly)


}
public plugin_precache()
{
	

	engfunc(EngFunc_PrecacheModel,MOLLY_W_MODEL);
	engfunc(EngFunc_PrecacheSound, THROWABLE_LAUNCH_SFX)
	engfunc(EngFunc_PrecacheSound, CUSTOM_GRENADE_BOUNCE_SOUND)
	engfunc(EngFunc_PrecacheSound, GLASS_VIAL_BREAK)
	engfunc(EngFunc_PrecacheSound, MOLLY_FIRE_SFX)



}
