#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "my_include/my_author_header.inc"
#define STRING_SIZE 128
#define BIG_STRING_SIZE (STRING_SIZE*4)

#define PLUGIN "authored register func"
#define VERSION "1.0.0"

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

}

public plugin_natives(){

    register_native("my_authored_register_func", "_my_authored_register_func",0)

}


//public _my_authored_register_func(const plugin_name[], const plugin_ver[], const original_author[], bool:is_modified=false, const new_author[]="")
/*public _my_authored_register_func(iPlugin, iParam){

    new plugin_name[STRING_SIZE],
        plugin_ver[STRING_SIZE],
        original_author[STRING_SIZE],
        new_author[STRING_SIZE]

    new is_modified=get_param(4)

    get_string(1,plugin_name,STRING_SIZE-1)
    get_string(2,plugin_ver,STRING_SIZE-1)
    get_string(3,original_author,STRING_SIZE-1)
    if(is_modified){
        get_string(5,new_author,STRING_SIZE-1)
    }

    new author_string[BIG_STRING_SIZE]={0}
    if(is_modified){

        formatex(author_string,BIG_STRING_SIZE-1,"%s (MODIFIED BY %s)",original_author,new_author)
    }
    else{
        formatex(author_string,BIG_STRING_SIZE-1,"%s",original_author)
    }
    new result=register_plugin(plugin_name,plugin_ver,author_string)
    return result

}*/