#if defined sh_man_hook_funcs
  #endinput
#endif
#define sh_man_hook_funcs


stock const man_hook_sounds[1][]={"weapons/teliko_slitter/knife_stab.wav"}
#define HOOK_TASKID 27823709
#define HOOK_DRAG_THINK_PERIOD 0.1
#define HOOK_DRAG_THINK_TIMES (hook_drag_time/HOOK_DRAG_THINK_PERIOD)
#define DRAG_FORCE 10.0
native hook_set_hook(id,value_to_set)
native hook_get_hook(id)
native hook_get_dragging_who(id)
native hook_get_hook_kills(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
