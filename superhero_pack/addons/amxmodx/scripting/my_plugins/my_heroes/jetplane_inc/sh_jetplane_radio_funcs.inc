#if defined sh_yandere_jet_radio_funcs
  #endinput
#endif
#define sh_yandere_jet_radio_funcs

#define RADIO_SCAN_PERIOD 1.0

#define RADIO_RELOAD_TASKID 4752981

#define RADIO_RADIUS 500.0



native get_jet_scans(jet_id)
native set_jet_scans(jet_id,num_scans)
native reset_jet_scans(jet_id)
native get_user_jet_scans(id)
native set_user_jet_scans(id,num_scans)
native reset_user_jet_scans(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
