#include <amxmodx>
#include <amxmisc>
#include <newmenus>



#define PLUGIN "ThrashBrat's first menu plugin"
#define VERSION "1.0.0"
#include "my_include/my_author_header.inc"

#define KEYS (MENU_KEY_0|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_BACK|MENU_EXIT)
#define MENU_NAME "The menu of things and stuff"
#define CMD_NAME "amx_testing_mode_menu"
new gMenuID = -1





public plugin_init(){


    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd(CMD_NAME, "menu_display_inittializer", ADMIN_IMMUNITY, "My first menu")
    



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
    menu_display(id,gMenuID)
    
    return PLUGIN_HANDLED
}



public menu_function_example(id, menu, item)
{   
    if(menu!=gMenuID){
        return PLUGIN_HANDLED
    }
    switch(item){
        case 0:{

            server_cmd("+testing")
            server_exec()

        }
        case 1:{

            server_cmd("-testing")
            server_exec()

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