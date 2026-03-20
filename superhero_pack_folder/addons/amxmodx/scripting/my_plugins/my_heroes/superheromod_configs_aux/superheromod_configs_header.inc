#if defined superheromod_configs_header
  #endinput
#endif
#define superheromod_configs_header


#define SHCONFIGS_CFG_FILENAME "shero_configs.cfg"
#define SHCONFIGS_CFG_DIRECTORY "/shero_configs"

#define MAX_CHARS_STRING 128
#define MAX_CONFIGS_PER_PLAYER_HARD_CAP 20


stock MySQL_Handle;

stock sh_max_num_configs_per_player_pcvar


stock shconfigs_cfg_folder[128],shconfigs_cfg_file[128]

stock bool:number_of_configs_allowed(num){


    return ((num>=1) && (num<= MAX_CONFIGS_PER_PLAYER_HARD_CAP))

}

stock const DEFAULT_DB_NAME[MAX_CHARS_STRING] = "sh_skill_configs"
stock const DEFAULT_USER_NAME[MAX_CHARS_STRING] = "Terezka_Broucku"
stock const DEFAULT_USER_PASS[MAX_CHARS_STRING] = "white_gown_queen_xd"


enum setting_ids{
    SETTING_MAX_NUM_CONFIGS=0,
    MAX_SETTING_IDS
}
enum setting_init_data_type{
    data_type_num=0,
    data_type_float,
    data_type_str,
    max_setting_init_data_type

}
stock const setting_init_data_type_names[_:max_setting_init_data_type][]={
    "INT",
    "FLOAT",
    "STRING"
}
enum setting_struct{
    cvar_p,
    value_num,
    Float:value_float,
    value_string[MAX_CHARS_STRING]
}
enum cvar_struct{

    setting_data_type,
    default_value[MAX_CHARS_STRING],
    setting_name[MAX_CHARS_STRING],
    cvar_name[MAX_CHARS_STRING]

}
stock const CVAR_INIT[_:MAX_SETTING_IDS][cvar_struct]={
    
    {_:data_type_num,"10","max_configs_per_player","sh_max_configs_per_player"}
}

stock setting_struct_arr[_:MAX_SETTING_IDS][setting_struct]


stock initialize_settings(){

    for(new i=0;i<_:MAX_SETTING_IDS;i++){
        setting_struct_arr[i][cvar_p]=register_cvar(CVAR_INIT[i][cvar_name],CVAR_INIT[i][default_value])
    }
}

stock assign_setting_values(){

    for(new i=0;i<_:MAX_SETTING_IDS;i++){
        server_print("Assigning value on setting named %s:^nfrom cvar named %s (with type %s)...^n^n",CVAR_INIT[i][setting_name],CVAR_INIT[i][cvar_name],setting_init_data_type_names[CVAR_INIT[i][setting_data_type]])
        switch(CVAR_INIT[i][setting_data_type]){
            case data_type_num:{
                setting_struct_arr[i][value_num]=get_pcvar_num(setting_struct_arr[i][cvar_p])
                server_print("^n...with value %d^n^n",setting_struct_arr[i][value_num])
            }
            case data_type_float:{

                setting_struct_arr[i][value_float]=get_pcvar_float(setting_struct_arr[i][cvar_p])
                server_print("^n...with value %0.2f^n^n",setting_struct_arr[i][value_float])
                
            }
            case data_type_str:{
                
                get_pcvar_string(setting_struct_arr[i][cvar_p], setting_struct_arr[i][value_string], MAX_CHARS_STRING)
                server_print("^n...with value %s^n^n",setting_struct_arr[i][value_string])
                
            }
            default:{

                continue
            }


        }
    }


}
native bool:fetch_player_config(player_id,config_id)