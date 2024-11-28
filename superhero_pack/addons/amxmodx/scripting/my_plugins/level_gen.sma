



#define Struct enum


#define PLUGIN_NAME "Level xp generator"
#define VERSION "1.0"
#define AUTHOR "ThrashBrat"


#define MAX_LEVELS 150
#define PATHSIZE 128
#define BUFFSIZE 8192
#define LEVEL_CFG_FILENAME "level_gen.cfg"
#define LEVEL_GEN_RESULT "level_gen.ini"
#define LEVEL_GEN_CSV_LEVELS "level_levels.csv"
#define LEVEL_GEN_CSV_XPGAIN "level_xpgain.csv"
#define LEVEL_GEN_CSV_KILLS "level_kills.csv"
#define LEVEL_GEN_CSV_KILLS_CUSTOM "level_kills_custom.csv"

#define XP_NEEDED_FUNC  calculate_level_poly_it
#define XP_GAINED_FUNC  calculate_poly_xpgain_it

#include <amxmodx>
#include <amxmisc>

new num_levels
new Float:a_val, Float:b_val,Float:c_val,Float:d_val, 

Float:e_val, Float:f_val,

Float:g_val, Float:h_val,Float:i_val,Float:j_val

new num_levels_cvar_p,a_val_cvar_p,b_val_cvar_p,c_val_cvar_p,d_val_cvar_p,

e_val_cvar_p,f_val_cvar_p,

g_val_cvar_p,h_val_cvar_p,i_val_cvar_p,j_val_cvar_p

new level_cfg_folder[128],level_cfg_file[128],level_ini_file[128], xp_gain_csv_file[128], level_xp_csv_file[128],level_kills_needed_csv_file[128],
level_kills_custom_csv_file[128]

new Float:g_needed[MAX_LEVELS+1]
new Float:g_gained[MAX_LEVELS+1]
new g_kills[MAX_LEVELS+1]
new g_kills_custom[MAX_LEVELS+1]

public plugin_init()
{
register_plugin( PLUGIN_NAME, VERSION, AUTHOR );
register_cvar( "level_gen_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );

num_levels_cvar_p         = register_cvar( "level_gen_num_levels"        , "10"   );
a_val_cvar_p         = register_cvar( "level_gen_a_val"        , "1.0"   );
b_val_cvar_p   = register_cvar( "level_gen_b_val"  , "1.0"   );
c_val_cvar_p        = register_cvar( "level_gen_c_val"       , "120.0" );

d_val_cvar_p         = register_cvar( "level_gen_d_val"        , "1.0"   );
e_val_cvar_p   = register_cvar( "level_gen_e_val"  , "1.0"   );
f_val_cvar_p   = register_cvar( "level_gen_f_val"  , "1.0"   );

g_val_cvar_p         = register_cvar( "level_gen_g_val"        , "1.0"   );
h_val_cvar_p   = register_cvar( "level_gen_h_val"  , "1.0"   );
i_val_cvar_p   = register_cvar( "level_gen_i_val"  , "1.0"   );
j_val_cvar_p   = register_cvar( "level_gen_j_val"  , "1.0"   );

register_concmd("level_gen", "level_gen", ADMIN_RCON);

register_concmd("kill_req_gen", "kill_req_gen", ADMIN_RCON,"<NIVEL ESCOLHIDO>");

reset_arrs()
setupConfig()
loadConfig()
loadCVARS()
make_arrs()
}

reset_arrs(){

	arrayset(g_needed,0.0,MAX_LEVELS);
	
	arrayset(g_gained,0.0,MAX_LEVELS);
	
	arrayset(g_kills,0,MAX_LEVELS);
	
	arrayset(g_kills_custom,0,MAX_LEVELS);
	


}

loadCVARS(){

	num_levels=get_pcvar_num(num_levels_cvar_p)
	num_levels=min(MAX_LEVELS,num_levels)
	a_val=get_pcvar_float(a_val_cvar_p)
	b_val=get_pcvar_float(b_val_cvar_p)
	c_val=get_pcvar_float(c_val_cvar_p)
	d_val=get_pcvar_float(d_val_cvar_p)
	e_val=get_pcvar_float(e_val_cvar_p)
	f_val=get_pcvar_float(f_val_cvar_p)
	
	g_val=get_pcvar_float(g_val_cvar_p)
	h_val=get_pcvar_float(h_val_cvar_p)
	i_val=get_pcvar_float(i_val_cvar_p)
	j_val=get_pcvar_float(j_val_cvar_p)
	console_print(0,"LEVEL GEN MATH EXPR: %f * pow( %f ,(x * %f)) + %f",a_val,b_val,c_val,d_val);
	console_print(0,"LEVEL GEN MATH EXPR POLY: (%f * x * x) + (%f * x) + %f",a_val,b_val,c_val);
	console_print(0,"LINEAR LEVEL GEN XPGAIN MATH EXPR: %f * x + %f",e_val,f_val);
	console_print(0,"POLY LEVEL GEN XPGAIN MATH EXPR: (%f * x * x) + (%f * x) + %f",g_val,h_val,i_val);
	console_print(0,"EXP GEN MATH XPGAIN MATH EXPR: %f * pow( %f ,(x * %f)) + %f",g_val,h_val,i_val,j_val);

}
Float:calculate_level_it(Float:it){

	return floatadd((floatmul(a_val , floatpower(b_val,floatmul(c_val,it)))), d_val)
}
Float:calculate_level_poly_it(Float:it){

	return floatadd(floatadd(floatmul(a_val,floatpower(it,2.0)),floatmul(b_val,it)),c_val)
}
Float:calculate_exp_xpgain_it(Float:it){

	return floatadd((floatmul(g_val , floatpower(h_val,floatmul(i_val,it)))), j_val)
}
Float:calculate_poly_xpgain_it(Float:it){
	
	return floatadd(floatadd(floatmul(g_val,floatpower(it,2.0)),floatmul(h_val,it)),i_val)
}
Float:calculate_lin_xpgain_it(Float:it){

	return floatadd(floatmul(e_val, it),  f_val)
}
public level_gen(id)
{

reset_arrs()
loadConfig()
loadCVARS()
make_files()



}

public kill_req_gen(id, level, cid)
{
	new level_arg[16]
	new level_num
	if (read_argc() >= 2)
	{
		loadCVARS()
		read_argv(1,level_arg,charsmax(level_arg))
		level_num= min(str_to_num(level_arg),num_levels)
		log_amx("LVL %d REQUIRED KILLS!!!!",level_num);
		make_kills_custom(level_num)
	}
	else{
	
		log_amx("Invalid number of arguments!!!!! %d provided! %d needed!",read_argc(),2);
	
	}

	return PLUGIN_HANDLED;

}

//----------------------------------------------------------------------------------------------
setupConfig()
{
	// Set Up Config Files
	get_configsdir(level_cfg_folder, charsmax(level_cfg_folder))
	add(level_cfg_folder, charsmax(level_cfg_folder), "/level_gen", 20)

	// Attempt to create directory if it does not exist
	if ( !dir_exists(level_cfg_folder) ) {
		mkdir(level_cfg_folder)
	}

	formatex(level_cfg_file, charsmax(level_cfg_file), "%s/%s", level_cfg_folder,LEVEL_CFG_FILENAME)
}


//----------------------------------------------------------------------------------------------
loadConfig()
{
	//Load SH Config File
	if ( file_exists(level_cfg_file) ) {
		
		log_amx("Loading levels.cfg")

		server_cmd("exec %s", level_cfg_file)

		//Force the server to flush the exec buffer
		server_exec()

		//Note: I do not believe this is an issue anymore disabling until known otherwise - vittu
		//Exec the config again due to issues with it not loading all the time
		//server_cmd("exec %s", gSHConfig)
	}
	else {
		log_amx("Could not find %s file", level_cfg_file)
	}
}

make_arrs(){
	
	g_needed[0]=0.0
	for(new it=1;it<=num_levels;it++){
	
		g_needed[it]=XP_NEEDED_FUNC(float(it-1))
	
	}
	for(new it=0;it<=num_levels;it++){
	
		g_gained[it]=XP_GAINED_FUNC(float(it-1))
	
	}
	for(new it=0;it<=num_levels;it++){
	
		g_kills[it]=floatround(floatdiv(g_needed[it],g_gained[it]),floatround_ceil)
	
	}



}

make_kill_arr(chosen){


	for(new it=0;it<=num_levels;it++){
	
		g_kills_custom[it]=floatround(floatdiv(g_needed[it],g_gained[chosen]),floatround_ceil)
	
	}

}

make_result(levelsFile){

	fprintf(levelsFile,"NUMLEVELS %d^nLTXPLEVELS ",num_levels)
	for(new it=0;it<=num_levels;it++){
		
		fprintf(levelsFile,"%.0f ",g_needed[it])
	
	
	
	}
	fprintf(levelsFile,"^nLTXPGIVEN ")
	for(new it=0;it<=num_levels;it++){
		
		fprintf(levelsFile,"%.0f ",g_gained[it])
	
	
	
	}



}
make_levels_csv(levelsCSVFile){

	fprintf(levelsCSVFile,"LEVEL, XPREQUIRED^n");
	for(new it=0;it<=num_levels;it++){
	
		fprintf(levelsCSVFile,"%d, %.0f^n",it,g_needed[it])
	
	}



}
make_xpgain_csv(xpgainCSVFile){


	fprintf(xpgainCSVFile,"LEVEL, XPGAINED^n");
	
	for(new it=0;it<=num_levels;it++){
	
		fprintf(xpgainCSVFile,"%d, %.0f^n",it,g_gained[it])
	
	}


}

make_kills_needed_csv(levelKillsCSVFile){


	fprintf(levelKillsCSVFile,"LEVEL, KILLSNEEDED^n");
	for(new it=0;it<=num_levels;it++){
	
		fprintf(levelKillsCSVFile,"%d, %d^n",it,g_kills[it])
	
	}


}

make_kills_custom_csv(levelKillsCSVFile,level_arg){


	fprintf(levelKillsCSVFile,"LEVEL, KILLSNEEDED_LVL_%d^n",level_arg);
	for(new it=1;it<=num_levels;it++){
	
		fprintf(levelKillsCSVFile,"%d, %d^n",it,g_kills_custom[it])
	
	}


}
make_kills_custom(level_arg){

	formatex(level_kills_custom_csv_file, charsmax(level_kills_custom_csv_file), "%s/%s", level_cfg_folder,LEVEL_GEN_CSV_KILLS_CUSTOM)

	new levelKillsCSVFile = fopen(level_kills_custom_csv_file, "wt")
	if (!levelKillsCSVFile) {
		log_amx("Failed to create %s, please verify file/folder permissions",level_kills_custom_csv_file)
		return
	}
	
	reset_arrs()
	make_arrs()
	make_kill_arr(level_arg)
	make_kills_custom_csv(levelKillsCSVFile,level_arg);
	
	fclose(levelKillsCSVFile)
}

make_files(){

	formatex(level_ini_file, charsmax(level_ini_file), "%s/%s", level_cfg_folder,LEVEL_GEN_RESULT)
	formatex(level_xp_csv_file, charsmax(level_xp_csv_file), "%s/%s", level_cfg_folder,LEVEL_GEN_CSV_LEVELS)
	formatex(xp_gain_csv_file, charsmax(xp_gain_csv_file), "%s/%s", level_cfg_folder,LEVEL_GEN_CSV_XPGAIN)
	formatex(level_kills_needed_csv_file, charsmax(level_kills_needed_csv_file), "%s/%s", level_cfg_folder,LEVEL_GEN_CSV_KILLS)

	new levelsFile = fopen(level_ini_file, "wt")
	if (!levelsFile) {
		log_amx("Failed to create %s, please verify file/folder permissions",level_ini_file)
		return
	}
	new levelsCSVFile = fopen(level_xp_csv_file, "wt")
	if (!levelsCSVFile) {
		fclose(levelsFile)
		log_amx("Failed to create %s, please verify file/folder permissions",level_xp_csv_file)
		return
	}
	new xpgainCSVFile = fopen(xp_gain_csv_file, "wt")
	if (!xpgainCSVFile) {
		fclose(levelsFile)
		fclose(levelsCSVFile)
		log_amx("Failed to create %s, please verify file/folder permissions",xp_gain_csv_file)
		return
	}
	new levelKillsCSVFile = fopen(level_kills_needed_csv_file, "wt")
	if (!levelKillsCSVFile) {
		fclose(levelsFile)
		fclose(levelsCSVFile)
		fclose(xpgainCSVFile)
		log_amx("Failed to create %s, please verify file/folder permissions",level_kills_needed_csv_file)
		return
	}
	
	reset_arrs()
	make_arrs()
	make_result(levelsFile)
	make_xpgain_csv(xpgainCSVFile);
	make_levels_csv(levelsCSVFile);
	make_kills_needed_csv(levelKillsCSVFile);
	
	fclose(levelsFile)
	fclose(levelsCSVFile)
	fclose(xpgainCSVFile)
	fclose(levelKillsCSVFile)
}
