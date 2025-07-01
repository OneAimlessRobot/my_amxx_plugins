#if defined sh_flora_field_funcs
  #endinput
#endif
#define sh_flora_field_funcs

#define FLORA_FIELD_CLASSNAME "flora_field"



// GLOBAL VARIABLES
#define FLORA_COOLDOWN_TASKID 7231819
#define FLORA_LOAD_TASKID 6128376

#define FLORA_CHARGE_TASKID 3479886
#define FLORA_DEPLOY_TASKID 7123436
#define FLORA_CHARGE_PERIOD 0.1
#define FLORA_THINK_PERIOD 0.35

#define FLORA_CHARGE_RATE 100.0
#define FIELD_ACTIVE_TIME_BUFFER 10.0

#define FIELD_DEPLOYED "shmod/flora/fields/flora_deployed.wav"
#define FIELD_HUM "shmod/flora/fields/flora_fieldambience.wav"
#define FIELD_HEAL "shmod/ration.wav"
#define FIELD_DESTROYED "shmod/flora/fields/field_destroy.wav"
#define FIELD_CHARGING "shmod/flora/fields/field_charging.wav"
#define FIELD_TELEPORT "shmod/flora/fields/flora_teleport.wav"
#define FIELD_MDL "models/shmod/jaqueo/shield/shield.mdl"
#define FIELD_NULL "common/null.wav"

#define FLORA_HEAL_GLOW_TIME 3.0
#define FLORA_UNGLISTEN_TASKID 51237123

native clear_fields()

native reset_flora_user(id)

native Float:field_get_user_field_cooldown(id)

native field_uncharge_user(id)

native form_field(id)

native field_loaded(id)

native clear_user_fields(id)

native flora_max_fields()

native flora_start_fields()

native Float:flora_get_cooldown()

native is_too_close(id)

native flora_get_user_num_active_fields(id)
native flora_dec_user_num_active_fields(id,value)
native flora_inc_user_num_active_fields(id,value)
native flora_set_user_num_active_fields(id,value)