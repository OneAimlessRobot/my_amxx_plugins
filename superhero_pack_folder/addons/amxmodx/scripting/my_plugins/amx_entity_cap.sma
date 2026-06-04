#define AUX_STUFF_GIVE_MACROS
#include <amxmisc>
#include <orpheu>
#include <orpheu_stocks>
#include "../include/fakemeta.inc"
#include "task_allocator_inc/task_allocator_aux_stuff.inc"
#include "../my_include/auxiliar_stuff.inc"


#define PLUGIN "AMX Entity Cap"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


stock const num_ents_print_cmd[]="print_num_ents"

stock const num_ents_cycle_print_toggle_cmd[]="toggle_print_num_ents_cycle"

#define name_of_default_map "de_dust4ever"

#define count_entities_orpheu (OrpheuCall(EntityCount_OrpheuHook))

static engine_entity_cap = 0,
		show_entity_count_taskid = -1,
		bool:show_count_enabled = false,
		pcvar_entity_cap = -1,
		entity_cap_cached_value = 0,
		pcvar_print_num_ents_period = -1,
		Float:print_num_ents_period_cached_value = 1.0

static OrpheuFunction:EntityCreated_OrpheuHook = enum_zero,
	OrpheuFunction:EntityCount_OrpheuHook = enum_zero,
	bool:g_bMapChanging = false

public plugin_init(){



	register_plugin(PLUGIN, VERSION, AUTHOR);

	EntityCreated_OrpheuHook = OrpheuGetFunction("CREATE_NAMED_ENTITY")

	EntityCount_OrpheuHook = OrpheuGetEngineFunction("pfnNumberOfEntities", "NumberOfEntities")

	OrpheuRegisterHook(EntityCreated_OrpheuHook, "on_entity_created", OrpheuHookPost);

	pcvar_entity_cap = create_cvar("amx_num_ents_cap","500")
	
	pcvar_print_num_ents_period = create_cvar("amx_print_num_ents_period","2.0")
	
	// Retrieve the engine's hard maximum edict cap
	engine_entity_cap = global_get(glb_maxEntities);
	
	register_srvcmd(num_ents_cycle_print_toggle_cmd, "num_ents_toggle_cycle_print", ADMIN_IMMUNITY)

	register_concmd(num_ents_print_cmd, "num_ents_print", ADMIN_IMMUNITY)
	

	show_entity_count_taskid = allocate_typed_task_id(generic_task)

}
public plugin_cfg(){
	
	entity_cap_cached_value = cvar_val(num, pcvar_entity_cap)
	
	print_num_ents_period_cached_value = cvar_val(float, pcvar_print_num_ents_period)

	set_task(print_num_ents_period_cached_value,"entity_count_task",show_entity_count_taskid,_,_,"b")
}
public entity_count_task(taskid){

	if(show_count_enabled){
		print_entity_count_status()
	}

}
print_entity_count_status(id=-1){

	(id<0)?
	server_print("The map currently has:^n^n^nNum entities (from engine): %d^nPlugin cap: %d^nEngine cap: %d^n",
						count_entities_orpheu,
						entity_cap_cached_value,
						engine_entity_cap):
	console_print(id,"The map currently has:^n^n^nNum entities (from engine): %d^nPlugin cap: %d^nEngine cap: %d^n",
						count_entities_orpheu,
						entity_cap_cached_value,
						engine_entity_cap)
	

}
public num_ents_toggle_cycle_print(id,level,cid){

	if (!cmd_access(id,level,cid,1)){
		return PLUGIN_HANDLED
	}

	show_count_enabled=!show_count_enabled

	return PLUGIN_HANDLED
}
public num_ents_print(id,level,cid){

	if (!cmd_access(id,level,cid,1)){
		return PLUGIN_HANDLED
	}

	print_entity_count_status(id)

	return PLUGIN_HANDLED
}
public OrpheuHookReturn:on_entity_created(){
	
	if((count_entities_orpheu >= (entity_cap_cached_value-1))&&!g_bMapChanging){

		g_bMapChanging = true
		print_entity_count_status()
		server_print("Entity limit reached! changing map!")
		engine_changelevel(name_of_default_map)

	}


}
