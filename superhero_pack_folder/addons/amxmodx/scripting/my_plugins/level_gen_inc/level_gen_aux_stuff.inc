
#define Struct enum


#define PLUGIN_NAME "Level xp generator"
#define VERSION "1.0"
#define AUTHOR "ThrashBrat"


#define MAX_LEVELS 150
#define PATHSIZE 128
#define BUFFSIZE 8192
#define LEVEL_CFG_FILENAME "level_gen.cfg"
#define LEVEL_CFG_DIRECTORY "/level_gen"
#define LEVEL_GEN_RESULT "level_gen.ini"
#define LEVEL_GEN_CSV_LEVELS "level_levels.csv"
#define LEVEL_GEN_CSV_XPGAIN "level_xpgain.csv"
#define LEVEL_GEN_CSV_KILLS "level_kills.csv"
#define LEVEL_GEN_CSV_KILLS_CUSTOM "level_kills_custom.csv"

#define XP_NEEDED_FUNC  calculate_level_poly_it
#define XP_GAINED_FUNC  calculate_lin_xpgain_it
stock num_levels
stock Float:a_val, Float:b_val,Float:c_val,Float:d_val, 

Float:e_val, Float:f_val,

Float:g_val, Float:h_val,Float:i_val,Float:j_val,

Float:sum_coeff_needed,

Float:sum_coeff_gained,

Float:k_val,Float:l_val,Float:m_val,Float:n_val

stock num_levels_cvar_p,a_val_cvar_p,b_val_cvar_p,c_val_cvar_p,d_val_cvar_p,

e_val_cvar_p,f_val_cvar_p,

g_val_cvar_p,h_val_cvar_p,i_val_cvar_p,j_val_cvar_p,
sum_coeff_needed_cvar_p,
sum_coeff_gained_cvar_p,
k_val_cvar_p,
l_val_cvar_p,
m_val_cvar_p,
n_val_cvar_p

stock level_cfg_folder[128],level_cfg_file[128],level_ini_file[128], xp_gain_csv_file[128], level_xp_csv_file[128],level_kills_needed_csv_file[128],
level_kills_custom_csv_file[128]

stock Float:g_needed[MAX_LEVELS+1]
stock Float:g_gained[MAX_LEVELS+1]
stock g_kills[MAX_LEVELS+1]
stock g_kills_custom[MAX_LEVELS+1]