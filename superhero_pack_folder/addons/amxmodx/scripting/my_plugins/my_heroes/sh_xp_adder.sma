#include "../my_include/superheromod.inc"
#include "./sh_xp_adder_inc/sh_xp_adder_inc.inc"

#define PLUGIN "Superhero xp adder funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


enum xp_bonus_struct{

	xp_extra_earn_string[64],
	
	xp_extra_type_string[32],
	
	Float:xp_extra_type_mult,

	xp_extra_type_bonus,

}

stock const xp_extra_earn_struct_arr[xp_type_bonus_id][xp_bonus_struct] = {
	{"for killing players" ,"XP_KILL_XP", 0.0, 0},

	{"for planting the bomb", "XP_BOMB_PLANT_XP",200.0, 50},
	{"along with your team for detonating the bomb", "XP_BOMB_EXPLODE_XP",900.0, 10},
	{"along with your team for saving the bomb target", "XP_BOMB_TARGET_SAVE_XP",500.0, 10},


	{"for being the bomb defuser", "XP_BOMB_DEFUSE_XP",300.0, 5},
	{"for rescuing a hostage", "XP_HOSTAGE_RESCUED_XP",150.0,25},
	{"along with your team for rescuing all the hostages", "XP_HOSTAGE_ALL_RESCUED_XP",900.0,15},


	{"for killing the vip", "XP_VIP_ASSASSINATE_XP",3.0,15},
	{"for escaping as the vip", "XP_VIP_ESCAPE_XP",300.0, 30},
	{"along with your team for protecting the vip", "XP_VIP_PROTECT_XP",2500.0, 10}



}

stock player_built_xp_this_round[SH_MAXSLOTS+1][xp_type_bonus_id]


public plugin_init()
{

register_plugin(PLUGIN, VERSION, AUTHOR)

for(new i=0;i<sizeof player_built_xp_this_round;i++){

    arrayset(player_built_xp_this_round[i],0,sizeof player_built_xp_this_round[])

}


}

public xp_fwd_ret_id:sh_set_user_xp_fwd_pre(&id, &xp,xp_type_bonus_id:xp_type){

    if(!sh_is_active()||!is_user_connected(id)){

        return XP_FWD_PASS
    }
    player_built_xp_this_round[id][xp_type]+=(xp+
                xp_extra_earn_struct_arr[xp_type][xp_extra_type_bonus]);
    
    if(xp_type>enum_zero){
        sh_chat_message(id,-1,"You shall be awarded an extra %d xp %s at the end of the round",(xp+
        
                xp_extra_earn_struct_arr[xp_type][xp_extra_type_bonus]),
                xp_extra_earn_struct_arr[xp_type][xp_extra_earn_string])
    }
    return XP_FWD_PASS

}

public sh_round_start(){

    if(!sh_is_active()){
        return;
    }
    for(new i=1;i< sh_maxplayers()+1;i++){
        if(is_user_connected(i)){
            for(new xp_type_bonus_id:type=enum_zero; type<xp_type_bonus_id; type++){
                new xp_earned=player_built_xp_this_round[i][type]*
                            (floatround( xp_extra_earn_struct_arr[type][xp_extra_type_mult]));

                if(xp_earned>0){
                    sh_chat_message(i,-1,"You were awarded an extra %d xp %s last round!",
                                xp_earned,
                                xp_extra_earn_struct_arr[type][xp_extra_earn_string])
                    
                    sh_set_user_xp(i,xp_earned,true);
                }
            }
            arrayset(player_built_xp_this_round[i], 0, xp_type_bonus_id)
        }
    }

}