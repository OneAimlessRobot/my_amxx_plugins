#include "../my_include/superheromod.inc"
#include "./sh_xp_adder_inc/sh_xp_adder_inc.inc"

#define PLUGIN "Superhero help file funcs"
#define VERSION "1.0.0"
#define AUTHOR "ThrasherBratter"
#define Struct				enum


stock player_built_xp_this_round[SH_MAXSLOTS+1][XP_VIP_PROTECT_XP+1]
enum{
	TITLE=0,
	INDEX_NAME=1,
	DIR_NAME=2,
	HERO_NAME=3
};

public plugin_init()
{

register_plugin(PLUGIN, VERSION, AUTHOR)

for(new i=0;i<sizeof player_built_xp_this_round;i++){

    arrayset(player_built_xp_this_round[i],0,sizeof player_built_xp_this_round[])

}


}

public sh_set_user_xp_fwd_pre(&id, &xp,xp_type){

    if(!sh_is_active()||!is_user_connected(id)){

        return XP_FWD_PASS
    }
    sh_chat_message(id,-1,"XP FORWARD WAS TRIGGERED on PLAYER %d with type %s and %d extra XP on that type!!!",id,xp_extra_type_strings[xp_type],xp)
    player_built_xp_this_round[id][xp_type]+=xp;
    return XP_FWD_PASS

}

public sh_round_end(){

    if(!sh_is_active()) return;
    for(new i=1;i<SH_MAXSLOTS;i++){
        if(is_user_connected(i)){
            for(new type=0;type<sizeof player_built_xp_this_round[];type++){
                if(player_built_xp_this_round[i][type]>0){
                    sh_chat_message(i,-1,"You were awarded an extra %d xp for %s last round!",player_built_xp_this_round[i][type],xp_extra_earn_strings[type])
                    sh_set_user_xp(i,player_built_xp_this_round[i][type],true);
                }
            }
            arrayset(player_built_xp_this_round[i],0,sizeof player_built_xp_this_round[])
        }
    }

}