/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __ENTITIES_LOOKUP_TABLE_H__
#define __ENTITIES_LOOKUP_TABLE_H__

#define min(a,b) ((a < b) ? a : b)
#define max(a,b) ((a > b) ? a : b)
#define clamp(v,m,M) ((m < M)?( ( v <= m) ? m : ( ( v >= M )? M : v) ) : ( ( v <= M) ? M : ( ( v >= m )? m : v) ) )

typedef uint32_t state_cell_type_t;

typedef char entity_name[50];


typedef enum entity_type_ids_for_arrays{
	

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
	HOSTAGE_ENTITY,
	MAX_ENTITY_NAMES


}entity_type_ids_for_arrays;


static const entity_name full_entity_name_array[MAX_ENTITY_NAMES] = {
				
	"player",
	"worldspawn",
	"func_wall",
	"func_door",
	"func_door_rotating",
	"func_wall_toggle",
	"func_breakable",
	"func_pushable",
	"func_train",
	"func_illusionary",
	"func_button",
	"func_rot_button",
	"func_rotating",
	"hostage_entity"



};

#endif
