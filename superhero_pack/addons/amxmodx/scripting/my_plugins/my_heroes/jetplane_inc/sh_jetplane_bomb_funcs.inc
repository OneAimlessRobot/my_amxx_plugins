#if defined sh_yandere_jet_bomb_funcs
  #endinput
#endif
#define sh_yandere_jet_bomb_funcs

#define NUM_OF_EFFECT_COLORS 10

#define BOMB_DROP_PERIOD 20.0

#define BOMB_RELOAD_TASKID 2912922

#define BOMB_RADIUS 500.0



#define BOMB_EXPLODE_SOUND "weapons/explode3.wav"

#define JETBOMB_FALLOFF_DIST 100.0
#define JETPLANE_BOMB_CLASSNAME "yandere_bomb"
#define BOMB_MODEL "models/shmod/yandere/jetplane/projectiles/airattack_nuke.mdl"

native get_jet_bombs(jet_id)
native set_jet_bombs(jet_id,num_bombs)
native reset_jet_bombs(jet_id)
native get_user_jet_bombs(id)
native set_user_jet_bombs(id,num_bombs)
native reset_user_jet_bombs(id)
native clear_bombs()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
