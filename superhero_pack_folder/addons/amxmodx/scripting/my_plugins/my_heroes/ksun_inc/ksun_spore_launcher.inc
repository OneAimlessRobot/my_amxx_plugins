

#if defined sh_ksun_launcher_funcs
  #endinput
#endif
#define sh_ksun_launcher_funcs



native get_player_launcher_phase(id)
native get_player_launcher(id)
native launcher_deploy(id)
native spores_launch(id)
native spores_reset_user(id,bool:reset_spores=true)
native bool:spores_busy(id)