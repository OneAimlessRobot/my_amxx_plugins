
#define AUX_STUFF_GIVE_MACROS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
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


enum the_global_tasks{

    MARK,
    DRAW_AIM_VECTOR,
    FIX_PLAYER_AIM_VECTOR


}

enum global_task_struct{

    the_func_name[128],
    the_taskid,
    Float:the_period


}



new g_who_marks_who[MAX_PLAYERS+1] = {0, ...},
    g_who_draws_who_aim_vector[MAX_PLAYERS+1] = {0, ...},
    Float:g_player_countdown_mark[MAX_PLAYERS+1] = {0.0, ...},
    Float:g_player_countdown_draw_aim_vector[MAX_PLAYERS+1] = {0.0, ...},
    Float:g_player_fixed_aim_vector[MAX_PLAYERS+1][3];

new is_being_fixed_bitmask = 0

new the_global_tasks_array[the_global_tasks][global_task_struct] = {

    {"generic_track_task", -1, MARK_TASK_PERIOD},
    {"draw_aim_vector_task", -1, DRAW_AIM_VECTOR_TASK_PERIOD},
    {"fix_player_aim_vector_task", -1, FIX_AIM_VECTOR_TASK_PERIOD},



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
    pcvar_bot_difficulty = -1

public plugin_init(){


    register_plugin(PLUGIN, VERSION, AUTHOR);
    pcvar_sh_alive_drop = get_cvar_pointer("sh_alivedrop")
    pcvar_bot_autokill_delay = get_cvar_pointer(BOTS_AUTOKILL_DELAY_CVAR_NAME)
    pcvar_bot_difficulty = get_cvar_pointer(BOTS_DIFFICULTY_CVAR_NAME)

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
    draw_aim_vector_val

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
    {"Render a player's aim vector just for you", "amx_draw_aim_vector", 1}


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
    g_who_draws_who_aim_vector[ent_id] = 0
    g_player_countdown_mark[ent_id] = 0.0
    g_player_countdown_draw_aim_vector[ent_id] = 0.0;

    Assign_BitVar(is_being_fixed_bitmask,ent_id, false_for_macro)

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
show_player_menu(id){

    new menuID = menu_create(PLAYER_MENU_NAME, "do_something_to_player_menu_handler")

    static item_string[1]
        
    new bool:should_show_menu = false
    static the_players[MAX_PLAYERS], pnum, pid, player_name[128], item_label_string[128], team_name[128]
    get_players(the_players, pnum)
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
    menu_additem(gMenuID,"Do something to a player")
    menu_additem(gMenuID,"Toggle Bot Autokill")
    menu_additem(gMenuID,"Change Bot Difficulty")

    
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
    difficulty = bot_difficulty_tag:item_string[0]

    set_pcvar_num(pcvar_bot_difficulty,_:difficulty)

    client_print(id, print_chat, "Difficulty set to %s!", bot_difficulty_names[difficulty])



}
public menu_function_example(id, menu, item)
{   
    if(menu!=gMenuID){
        return PLUGIN_HANDLED
    }
    static bool:alivedrop = false,
            Float:autokill_delay = 0.0
    alivedrop=false;
    autokill_delay = 0.0;
    switch(item){
        case 0:{

            server_cmd("+testing")
            server_exec()

        }
        case 1:{

            server_cmd("-testing")
            server_exec()

        }
        case 2:{
            alivedrop = (get_pcvar_bool(pcvar_sh_alive_drop)) 

            set_pcvar_bool(pcvar_sh_alive_drop,!alivedrop)

            client_print(id, print_chat, "Superhero alive drop %s",!alivedrop?"Enabled!":"Disabled...")
        }
        case 3:{

            
            show_player_menu(id)

        }
        case 4:{

            autokill_delay = (get_pcvar_float(pcvar_bot_autokill_delay))

            set_pcvar_float(pcvar_bot_autokill_delay,(autokill_delay>0.0)?0.0:DEFAULT_AUTOKILL_DELAY_VALUE)

            client_print(id, print_chat, "Bot autokill %s",(autokill_delay<=0.0)?"Enabled!":"Disabled...")

        }
        case 5:{

            show_bot_difficulty_menu(id)

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