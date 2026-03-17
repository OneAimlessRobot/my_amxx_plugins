#include "../my_include/superheromod.inc"
#include "../my_include/my_author_header.inc"

#define PLUGIN "Superhero damage source logging"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

public plugin_init(){

    register_plugin(PLUGIN, VERSION, AUTHOR);
    arrayset(sh_damage_source_hero_ids,0,sizeof(sh_damage_source_hero_ids))
    for(new i=0;i<MAX_SH_CUSTOM_DMG_SOURCES;i++){
        arrayset(sh_damage_source_short_names[i],0,sizeof(sh_damage_source_short_names))
        arrayset(sh_damage_source_long_names[i],0,sizeof(sh_damage_source_long_names))
    }
    generic_dmg_source_wpn_id=sh_log_damage_source_primitive();
}

public plugin_natives(){

    register_native("sh_log_custom_damage_source", "_sh_log_custom_damage_source",0)


}

sh_log_damage_source_primitive(hero_id=-1,short_name[SAFE_BUFFER_SIZE+1]="",long_name[SAFE_BUFFER_SIZE+1]="",is_a_melee=1){

        new is_generic_hero=0;
        if((hero_id<0 )|| (hero_id >=SH_MAXHEROS)){
            is_generic_hero=1;
            server_print("Invalid hero id %d at _sh_log_custom_damage_source!^nHero id must be between exactly %d and %d!^nGeneric damage source will be logged^n",hero_id,0,SH_MAXHEROS-1)

        }
        new wpn_id=custom_weapon_add(is_generic_hero?generic_dmg_source_name:long_name, is_a_melee, is_generic_hero?generic_dmg_source_name:short_name)
        if(wpn_id>0){
            sh_damage_source_hero_ids[wpn_id]=is_generic_hero?-1:hero_id;
            sh_damage_source_is_a_melee[wpn_id]=is_generic_hero?generic_dmg_source_is_melee:is_a_melee;
            copy(sh_damage_source_short_names[wpn_id],SAFE_BUFFER_SIZE-1,is_generic_hero?generic_dmg_source_name:short_name)
            copy(sh_damage_source_long_names[wpn_id],SAFE_BUFFER_SIZE-1,is_generic_hero?generic_dmg_source_name:long_name)
            new hero_name[MAX_HERO_NAME_LENGTH];
            if(!is_generic_hero){
            sh_get_hero_name_from_id(hero_id,hero_name)
            }
            server_print("Valid wpn_id obtained at _sh_log_custom_damage_source!^nIt came out as %d!^nA new weapon will be added!\nHere is the identification of this custom danage source:^n1 - hero_name: %s (id is %d)^n2 - wpn_id: %d^n3 - long_name: %s (short: %s)^n4 - %s^n^n",wpn_id,is_generic_hero?generic_dmg_hero_name:hero_name,sh_damage_source_hero_ids[wpn_id],wpn_id,sh_damage_source_long_names[wpn_id],sh_damage_source_short_names[wpn_id],sh_damage_source_is_a_melee[wpn_id]? "This weapon is a melee weapon":"This weapon is not a melee weapon")

        }
        else{

            server_print("Invalid wpn_id obtained at _sh_log_custom_damage_source!^nIt came out as %d which is <= 0!^nAborting...^n",wpn_id)
            return -1
        }
        return wpn_id


}

public _sh_log_custom_damage_source(iPlugin,iParams){

    new hero_id= get_param(1)

    new short_name_arr[SAFE_BUFFER_SIZE+1]
    new long_name_arr[SAFE_BUFFER_SIZE+1]
    get_array(2,short_name_arr,SAFE_BUFFER_SIZE+1)
    get_array(3,long_name_arr,SAFE_BUFFER_SIZE+1)
    new is_a_melee=get_param(4)

    return sh_log_damage_source_primitive(hero_id,short_name_arr,long_name_arr,is_a_melee)
    
}


public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&wpnid){


    if((wpnid >0 && wpnid < MAX_SH_CUSTOM_DMG_SOURCES))
    {
        if(damage > 0){
            custom_weapon_shot(wpnid, attacker)
            custom_weapon_dmg(wpnid, attacker, victim, damage, headshot?HIT_HEAD:HIT_STOMACH)
        }
    }
    else if(damage > 0){

        arrayset(wpnDescription,0,sizeof(wpnDescription))
        strcat(wpnDescription,generic_dmg_source_name,sizeof(wpnDescription)-1)
        custom_weapon_shot(generic_dmg_source_wpn_id, attacker)
        custom_weapon_dmg(generic_dmg_source_wpn_id, attacker, victim, damage, headshot?HIT_HEAD:HIT_STOMACH)
    }

    return DMG_FWD_PASS


}
