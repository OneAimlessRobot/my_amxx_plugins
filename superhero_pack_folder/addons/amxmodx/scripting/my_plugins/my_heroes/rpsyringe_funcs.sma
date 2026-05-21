#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_rpsyringe_funcs.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"


#define PLUGIN "Superhero yakui mk2 pt4"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
new gHeroID = -1

new gNumRockets[SH_MAXSLOTS+1]

new RPSYRINGE_RELOAD_TIMER_TASKID = 0

new gRocketsEngaged_mask = 0
new has_rocket[SH_MAXSLOTS+1] = {0, ...}

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_entity_as_wall_touchable(ROCKET_CLASSNAME,"seringa_toqueta_de_entiteta")
	register_custom_touchable(ROCKET_CLASSNAME,"seringa_toqueta_de_entiteta",player_vector,1)
	static const custom_vector[][]={ROCKET_CLASSNAME}
	register_custom_touchable(ROCKET_CLASSNAME,"seringa_toqueta_de_la_seringa",custom_vector,1)

	register_forward(FM_CmdStart, "CmdStart");
	RPSYRINGE_RELOAD_TIMER_TASKID =allocate_typed_task_id(player_task)
}

public plugin_natives(){

	register_native("gatling_set_num_rockets","_gatling_set_num_rockets",0);
	register_native("gatling_get_num_rockets","_gatling_get_num_rockets",0);
	register_native("gatling_dec_num_rockets","_gatling_dec_num_rockets",0);

	register_native("gatling_set_rockets","_gatling_set_rockets",0);
	register_native("gatling_get_rockets","_gatling_get_rockets",0);
	
	
}

public plugin_cfg(){

	gHeroID = gatling_get_hero_id()
}
public _gatling_get_rockets(iPlugin,iParams){
	new id=get_param(1)
	return Get_BitVar(gRocketsEngaged_mask,id)	
}
public _gatling_set_rockets(iPlugin,iParams){
	
	new id= get_param(1)
	new value_to_set= get_param(2);
	Assign_BitVar(gRocketsEngaged_mask,id, value_to_set)	
}

public _gatling_set_num_rockets(iPlugin,iParams){

	new id= get_param(1)
	new value_to_set=get_param(2)
	if(!is_user_connected(id)){
		
		return
	}
	gNumRockets[id]=value_to_set;

}

public _gatling_get_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return -1
	}
	return gNumRockets[id]

}

public _gatling_dec_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return
	}
	gNumRockets[id]-= (gNumRockets[id]>0)? 1:0

}
public CmdStart(id, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if ( !hasRoundStarted()||!client_is_hero_user(id, gHeroID)) return FMRES_IGNORED;
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==YAKUI_WEAPON_CLASSID){
		if(button & IN_ATTACK2)
		{
			button &= ~IN_ATTACK2;
			set_uc(uc_handle, UC_Buttons, button);
			if( !Get_BitVar(gRocketsEngaged_mask,id) || !(is_user_alive(id))||has_rocket[id]) return FMRES_IGNORED
			if(gNumRockets[id] == 0)
			{
				if(!is_user_bot(id)){
					client_print(id, print_center, "You are out of rockets")
				}
				return FMRES_IGNORED
			}
			make_rocket(id,floatround(ROCKET_SPEED))
			
		}
	}
	
	return FMRES_IGNORED;
}
public seringa_toqueta_de_la_seringa(pToucher, pTouched) {

	if(!is_valid_ent(pToucher)) return
	
	remove_missile(pToucher)
}

public seringa_toqueta_de_entiteta(pToucher, pTouched) {
	
	if(!is_valid_ent(pToucher)) return

	static Float:fl_vExplodeAt[3]
	entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
	new id = entity_get_edict(pToucher, EV_ENT_owner)
	
	//retrieve current rocket fx num

	
	new fx_id:fx_num=fx_id:entity_get_int(pToucher,EV_INT_iuser3)
	new entlist[33];
	new numfound = find_sphere_class(pToucher,"player", ROCKET_RADIUS ,entlist, 32);
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		if( !is_user_alive(pid) ) continue
		
		make_effect(pid,id,gHeroID,fx_num,false)
	}
	
	anime_kill_fx(fl_vExplodeAt)
	
	emit_sound(pToucher, CHAN_WEAPON, SMOKE_EXPLODE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	new color[3]
	sh_get_pill_color(fx_num,id,color)
	make_shockwave(fl_vExplodeAt,ROCKET_RADIUS,color)

	remove_missile(pToucher)
}
make_rocket(id,iarg1)
{

new Float:vOrigin[3]
new Float:vAngles[3]
entity_get_vector(id, EV_VEC_origin, vOrigin)
entity_get_vector(id, EV_VEC_v_angle, vAngles)
new notFloat_vOrigin[3]
notFloat_vOrigin[0] = floatround(vOrigin[0])
notFloat_vOrigin[1] = floatround(vOrigin[1])
notFloat_vOrigin[2]  =floatround(floatadd( vOrigin[2] , 50.0))


new NewEnt
NewEnt = create_entity("info_target")
if(NewEnt == 0) {
if(!is_user_bot(id)){
	client_print(id,print_chat,"[SH](Yakui the Maid Mk2): Rocket fail!")
}
return PLUGIN_HANDLED
}

entity_set_string(NewEnt, EV_SZ_classname, ROCKET_CLASSNAME)
entity_set_model(NewEnt, "models/rpgrocket.mdl")

new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

entity_set_vector(NewEnt, EV_VEC_mins,fl_vecminsx)
entity_set_vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

entity_set_origin(NewEnt, vOrigin)
entity_set_vector(NewEnt, EV_VEC_angles, vAngles)
entity_set_int(NewEnt, EV_INT_effects, 64)
entity_set_int(NewEnt, EV_INT_solid, 2)

entity_set_int(NewEnt, EV_INT_movetype, 10)


entity_set_edict(NewEnt, EV_ENT_owner, id)

new Float:fl_iNewVelocity[3]
new iNewVelocity[3]
velocity_by_aim(id, iarg1, fl_iNewVelocity)
entity_set_vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)
iNewVelocity[0] = floatround(fl_iNewVelocity[0])
iNewVelocity[1] = floatround(fl_iNewVelocity[1])
iNewVelocity[2] = floatround(fl_iNewVelocity[2])

emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
has_rocket[id] = NewEnt

gNumRockets[id]-= (gNumRockets[id]>0)? 1:0

new fx_id:fx_num=sh_gen_effect()

//this will store the fx num in the rocket ent
entity_set_int(NewEnt,EV_INT_iuser3,fx_num)
trail(NewEnt,FX_COLOR_OFFSET(fx_num),30,20)
entity_set_float(NewEnt, EV_FL_gravity, 0.75)
set_task(ROCKET_SHOOT_PERIOD,"reload_rocket_task",id+RPSYRINGE_RELOAD_TIMER_TASKID)

return PLUGIN_HANDLED
}
public reload_rocket_task(id){

	id-=RPSYRINGE_RELOAD_TIMER_TASKID

	if(is_user_connected(id)){
		has_rocket[id]=0
	}


}
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
has_rocket[id] = 0
}
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
remove_missile(missile){
if(!pev_valid(missile)){
	
	return PLUGIN_CONTINUE
}

new Float:fl_origin[3]
entity_get_vector(missile, EV_VEC_origin, fl_origin)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_IMPLOSION)
write_coord(floatround(fl_origin[0]))
write_coord(floatround(fl_origin[1]))
write_coord(floatround(fl_origin[2]))
write_byte (200)
write_byte (40)
write_byte (45)
message_end()

emit_sound(missile, CHAN_VOICE, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
emit_sound(missile, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
emit_sound(missile, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
remove_entity(missile)
return PLUGIN_CONTINUE
}

public plugin_precache()
{
engfunc(EngFunc_PrecacheSound,SMOKE_EXPLODE_SOUND)
engfunc(EngFunc_PrecacheModel,GATLING_P_MODEL)
engfunc(EngFunc_PrecacheModel,GATLING_V_MODEL)

}
