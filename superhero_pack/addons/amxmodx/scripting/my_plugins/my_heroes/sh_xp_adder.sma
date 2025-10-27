#include "../my_include/superheromod.inc"
#include "./sh_xp_adder_inc/sh_xp_adder_inc.inc"

#define PLUGIN "Superhero xp adder funcs"
#define VERSION "1.0.0"
#define AUTHOR "ThrasherBratter"
#define Struct				enum


stock player_built_xp_this_round[SH_MAXSLOTS+1][XP_VIP_PROTECT_XP+1]


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
    player_built_xp_this_round[id][xp_type]+=(xp+xp_extra_type_bonuses[xp_type]);
    return XP_FWD_PASS

}

public sh_round_end(){

    if(!sh_is_active()) return;
    for(new i=1;i<=SH_MAXSLOTS;i++){
        if(is_user_connected(i)){
            for(new type=0;type<sizeof player_built_xp_this_round[];type++){
                if(player_built_xp_this_round[i][type]>0){
                    new xp_earned=player_built_xp_this_round[i][type]*(floatround(xp_extra_type_mults[type]));
                    sh_chat_message(i,-1,"You were awarded an extra %d xp %s last round!",xp_earned,xp_extra_earn_strings[type])
                    sh_set_user_xp(i,xp_earned,true);
                }
            }
            arrayset(player_built_xp_this_round[i],0,sizeof player_built_xp_this_round[])
        }
    }

}