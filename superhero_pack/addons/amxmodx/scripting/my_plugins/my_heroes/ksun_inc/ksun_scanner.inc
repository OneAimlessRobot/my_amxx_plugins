#if defined sh_ksun_scanner_funcs
  #endinput
#endif
#define sh_ksun_scanner_funcs



#define SCANNER_CLASSNAME "ksun_launcher_scanner"
#define LAUNCHER_SCAN_SFX "shmod/ksun/launcher/scanner_wash.wav"

#define SCAN_LOOP_PERIOD 0.2
#define SCAN_DIST_INC floatmul(floatsub(ksun_track_max_radius,ksun_track_min_radius),floatdiv(SCAN_LOOP_PERIOD,ksun_track_traverse_time))


native get_scanner_player_tracks_player(id1,id2)
native set_scanner_player_tracks_player(id1,id2,value)
native scanners_clear()
native get_player_scanner(id)
native set_player_scanner(id, scanner_id)
native destroy_player_scanner(id)
native get_from_player_targets(id,index)

native get_player_num_victims(id)
native dec_player_num_victims(id)
native set_player_num_victims(id,value)

native get_player_num_launched_spores(id)
native dec_player_num_launched_spores(id)
native set_player_num_launched_spores(id,value)

native get_player_num_deployed_spores(id)
native dec_player_num_deployed_spores(id)
native set_player_num_deployed_spores(id,value)

native get_spore_from_player_spores(id,index)
native get_target_from_player_targets(id,index)

native set_spore_at_player_spores(id,index,value)
native set_target_at_player_targets(id,index,value)

native spawn_scanner(id)
native Float:get_scanner_min_radius()
native Float:get_scanner_max_radius()
native Float:get_scanner_traverse_time()

native reset_player_targets(id)


