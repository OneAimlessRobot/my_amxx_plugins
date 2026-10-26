#if defined sh_aux_consts_entity_vectors
  #endinput
#endif
#define sh_aux_consts_entity_vectors

enum entity_type_ids_for_arrays{
	

	PLAYER=0,
	WORLDSPAWN,
	FUNC_WALL,
	FUNC_DOOR,
	FUNC_DOOR_ROTATING,
	FUNC_WALL_TOGGLE,
	FUNC_BREAKABLE,
	FUNC_PUSHABLE,
	FUNC_TRAIN,
	FUNC_ILLUSIONARY,
	FUNC_BUTTON,
	FUNC_ROT_BUTTON,
	FUNC_ROTATING,
	HOSTAGE_ENTITY

}


stock const entity_type_ids_for_arrays:player_vector[entity_type_ids_for_arrays:1]={PLAYER},
			entity_type_ids_for_arrays:breakable_vector[entity_type_ids_for_arrays:1]={FUNC_BREAKABLE},
			entity_type_ids_for_arrays:hostage_vector[entity_type_ids_for_arrays:1]={HOSTAGE_ENTITY},
			entity_type_ids_for_arrays:hurtable_vector[entity_type_ids_for_arrays:1]={FUNC_BREAKABLE,HOSTAGE_ENTITY},
			entity_type_ids_for_arrays:szWallEntities[entity_type_ids_for_arrays:12] = {
					WORLDSPAWN, FUNC_WALL, FUNC_DOOR,  FUNC_DOOR_ROTATING,
					FUNC_WALL_TOGGLE, FUNC_BREAKABLE, FUNC_PUSHABLE, FUNC_TRAIN,
					FUNC_ILLUSIONARY, FUNC_BUTTON, FUNC_ROT_BUTTON, FUNC_ROTATING
				},
			
			entity_type_ids_for_arrays:full_entity_array_for_trace_attack[entity_type_ids_for_arrays] = {
				
				PLAYER,
				WORLDSPAWN,
				FUNC_WALL,
				FUNC_DOOR,
				FUNC_DOOR_ROTATING,
				FUNC_WALL_TOGGLE,
				FUNC_BREAKABLE,
				FUNC_PUSHABLE,
				FUNC_TRAIN,
				FUNC_ILLUSIONARY,
				FUNC_BUTTON,
				FUNC_ROT_BUTTON,
				FUNC_ROTATING,
				HOSTAGE_ENTITY



			},
			entity_type_ids_for_arrays:full_entity_array_except_player[entity_type_ids_for_arrays:14] = {
				
				WORLDSPAWN,
				FUNC_WALL,
				FUNC_DOOR,
				FUNC_DOOR_ROTATING,
				FUNC_WALL_TOGGLE,
				FUNC_BREAKABLE,
				FUNC_PUSHABLE,
				FUNC_TRAIN,
				FUNC_ILLUSIONARY,
				FUNC_BUTTON,
				FUNC_ROT_BUTTON,
				FUNC_ROTATING,
				HOSTAGE_ENTITY



			},

			entity_type_ids_for_arrays:player_worldspawn_array[entity_type_ids_for_arrays:2]={
				
				WORLDSPAWN,
				PLAYER
			}


#define length_of_trace_attack_entity_array (sizeof full_entity_array_for_trace_attack)

native ecnlt_get_name(entity_type_ids_for_arrays:ent_type_id, ent_name_dst[], len)
