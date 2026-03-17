#if defined my_author_header_inc_stuff
  #endinput
#endif
#define my_author_header_inc_stuff

#define STRING_SIZE 128
#define BIG_STRING_SIZE (STRING_SIZE*4)

#define AUTHOR "ThrashBrat"

#define Struct enum

///native my_authored_register_func(const plugin_name[], const plugin_ver[], const original_author[], bool:is_modified=false, const new_author[]="")

stock my_authored_register_func(const plugin_name[], const plugin_ver[], const original_author[], bool:is_modified=false, const new_author[]="", const url[]="", const description[]=""){
    new author_string[BIG_STRING_SIZE]={0}
    if(is_modified){

        formatex(author_string,BIG_STRING_SIZE-1,"(MODIFIED BY %s) %s",new_author,original_author)
    }
    else{
        formatex(author_string,BIG_STRING_SIZE-1,"%s",original_author)
    }
    new result=register_plugin(plugin_name,plugin_ver,author_string,url,description)
    return result

}