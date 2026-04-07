#if defined sh_camera_funcs
  #endinput
#endif
#define sh_camera_funcs

#define CAMERA_CLASSNAME "cam"


#define CAMERA_WORLD_MDL "models/shmod/camman/camera/camera.mdl"

#define CAMERA_CLICK_SFX "shmod/camman/camera/camera_click.wav"
#define CAMERA_BOOTING_SFX "shmod/camman/camera/camera_booting.wav"
#define CAMERA_BOOTED_SFX "shmod/camman/camera/camera_booted.wav"

#define CAMERA_WORLD_MDL "models/shmod/camman/camera/camera.mdl"


#define CAMERA_DAMAGE_FALLOFF_DIST 750.0

#define CAMERA_PLANT_PERIOD 1.0



#define CAMERA_ARMING_TIME 4.0

#define CAMERA_DAMAGE 200


#define ALPHA_INC 20
#define CAMERA_WAIT_TIME 1.0

#define CAMERA_CHARGE_PERIOD 0.1
#define CAMERA_CHARGE_TIMES floatround(floatdiv(min_charge_time,CAMERA_CHARGE_PERIOD))

#define MAX_CAMERAS 10



#define HALF_CAMERA_SIZE 8.0
#define CAMERA_SIZE (HALF_CAMERA_SIZE*2.0)
#define CAMERA_DISARM_PERIOD 0.1
#define CAMERA_DISARM_TIMES floatround(floatdiv(min_charge_time,CAMERA_DISARM_PERIOD))

#define CAMERA_FRAMERATE 60.0


#define ZOOM_INC 2.0

#define MAX_ZOOM 160.0

#define MIN_ZOOM 45.0
native clear_cameras()
native camera_get_camera_disarmer_on(id)
native camera_set_camera_disarmer_on(id,value_to_set)
native camera_get_camera_armed(id)
native toggle_camera_view(id)
native camera_get_camera_planted(id)
native camera_set_camera_armed(id,value_to_set)
native camera_get_camera_loaded(id)
native user_can_plant_camera(id)
native camera_get_camera_charging(id)
native camera_uncharge_camera(id)
native camera_charge_camera(id)
native camera_disarm_camera(id,mine_id)
native camera_clear_user_camera(id)
native camera_undisarm_camera(id)
native camera_get_camera_disarming(id)

native plant_camera(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
