#if defined sh_camera_funcs
  #endinput
#endif
#define sh_camera_funcs

#define CAMERA_CLASSNAME "sh_cam"

native clear_cameras()
native camera_get_camera_disarmer_on(id)
native camera_set_camera_disarmer_on(id,value_to_set)
native camera_get_camera_armed(id)
native toggle_camera_view(id)
native camera_get_camera_planted(id)
native camera_get_camera_loaded(id)
native user_can_plant_camera(id)
native camera_get_camera_charging(id)
native camera_charge_camera(id)
native camera_disarm_camera(id)
native camera_set_camera_armed(id,value_to_set)
native camera_set_camera_planting(id,value_to_set)
native camera_get_camera_planting(id)
native camera_get_camera_disarming(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
