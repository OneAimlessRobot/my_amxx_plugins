#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_PDATA_ALIASES
#define I_WANT_ENTITY_VECTORS
#define I_WANT_RESOURCE_ALIASES
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


const Float:dummy_val_speed = 0.1;
const Float:think_period_dummy_val = 0.0005

		
#define PLUGIN "SH_AuxFun15: proj. wpn gating"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "../my_include/auxiliar_stuff.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt15.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt15.inc"


static sh_player_hero_projectile_weapon_tracker[SH_MAXSLOTS+1];

new const DEBUG = 0

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
	register_concmd(player_projectile_weapons_print,player_projectile_weapons_print,ADMIN_IMMUNITY,"param 1: playername")

	register_concmd(hero_projectile_weapons_print,hero_projectile_weapons_print,ADMIN_IMMUNITY,"param 1: hero name")

	register_ham_hook_multiple(Ham_TraceAttack,full_entity_array_for_trace_attack,sizeof(full_entity_array_for_trace_attack),
						"Ham_TraceAttackProjectileWeapon",_,true)

	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPostProjectileWeapons", 1)

}

public fm_UpdateClientDataPostProjectileWeapons(player, sendWeapons, cd)
{
	if(!is_user_alive(player)){
		
		return FMRES_IGNORED
	}
	if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[player], _:get_user_weapon(player))){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem,XO_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public Ham_TraceAttackProjectileWeapon(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[idattacker], _:get_user_weapon(idattacker))){
		return HAM_IGNORED
	}

	damage= 0.0
	SetHamParamFloat(3,damage)
	
	return HAM_SUPERCEDE
	
}

public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}

public plugin_natives(){

	register_native("sh_get_player_has_hero_projectile_weapon","_sh_get_player_has_hero_projectile_weapon")
	register_native("launch_projectile_native", "_launch_projectile_native")

}
public bool:_sh_get_player_has_hero_projectile_weapon(iPLugin,iParams){

	new id = get_param(1),
		my_weapon_ids:weapon_id = my_weapon_ids:get_param(2);
	
	return bool:Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:weapon_id)
}
stock print_player_hero_projectile_weapon_flags(id){
	static weapon_name_buff[50]
	server_print("The state of hero projectile weapon flags for this player is:^n^n")
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){
		
		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))
																	
			server_print("%s^nHas been:^n - picked!",weapon_name_buff)
		}

	}

}

public sh_print_player_projectile_weapons(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31)

	new player = cmd_target(id,arg,2)

	if (!player) return PLUGIN_HANDLED

	print_player_hero_projectile_weapon_flags(player)

	return PLUGIN_HANDLED
}
stock print_hero_projectile_weapon_flags(heroID){
	static weapon_name_buff[50]
	server_print("The projectile weapons flags for this hero are:^n^n")
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){
		
		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))
																	
			server_print("- %s^n",weapon_name_buff)
		}

	}

}

public sh_print_hero_projectile_weapons(id,level,cid){

	static arg[MAX_HERO_NAME_LENGTH],
			hero_name_to_use[MAX_HERO_NAME_LENGTH]

	read_argv(1,arg,charsmax(arg))

	static arg_strlen;

	arg_strlen = strlen(arg)


	if(!arg_strlen){
		
		console_print(id, "Part of hero name is required!")

		return PLUGIN_HANDLED
	}

	static heroID;

	if((heroID = sh_match_string_with_hero_name(id,arg)) < 0){


		return PLUGIN_HANDLED


	}
	
	sh_get_hero_name_from_id(heroID,hero_name_to_use)
	
	console_print(id, "Hero name obtained: %s", hero_name_to_use)
	
	print_hero_projectile_weapon_flags(heroID)
	
	return PLUGIN_HANDLED

}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	static weapon_name_buff[50]
	
	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}

	if(( heroID < 0 )||(heroID >= SH_MAXHEROS)){
		return INIT_FWD_PASS
	}
	if(mode!=SH_HERO_ADD){
		
		return INIT_FWD_PASS
	}
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){

		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			
				wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))

				sh_chat_message(id,-1,"You have picked heroes with ^"%s^" projectile weapon already!...",
							weapon_name_buff)
			
				true_return_result =  INIT_FWD_BLOCK
				break;
			}
		}
	}

	return true_return_result
}
public sh_hero_init(id,heroID, sh_init_mode:mode){
	
	if(!client_is_within_range(id)){

		return
	}

	if(( heroID < 0 )||(heroID >= SH_MAXHEROS)){
		return
	}
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){

		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			switch(mode){

				case SH_HERO_ADD:{

					if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
						
						Assign_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i, true_for_macro)
					

					}
				}
				case SH_HERO_DROP:{
					
					if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
						
						Assign_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i, false_for_macro)
					

					}

				}

			}
			

		}

	}
}


/*

	parms
	owner: id
	launch_speed: floatround(SPEAR_SPEED*(curr_charge[id]/max_charge_time))
	think_period: SPEAR_SHOOT_PERIOD
	entity_family: "info_target"
	classname: SPEAR_CLASSNAME
	model_filename: SPEAR_W_MODEL
	solid_type: SOLID_BBOX
	move_type: MOVETYPE_BOUNCE
	gravity: entity_set_float(Ent,EV_FL_gravity, MARIA_PROJECTILE_GRAVITY_MULT*0.1)
	effects: EF_MUZZLEFLASH
	post_launch_callback_plugin_id: 
	post_launch_callback_id:

	callback is of format: (noreturn)func_name(entity_returned, owner_id, Float:Velocity[3], &bool:modified_speed_flag = false){

	modify the velocity vector to modify velocity RIGHT AFTER launch!

	if you want to modify the speed parameters, set the flag to true!

	it isnt called on failure!

	buffs will be assumed to have size 128!


	return: entity_id on success, -1 on failure

launch_projectile_native(id,   1
					Float:launch_speed,  2
					Float:think_period,  3
					const new_classname[128],  4
					const model_filename[128],   5
					const entity_family[128] = "info_target",  6
					Float:box_mins[3] = {-1.0,-1.0,-1.0},  7
					Float:box_maxs[3] = {1.0,1.0,1.0},   8
					Float:launch_height_offset = 0.0,   9
					solid_type = SOLID_BBOX,  10
					move_type = MOVETYPE_BOUNCE,  11
					effects = EF_MUZZLEFLASH,   12
					Float:gravity = 1.0,    13
					post_launch_callback_plugin_id = -1,  14
					post_launch_callback_id = -1     15)   


*/
public _launch_projectile_native(iPlugins, iParams){

	new id = get_param(1)

	if(!is_user_alive(id)){

		return -1
	}

	new Float:launch_speed = get_param_f(2)
	
	
	launch_speed = max_macro(launch_speed,dummy_val_speed)


	new Float:think_period = get_param_f(3)


	think_period = max_macro(think_period,think_period_dummy_val)

	static new_classname[128],
			model_filename[128],
			entity_family[128],
			Float:box_mins[3],
			Float:box_maxs[3]
		
	
	get_string(4,new_classname,charsmax(new_classname))
	get_string(5,model_filename,charsmax(model_filename))
	get_string(6,entity_family,charsmax(entity_family))


	get_array_f(7,box_mins,sizeof(box_mins))
	get_array_f(8,box_maxs,sizeof(box_maxs))


	new Float:launch_height_offset = get_param_f(9),
		solid_type = get_param(10),
		move_type = get_param(11),
		effects = get_param(12),
		Float:gravity = get_param_f(13),
		post_launch_callback_plugin_id = get_param(14),
		post_launch_callback_id = get_param(15)



	if(DEBUG){


		server_print("Projectile owner id obtained: %d^n", id)
		server_print("Projectile launch speed obtained: %0.2f^n", launch_speed)
		server_print("Projectile think period obtained: %0.2f^n", think_period)
		server_print("Projectile classname to apply: %s^n", new_classname)
		server_print("Projectile entity family obtained: %s^n", entity_family)
		server_print("Projectile model filename obtained: %s^n", model_filename)
		server_print("Projectile mins vector obtained^n")
		print_vector(box_mins)
		server_print("Projectile maxs vector obtained^n")
		print_vector(box_maxs)
		server_print("^nProjectile launch height offset obtained: %0.2f^n",launch_height_offset)
		server_print("^nProjectile solid type value obtained: %d^n",solid_type)
		server_print("^nProjectile move type value obtained: %d^n",move_type)
		server_print("^nProjectile effects value obtained: %d^n",effects)
		server_print("^nProjectile launch gravity obtained: %0.2f^n",gravity)
		server_print("Projectile plugin id obtained: %d^n", post_launch_callback_plugin_id)
		server_print("Projectile post launch callback id obtained: %d^n", post_launch_callback_id)


	}



	static Float:Origin[3], Float:Velocity[3], Float:vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity(entity_family)

	if (!Ent){
		
		return -1
	
	}

	entity_set_string(Ent, EV_SZ_classname, new_classname)
	entity_set_model(Ent, model_filename)

	entity_set_vector(Ent, EV_VEC_mins, box_mins)
	entity_set_vector(Ent, EV_VEC_maxs, box_maxs)

	
	Origin[2]+=launch_height_offset
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, effects)
	entity_set_int(Ent, EV_INT_solid, solid_type)
	entity_set_int(Ent, EV_INT_movetype, move_type)
	entity_set_float(Ent, EV_FL_gravity, gravity)

	entity_set_edict(Ent,EV_ENT_owner,id)
	
	my_velocity_by_aim(id, launch_speed , Velocity, dummy_vector)



	
	if((post_launch_callback_plugin_id>=0)&&(post_launch_callback_id>=0)){
		static Float:modded_speed[3],
			bool:modified_speed_flag = false;

		modified_speed_flag = false
		multiply_3d_vector_by_scalar(Velocity,1.0,modded_speed)

		if(DEBUG){
			server_print("Pre callback speed vector of entity:^n")
			print_vector(modded_speed)
		}
		
		callfunc_begin_i(post_launch_callback_id,post_launch_callback_plugin_id)
		callfunc_push_int(Ent)
		callfunc_push_int(id)
		callfunc_push_array(_:modded_speed, sizeof modded_speed, true)
		callfunc_push_intrf(_:modified_speed_flag)
		callfunc_end()

		if(modified_speed_flag){
			if(DEBUG){
				server_print("The vector WAS modded by caller!^n")
				server_print("Post callback speed vector of entity:^n")
				print_vector(modded_speed)
			}
			entity_set_vector(Ent, EV_VEC_velocity ,modded_speed)

		}
		else{
			
			if(DEBUG){
				server_print("The vector was not modded by caller!^n")
			}
			entity_set_vector(Ent, EV_VEC_velocity ,Velocity)


		}


	}

	entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,think_period));

	return Ent

}
