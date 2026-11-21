#if defined sh_aux_natives_pt15
  #endinput
#endif
#define sh_aux_natives_pt15



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
native launch_projectile_native(id,
						Float:launch_speed,
						Float:think_period,
						const new_classname[128],
						const model_filename[128],
						const entity_family[128] = "info_target",
						Float:box_mins[3] = {-1.0,-1.0,-1.0},
						Float:box_maxs[3] = {1.0,1.0,1.0}, 
						Float:launch_height_offset = 0.0, 
						solid_type = SOLID_BBOX,
						move_type = MOVETYPE_BOUNCE,
						effects = EF_MUZZLEFLASH,
						Float:gravity = 1.0,
						post_launch_callback_plugin_id = -1,
						post_launch_callback_id = -1)


native bool:sh_get_player_has_hero_projectile_weapon(player_id, my_weapon_ids:the_weapon_id)
/*

  weapon gating macro: the first parameter is who is attacking, the second parameter is the weapon id
  It is assumed that we know that the person has the weapon!
  the third parameter and fourth parameters is what to do in case we have the projectile weapon because of one of our heroes
  if %3 is continue or break, %4 should not be used
*/
#define weapon_gating_macro_code_snippet(%1,%2,%3,%4) if(sh_get_player_has_hero_projectile_weapon(%1,my_weapon_ids:%2)) %3 %4