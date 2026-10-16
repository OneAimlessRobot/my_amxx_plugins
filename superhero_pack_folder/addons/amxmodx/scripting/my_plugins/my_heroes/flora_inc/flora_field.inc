#if defined sh_flora_field_funcs
  #endinput
#endif
#define sh_flora_field_funcs

#define FLORA_FIELD_CLASSNAME "flora_field"




#define FLORA_CHARGE_PERIOD 0.1
#define FLORA_THINK_PERIOD 0.35

#define FLORA_CHARGE_RATE 100.0
#define FIELD_ACTIVE_TIME_BUFFER 10.0

#define FIELD_DEPLOYED "shmod/flora/fields/flora_deployed.wav"
#define FIELD_HUM "shmod/flora/fields/flora_fieldambience.wav"
#define FIELD_HEAL "shmod/flora/fields/flora_heal.wav"
#define FIELD_DESTROYED "shmod/flora/fields/field_destroy.wav"
#define FIELD_CHARGING "shmod/flora/fields/field_charging.wav"
#define FIELD_TELEPORT "shmod/flora/fields/flora_teleport.wav"
#define FIELD_DIG_SOUND "ambience/port_suckin1.wav"


#define FLORA_HEAL_GLOW_TIME 3.0
enum flora_sheltered_values{
  NONE=0,
  OUTSIDE,
  SHELTERED,
  DUNGEON_DWELLER
}

stock const sh_custom_color:flora_damage_colors[flora_sheltered_values]={
  GREEN,
  GREEN,
  YELLOW,
  RED

}
native reset_flora_user(id, bool:newRound= false)

native Float:field_get_user_field_cooldown(id)

native field_uncharge_user(id)

native form_field(id)

native field_loaded(id)

native flora_get_user_num_active_fields(id)
native flora_dec_user_num_active_fields(id,value)
native flora_inc_user_num_active_fields(id,value)
native flora_set_user_num_active_fields(id,value)

native flora_get_user_num_fields(id)
native flora_set_user_num_fields(id,value)
native flora_dec_user_num_fields(id,value)
native flora_inc_user_num_fields(id,value)