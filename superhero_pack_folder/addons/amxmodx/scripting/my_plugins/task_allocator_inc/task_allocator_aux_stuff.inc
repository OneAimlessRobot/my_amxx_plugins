#if defined task_allocator_aux_stuff_included
  #endinput
#endif
#define task_allocator_aux_stuff_included


#define ALLOCATOR_CFG_FILENAME "allocator.cfg"
#define ALLOCATOR_CFG_DIRECTORY "/task_allocator"

stock const max_integer_limit= (power(2,31)-1);


// the_taskid= allocate_typed_task_id(generic_task)
enum task_type{
        player_task=0,
        entity_task,
        generic_task,
        max_task_type
};
enum task_type_string_fields{
        convar_string=0,
        default_value_string,
        type_name,
        task_type_string_max_field
};
stock allocator_cfg_folder[128],allocator_cfg_file[128]



const default_starting_id =1000
stock starting_id = default_starting_id;

const default_slots_per_player_task = 40
const default_slots_per_entity_task = 2000
const default_slots_per_generic_task = 10

stock const default_slots_per_player_task_arr[_:max_task_type]={
        
        default_slots_per_player_task,
        default_slots_per_entity_task,
        default_slots_per_generic_task
        
};

stock const default_slots_task_type_strings[_:max_task_type][_:task_type_string_max_field][]={
        
        {"ta_slots_per_player_task","40","player_task"},
        {"ta_slots_per_entity_task","2000","entity_task"},
        {"ta_slots_per_generic_task","10","generic_task"}
        
};

stock slots_per_task_type[_:max_task_type];




stock curr_num_of_tasks,
        prev_task_id_given,
        task_id_to_give;



stock starting_id_pcvar, slots_per_task_type_pcvars[_:max_task_type];


native allocate_typed_task_id(task_type:the_tipe);
