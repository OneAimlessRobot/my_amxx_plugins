#if defined sh_ksun_global_funcs
  #endinput
#endif
#define sh_ksun_global_funcs



enum ksun_reset_occasions{
	never_reset=0,
	reset_on_death=1,
	reset_on_new_round=2,
	always_reset=3
	
	
}

native spores_ksun_hero_id()

native ksun_dec_num_available_spores(id)

native ksun_get_num_available_spores(id)

native ksun_reset_occasions:ksun_get_when_reset_spores()

