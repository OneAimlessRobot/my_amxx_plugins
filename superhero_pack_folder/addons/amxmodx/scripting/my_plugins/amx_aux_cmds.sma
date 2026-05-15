#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/amxconst.inc"
#include "../include/engine.inc"
#include "../include/fakemeta.inc"
#include "../include/xs.inc"
#include "../include/hamsandwich.inc"
#include "../include/fun.inc"
#include "../include/reapi.inc"
#include "../include/fakemeta.inc"
#include "../include/cstrike.inc"
#include "my_include/my_author_header.inc"
#include "my_include/auxiliar_stuff.inc"

#define PLUGIN "amx aux admin cmds"
#define VERSION "1.0.0"
/**

	register_concmd("amx_heal","admin_heal",ADMIN_LEVEL_A,"<authid, nick, @team or #userid> <life to give>")
     
    
you have to chain these in a bitwise "or" to get the obey_immunity_flags
#define CMDTARGET_OBEY_IMMUNITY (1<<0) // Obey immunity
#define CMDTARGET_ALLOW_SELF    (1<<1) // Allow self targeting
#define CMDTARGET_ONLY_ALIVE    (1<<2) // Target must be alive
#define CMDTARGET_NO_BOTS       (1<<3) // Target can't be a bot


Im going to gut this out to make my handlers
//ADMIN HEAL v0.9.3 by f117bomb
//=========================================================
public admin_heal(id,level,cid){
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8], name2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,7)
	get_user_name(id,name2,31)
	if (arg[0]=='@'){
		new players[32], inum
		get_players(players,inum,"ae",arg[1])
		if (inum==0){
			console_print(id,"%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for(new a=0;a<inum;++a) {
			new user_health = get_user_health(players[a])
			set_user_health(players[a], str_to_num(arg2) + user_health)
		}
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_TEAM_CASE2", name2, arg[1])
			case 1:	client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_TEAM_CASE1", arg[1])
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_HEAL_ALL_SUCCESS")
		log_amx("%L", LANG_SERVER, "AINO_LOG_HEAL_ALL", name2, arg[1])
	}
	else {
		new player = cmd_target(id,arg,14)
		if (!player) return PLUGIN_HANDLED
		new user_health = get_user_health(player)
		set_user_health(player, str_to_num(arg2) + user_health)
		new name[32]
		get_user_name(player,name,31)
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_CASE2", name2, name)
			case 1:	client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_CASE1", name)
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_SUCCESS", name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_HEAL_PLAYER", name2, name)
	}
	return PLUGIN_HANDLED
}

*/
enum CMD_IDS{

    AUX_CMD_REVIVE_USER=0,
    AUX_CMD_STAGE_MURDER,
    AUX_CMD_STAGE_ASSAULT,
    AUX_CMD_MINIMAP_TRACK,
    AUX_CMD_STAGE_HIT,
    AUX_CMD_ENTITY_DETECT_TOGGLE,
    MAX_CUSTOM_CMD_IDS
}

enum CMD_WRAPPER_STRUCT{

    cmd_name[128],
    cmd_callback_func[128],
    parameter_description[512],
    param_num,
    flags,
    obey_immunity_flags,
    bool:is_client_command,
    command_id
};

new array_of_commands[_:MAX_CUSTOM_CMD_IDS][CMD_WRAPPER_STRUCT]={
    {"amx_revive","amx_revive","Revive a player.",1,ADMIN_LEVEL_A,CMDTARGET_ALLOW_SELF,false,0},
    {"amx_stage_murder","amx_stage_murder","Stage a murder between two players!",2,ADMIN_LEVEL_A,0,false,0},
    {"amx_stage_assault","amx_stage_assault","Make one player damage another!",3,ADMIN_LEVEL_A,0,false,0},
    {"amx_minimap_track","amx_minimap_track","see where a player is on your radar!",1,ADMIN_LEVEL_A,CMDTARGET_ONLY_ALIVE,true,0},
    {"amx_stage_hit","amx_stage_hit","Stage a hit in a specific hitzone between two players!",1,ADMIN_LEVEL_A,CMDTARGET_ONLY_ALIVE,true,0},
    {"amx_entity_detector_mode","amx_entity_detector_mode","get entity names by looking at them! No parameters except player to toggle",1,ADMIN_LEVEL_A,CMDTARGET_ONLY_ALIVE,true,0}



}
new is_entity_scanner_mode = 0
public plugin_init(){

    register_plugin(PLUGIN, VERSION, AUTHOR);

    for(new i=0;i<_:MAX_CUSTOM_CMD_IDS;i++){
        new command_ide=0;
        new is_client_cmd=array_of_commands[i][is_client_command]
        if(is_client_cmd){
            command_ide=array_of_commands[i][command_id]=register_clcmd(
                            array_of_commands[i][cmd_name], 
                            array_of_commands[i][cmd_callback_func],
                            array_of_commands[i][parameter_description], 
                            array_of_commands[i][flags],
                            array_of_commands[i][obey_immunity_flags])

        }
        else{
            command_ide=array_of_commands[i][command_id]=register_concmd(
                            array_of_commands[i][cmd_name], 
                            array_of_commands[i][cmd_callback_func],
                            array_of_commands[i][parameter_description], 
                            array_of_commands[i][flags],
                            array_of_commands[i][obey_immunity_flags])

        }
        if(command_ide!=0){
            /*   server_print("%s Command registered!^nName: %s^n",
                            is_client_cmd?"Client":"Console",
                            array_of_commands[i][cmd_name])
            server_print("Callback function name: %s^n",array_of_commands[i][cmd_callback_func])
            server_print("Parameter_description: %s^n",array_of_commands[i][parameter_description])
            server_print("Number of parameters: %d^n",array_of_commands[i][param_num])
            server_print("Access flags: %d^n",array_of_commands[i][flags])
            server_print("Immunity check flags: %d^n",array_of_commands[i][obey_immunity_flags])
            server_print("Command ID on struct: %d^n",array_of_commands[i][command_id])
            server_print("Command ID returned: %d^n",command_ide)
            */
        }
        else{
            server_print("We got 0 on command ID! What happened?")

        }
    }
    register_forward(FM_TraceLine, "entity_target_tracing")
}

public entity_target_tracing(Float:v1[3],Float:v2[3],noMonsters,id,trace)
{
    if( !is_user_alive(id) || !Get_BitVar(is_entity_scanner_mode, id )||is_user_bot(id)){
        return FMRES_IGNORED;
    }

    new entity = get_tr2(trace, TR_pHit);

    // if looking at something
    if( is_valid_ent(entity))
    {

        static hud_msg[128]
        static entity_classname[127]
        entity_get_string(entity,EV_SZ_classname,entity_classname,charsmax(entity_classname))

        formatex(hud_msg,127,"Classname of entity %d: %s",entity,entity_classname)
        client_print(id,print_center,"%s",hud_msg)
                    
    }
    else{

        client_print(id,print_chat,"Invalid entity %d",entity)

    }
    return FMRES_IGNORED;
}
detect_user(id,enemy,Float:origin[3]){

	if(!is_valid_ent(id)||!is_valid_ent(enemy)) return 

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
	write_byte(1)
	write_byte(enemy)
	write_coord_f(origin[0])
	write_coord_f(origin[1])
	write_coord_f(origin[2])
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
	write_byte(enemy)
	message_end()
    

}
public amx_minimap_track(id,level,cid){

    if (!cmd_access(id,level,cid,2))
        return PLUGIN_HANDLED
    if (!is_user_alive(id)){

        console_print(id,"You need to be alive to use this!^nRejected.")
        return PLUGIN_HANDLED
    }
    new arg[32]
    read_argv(1,arg,31)
    new player = cmd_target(id,arg,2)
    if (!player) return PLUGIN_HANDLED
    new Float:origin[3]
    entity_get_vector(player,EV_VEC_origin,origin)
    detect_user(id,player,origin)
    return PLUGIN_HANDLED


}
public amx_entity_detector_mode(id,level,cid){

    if (!cmd_access(id,level,cid,2))
        return PLUGIN_HANDLED

    static arg[32], name2[32]
    read_argv(1,arg,31)
    get_user_name(id,name2,31)

    new player = cmd_target(id,arg,2)
    if (!player) return PLUGIN_HANDLED
    if(!is_user_alive(player)){
        
        console_print(id,"That player is still alive! Rejecting^n")
        return PLUGIN_HANDLED    
            
    }
    static player_name[128]
    get_user_name(player, player_name, charsmax(player_name));
    new bool:we_are_on = bool:Get_BitVar(is_entity_scanner_mode, player );
    Assign_BitVar(is_entity_scanner_mode, player , !we_are_on);
    console_print(0, "%s just toggled entity scanner mode on player named %s!^nIt is now %s",name2,player_name, !we_are_on?"On":"Off")
    log_amx("%s just toggled entity scanner mode on player named %s!^nIt is now %s",name2,player_name, !we_are_on?"On":"Off")
    return PLUGIN_HANDLED
}
public amx_revive(id,level,cid){

    if (!cmd_access(id,level,cid,2))
        return PLUGIN_HANDLED

    new arg[32], name2[32]
    read_argv(1,arg,31)
    get_user_name(id,name2,31)

    new player = cmd_target(id,arg,2)
    if (!player) return PLUGIN_HANDLED
    if(is_user_alive(player)){
        
        console_print(id,"That player is still alive! Rejecting^n")
        return PLUGIN_HANDLED    
            
    }
    cs_user_spawn(player)
    new name[32]
    get_user_name(player,name,31)
    
    console_print(0, "%s just respawned player named %s!^n",name2,name)
    log_amx("%s just respawned player named %s!^n",name2,name)
    return PLUGIN_HANDLED
}

public amx_stage_murder(id,level,cid){

    if (!cmd_access(id,level,cid,3))
        return PLUGIN_HANDLED

    new arg[32], arg2[32]
    read_argv(1,arg,31)
    read_argv(2,arg2,31)

    new player = cmd_target(id,arg,2)
    
    if (!player) return PLUGIN_HANDLED
    
    new player2 = cmd_target(id,arg2,2)
    
    if (!player2) return PLUGIN_HANDLED
    
    if(!is_user_alive(player2)){
        
        console_print(id,"That player is dead! People are not stupid...^n")
        return PLUGIN_HANDLED    
            
    }
    new Ent = create_entity("info_target")
    if (pev_valid(Ent)!=2){
        console_print(id,"Error while creating killer entity!^n")
        return PLUGIN_HANDLED    
    }
    entity_set_string(Ent, EV_SZ_classname, "real murder (TM)")
    set_user_godmode(player2,0)
    ExecuteHam(Ham_TakeDamage,player2,Ent,player,float(get_user_health(player2)*2),DMG_GENERIC);
    remove_entity(Ent)
    new name[32]
    get_user_name(player,name,31)
    new name2[32]
    get_user_name(player2,name2,31)
    
    console_print(0, "%s just murdered player named %s in cold blood! (Shocked gasps)^n",name,name2)
    log_amx("%s just murdered player named %s in cold blood! (Shocked gasps)^n",name,name2)
    return PLUGIN_HANDLED
}
public amx_stage_assault(id,level,cid){

    if (!cmd_access(id,level,cid,4))
        return PLUGIN_HANDLED

    new arg[32], arg2[32],arg3[8]
    read_argv(1,arg,31)
    read_argv(2,arg2,31)
    read_argv(3,arg3,8)

    new player = cmd_target(id,arg,2)
    
    if (!player) return PLUGIN_HANDLED
    
    new player2 = cmd_target(id,arg2,2)
    
    if (!player2) return PLUGIN_HANDLED
    
    if(!is_user_alive(player2)){
        
        console_print(id,"That player is dead! People are not stupid...^n")
        return PLUGIN_HANDLED    
            
    }
    new Ent = create_entity("info_target")
    if (pev_valid(Ent)!=2){
        console_print(id,"Error while creating killer entity!^n")
        return PLUGIN_HANDLED    
    }
    new Float:damage=str_to_float(arg3)
    entity_set_string(Ent, EV_SZ_classname, "real agression! TM!")
    ExecuteHam(Ham_TakeDamage,player2,Ent,player,damage,DMG_GENERIC);
    remove_entity(Ent)
    new name[32]
    get_user_name(player,name,31)
    new name2[32]
    get_user_name(player2,name2,31)
    
    console_print(0, "(Shocked gasps) %s just BELIGERANTELY assaulted a player named %s! (%0.2f damage)^n",name,name2,damage)
    log_amx("(Shocked gasps) %s just BELIGERANTELY assaulted a player named (%0.2f damage)%s!^n",name,name2,damage)
    return PLUGIN_HANDLED
}
public amx_stage_hit(id,level,cid){

    if (!cmd_access(id,level,cid,4))
        return PLUGIN_HANDLED

    new arg[32], arg2[32],arg3[8],arg4[8]
    read_argv(1,arg,31)
    read_argv(2,arg2,31)
    read_argv(3,arg3,8)
    read_argv(4,arg4,8)

    new player = cmd_target(id,arg,2)
    
    if (!player) return PLUGIN_HANDLED
    
    new player2 = cmd_target(id,arg2,2)
    
    if (!player2) return PLUGIN_HANDLED
    
    if(!is_user_alive(player2)){
        
        console_print(id,"That player is dead! People are not stupid...^n")
        return PLUGIN_HANDLED    
            
    }
    new Float:damage=str_to_float(arg3)
    new hitgroup=str_to_num(arg4)

    if(!is_valid_hitzone(hitgroup)){
        
        console_print(id,"The hitzone should be between 0 (and including) and %d (and including)^n",HIT_SHIELD)
        return PLUGIN_HANDLED    
    }

    new dmg_entity = create_entity("info_target")
    if (pev_valid(dmg_entity)!=2){
        console_print(id,"Error while creating hitter entity!^n")
        return PLUGIN_HANDLED    
    }
    entity_set_string(dmg_entity, EV_SZ_classname, "some_serious_harm")
    new tr_handle=create_tr2()
    static Float:origin_1[3],Float:origin_2[3],Float:dir_vec[3]

    entity_get_vector(player2,EV_VEC_origin,origin_2)
    entity_get_vector(player,EV_VEC_origin,origin_1)
    entity_set_edict(dmg_entity, EV_ENT_owner,player)

    xs_vec_sub(origin_2,origin_1,dir_vec)
    xs_vec_normalize(dir_vec,dir_vec)
    xs_vec_mul_scalar(dir_vec,entity_range(player2,player)*2,dir_vec)
    
    set_tr2(tr_handle, TR_pHit, player2);
    set_tr2(tr_handle, TR_iHitgroup, hitgroup);

    rg_multidmg_clear()
    ExecuteHamB(Ham_TraceAttack, player2,player,damage,dir_vec, tr_handle, DMG_BULLET)
    
    rg_multidmg_apply(dmg_entity,player)

    remove_entity(dmg_entity)

    free_tr2(tr_handle)
    new name[32]
    get_user_name(player,name,31)
    new name2[32]
    get_user_name(player2,name2,31)
    
    console_print(0, "%s just hit %s in hitzone %d, which is %s, with damage %0.2f!^n",name,name2,hitgroup,hitzone_names[hitgroup],damage)
    log_amx("%s just hit %s in hitzone %d, which is %s, with damage %0.2f!^n",name,name2,hitgroup,hitzone_names[hitgroup],damage)
    return PLUGIN_HANDLED
}