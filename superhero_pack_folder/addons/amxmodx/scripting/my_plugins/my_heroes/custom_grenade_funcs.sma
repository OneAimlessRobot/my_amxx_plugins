#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "custom_grenades/custom_grenades.inc"

#include "chaff_grenade_inc/sh_chaff_fx.inc"

#include "tranq_gun_inc/sh_molotov_fx.inc"

#include "tranq_gun_inc/sh_tranq_fx.inc"

#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "../my_include/stripweapons.inc"

#define PLUGIN "Superhero custom grenades module"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


enum sh_grenade_struct{

    sh_grenade_name[128],
    sh_grenade_classname[128],
    sh_grenade_modelname[128],
	sh_grenade_weaponname[128],
    sh_grenade_break_sound[128],
	sh_grenade_weapon_classid,
    sh_grenade_charge_taskid,
	sh_custom_color:grenade_color_num,
	Float:blast_radius,
    Float:sh_grenade_throw_speed,
	Float:min_charge_time,
	Float:max_charge_time,
	Float:throw_period


}

new sh_grenade_structs_arr[GREN_MAX_TYPES][sh_grenade_struct]={

	{"none","",
					"",
					"",
					"",
					0,
					-1,
					CUSTOM,
					0.0,
					0.0,
					0.0,
					0.0,
					9999999.0},
	
	
	{"molotov_cocktail","molotov_grenade",
					"models/w_hegrenade.mdl",
					"weapon_hegrenade",
					GLASS_VIAL_BREAK,
					CSW_HEGRENADE,
					-1,
					PINK,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5},

	{"chaff_grenade","chaff_grenade",
					"models/w_flashbang.mdl",
					"weapon_flashbang",
					crush_stunned,
					CSW_FLASHBANG,
					-1,
					WHITE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5},

	{"sleep_grenade","sleep_grenade",
					"models/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					SMOKE_EXPLODE_SOUND,
					CSW_SMOKEGRENADE,
					-1,
					BLUE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5},

	{"CO2_grenade","CO2_grenade",
					"models/w_smokegrenade.mdl",
					"weapon_smokegrenade",
					EXTINGUISH_FIRE_SOUND,
					CSW_SMOKEGRENADE,
					-1,
					LTGREEN,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5},

	{"shock_grenade","shock_grenade",
					"models/w_flashbang.mdl",
					"weapon_flashbang",
					SHOCK_GRENADE_SOUND,
					CSW_FLASHBANG,
					-1,
					LTBLUE,
					500.0,
					3000.0,
					1.0,
					5.0,
					1.5}

}

new sh_grenade_type:curr_user_grenade[SH_MAXSLOTS+1],
	sh_grenade_type:prev_user_grenade[SH_MAXSLOTS+1]

new sh_grenade_armed_mask[GREN_MAX_TYPES]

new Float:curr_charge[SH_MAXSLOTS+1][GREN_MAX_TYPES]

new curr_grenade_ammo[SH_MAXSLOTS+1][GREN_MAX_TYPES]


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

init_grenade(sh_grenade_type:type){

	sh_grenade_structs_arr[type][sh_grenade_charge_taskid]=allocate_typed_task_id(player_task)
	
	register_think(sh_grenade_structs_arr[type][sh_grenade_classname],
						"sh_grenade_think")

	register_entity_as_wall_touchable(sh_grenade_structs_arr[type][sh_grenade_classname],
						"sh_grenade_touch_things")
	register_custom_touchable(sh_grenade_structs_arr[type][sh_grenade_classname],
						"sh_grenade_touch_things",player_vector,1)
	
}
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_forward(FM_CmdStart, "CmdStart");
	
	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

		init_grenade(i)

	}

	register_event("CurWeapon","event_curr_grenade","be", "1=1")
	
	register_event("DeathMsg","on_death_custom_grenades","a")
}
public event_curr_grenade(id){
	
	if(!client_hittable(id)) return PLUGIN_CONTINUE;	
	
	new wpn_id=-1
	new bool:user_has_grenade=user_has_grenade_on(id, wpn_id)

	prev_user_grenade[id]=curr_user_grenade[id]
	
	if(!user_has_grenade){
		
		curr_user_grenade[id]=sh_grenade_type:0;
		return PLUGIN_CONTINUE
	
	}

	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

		if((wpn_id==sh_grenade_structs_arr[i][sh_grenade_weapon_classid])&&(curr_grenade_ammo[id][i]>0)){

				curr_user_grenade[id]=i
				if(curr_user_grenade[id]!=prev_user_grenade[id]){
					
					if(!is_user_bot(id)){
						client_print(id,print_center,"Grenade switch! (%s -> %s)",
							sh_grenade_structs_arr[prev_user_grenade[id]][sh_grenade_name],
							sh_grenade_structs_arr[curr_user_grenade[id]][sh_grenade_name]);
					}
					UnSet_BitVar(sh_grenade_armed_mask[prev_user_grenade[id]],id)
				}
				return PLUGIN_CONTINUE
		}
	}
	curr_user_grenade[id]=sh_grenade_type:0
	return PLUGIN_CONTINUE
}
public plugin_natives(){
	
	register_native( "uncharge_custom_nade","_uncharge_custom_nade",0)
	register_native( "set_custom_grenade_ammo","_set_custom_grenade_ammo",0)
	register_native( "get_custom_grenade_ammo","_get_custom_grenade_ammo",0)
	register_native( "give_custom_grenades","_give_custom_grenades",0)
	
	
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if(!sh_is_active()) return FMRES_IGNORED

	if (!client_hittable(id)) return FMRES_IGNORED;
	
	new sh_grenade_type:gren_type=curr_user_grenade[id]
	new wpn_id=-1
	if(!user_has_grenade_on(id,wpn_id)||(gren_type<=GREN_NONE)){

		UnSet_BitVar(sh_grenade_armed_mask[prev_user_grenade[id]],id);
		return FMRES_IGNORED
	}
	new ent = find_ent_by_owner(-1, sh_grenade_structs_arr[gren_type][sh_grenade_weaponname], id);



	
	new button = get_uc(uc_handle, UC_Buttons);

	if(button & IN_ATTACK)
	{
		button &= ~IN_ATTACK;
		set_uc(uc_handle, UC_Buttons, button);
		if( !(is_user_alive(id))) return FMRES_IGNORED
		
		if(!Get_BitVar(sh_grenade_armed_mask[gren_type],id)){
			Set_BitVar(sh_grenade_armed_mask[gren_type],id)
			curr_charge[id][gren_type]=0.0
			charge_user(id,gren_type)
			
		}
		else if(((100.0*(curr_charge[id][gren_type]/sh_grenade_structs_arr[gren_type][max_charge_time])))>95.0){

			launch_custom_grenade(id,gren_type)
			if(!is_user_bot(id)){
				client_print(id,print_center,"You have %d %s grenades left",
				get_custom_grenade_ammo(id,gren_type),sh_grenade_structs_arr[gren_type][sh_grenade_name]
				);
			}
			UnSet_BitVar(sh_grenade_armed_mask[gren_type],id)
		}
	}
	else if(Get_BitVar(sh_grenade_armed_mask[gren_type],id)){
		if(curr_charge[id][gren_type]>=sh_grenade_structs_arr[gren_type][min_charge_time]){
			launch_custom_grenade(id,gren_type)
			if(!is_user_bot(id)){
				client_print(id,print_center,"You have %d %s grenades left",
				get_custom_grenade_ammo(id,gren_type),sh_grenade_structs_arr[gren_type][sh_grenade_name]
				);
			}
		}
		else if(curr_charge[id][gren_type]>0.0){
			if(!is_user_bot(id)){
				sh_chat_message(id,-1,"%s grenade not charged! Not launched...",
				sh_grenade_structs_arr[gren_type][sh_grenade_name]);
			}
		}
		UnSet_BitVar(sh_grenade_armed_mask[gren_type],id)
	}
	if(ent){
		cs_set_user_bpammo(id, sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],
					get_custom_grenade_ammo(id,gren_type));
		
		strip_weapon_for_my_grenade_heroes(id,_,sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],
					!get_custom_grenade_ammo(id,gren_type))	
	}
	return FMRES_IGNORED;
}

public sh_round_end(){

	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

		remove_entity_name(sh_grenade_structs_arr[i][sh_grenade_classname])

	}
	

}

public _give_custom_grenades(iPlugin, iParams){
	new id=get_param(1)
	new sh_grenade_type:gren_type= sh_grenade_type:get_param(2)
	new grenade_ammount= get_param(3)
	if ( sh_is_active() && client_hittable(id)){

		cs_set_user_bpammo(id,
					sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],grenade_ammount);
		sh_give_weapon(id,sh_grenade_structs_arr[gren_type][sh_grenade_weapon_classid],false)
		curr_grenade_ammo[id][gren_type]=grenade_ammount
	}


}
public charge_task(any:param[1],id){
	if(!sh_is_active()||sh_is_freezetime()) return

	new sh_grenade_type:the_type= sh_grenade_type:param[0]
	id-=sh_grenade_structs_arr[the_type][sh_grenade_charge_taskid]

	if(!client_hittable(id)) return

	curr_charge[id][the_type]=floatadd(curr_charge[id][the_type],SH_CUSTOM_GRENADE_CHARGE_PERIOD)
	
	if(!is_user_bot(id)){
					
		new hud_msg[128];
		formatex(hud_msg,127,"[SH]: Curr %s grenade charge: %0.2f^n",
				sh_grenade_structs_arr[the_type][sh_grenade_name],
				100.0*(curr_charge[id][the_type]/sh_grenade_structs_arr[the_type][max_charge_time])
				);
		client_print(id,print_center,"%s",hud_msg)
	}
	if(Get_BitVar(sh_grenade_armed_mask[the_type],id)){
		set_task(SH_CUSTOM_GRENADE_CHARGE_PERIOD,"charge_task",id+sh_grenade_structs_arr[the_type][sh_grenade_charge_taskid],param,sizeof(param))
	}
	
	
	
}
charge_user(id,sh_grenade_type:the_type){
	new parm[1]
	parm[0]=the_type
	set_task(SH_CUSTOM_GRENADE_CHARGE_PERIOD,"charge_task",
		id+sh_grenade_structs_arr[the_type][sh_grenade_charge_taskid],
		parm,
		sizeof(parm))
}
public _uncharge_custom_nade(iPlugin,iParams){
	new id=get_param(1)
	new sh_grenade_type:gren_type= sh_grenade_type:get_param(2)

	UnSet_BitVar(sh_grenade_armed_mask[gren_type],id)
	
	
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

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname,
				sh_grenade_structs_arr[the_type][sh_grenade_classname])
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

velocity_by_aim(id, floatround(
				sh_grenade_structs_arr[the_type][sh_grenade_throw_speed]*
				(curr_charge[id][the_type]/sh_grenade_structs_arr[the_type][max_charge_time])),
				Velocity)

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
curr_grenade_ammo[id][the_type]=max(0,curr_grenade_ammo[id][the_type]-1)
if(!curr_grenade_ammo[id][the_type])
{
	
	if(!is_user_bot(id)){
		client_print(id, print_center, "You are out of %s grenades.",
								sh_grenade_structs_arr[the_type][sh_grenade_name])
	}
	engclient_cmd(id, "weapon_knife")
}
emit_sound(id, CHAN_WEAPON, THROWABLE_LAUNCH_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
trail(Ent,sh_grenade_structs_arr[the_type][grenade_color_num],10,5)
entity_set_float(Ent,EV_FL_nextthink,get_gametime()+1.0)

return PLUGIN_CONTINUE
}



public sh_grenade_think(id_grenade){

if ( !is_valid_ent(id_grenade) ) return

new owner=pev(id_grenade,pev_owner);

if(!is_user_connected(owner)){
	remove_entity(id_grenade)
}
static szClassname[32];

entity_get_string(id_grenade,EV_SZ_classname,szClassname,charsmax(szClassname))

new sh_grenade_type:the_type=GREN_NONE

for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

	if(equal(sh_grenade_structs_arr[i][sh_grenade_classname],szClassname)){

			the_type=i
			break;
	}
}

new Float:fl_vExplodeAt[3]
entity_get_vector(id_grenade, EV_VEC_origin, fl_vExplodeAt)
new vExplodeAt[3]
vExplodeAt[0] = floatround(fl_vExplodeAt[0])
vExplodeAt[1] = floatround(fl_vExplodeAt[1])
vExplodeAt[2] = floatround(fl_vExplodeAt[2])
make_shockwave(vExplodeAt,
			sh_grenade_structs_arr[the_type][blast_radius],
			LineColors[sh_grenade_structs_arr[the_type][grenade_color_num]],1,5,8,4)
anime_kill_fx(vExplodeAt)

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
	if( !client_hittable(pid) ) continue
	
	gren_effect_user(pid,owner,the_type)
}


remove_entity(id_grenade)

}

public sh_grenade_touch_things(pToucher, pTouched)
{
	
	return bounce_grenade_stock(pToucher)
}

public plugin_precache()
{

engfunc(EngFunc_PrecacheSound,"ambience/particle_suck2.wav")
engfunc(EngFunc_PrecacheSound, CUSTOM_GRENADE_BOUNCE_SOUND)
engfunc(EngFunc_PrecacheSound, THROWABLE_LAUNCH_SFX)

for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){

	engfunc(EngFunc_PrecacheSound, sh_grenade_structs_arr[i][sh_grenade_break_sound])
}


}
public on_death_custom_grenades(){
	if(!sh_is_active()) return
	
	new id = read_data(2)
	if(!is_user_connected(id)) return

	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){
		
		uncharge_custom_nade(id,i)
	}
}
public client_connect(id){

	arrayset(curr_grenade_ammo[id],0,GREN_MAX_TYPES)
	curr_user_grenade[id]=sh_grenade_type:0
	prev_user_grenade[id]=sh_grenade_type:0
	for(new sh_grenade_type:i=sh_grenade_type:1;i<GREN_MAX_TYPES;i++){
		
		uncharge_custom_nade(id,i)
		strip_weapon_for_my_grenade_heroes(id,_,
					sh_grenade_structs_arr[i][sh_grenade_weapon_classid],
					!get_custom_grenade_ammo(id,i))	
	}

	

}
public gren_effect_user(tg,attacker,sh_grenade_type:gren_type){

	switch(gren_type){

		case GREN_SLEEP:{

			sh_sleep_user(tg,attacker,-1)
		}
		case GREN_CHAFF:{

			sh_chaff_user(tg,attacker,-1)
		}
		case GREN_MOLLY:{

			sh_molly_user(tg,attacker,-1)
		}
		case GREN_CO2:{
			
			if(sh_is_user_burning(tg)){
				sh_chat_message(tg,-1,"You got ridden of flames with %s grenade!",
								sh_grenade_structs_arr[gren_type][sh_grenade_name])
				sh_unmolly_user(tg)
			}
			
		}
		case GREN_SHOCK:{
			if(sh_get_user_is_asleep(tg)){
				sh_chat_message(tg,-1,"You got woken up with %s grenade!",
								sh_grenade_structs_arr[gren_type][sh_grenade_name])
				sh_unsleep_user(tg)
			}
			sh_set_stun(tg,1.0,180.0)
		}
		default:{
			
			return
		
		}
	}
	
}