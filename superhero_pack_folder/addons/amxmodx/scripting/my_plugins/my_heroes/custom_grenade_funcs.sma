#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "custom_grenades/custom_grenades.inc"

#include "chaff_fx_inc/chaff_fx.inc"

#include "disrupt_fx_inc/disrupt_fx.inc"

#include "tranq_gun_inc/sh_molotov_fx.inc"



#include "tranq_gun_inc/sh_tranq_fx.inc"

#include "freeze_fx/freeze_fx.inc"

#include "co2_fx_inc/co2_fx.inc"

#include "shock_fx_inc/shock_fx.inc"


#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "sh_aux_stuff/sh_aux_inc.inc"

#include "track_fx_inc/track_fx.inc"

#include "bleed_knife_inc/sh_bknife_fx.inc"

#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "../my_include/stripweapons.inc"

#define PLUGIN "Superhero custom grenades module"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

#define SH_CUSTOM_GRENADE_CLASSNAME "sh_custom_grenade"

new SH_CUSTOM_GRENADE_CHARGE_TASKID
enum sh_grenade_struct{

    sh_grenade_name[128],
    sh_grenade_modelname[128],
	sh_grenade_weaponname[128],
    sh_grenade_break_sound[128],
	sh_grenade_weapon_classid,
	sh_custom_color:grenade_color_num,
	Float:blast_radius,
    Float:sh_grenade_throw_speed,
	Float:min_charge_time,
	Float:max_charge_time,
	Float:throw_period,
	Float:after_touch_fuse


}

new sh_grenade_structs_arr[GREN_MAX_TYPES][sh_grenade_struct]={

	{"none","",
					"",
					"",
					0,
					CUSTOM,
					0.0,
					0.0,
					0.0,
					0.0,
					9999999.0,
					12211.0},
	
	
	{"molotov_cocktail",
					"models/shmod/custom_nades_hackaround/w_hegrenade.mdl",
					"weapon_hegrenade",
					GLASS_VIAL_BREAK,
					CSW_HEGRENADE,
					PINK,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					3.0},

	{"chaff_grenade","models/shmod/custom_nades_hackaround/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					crush_stunned,
					CSW_SMOKEGRENADE,
					WHITE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					0.5},

	{"sleep_grenade","models/shmod/custom_nades_hackaround/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					SMOKE_EXPLODE_SOUND,
					CSW_SMOKEGRENADE,
					BLUE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					6.0},

	{"CO2_grenade",
					"models/shmod/custom_nades_hackaround/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					EXTINGUISH_FIRE_SOUND,
					CSW_SMOKEGRENADE,
					LTGREEN,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					3.5},

	{"shock_grenade",
					"models/shmod/custom_nades_hackaround/w_flashbang.mdl",
					"weapon_flashbang",
					SHOCK_GRENADE_SOUND,
					CSW_FLASHBANG,
					LTBLUE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					0.5},

	{"freeze_grenade",
					"models/shmod/custom_nades_hackaround/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					FROZEN_SFX,
					CSW_SMOKEGRENADE,
					FROZEN_BLUE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					2.33},

	{"disrupt_grenade",
					"models/shmod/custom_nades_hackaround/w_flashbang.mdl",
					"weapon_flashbang",
					crush_stunned,
					CSW_FLASHBANG,
					YELLOW,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					0.5},

	{"shrapnel_grenade",
					"models/shmod/custom_nades_hackaround/w_hegrenade.mdl",
					"weapon_hegrenade",
					PIERCE_WOUND_SFX,
					CSW_HEGRENADE,
					RED,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					2.6},

	{"marker_grenade",
					"models/shmod/custom_nades_hackaround/w_hegrenade.mdl",
					"weapon_hegrenade",
					"shmod/komak/fast_shot.wav",
					CSW_HEGRENADE,
					ORANGE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5,
					4.0}

}

new sh_grenade_type:curr_user_grenade[SH_MAXSLOTS+1] = {sh_grenade_type:0, ...},
	sh_grenade_type:prev_user_grenade[SH_MAXSLOTS+1] = {sh_grenade_type:0, ...}

new grenade_change_button_pressed_mask = 0

new sh_grenade_armed_mask = 0

new Float:curr_charge[SH_MAXSLOTS+1]

new curr_grenade_ammo[SH_MAXSLOTS+1][GREN_MAX_TYPES]
/**


enum cs_grenade_animation_sequences{

	cs_grenade_idle = 0,
	cs_grenade_pullpin,
	cs_grenade_throw,
	cs_grenade_deploy


}

 */
switch_grenade_animation_on_player(id, cs_grenade_animation_sequences:the_sequence_id){



	native_playanim(id,_:the_sequence_id)

	
}
bool:is_weapon_id_grenade(wpn_id){

	return ((wpn_id==CSW_HEGRENADE)||(wpn_id==CSW_SMOKEGRENADE)||(wpn_id==CSW_FLASHBANG))

}

bool:user_has_grenade_on(id,&weapon_id=-1){

	if(!is_user_connected(id)) return false

	new wpn_id=get_user_weapon(id)
	
	new bool:result=is_weapon_id_grenade(wpn_id)

	weapon_id=(result?(wpn_id):-1)

	return result

}
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_forward(FM_CmdStart, "CmdStart");
	
	SH_CUSTOM_GRENADE_CHARGE_TASKID=allocate_typed_task_id(player_task)
	
	register_think(SH_CUSTOM_GRENADE_CLASSNAME,"sh_grenade_think")

	register_entity_as_wall_touchable(SH_CUSTOM_GRENADE_CLASSNAME,"sh_grenade_touch_things")
	
	init_progress_bar_msg_var()

	register_event("CurWeapon","event_curr_grenade","be", "1=1")
	
	register_event("DeathMsg","on_death_custom_grenades","a")
}

public plugin_natives(){
	
	register_native( "uncharge_custom_nade","_uncharge_custom_nade",0)
	register_native( "set_custom_grenade_ammo","_set_custom_grenade_ammo",0)
	register_native( "get_custom_grenade_ammo","_get_custom_grenade_ammo",0)
	register_native( "give_custom_grenades","_give_custom_grenades",0)
	
	
}
grenade_switch_notification(id){
	if(!is_user_bot(id)){
		client_print(id,print_center,"Grenade switch! (%s -> %s)",
			sh_grenade_structs_arr[prev_user_grenade[id]][sh_grenade_name],
			sh_grenade_structs_arr[curr_user_grenade[id]][sh_grenade_name]);
	}
}
public event_curr_grenade(id){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE;	
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;	
	
	new wpn_id=-1
	new bool:user_has_grenade=user_has_grenade_on(id, wpn_id)

	prev_user_grenade[id]=curr_user_grenade[id]
	
	if(!user_has_grenade){
		
		progressBar(id,0)
		UnSet_BitVar(sh_grenade_armed_mask,id)
		return PLUGIN_CONTINUE
	
	}
	if(wpn_id==sh_grenade_structs_arr[prev_user_grenade[id]][sh_grenade_weapon_classid]){

		curr_user_grenade[id]=prev_user_grenade[id]
		return PLUGIN_CONTINUE
	}
	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

		if((wpn_id==sh_grenade_structs_arr[i][sh_grenade_weapon_classid])&&(curr_grenade_ammo[id][i]>0)){

				curr_user_grenade[id]=i
				if(curr_user_grenade[id]!=prev_user_grenade[id]){
					
					grenade_switch_notification(id)
					progressBar(id,0)

					curr_charge[id]=0.0;
					UnSet_BitVar(sh_grenade_armed_mask ,id)
				}
				return PLUGIN_CONTINUE
		}
	}
	curr_user_grenade[id]=sh_grenade_type:0
	return PLUGIN_CONTINUE
}
//execute inside cmd start only!!

bool:handle_grenade_change_button(id,wpn_id,uc_handle, button){
	
	static bool:changed_greande;
	
	changed_greande=false;
	
	if(button & IN_ALT1){

		button &= ~IN_ALT1
		set_uc(uc_handle, UC_Buttons, button)
		if(!Get_BitVar(grenade_change_button_pressed_mask,id)){
			Set_BitVar(grenade_change_button_pressed_mask,id)

			static sh_grenade_type:curr;
			
			curr=((curr_user_grenade[id]+sh_grenade_type:1)%GREN_MAX_TYPES)
			
			for(new it=0; it<_:GREN_MAX_TYPES; it++){
				
				
				if(wpn_id!=sh_grenade_structs_arr[curr][sh_grenade_weapon_classid]||
							(curr_grenade_ammo[id][curr]<=0)){
					
					curr= ((curr+sh_grenade_type:1)%GREN_MAX_TYPES)
					continue
				}
				changed_greande=true
				prev_user_grenade[id]=curr_user_grenade[id]
				curr_user_grenade[id]=curr

				switch_grenade_animation_on_player(id,
								cs_grenade_deploy)
				if(prev_user_grenade[id]>GREN_NONE){
					grenade_switch_notification(id)
				}
				progressBar(id,0)
				curr_charge[id]=0.0;
				UnSet_BitVar(sh_grenade_armed_mask,id);
				break;
			}

		}
	}
	else{

		UnSet_BitVar(grenade_change_button_pressed_mask,id)
	}
	return changed_greande
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if(!sh_is_active()) return FMRES_IGNORED

	if (!is_user_alive(id)) return FMRES_IGNORED;
	
	new sh_grenade_type:gren_type=curr_user_grenade[id]
	new wpn_id=-1
	if(!user_has_grenade_on(id,wpn_id)||(gren_type<=GREN_NONE)){

		UnSet_BitVar(sh_grenade_armed_mask,id);
		return FMRES_IGNORED
	}
	new ent = find_ent_by_owner(-1, sh_grenade_structs_arr[gren_type][sh_grenade_weaponname], id);

	static button;
	button = get_uc(uc_handle, UC_Buttons);
	
	static bool:changed_custom_grenade,bool:attk2_pressed,bool:is_same_grenade;
	changed_custom_grenade=handle_grenade_change_button(id,wpn_id,uc_handle,button)
	is_same_grenade=(!changed_custom_grenade)
	
	attk2_pressed= bool:(button & IN_ATTACK2)

	if(attk2_pressed){

		button &= ~IN_ATTACK2;
		set_uc(uc_handle, UC_Buttons, button);
	}

	if(!is_same_grenade) return FMRES_IGNORED
	
	if(attk2_pressed)
	{

		if( !(is_user_alive(id))) return FMRES_IGNORED
		
		if(!Get_BitVar(sh_grenade_armed_mask,id)){
			Set_BitVar(sh_grenade_armed_mask,id)
			curr_charge[id]=0.0
			switch_grenade_animation_on_player(id,cs_grenade_pullpin)
			progressBar(id,
					floatround(sh_grenade_structs_arr[gren_type][max_charge_time]))
			charge_user(id,gren_type)

		}
		else if(((100.0*(curr_charge[id]/sh_grenade_structs_arr[gren_type][max_charge_time])))>95.0){

			launch_custom_grenade(id,gren_type)
			progressBar(id,0)
			UnSet_BitVar(sh_grenade_armed_mask,id)
		}
	}
	else if(Get_BitVar(sh_grenade_armed_mask,id)){
		if((curr_charge[id]>=sh_grenade_structs_arr[gren_type][min_charge_time])){
			launch_custom_grenade(id,gren_type)
		}
		else if(curr_charge[id]>0.0){
			switch_grenade_animation_on_player(id,
											cs_grenade_idle)
		}
		progressBar(id,0)
		UnSet_BitVar(sh_grenade_armed_mask,id)
	}
	if(ent){

		new total_classid_nades=0
		for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

			if((wpn_id==sh_grenade_structs_arr[i][sh_grenade_weapon_classid])&&
								(curr_grenade_ammo[id][i]>0)){
					total_classid_nades+=curr_grenade_ammo[id][i]
			}
		}

		cs_set_user_bpammo(id,wpn_id,min(total_classid_nades,
						cs_get_user_bpammo(id,wpn_id)))
		if(total_classid_nades<=0){
			strip_weapon_for_my_grenade_heroes(id,_,wpn_id,true)
		}

	}
	return FMRES_IGNORED;
}

public sh_round_end(){

	remove_entity_name(SH_CUSTOM_GRENADE_CLASSNAME)

}

public _give_custom_grenades(iPlugin, iParams){
	new id=get_param(1)
	new sh_grenade_type:gren_type= sh_grenade_type:get_param(2)
	new grenade_ammount= get_param(3)
	if ( sh_is_active() && is_user_alive(id)){

		new ammo=cs_get_user_bpammo(id,
					sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid]);

		cs_set_user_bpammo(id,
					sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],ammo+grenade_ammount);
		
		sh_give_weapon(id,sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],false)
		
		curr_grenade_ammo[id][gren_type]=grenade_ammount
	}


}
public charge_task(any:param[1],id){
	if(!sh_is_active()||sh_is_freezetime()) return

	new sh_grenade_type:the_type= sh_grenade_type:param[0]
	id-=SH_CUSTOM_GRENADE_CHARGE_TASKID

	if(!is_user_alive(id)) return


	new wpn_id=get_user_weapon(id)

	curr_charge[id]=floatadd(curr_charge[id],SH_CUSTOM_GRENADE_CHARGE_PERIOD)
	
	if(((wpn_id==sh_grenade_structs_arr[the_type][sh_grenade_weapon_classid])&&
				curr_user_grenade[id]==the_type)&&
				Get_BitVar(sh_grenade_armed_mask,id)){
		set_task(SH_CUSTOM_GRENADE_CHARGE_PERIOD,"charge_task",id+SH_CUSTOM_GRENADE_CHARGE_TASKID,param,sizeof(param))
	}
	
	
	
}
charge_user(id,sh_grenade_type:the_type){
	new parm[1]
	parm[0]=the_type
	set_task(SH_CUSTOM_GRENADE_CHARGE_PERIOD,"charge_task",
		id+SH_CUSTOM_GRENADE_CHARGE_TASKID,
		parm,
		sizeof(parm))
}
public _uncharge_custom_nade(iPlugin,iParams){
	new id=get_param(1)
	UnSet_BitVar(sh_grenade_armed_mask,id)
	
	
}
public _set_custom_grenade_ammo(iPlugin,iParams){
	new id=get_param(1)
	new sh_grenade_type:gren_type= sh_grenade_type:get_param(2)
	new grenade_ammount= get_param(3)

	curr_grenade_ammo[id][gren_type]=grenade_ammount
	
	
}
public _get_custom_grenade_ammo(iPlugin,iParams){
	new id=get_param(1)
	new sh_grenade_type:gren_type= sh_grenade_type:get_param(2)

	return curr_grenade_ammo[id][gren_type]
	
	
}

launch_custom_grenade(id,sh_grenade_type:the_type)
{

switch_grenade_animation_on_player(id,cs_grenade_throw)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname,SH_CUSTOM_GRENADE_CLASSNAME)

entity_set_model(Ent,
				sh_grenade_structs_arr[the_type][sh_grenade_modelname])



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

/*

set grenade type!

Its iuser3!

*/

entity_set_int(Ent,EV_INT_iuser3,_:the_type)

velocity_by_aim(id, floatround(
				sh_grenade_structs_arr[the_type][sh_grenade_throw_speed]*
				(curr_charge[id]/sh_grenade_structs_arr[the_type][max_charge_time])),
				Velocity)

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
curr_grenade_ammo[id][the_type]=max(0,curr_grenade_ammo[id][the_type]-1)
new prev_vanilla_ammo=
	cs_get_user_bpammo(id,
	sh_grenade_structs_arr[the_type][sh_grenade_weapon_classid])

cs_set_user_bpammo(id,sh_grenade_structs_arr[the_type][sh_grenade_weapon_classid],
	prev_vanilla_ammo-1)

if(!curr_grenade_ammo[id][the_type])
{
	
	if(!is_user_bot(id)){
		client_print(id, print_center, "You are out of %s grenades.",
								sh_grenade_structs_arr[the_type][sh_grenade_name])
	}
	engclient_cmd(id, "weapon_knife")
}
else{
	if(!is_user_bot(id)){
		client_print(id, print_center, "You have %d %s grenades left.",
								get_custom_grenade_ammo(id,the_type),
								sh_grenade_structs_arr[the_type][sh_grenade_name])
	}
	engclient_cmd(id, "weapon_knife")

}
emit_sound(id, CHAN_WEAPON, THROWABLE_LAUNCH_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
trail(Ent,sh_grenade_structs_arr[the_type][grenade_color_num],10,5)
//set curr grenade touched wall -> 0 as a start
//set prev grenade touched wall -> 0 as a start
entity_set_int(Ent,EV_INT_iuser1,0)
entity_set_int(Ent,EV_INT_iuser2,0)
entity_set_float(Ent,EV_FL_nextthink,get_gametime()+1.0)

return PLUGIN_CONTINUE
}



public sh_grenade_think(id_grenade){

if ( !is_valid_ent(id_grenade) ) return PLUGIN_CONTINUE

new owner=entity_get_edict(id_grenade,EV_ENT_owner);

if(!is_user_connected(owner)){
	remove_entity(id_grenade)
	return PLUGIN_CONTINUE
}
static bool:prev_touched_wall,
		bool:curr_touched_wall,
		sh_grenade_type:the_type 

//get grenade type!
the_type = sh_grenade_type:entity_get_int(id_grenade,EV_INT_iuser3)

if(the_type<=sh_grenade_type:0){


	remove_entity(id_grenade)
	return PLUGIN_CONTINUE

}

//get touched wall state of grenade


prev_touched_wall = bool:entity_get_int(id_grenade,EV_INT_iuser2)
curr_touched_wall = bool:entity_get_int(id_grenade,EV_INT_iuser1)
entity_set_int(id_grenade,EV_INT_iuser2, _:curr_touched_wall)

if(!curr_touched_wall){

/*
if we havent touched a wall
keep waiting for the flag to be set by the touch hook
for the fuse to activate
*/

entity_set_float(id_grenade,EV_FL_nextthink,get_gametime()+1.0)
return PLUGIN_CONTINUE


}
if(!prev_touched_wall){

	entity_set_float(id_grenade,EV_FL_nextthink,
		get_gametime()+sh_grenade_structs_arr[the_type][after_touch_fuse])
	return PLUGIN_CONTINUE

}

static Float:fl_vExplodeAt[3]
entity_get_vector(id_grenade, EV_VEC_origin, fl_vExplodeAt)

fl_vExplodeAt[2] = fl_vExplodeAt[2]+30.0
make_shockwave(fl_vExplodeAt,
			sh_grenade_structs_arr[the_type][blast_radius],
			LineColors[sh_grenade_structs_arr[the_type][grenade_color_num]],1,5,8,4)

anime_kill_fx(fl_vExplodeAt)

emit_sound(id_grenade, CHAN_WEAPON,
				sh_grenade_structs_arr[the_type][sh_grenade_break_sound],
				VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

static entlist[33];
new numfound = find_sphere_class(id_grenade,"player",
				sh_grenade_structs_arr[the_type][blast_radius],
				entlist,
				charsmax(entlist));

for( new i= 0;(i< numfound);i++){

	new pid = entlist[i];
	if( !is_user_alive(pid) ) continue
	
	gren_effect_user(pid,owner,the_type)
}


remove_entity(id_grenade)
return PLUGIN_CONTINUE

}

public sh_grenade_touch_things(pToucher, pTouched)
{
	
	
	if(!is_valid_ent(pToucher)) return PLUGIN_CONTINUE
	if(!(bool:entity_get_int(pToucher,EV_INT_iuser1))){

		entity_set_int(pToucher,EV_INT_iuser1,1)
	}
	new Float:velocity[3]
	entity_get_vector(pToucher, EV_VEC_velocity ,velocity)
	emit_sound(pToucher, CHAN_WEAPON, CUSTOM_GRENADE_BOUNCE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	velocity[0]*=0.5
	velocity[1]*=0.5
	velocity[2]*=0.5
	entity_set_vector(pToucher, EV_VEC_velocity ,velocity)
	
	return PLUGIN_CONTINUE
}

public plugin_precache()
{

engfunc(EngFunc_PrecacheSound,"ambience/particle_suck2.wav")
engfunc(EngFunc_PrecacheSound, CUSTOM_GRENADE_BOUNCE_SOUND)
engfunc(EngFunc_PrecacheSound, THROWABLE_LAUNCH_SFX)

for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

	engfunc(EngFunc_PrecacheSound, sh_grenade_structs_arr[i][sh_grenade_break_sound])
	engfunc(EngFunc_PrecacheModel, sh_grenade_structs_arr[i][sh_grenade_modelname])
}


}
public on_death_custom_grenades(){
	if(!sh_is_active()) return
	
	new id = read_data(2)
	if(!is_user_connected(id)) return
	
	arrayset(curr_grenade_ammo[id],0,GREN_MAX_TYPES)
	curr_user_grenade[id]=sh_grenade_type:0
	prev_user_grenade[id]=sh_grenade_type:0
	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){
		
		uncharge_custom_nade(id,i)
		strip_weapon_for_my_grenade_heroes(id,_,
					sh_grenade_structs_arr[i][sh_grenade_weapon_classid],true)	
	}
}
public client_connect(id){

	arrayset(curr_grenade_ammo[id],0,GREN_MAX_TYPES)
	curr_user_grenade[id]=sh_grenade_type:0
	prev_user_grenade[id]=sh_grenade_type:0
	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){
		
		uncharge_custom_nade(id,i)
		strip_weapon_for_my_grenade_heroes(id,_,
					sh_grenade_structs_arr[i][sh_grenade_weapon_classid],true)	
	}

	

}
public gren_effect_user(tg,attacker,sh_grenade_type:gren_type){

	switch(gren_type){

		case GREN_SLEEP:{

			sh_sleep_user(tg,attacker,-1)
		}
		case GREN_CHAFF:{

			sh_chaff_user(tg)
		}
		case GREN_MOLLY:{
			
			
			sh_molly_user(tg,attacker,-1)
		}
		case GREN_CO2:{
			
			sh_co2_user(tg)
			
		}
		case GREN_SHOCK:{
			sh_shock_user(tg)
		}
		case GREN_FREEZE:{
			
			sh_freeze_user(tg,5.0,130.0)
		}
		case GREN_DISRUPT:{
			
			sh_disrupt_user(tg,attacker,-1)
		}
		case GREN_SHRAPNEL:{
			
			sh_bleed_user(tg,attacker,BLEED_MINI,-1,0)
		}
		case GREN_MARKER:{
			
			track_user(tg,attacker,1,0.07,0.5,20.0,
					sh_grenade_structs_arr[gren_type][grenade_color_num])
		}
		default:{
			
			return
		
		}
	}
	
}