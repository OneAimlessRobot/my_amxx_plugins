#include <amxconst>
#include <csx>
#include "../my_include/superheromod.inc"
#include "../my_include/my_author_header.inc"

#define PLUGIN "Superhero damage source logging"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock generic_dmg_source_wpn_id;
const bool:generic_dmg_source_is_melee=false;
stock generic_dmg_hero_name[MAX_HERO_NAME_LENGTH]="some_hero"
stock const generic_dmg_source_name[SAFE_BUFFER_SIZE+1]="sh_generic_dmg";
stock const generic_dmg_source_log_name[SAFE_BUFFER_SIZE+1]="sh_generic_dmg";

//These are indexed by "SH_CUSTOM_DMG_WPN_ID"
//and the max number of weapons is "MAX_SH_CUSTOM_DMG_SOURCES"
enum damage_source_struct{

    the_hero_id,
    bool:is_damage_source_a_melee,
    dmg_source_short_name[SAFE_BUFFER_SIZE+1],
    dmg_source_log_name[SAFE_BUFFER_SIZE+1]


}

new sh_damage_source_arrays[MAX_SH_CUSTOM_DMG_SOURCES][damage_source_struct]


//returns wpn_id to be used in calls to sh_extra_damage if desired


public plugin_init(){

    register_plugin(PLUGIN, VERSION, AUTHOR);
    

    generic_dmg_source_wpn_id=sh_log_custom_damage_source();
}

public plugin_natives(){

    register_native("sh_log_custom_damage_source", "_sh_log_custom_damage_source")
    register_native("sh_get_generic_dmg_source_wpn_id", "_sh_get_generic_dmg_source_wpn_id")


}
public _sh_get_generic_dmg_source_wpn_id(iPlugin,iParams){

    return generic_dmg_source_wpn_id;
}
public _sh_log_custom_damage_source(iPlugin,iParams){

    new hero_id= get_param(1)

    static short_name_arr[SAFE_BUFFER_SIZE+1],
        log_name_arr[SAFE_BUFFER_SIZE+1]
    
    bzero(short_name_arr);
    bzero(log_name_arr);

    get_string(2,short_name_arr,charsmax(short_name_arr))
    get_string(3,log_name_arr,charsmax(log_name_arr))
    new bool:is_a_melee= bool:get_param(4)
    new is_generic_hero=0;
    if((hero_id<-1 )|| (hero_id >=SH_MAXHEROS+1)){
        is_generic_hero=1;
        /*
        server_print("Invalid hero id %d at _sh_log_custom_damage_source!^nHero id must be between exactly %d and %d!^nGeneric damage source will be logged^n",hero_id,-1,SH_MAXHEROS-1)
        */
    }
    new wpn_id=custom_weapon_add(is_generic_hero?generic_dmg_source_name:short_name_arr, is_generic_hero?generic_dmg_source_is_melee:is_a_melee, is_generic_hero?generic_dmg_source_log_name:log_name_arr)
    if(wpn_id>0){
        sh_damage_source_arrays[wpn_id][the_hero_id] = is_generic_hero?-1:hero_id;
        sh_damage_source_arrays[wpn_id][is_damage_source_a_melee]=is_generic_hero?generic_dmg_source_is_melee:is_a_melee;
        copy(sh_damage_source_arrays[wpn_id][dmg_source_short_name],SAFE_BUFFER_SIZE,is_generic_hero?generic_dmg_source_name:short_name_arr)
        copy(sh_damage_source_arrays[wpn_id][dmg_source_log_name],SAFE_BUFFER_SIZE,is_generic_hero?generic_dmg_source_log_name:log_name_arr)
        
    }
    else{

        server_print("Invalid wpn_id obtained at _sh_log_custom_damage_source!^nIt came out as %d which is <= 0!^nAborting...^n",wpn_id)
        wpn_id=-1
    }
    
    /*if(sh_damage_source_is_a_melee[wpn_id]){
        
    server_print("^nValid wpn_id obtained! %d^n",wpn_id)

    static hero_name[MAX_HERO_NAME_LENGTH]
    if(sh_damage_source_arrays[wpn_id][the_hero_id]>=0){
        sh_get_hero_name_from_id(hero_id, hero_name)

    }
    else{

        server_print("It is for a generic hero!");
    }
    server_print("The hero name is: %s",
            is_generic_hero?generic_dmg_hero_name:hero_name)

    server_print("The short name was: %s",
                                sh_damage_source_arrays[wpn_id][dmg_source_short_name])

    server_print("The log name was: %s",
                               sh_damage_source_arrays[wpn_id][dmg_source_log_name])

    server_print("This weapon is %s a melee!",
                                sh_damage_source_arrays[wpn_id][is_damage_source_a_melee]?"considered a":"NOT considered a")
    }
    */
    return wpn_id
}