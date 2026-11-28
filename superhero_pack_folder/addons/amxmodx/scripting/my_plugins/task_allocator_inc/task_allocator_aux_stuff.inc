#if defined task_allocator_aux_stuff_included
  #endinput
#endif
#define task_allocator_aux_stuff_included
// the_taskid= allocate_typed_task_id(generic_task)
enum task_type{
        player_task=0,
        entity_task,
        generic_task,
        max_task_type
};


native allocate_typed_task_id(task_type:the_tipe,stack_ammount=1);
