#if defined sh_slitter_funcs
  #endinput
#endif
#define sh_slitter_funcs

#define SLITTER_V_MODEL "models/shmod/teliko/v_knife.mdl"

stock const teliko_slitter_sounds[1][]={"weapons/teliko_slitter/knife_stab.wav"}
#define SLITTER_TASKID 21211221
#define SLITTER_DRAG_THINK_PERIOD 0.1
#define SLITTER_DRAG_THINK_TIMES (slitter_drag_time/SLITTER_DRAG_THINK_PERIOD)
#define DRAG_FORCE 10.0
native slitter_set_slitter(id,value_to_set)
native slitter_get_slitter(id)
native slitter_get_dragging_who(id)
native slitter_get_slit_kills(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
