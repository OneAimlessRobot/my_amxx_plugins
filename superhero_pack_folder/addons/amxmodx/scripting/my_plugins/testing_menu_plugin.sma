
#define AUX_STUFF_GIVE_MACROS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define AUX_STUFF_GIVE_HITPOINTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_BASIC_MACROS
#define I_WANT_PDATA_ALIASES
#define I_WANT_RESOURCE_ALIASES
#include <float>
#include <xs>
#include <amxmodx>
#include <cstrike>
#include "../include/engine.inc"
#include <fakemeta>
#include <amxmisc>
#include <newmenus>
#include "../include/hamsandwich.inc"
#include "my_include/randomx.inc"
#include "my_include/auxiliar_stuff.inc"
#include "my_include/superheromod.inc"
#include "my_heroes/sh_aux_stuff/sh_aux_inc.inc"
#include "my_heroes/sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "ThrashBrat's first menu plugin"
#define VERSION "1.0.0"
#include "my_include/my_author_header.inc"

#define KEYS (MENU_KEY_0|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_BACK|MENU_EXIT)
#define MENU_NAME "The menu of things and stuff"
#define PLAYER_MENU_NAME "Available players:"
#define PLAYER_SUBMENU_NAME "What to do:"
#define BOT_DIFFICULTY_MENU_NAME "Bot difficulty menu name"

#define CMD_NAME "test_menu"

#define MARK_TASK_PERIOD 0.44
#define DRAW_AIM_VECTOR_TASK_PERIOD 0.44
#define FIX_AIM_VECTOR_TASK_PERIOD 0.44
#define AIMBOT_PLAYER_TASK_PERIOD 0.44
enum main_menu_constants{

    ENABLE_TESTING_MODE = 0,
    DISABLE_TESTING_MODE,
    TOGGLE_SUPERHERO_ALIVEDROP,
    EXEC_SUPERHEROMOD_CFG,
    DO_SOMETHING_TO_PLAYER,
    TOGGLE_BOT_AUTOKILL,
    CHANGE_BOT_DIFFICULTY,
    CHECK_BOT_DIFFICULTY,
    COUNT_ENTITIES_OF_TYPE,
    TOGGLE_ENTITY_CAP_MONITOR,
    PRODUCE_ROUND_RESTART,
    SET_NUMBER_OF_BOTS,
    SET_BOT_JOINED_TEAM,
    TOGGLE_BOT_FREEZE,
    TOGGLE_BOT_IGNORE_ENEMIES,
    TOGGLE_BOT_IGNORE_OBJECTIVES,
    GET_HERO_ID_FROM_NAME



}
/*


    menu_additem(gMenuID,"Enable testing mode")
    menu_additem(gMenuID,"Disable testing mode")
    menu_additem(gMenuID,"Toggle superhero alive drop")
    menu_additem(gMenuID,"Exec superheromod cfg")
    menu_additem(gMenuID,"Do something to a player")
    menu_additem(gMenuID,"Toggle Bot Autokill")
    menu_additem(gMenuID,"Change Bot Difficulty")
    menu_additem(gMenuID,"Check Bot Difficulty")
    menu_additem(gMenuID,"Count entities of a type")
    menu_additem(gMenuID,"Toggle entity cap monitor")
    menu_additem(gMenuID,"Produce game restart")
    menu_additem(gMenuID,"Set number of bots")
    menu_additem(gMenuID,"Set bot join team")
    menu_additem(gMenuID,"Toggle bot freeze")
    menu_additem(gMenuID,"Toggle bot ignore enemies")
    menu_additem(gMenuID,"Toggle bot ignore objectives")

*/
enum the_global_tasks{

    MARK,
    DRAW_AIM_VECTOR,
    FIX_PLAYER_AIM_VECTOR,
    AIMBOT_PLAYER


}

enum global_task_struct{

    the_func_name[128],
    the_taskid,
    Float:the_period


}



new g_who_marks_who[MAX_PLAYERS+1] = {0, ...},
    g_who_aimbots_who[MAX_PLAYERS+1] = {0, ...},
    g_who_draws_who_aim_vector[MAX_PLAYERS+1] = {0, ...},
    Float:g_player_countdown_mark[MAX_PLAYERS+1] = {0.0, ...},
    Float:g_player_countdown_draw_aim_vector[MAX_PLAYERS+1] = {0.0, ...},
    Float:g_player_fixed_aim_vector[MAX_PLAYERS+1][3];

new is_being_fixed_bitmask = 0,
    is_being_aimbotted = 0

new the_global_tasks_array[the_global_tasks][global_task_struct] = {

    {"generic_track_task", -1, MARK_TASK_PERIOD},
    {"draw_aim_vector_task", -1, DRAW_AIM_VECTOR_TASK_PERIOD},
    {"fix_player_aim_vector_task", -1, FIX_AIM_VECTOR_TASK_PERIOD},
    {"aimbot_player_task", -1, AIMBOT_PLAYER_TASK_PERIOD},



}

new gMenuID = -1

#define BOTS_AUTOKILL_DELAY_CVAR_NAME "yb_autokill_delay"
#define DEFAULT_AUTOKILL_DELAY_VALUE 4.0
#define BOTS_DIFFICULTY_CVAR_NAME "yb_difficulty"


enum bot_difficulty_tag{

    MININUM = 0,
    MEDIUM,
    HARD,
    ULTRA,
    MAXIMUM,
    


}

new bot_difficulty_names[bot_difficulty_tag][128] = {

    "Easiest",
    "Normal",
    "Hard",
    "Ultra",
    "Maximum"




}

new pcvar_sh_alive_drop = -1,
    pcvar_bot_autokill_delay = -1,
    pcvar_bot_difficulty = -1,
    pcvar_round_restart = -1,
    pcvar_yb_quota = -1,
    pcvar_bot_join_team = -1,
    pcvar_yb_ignore_objectives = -1,
    pcvar_yb_ignore_enemies = -1,
    pcvar_yb_freeze_bots = -1

public plugin_init(){


    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    pcvar_yb_quota = get_cvar_pointer("yb_quota")
    pcvar_sh_alive_drop = get_cvar_pointer("sh_alivedrop")
    pcvar_yb_ignore_objectives = get_cvar_pointer("yb_ignore_objectives")
    pcvar_yb_ignore_enemies = get_cvar_pointer("yb_ignore_enemies")
    pcvar_yb_freeze_bots = get_cvar_pointer("yb_freeze_bots")
    pcvar_round_restart = get_cvar_pointer("sv_restart")
    pcvar_bot_join_team = get_cvar_pointer("yb_join_team")
    pcvar_bot_autokill_delay = get_cvar_pointer(BOTS_AUTOKILL_DELAY_CVAR_NAME)
    pcvar_bot_difficulty = get_cvar_pointer(BOTS_DIFFICULTY_CVAR_NAME)

    register_concmd("set_quota", "set_quota", ADMIN_IMMUNITY, "Set number of bots to play with")
    register_concmd("set_bot_team", "set_bot_team", ADMIN_IMMUNITY, "Sets the team that bots are allowed to join")
    register_concmd("pick_hero_on_player", "pick_hero_on_player", ADMIN_IMMUNITY, "Force-Pick hero on player by heroID")
    register_concmd("drop_hero_off_of_player", "drop_hero_off_of_player", ADMIN_IMMUNITY, "Force-Drop hero on player by heroID")
    register_concmd("amx_countentities", "amx_countentities", ADMIN_IMMUNITY, "Search number of entities based on name")
    register_concmd("amx_get_hero_id_from_name", "amx_get_hero_id_from_name", ADMIN_IMMUNITY, "Match part of a hero name and obtain FIRST hero id along with the full name that matches!")

    register_clcmd(CMD_NAME, "menu_display_inittializer", ADMIN_IMMUNITY, "My first menu")
    RegisterHam(Ham_Spawn, "player", "ham_PlayerSpawn_Post", 1, true)


    for(new any:i =  enum_zero; i<the_global_tasks; i++){

        the_global_tasks_array[i][the_taskid] = allocate_typed_task_id(generic_task)
        set_task(the_global_tasks_array[i][the_period], the_global_tasks_array[i][the_func_name],the_global_tasks_array[i][the_taskid], _,_,"b")

    }

}
enum things_to_do_to_players{

    align_angle_vectors,
    revive_player,
    track_player,
    draw_aim_vector_val,
    aimbot_player

}

enum thing_to_do_to_player_struct{

    item_name[128],
    func_name[128],
    num_parameters


}

new things_to_do_to_player_array[things_to_do_to_players][thing_to_do_to_player_struct] = {

    {"Align their angle vector with yours", "align_with_player_vector", 1},
    {"Revive a player", "amx_revive", 1},
    {"Track a player", "amx_track", 1},
    {"Render a player's aim vector just for you", "amx_draw_aim_vector", 1},
    {"Lock a players aim to an entity", "amx_aimbot_player", 1}


}

point_player_towards_other_player(handled_player, target_player){
    static Float:the_raw_carthesian_vector_to_store[3],
            Float:the_angle_vector_to_apply[3]

    //the output of this is a carthesian vector!
    get_entity_direction_vector_raw(handled_player,target_player, the_raw_carthesian_vector_to_store)

    //Normalize it!
    vector_norm(the_raw_carthesian_vector_to_store,the_raw_carthesian_vector_to_store)

    vector_to_angle(the_raw_carthesian_vector_to_store,the_angle_vector_to_apply)


    the_angle_vector_to_apply[0] = -the_angle_vector_to_apply[0]

    entity_set_vector(handled_player, EV_VEC_v_angle,the_angle_vector_to_apply)
    entity_set_vector(handled_player, EV_VEC_angles,the_angle_vector_to_apply)
    entity_set_int(handled_player, EV_INT_fixangle, 1)


}
public amx_countentities(id,level,cid){

    if (!cmd_access(id,level,cid,1)){
        return PLUGIN_HANDLED
    }

    new arg[128]
    read_argv(1,arg,charsmax(arg))
    new count = 0

    new grenada = find_ent_by_class(-1, arg)
    while(grenada) {
        count++
        grenada = find_ent_by_class(grenada,arg)

    }

    client_print(id,print_chat, "We have found a total of %d entities with classname exactly equal to ^"%s^"",count,arg)

    return PLUGIN_HANDLED


}
public amx_get_hero_id_from_name(id,level,cid){

    if (!cmd_access(id,level,cid,1)){
        return PLUGIN_HANDLED
    }

    static arg[MAX_HERO_NAME_LENGTH]
    
    static obtained_hero_name[MAX_HERO_NAME_LENGTH]


    read_argv(1,arg,charsmax(arg))


    copy(obtained_hero_name,sizeof(arg),arg)

    
    new heroID = sh_match_string_with_hero_name(id,obtained_hero_name)

    //internal array indices only count to (SH_MAXHEROS-1)

    if(heroID<0 || heroID >= SH_MAXHEROS){

        client_print(id, print_chat, "No valid hero id or name was obtained!")
        return PLUGIN_HANDLED
        
    }


    client_print(id,print_chat, "The hero id obtained from the pattern ^"*%s*^" was %d! from hero named ^"%s^"",arg,heroID,obtained_hero_name)

    return PLUGIN_HANDLED


}
public generic_track_task(task_id){


    static the_players[MAX_PLAYERS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if(!is_user_alive(id)){

            continue
        }

        if(!is_user_alive(g_who_marks_who[id])){

            continue
        }
        if(g_player_countdown_mark[id]<=0.0){

            continue
        }
        static Float:my_origin[3], Float:tg_origin[3]

        entity_get_vector(id, EV_VEC_origin, my_origin)
        entity_get_vector(g_who_marks_who[id], EV_VEC_origin, tg_origin)

        laser_line(id,my_origin,tg_origin,false,sh_custom_color:{WHITE,WHITE,WHITE}, true)

        g_player_countdown_mark[id] -= min_macro(MARK_TASK_PERIOD, g_player_countdown_mark[id])


        
    }
}

public draw_aim_vector_task(task_id){


    static the_players[MAX_PLAYERS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if(!is_user_alive(id)){

            continue
        }

        if(!is_user_alive(g_who_draws_who_aim_vector[id])){

            continue
        }
        if(g_player_countdown_draw_aim_vector[id]<=0.0){

            continue
        }
        static Float:aim_origin[3], Float:tg_origin[3]

        my_get_aim_origin(g_who_draws_who_aim_vector[id],aim_origin)
        entity_get_vector(g_who_draws_who_aim_vector[id], EV_VEC_origin, tg_origin)

        laser_line(id,tg_origin,aim_origin,false,sh_custom_color:{WHITE,WHITE,WHITE}, true)

        g_player_countdown_draw_aim_vector[id] -= min_macro(MARK_TASK_PERIOD, g_player_countdown_draw_aim_vector[id])


        
    }
}

public fix_player_aim_vector_task(task_id){

    static the_players[MAX_PLAYERS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if(!is_user_alive(id)){

            continue
        }
        if(!is_user_alive(id)){

            continue
        }

        if(!Get_BitVar(is_being_fixed_bitmask,id)){

            continue


        }
        entity_set_vector(id,EV_VEC_angles,g_player_fixed_aim_vector[id])

        entity_set_vector(id,EV_VEC_v_angle,g_player_fixed_aim_vector[id])

        entity_set_int(id,EV_INT_fixangle,1)


        
    }
    
}
public aimbot_player_task(task_id){

    static the_players[MAX_PLAYERS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if(!is_user_alive(id)){

            continue
        }
        if(!is_user_alive(id)){

            continue
        }

        if(!Get_BitVar(is_being_aimbotted,id)){

            continue


        }
        if(!is_user_alive(g_who_aimbots_who[id])){

            continue
        }

        point_player_towards_other_player(id,g_who_aimbots_who[id])


        
    }
    
}
public amx_track(id,tg_id){

    if (!is_user_connected(id)){
        
        return
    }
    if(!is_user_alive(tg_id)){
        
        
        console_print(id,"They need to be alive for you to use this!^nRejected.")
        return

    }
    
    static Float:origin[3]
    entity_get_vector(tg_id,EV_VEC_origin,origin)
    detect_user(id,tg_id,origin)
    g_player_countdown_mark[id] = 3.0
    g_who_marks_who[id] = tg_id


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


public amx_draw_aim_vector(id,tg_id){

    if (!is_user_connected(id)){
        
        return
    }
    if(!is_user_alive(tg_id)){
        
        
        console_print(id,"They need to be alive for you to use this!^nRejected.")
        return

    }
    
    static Float:origin[3]
    entity_get_vector(tg_id,EV_VEC_origin,origin)
    detect_user(id,tg_id,origin)
    g_player_countdown_draw_aim_vector[id] = 3.0
    g_who_draws_who_aim_vector[id] = tg_id


}

public amx_revive(id,tg_id){

    
    if (!is_user_connected(id)){
        return
    }
    if(is_user_alive(tg_id)){
        
        
        console_print(id,"That player is still alive! Rejecting^n")
        return

    }
    cs_user_spawn(tg_id)
    static name[32], name2[32]
    get_user_name(tg_id,name,31)
    
    get_user_name(id,name2,31)

    console_print(0, "%s just respawned player named %s!^n",name2,name)
    log_amx("%s just respawned player named %s!^n",name2,name)
    client_print(tg_id,print_chat,"[AMXX Revive]: %s has just revived you!",name2);
    client_print(id,print_chat,"[AMXX Revive]: You just revived %s!",name);
    
}
public ham_PlayerSpawn_Post(ent_id){

    if(!is_user_alive(ent_id)){
        return HAM_IGNORED
    }

    g_who_marks_who[ent_id] = 0
    g_who_aimbots_who[ent_id] = 0
    g_who_draws_who_aim_vector[ent_id] = 0
    g_player_countdown_mark[ent_id] = 0.0
    g_player_countdown_draw_aim_vector[ent_id] = 0.0;

    Assign_BitVar(is_being_fixed_bitmask,ent_id, false_for_macro);
    Assign_BitVar(is_being_aimbotted,ent_id, false_for_macro);
    

    return HAM_IGNORED

}

public align_with_player_vector(id, tg_id){

    if(!client_is_within_custom_range(tg_id,MAX_PLAYERS)){
        return
    }

    if(!is_user_alive(tg_id)){
        
        
        console_print(id,"They need to be alive for you to use this!^nRejected.")
        return

    }
    static Float:cart_vector_for_aiming[3],
            player_name[128]
    

    get_user_name(tg_id, player_name, charsmax(player_name))


    if(Get_BitVar(is_being_aimbotted,tg_id)){

        console_print(id,"%s is already being aimbotted!",player_name)
        return

    }
    if(Get_BitVar(is_being_fixed_bitmask,tg_id)){

        Assign_BitVar(is_being_fixed_bitmask,tg_id, false_for_macro)
        console_print(id,"Toggling aim fixing off for %s!",player_name)
        return

    }



    client_print(id, print_chat, "We have attempted to toggle on aimfixing AND align %s 's aim and rotation angles with yours!",player_name)
    
    velocity_by_aim(id, 40, cart_vector_for_aiming)

    vector_to_angle(cart_vector_for_aiming,g_player_fixed_aim_vector[tg_id])

    

    g_player_fixed_aim_vector[tg_id][0] = -g_player_fixed_aim_vector[tg_id][0]

    Assign_BitVar(is_being_fixed_bitmask,tg_id, true_for_macro)


}
public amx_aimbot_player(id, tg_id){

    if(!client_is_within_custom_range(tg_id,MAX_PLAYERS)){
        return
    }

    if(!is_user_alive(tg_id)){
        
        
        console_print(id,"They need to be alive for you to use this!^nRejected.")
        return

    }
    static player_name[128]
    

    get_user_name(tg_id, player_name, charsmax(player_name))
    

    if(Get_BitVar(is_being_fixed_bitmask,tg_id)){

        console_print(id,"%s is already being aimfixed!",player_name)
        return

    }

    if(Get_BitVar(is_being_aimbotted,tg_id)){

        Assign_BitVar(is_being_aimbotted,tg_id, false_for_macro)
        console_print(id,"Removing aimbotting from %s!",player_name)
        return

    }

    show_aimbot_target_menu(id,tg_id)


}

aimbot_player_payload(id, aimbot_cheater, tg_id){


    if(!is_user_alive(aimbot_cheater)){
        console_print(id, "This player is dead! You cant do that")
        return

    }
    if(!is_user_alive(tg_id)){
        console_print(id, "The target is dead! You cant do that")
        return

    }

    Assign_BitVar(is_being_aimbotted,aimbot_cheater, true_for_macro)

    g_who_aimbots_who[aimbot_cheater] = tg_id



}
show_aimbot_target_menu(id,aimbot_user){

    new menuID = menu_create(PLAYER_MENU_NAME, "aimbot_target_player_handler")

    static item_string[3]
        
    new bool:should_show_menu = false
    static the_players[MAX_PLAYERS], pnum, pid, player_name[128], item_label_string[128], team_name[128]
    get_players(the_players, pnum, "h")
    for (new i = 0; i < pnum; i++) {
        
        pid = the_players[i]

        if(!is_user_alive(pid)){

            continue
        }
        if(pid == aimbot_user){

            continue
        }
        
        
        if(!should_show_menu){

            should_show_menu = true

        }
        item_string[0] = id
        item_string[1] = aimbot_user
        item_string[2] = pid

        get_user_team(pid, team_name, charsmax(team_name))
        get_user_name(pid,player_name, charsmax(player_name))
        
        formatex(item_label_string,charsmax(item_label_string), "%s, %s, %s",player_name, team_name,is_user_alive(pid)?"Alive!":"Dead...")

        menu_additem(menuID,item_label_string,item_string)

    }

    should_show_menu?menu_display(id,menuID):menu_destroy(menuID)

}
show_player_menu(id){

    new menuID = menu_create(PLAYER_MENU_NAME, "do_something_to_player_menu_handler")

    static item_string[1]
        
    new bool:should_show_menu = false
    static the_players[MAX_PLAYERS], pnum, pid, player_name[128], item_label_string[128], team_name[128]
    get_players(the_players, pnum, "h")
    for (new i = 0; i < pnum; i++) {
        
        pid = the_players[i]

        if(!is_user_connected(pid)){

            continue
        }
        
        
        if(!should_show_menu){

            should_show_menu = true

        }
        item_string[0] = pid

        get_user_team(pid, team_name, charsmax(team_name))
        get_user_name(pid,player_name, charsmax(player_name))
        
        formatex(item_label_string,charsmax(item_label_string), "%s, %s, %s",player_name, team_name,is_user_alive(pid)?"Alive!":"Dead...")

        menu_additem(menuID,item_label_string,item_string)

    }

    should_show_menu?menu_display(id,menuID):menu_destroy(menuID)

}
public do_something_to_player_menu_handler(id, menu, item){


    if(item <0){

        return PLUGIN_HANDLED
    }

    static item_string[1],
    player_id = 0
    menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
    player_id = item_string[0]

    if(is_user_connected(player_id)){
        

        do_something_to_player_submenu(id, player_id)
    }
    return PLUGIN_CONTINUE

}

do_something_to_player_submenu(id, player_id){

    new menuID = menu_create(PLAYER_SUBMENU_NAME, "do_something_to_player_submenu_handler")

    static item_string[2]
        
    new bool:should_show_menu = false
    for (new any:i = enum_zero; i < things_to_do_to_players; i++) {
        
        
        if(!should_show_menu){

            should_show_menu = true

        }

        item_string[0] = player_id
        item_string[1] = get_func_id(things_to_do_to_player_array[i][func_name])
        
        menu_additem(menuID,things_to_do_to_player_array[i][item_name],item_string)

    }

    should_show_menu?menu_display(id,menuID):menu_destroy(menuID)

}
public do_something_to_player_submenu_handler(id, menu, item){

    static item_string[2],
    player_id = 0,
    function_to_do = 0

    menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
    player_id = item_string[0]
    function_to_do = item_string[1]

    callfunc_begin_i(function_to_do)
    callfunc_push_int(id)
    callfunc_push_int(player_id)
    callfunc_end()

}
public aimbot_target_player_handler(id, menu, item){

    static item_string[3],
    id = 0,
    player_id = 0,
    player_id_to_aimbot = 0

    menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
    id = item_string[0]
    player_id = item_string[1]
    player_id_to_aimbot = item_string[2]
    
    aimbot_player_payload(id, player_id, player_id_to_aimbot)

}


public menu_display_inittializer(id,level,cid){

    if (!cmd_access(id,level,cid,1))
        return PLUGIN_HANDLED

    if(!is_user_connected(id)){
        return PLUGIN_HANDLED
    }
    gMenuID = menu_create(MENU_NAME, "menu_function_example")

    menu_additem(gMenuID,"Enable testing mode")
    menu_additem(gMenuID,"Disable testing mode")
    menu_additem(gMenuID,"Toggle superhero alive drop")
    menu_additem(gMenuID,"Exec superheromod cfg")
    menu_additem(gMenuID,"Do something to a player")
    menu_additem(gMenuID,"Toggle Bot Autokill")
    menu_additem(gMenuID,"Change Bot Difficulty")
    menu_additem(gMenuID,"Check Bot Difficulty")
    menu_additem(gMenuID,"Count entities of a type")
    menu_additem(gMenuID,"Toggle entity cap monitor")
    menu_additem(gMenuID,"Produce game restart")
    menu_additem(gMenuID,"Set number of bots")
    menu_additem(gMenuID,"Set bot join team")
    menu_additem(gMenuID,"Toggle bot freeze")
    menu_additem(gMenuID,"Toggle bot ignore enemies")
    menu_additem(gMenuID,"Toggle bot ignore objectives")
    menu_additem(gMenuID,"Obtain hero id from part of name!")


    
    menu_display(id,gMenuID)
    
    return PLUGIN_HANDLED
}


show_bot_difficulty_menu(id){

    new menuID = menu_create(BOT_DIFFICULTY_MENU_NAME, "bot_difficulty_menu_handler")

    static item_string[1]
        
    new bool:should_show_menu = false
    for (new any:i = enum_zero; i < bot_difficulty_tag; i++) {
        
        
        if(!should_show_menu){

            should_show_menu = true

        }

        item_string[0] = i
        
        menu_additem(menuID,bot_difficulty_names[i],item_string)

    }

    should_show_menu?menu_display(id,menuID):menu_destroy(menuID)

}

public bot_difficulty_menu_handler(id, menu, item){

    static item_string[1],
    bot_difficulty_tag:difficulty = enum_zero;


    menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
    static shitty_variable_leave_me_alone_stupid_warning; shitty_variable_leave_me_alone_stupid_warning = _:bot_difficulty_tag
    difficulty = bot_difficulty_tag:clamp_macro(item_string[0], 0,shitty_variable_leave_me_alone_stupid_warning-1)

    set_pcvar_num(pcvar_bot_difficulty,_:difficulty)

    client_print(id, print_chat, "Difficulty set to %s!", bot_difficulty_names[difficulty])



}
public set_quota(id,level,cid){

    if (!cmd_access(id,level,cid,1)){
        return PLUGIN_HANDLED
    }

    new arg[31]
    read_argv(1,arg,charsmax(arg))
    new the_quota_num = str_to_num(arg)


    set_pcvar_num(pcvar_yb_quota,clamp_macro(the_quota_num,0,get_maxplayers()))
    return PLUGIN_HANDLED

}
public pick_hero_on_player(id,level,cid){

    if (!cmd_access(id,level,cid,2)){
        return PLUGIN_HANDLED
    }
    new arg1[128],arg2[8]

    read_argv(1, arg1, charsmax(arg1))

    new player = cmd_target(id,arg1,2)
    
    if (!player) return PLUGIN_HANDLED

    read_argv(2, arg2, charsmax(arg2))

    new heroID = str_to_num(arg2)

    if(!sh_pick_hero_without_menu(player,heroID)){

        console_print(id, "Unable to force pick hero with ID %d onto player %d!",heroID,player)
    }
    else{
        console_print(id, "Operation successful!")


    }
    return PLUGIN_HANDLED
}
public drop_hero_off_of_player(id,level,cid){

    if (!cmd_access(id,level,cid,2)){
        return PLUGIN_HANDLED
    }
    new arg1[128],arg2[8]

    read_argv(1, arg1, charsmax(arg1))

    new player = cmd_target(id,arg1,2)
    
    if (!player) return PLUGIN_HANDLED

    read_argv(2, arg2, charsmax(arg2))

    new heroID = str_to_num(arg2)

    if(!sh_remove_user_power_without_menu(player,heroID)){

        console_print(id, "Unable to force drop hero with ID %d from player %d!",heroID,player)
    }
    else{
        console_print(id, "Operation successful!")


    }
    return PLUGIN_HANDLED
}
public set_bot_team(id,level,cid){

    if (!cmd_access(id,level,cid,1)){
        return PLUGIN_HANDLED
    }

    new arg0[128]

    read_argv(1,arg0, charsmax(arg0))
    
    set_pcvar_string(pcvar_bot_join_team,arg0)
    return PLUGIN_HANDLED

}

public menu_function_example(id, menu, item)
{   
    if(menu!=gMenuID){
        return PLUGIN_HANDLED
    }
    static bool:alivedrop = false,
            Float:autokill_delay = 0.0,
            bool:bot_freeze = false,
            bool:bot_ignore_objectives = false,
            bool:bot_ignore_enemies = false

    alivedrop=false;
    bot_freeze=false;
    bot_ignore_objectives=false;
    bot_ignore_enemies=false;
    autokill_delay = 0.0;
    
    switch(main_menu_constants:item){
        case ENABLE_TESTING_MODE:{

            server_cmd("+testing")
            server_exec()

        }
        case DISABLE_TESTING_MODE:{

            server_cmd("-testing")
            server_exec()

        }
        case TOGGLE_SUPERHERO_ALIVEDROP:{
            alivedrop = (get_pcvar_bool(pcvar_sh_alive_drop)) 

            set_pcvar_bool(pcvar_sh_alive_drop,!alivedrop)

            client_print(id, print_chat, "Superhero alive drop %s",!alivedrop?"Enabled!":"Disabled...")
        }
        case EXEC_SUPERHEROMOD_CFG:{
            
            server_cmd("exec %s", "exec_superhero_cfg.cfg")

        }
        case DO_SOMETHING_TO_PLAYER:{

            
            show_player_menu(id)

        }
        case TOGGLE_BOT_AUTOKILL:{

            autokill_delay = (get_pcvar_float(pcvar_bot_autokill_delay))

            set_pcvar_float(pcvar_bot_autokill_delay,(autokill_delay>0.0)?0.0:DEFAULT_AUTOKILL_DELAY_VALUE)

            client_print(id, print_chat, "Bot autokill %s",(autokill_delay<=0.0)?"Enabled!":"Disabled...")

        }
        case CHANGE_BOT_DIFFICULTY:{

            show_bot_difficulty_menu(id)

        }
        case CHECK_BOT_DIFFICULTY:{

            client_print(id, print_chat, "The current bot difficulty is: %s!",
            
                        bot_difficulty_names[bot_difficulty_tag:cvar_val(num, pcvar_bot_difficulty)])

        }
        case COUNT_ENTITIES_OF_TYPE:{

            client_cmd(id, "messagemode amx_countentities")
        }
        case TOGGLE_ENTITY_CAP_MONITOR:{

            server_cmd("toggle_print_num_ents_cycle")
        }
        case PRODUCE_ROUND_RESTART:{

            set_pcvar_num(pcvar_round_restart,1)
        }
        case SET_NUMBER_OF_BOTS:{

            client_cmd(id, "messagemode set_quota")
            
        }
        case SET_BOT_JOINED_TEAM:{
            client_cmd(id, "messagemode set_bot_team")
            
        }
        case TOGGLE_BOT_FREEZE:{

            bot_freeze = (get_pcvar_bool(pcvar_yb_freeze_bots)) 

            set_pcvar_bool(pcvar_yb_freeze_bots,!bot_freeze)

            client_print(id, print_chat, "Keep bots frozen %s",!bot_freeze?"Enabled!":"Disabled...")
            
        }
        case TOGGLE_BOT_IGNORE_ENEMIES:{

            bot_ignore_enemies = (get_pcvar_bool(pcvar_yb_ignore_enemies)) 

            set_pcvar_bool(pcvar_yb_ignore_enemies,!bot_ignore_enemies)

            client_print(id, print_chat, "Bot ignore enemies %s",!bot_ignore_enemies?"Enabled!":"Disabled...")
            
        }
        case TOGGLE_BOT_IGNORE_OBJECTIVES:{

            bot_ignore_objectives = (get_pcvar_bool(pcvar_yb_ignore_objectives)) 

            set_pcvar_bool(pcvar_yb_ignore_objectives,!bot_ignore_objectives)

            client_print(id, print_chat, "Bot ignore objectives %s",!bot_ignore_objectives?"Enabled!":"Disabled...")
            
        }
        case GET_HERO_ID_FROM_NAME:{


            client_cmd(id, "messagemode amx_get_hero_id_from_name")
        }

        /*
            menu canceled!
        */
        default:{
            
        }

    }

    menu_destroy(gMenuID)
    return PLUGIN_HANDLED
}